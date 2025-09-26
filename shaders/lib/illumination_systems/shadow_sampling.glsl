/*
═══════════════════════════════════════════════════════════════════════════════════════
                             SHADOW SAMPLING SYSTEM
                          Enhanced & Organized by VcorA
═══════════════════════════════════════════════════════════════════════════════════════

  This file implements advanced shadow sampling algorithms including:
  - Shadow map coordinate transformation and distortion
  - Multi-sample shadow filtering with TAA integration
  - Colored shadow support for translucent materials
  - Quality-based sampling optimization
  - Noise-based sampling patterns for soft shadows

  Main Features:
  - Perspective shadow mapping with bias correction
  - Colored translucent shadow sampling
  - Temporal Anti-Aliasing filtered shadows
  - Interleaved gradient noise for sample distribution
  - Distance-based shadow softening

  Copyright © 2025 VcorA - Enhanced Organization & Comments
  Part of Luminara Shader Pack - Shadow Sampling Management System

═══════════════════════════════════════════════════════════════════════════════════════
*/

//═══════════════════════════════════════════════════════════════════════════════════════
//                         SHADOW COORDINATE TRANSFORMATION
//                    VcorA Enhanced: Perspective Shadow Mapping
//═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Transform player-space position to shadow map coordinates
 * Applies perspective distortion and depth scaling for shadow mapping
 * 
 * @param playerPos: World position relative to player
 * @return: Shadow map coordinates [0.0, 1.0] range
 */
vec3 GetShadowPos(vec3 playerPos) {
    // Transform to shadow space using shadow matrix
    vec3 shadowPos = PlayerToShadow(playerPos);
    
    // Calculate radial distance for perspective distortion
    float distb = sqrt(shadowPos.x * shadowPos.x + shadowPos.y * shadowPos.y);
    
    // Apply shadow map bias for perspective correction
    float distortFactor = distb * shadowMapBias + (1.0 - shadowMapBias);
    shadowPos.xy /= distortFactor;
    
    // Scale depth component for proper z-fighting prevention
    shadowPos.z *= 0.2;
    
    // Convert from [-1,1] to [0,1] texture coordinate space
    return shadowPos * 0.5 + 0.5;
}

//═══════════════════════════════════════════════════════════════════════════════════════
//                            BASIC SHADOW SAMPLING
//                   VcorA Enhanced: Colored Shadow Support
//═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Sample shadow maps with colored shadow support
 * Handles both opaque and translucent shadow casting
 * 
 * @param shadowPos: Shadow map coordinates
 * @param colorMult: Color multiplier for tinted shadows
 * @param colorPow: Color power adjustment for shadow intensity
 * @return: Shadow color with alpha (RGB + shadow factor)
 */
vec3 SampleShadow(vec3 shadowPos, float colorMult, float colorPow) {
    // Sample primary shadow map (depth only)
    float shadow0 = shadow2D(shadowtex0, vec3(shadowPos.st, shadowPos.z)).x;

    vec3 shadowcol = vec3(0.0);
    
    // Check if pixel is in shadow
    if (shadow0 < 1.0) {
        // Sample secondary shadow map (with alpha)
        float shadow1 = shadow2D(shadowtex1, vec3(shadowPos.st, shadowPos.z)).x;
        
        // If translucent shadow caster detected
        if (shadow1 > 0.9999) {
            // Sample colored shadow from color buffer
            shadowcol = texture2D(shadowcolor0, shadowPos.st).rgb * shadow1;

            // Apply color modifications
            shadowcol *= colorMult;
            shadowcol = pow(shadowcol, vec3(colorPow));
        }
    }

    // Blend colored shadow with shadow factor
    return shadowcol * (1.0 - shadow0) + shadow0;
}

//═══════════════════════════════════════════════════════════════════════════════════════
//                         NOISE GENERATION FOR SHADOWS
//                    VcorA Enhanced: Temporal Noise Pattern
//═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Generate interleaved gradient noise for shadow sampling
 * Creates temporal noise pattern for TAA integration
 * 
 * @return: Noise value [0.0, 1.0] for sample offset
 */
float InterleavedGradientNoiseForShadows() {
    // Base noise calculation using fragment coordinates
    float n = 52.9829189 * fract(0.06711056 * gl_FragCoord.x + 0.00583715 * gl_FragCoord.y);
    
    // TAA integration - temporal variation for certain buffers
    #if !defined GBUFFERS_ENTITIES && !defined GBUFFERS_HAND && !defined GBUFFERS_TEXTURED && defined TAA
        // Add temporal offset using golden ratio for smooth distribution
        return fract(n + goldenRatio * mod(float(frameCounter), 3600.0));
    #else
        // Static noise for other buffers
        return fract(n);
    #endif
}

//═══════════════════════════════════════════════════════════════════════════════════════
//                           SAMPLE OFFSET CALCULATION
//                     VcorA Enhanced: Circular Distribution
//═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Calculate offset distance for shadow sampling pattern
 * Creates circular distribution for smooth shadow edges
 * 
 * @param x: Normalized distance parameter [0.0, 1.0]
 * @param s: Sample count for normalization
 * @return: 2D offset vector for sampling
 */
vec2 offsetDist(float x, int s) {
    // Convert distance to angle using fractional noise
    float n = fract(x * 2.427) * 3.1415;
    
    // Create circular sample pattern with distance scaling
    return vec2(cos(n), sin(n)) * 1.4 * x / s;
}

//═══════════════════════════════════════════════════════════════════════════════════════
//                        TAA FILTERED SHADOW SAMPLING
//                   VcorA Enhanced: Quality-Based Multi-Sampling
//═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Advanced shadow sampling with TAA filtering
 * Multi-sample shadows with quality-based sample counts
 * 
 * @param shadowPos: Shadow map coordinates
 * @param lViewPos: View space distance for LOD
 * @param offset: Additional sampling offset
 * @param leaves: Special handling for foliage
 * @param colorMult: Color multiplier for tinted shadows
 * @param colorPow: Color power adjustment
 * @return: Filtered shadow result
 */
vec3 SampleTAAFilteredShadow(vec3 shadowPos, float lViewPos, float offset, bool leaves, float colorMult, float colorPow) {
    vec3 shadow = vec3(0.0);
    float gradientNoise = InterleavedGradientNoiseForShadows();

    // Quality-based sample count determination
    #if SHADOW_QUALITY == 0
        int shadowSamples = 0; // We don't use SampleTAAFilteredShadow on Shadow Quality 0
    #elif SHADOW_QUALITY == 1
        int shadowSamples = 1;                              // Low quality: single sample
    #elif SHADOW_QUALITY == 2 || SHADOW_QUALITY == 3
        int shadowSamples = 2;                              // Medium quality: dual samples
    #elif SHADOW_QUALITY == 4
        int shadowSamples = 2;                              // High quality base
        if (lViewPos < 10.0) shadowSamples = 6;             // Close-up enhancement
    #elif SHADOW_QUALITY == 5
        int shadowSamples = 6;                              // Ultra quality base
        if (lViewPos < 10.0) shadowSamples = 12;            // Maximum close-up quality
    #endif

    // Buffer-specific optimizations
    #if !defined GBUFFERS_ENTITIES && !defined GBUFFERS_HAND && !defined GBUFFERS_TEXTURED
        offset *= 1.3875;                                   // Larger offset for terrain shadows
    #else
        shadowSamples *= 2;                                 // More samples for detailed objects
        offset *= 0.69375;                                  // Smaller offset for precision
    #endif

    //═══════════════════════════════════════════════════════════════════════════════════════
    //                           MULTI-SAMPLE SHADOW LOOP
    //                     VcorA Enhanced: Optimized Sampling Pattern
    //═══════════════════════════════════════════════════════════════════════════════════════

    float shadowPosZM = shadowPos.z;                        // Modified Z coordinate for depth
    
    for (int i = 0; i < shadowSamples; i++) {
        // Calculate offset pattern for current sample
        vec2 offset2 = offsetDist(gradientNoise + i, shadowSamples) * offset;
        
        // Special depth handling for foliage (leaves)
        if (leaves) shadowPosZM = shadowPos.z - 0.12 * offset * (gradientNoise + i) / shadowSamples;
        
        // Sample shadow map at positive and negative offsets for better coverage
        shadow += SampleShadow(vec3(shadowPos.st + offset2, shadowPosZM), colorMult, colorPow);
        shadow += SampleShadow(vec3(shadowPos.st - offset2, shadowPosZM), colorMult, colorPow);
    }

    // Normalize by total sample count
    shadow /= shadowSamples * 2.0;

    return shadow;                                          // Return filtered shadow result
}

//═══════════════════════════════════════════════════════════════════════════════════════
//                            BASIC SHADOW FILTERING
//                    VcorA Enhanced: Simple 4-Sample Pattern
//═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Pre-defined offset pattern for basic shadow filtering
 * Creates a cross pattern for simple but effective shadow softening
 */
vec2 shadowOffsets[4] = vec2[4](
    vec2( 1.0, 0.0),                                        // Right
    vec2( 0.0, 1.0),                                        // Up
    vec2(-1.0, 0.0),                                        // Left
    vec2( 0.0,-1.0));                                       // Down

/**
 * Basic filtered shadow sampling using 4-sample cross pattern
 * Used for lower quality settings or fallback scenarios
 * 
 * @param shadowPos: Shadow map coordinates
 * @param offset: Sampling offset radius
 * @return: Average shadow value from 4 samples
 */
vec3 SampleBasicFilteredShadow(vec3 shadowPos, float offset) {
    float shadow = 0.0;

    // Sample at 4 cardinal directions
    for (int i = 0; i < 4; i++) {
        shadow += shadow2D(shadowtex0, vec3(offset * shadowOffsets[i] + shadowPos.st, shadowPos.z)).x;
    }

    return vec3(shadow * 0.25);                             // Return averaged result
}

//═══════════════════════════════════════════════════════════════════════════════════════
//                              MAIN SHADOW FUNCTION
//                      VcorA Enhanced: Complete Shadow Processing
//═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Main shadow sampling function with quality-based selection
 * Handles all shadow calculations including color and filtering
 * 
 * @param shadowPos: Shadow map coordinates
 * @param lViewPos: View space distance for LOD
 * @param lightmapY: Sky light intensity for color adjustment
 * @param offset: Base sampling offset
 * @param leaves: Special foliage handling flag
 * @return: Final shadow color and intensity
 */
vec3 GetShadow(vec3 shadowPos, float lViewPos, float lightmapY, float offset, bool leaves) {
    //═══════════════════════════════════════════════════════════════════════════════════════
    //                        SHADOW OFFSET ADJUSTMENTS
    //                   VcorA Enhanced: Context-Specific Scaling
    //═══════════════════════════════════════════════════════════════════════════════════════
    
    #if SHADOW_QUALITY > 0
        #if ENTITY_SHADOWS_DEFINE == -1 && defined GBUFFERS_BLOCK
            offset *= 4.0;                                  // Larger offset for block entities
        #else
            #ifdef OVERWORLD
                offset *= 1.0 + rainFactor2 * 2.0;         // Rain increases shadow softness
            #else
                offset *= 3.0;                              // Higher base offset in Nether/End
            #endif
        #endif
    #endif

    //═══════════════════════════════════════════════════════════════════════════════════════
    //                         COLORED SHADOW PARAMETERS
    //                    VcorA Enhanced: Dynamic Color Adjustment
    //═══════════════════════════════════════════════════════════════════════════════════════

    float colorMult = 1.2 + 3.8 * lightmapY;               // Natural strength is 5.0 - sky light influence
    float colorPow = 1.1 - 0.6 * pow2(pow2(pow2(lightmapY))); // Power curve for color intensity

    //═══════════════════════════════════════════════════════════════════════════════════════
    //                        QUALITY-BASED SHADOW SAMPLING
    //                     VcorA Enhanced: Optimized Selection
    //═══════════════════════════════════════════════════════════════════════════════════════

    #if SHADOW_QUALITY >= 1
        // High quality: Use TAA filtered shadows
        vec3 shadow = SampleTAAFilteredShadow(shadowPos, lViewPos, offset, leaves, colorMult, colorPow);
    #else
        // Low quality: Use basic filtered shadows
        vec3 shadow = SampleBasicFilteredShadow(shadowPos, offset);
    #endif

    return shadow;                                          // Return final shadow result
}

/*
═══════════════════════════════════════════════════════════════════════════════════════
                            END OF SHADOW SAMPLING SYSTEM
                        Enhanced & Organized by VcorA © 2025
═══════════════════════════════════════════════════════════════════════════════════════
*/
