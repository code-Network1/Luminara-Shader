/*
 * ═══════════════════════════════════════════════════════════════════════════════════════
 * 
 *                        MAIN ATMOSPHERIC RENDERING SYSTEM
 *                         Luminara Shader - Core Atmosphere Module
 * 
 * ═══════════════════════════════════════════════════════════════════════════════════════
 * 
 * Copyright (c) 2025 VcorA Development
 * All rights reserved. Unauthorized reproduction or distribution is prohibited.
 * 
 * This is the main atmospheric rendering module that coordinates volumetric atmospheric
 * effects, shadow calculations, and lighting interactions for the Luminara Shader.
 * 
 * ═══════════════════════════════════════════════════════════════════════════════════════
 */

//═══════════════════════════════════════════════════════════════════════════════════════
//                                   DEPENDENCIES
//═══════════════════════════════════════════════════════════════════════════════════════

#include "/lib/color_schemes/core_color_system.glsl"

#ifdef MOON_PHASE_INF_ATMOSPHERE
    #include "/lib/color_schemes/color_effects_system.glsl"
#endif

#include "/lib/atmospherics/atmosphericVolumetricSystem.glsl"

//═══════════════════════════════════════════════════════════════════════════════════════
//                                UTILITY FUNCTIONS
//═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Generates interleaved gradient noise for atmospheric dithering
 * @return: Noise value [0.0, 1.0] for temporal anti-aliasing
 */
float GenerateAtmosphericNoise() 
{
    float noiseBase = 52.9829189 * fract(0.06711056 * gl_FragCoord.x + 0.00583715 * gl_FragCoord.y);
    
    #ifdef TAA
        // Use temporal variation for smoother sampling
        return fract(noiseBase + goldenRatio * mod(float(frameCounter), 3600.0));
    #else
        // Static noise for consistent sampling
        return fract(noiseBase);
    #endif
}

//═══════════════════════════════════════════════════════════════════════════════════════
//                               SHADOW SYSTEM FUNCTIONS
//═══════════════════════════════════════════════════════════════════════════════════════

#if SHADOW_QUALITY > -1

/**
 * Transforms atmospheric position to shadow map coordinates
 * @param tracePos: Position in atmospheric space
 * @param cameraPos: Current camera position
 * @return: Shadow map coordinates [0.0, 1.0]
 */
vec3 TransformToShadowSpace(vec3 tracePos, vec3 cameraPos) 
{
    vec3 worldPosition = PlayerToShadow(tracePos - cameraPos);
    
    // Calculate distance-based distortion
    float horizontalDistance = sqrt(worldPosition.x * worldPosition.x + worldPosition.y * worldPosition.y);
    float distortionFactor = 1.0 - shadowMapBias + horizontalDistance * shadowMapBias;
    
    // Apply shadow transformation
    vec3 shadowPosition = vec3(
        vec2(worldPosition.xy / distortionFactor), 
        worldPosition.z * 0.2
    );
    
    return shadowPosition * 0.5 + 0.5;
}

/**
 * Performs shadow testing for atmospheric elements
 * @param tracePos: Position to test for shadows
 * @param cameraPos: Current camera position
 * @param altitudeLevel: Atmospheric altitude level
 * @param lowerBound: Lower altitude boundary
 * @param upperBound: Upper altitude boundary
 * @return: true if position is in shadow, false otherwise
 */
bool TestAtmosphericShadow(vec3 tracePos, vec3 cameraPos, int altitudeLevel, 
                          float lowerBound, float upperBound) 
{
    const float shadowOffset = 0.5;
    
    vec3 shadowCoordinates = TransformToShadowSpace(tracePos, cameraPos);
    
    // Check if coordinates are within shadow map bounds
    if (length(shadowCoordinates.xy * 2.0 - 1.0) < 1.0) {
        float shadowSample = shadow2D(shadowtex0, shadowCoordinates).z;
        
        if (shadowSample == 0.0) return true;
    }
    
    return false;
}

#endif

//═══════════════════════════════════════════════════════════════════════════════════════
//                              ATMOSPHERIC MODULE INCLUDES
//═══════════════════════════════════════════════════════════════════════════════════════

#ifdef CLOUDS_REIMAGINED
    #include "/lib/atmospherics/atmosphericVolumetricSystem.glsl"
#endif

#ifdef CLOUDS_UNBOUND
    #include "/lib/atmospherics/atmosphere/weatherSystem.glsl"
#endif

//═══════════════════════════════════════════════════════════════════════════════════════
//                            MAIN ATMOSPHERIC RENDERING FUNCTION
//═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Main atmospheric rendering pipeline
 * @param atmosphericDepth: Output depth information for atmospheric elements
 * @param skyFade: Sky fade factor for blending
 * @param cameraPos: Current camera position
 * @param playerPos: Player view direction
 * @param viewDistance: Current view distance
 * @param sunDotProduct: Dot product with sun direction
 * @param upDotProduct: Dot product with up vector
 * @param ditherNoise: Dithering noise for sampling
 * @param auroraContribution: Aurora borealis color contribution
 * @param nebulaContribution: Night nebula color contribution
 * @return: Final atmospheric color and alpha
 */
vec4 RenderAtmosphericEffects(inout float atmosphericDepth, float skyFade, vec3 cameraPos, 
                             vec3 playerPos, float viewDistance, float sunDotProduct, 
                             float upDotProduct, float ditherNoise, vec3 auroraContribution, 
                             vec3 nebulaContribution) 
{
    vec4 atmosphericResult = vec4(0.0);
    
    // Normalize player position for calculations
    vec3 normalizedPlayerPos = normalize(playerPos);
    
    // Calculate effective view distance with safety bounds
    float effectiveViewDistance = viewDistance < renderDistance * 1.5 ? viewDistance - 1.0 : 1000000000.0;
    
    // Calculate sky fade multiplier for blending
    float skyFadeMultiplier = pow2(skyFade * 3.333333 - 2.333333);
    
    // Calculate view threshold based on up vector orientation
    float thresholdMixFactor = pow2(clamp01(upDotProduct * 5.0));
    float viewThreshold = mix(far, 1000.0, thresholdMixFactor * 0.5 + 0.5);
    
    #ifdef DISTANT_HORIZONS
        viewThreshold = max(viewThreshold, renderDistance);
    #endif
    
    // Apply weather-based color adjustments
    #ifdef CLOUDS_REIMAGINED
        cloudAmbientColor *= 1.0 - 0.25 * rainFactor;
    #endif
    
    // Apply custom color multipliers
    vec3 atmosphericColorMultiplier = vec3(1.0);
    #if CLOUD_R != 100 || CLOUD_G != 100 || CLOUD_B != 100
        atmosphericColorMultiplier *= vec3(CLOUD_R, CLOUD_G, CLOUD_B) * 0.01;
    #endif
    
    cloudAmbientColor *= atmosphericColorMultiplier;
    cloudLightColor *= atmosphericColorMultiplier;
    
    // Render atmospheric layers based on configuration
    #if !defined DOUBLE_REIM_CLOUDS || defined CLOUDS_UNBOUND
        // Single layer rendering
        atmosphericResult = GetVolumetricClouds(
            cloudAlt1i, viewThreshold, atmosphericDepth, skyFade, skyFadeMultiplier,
            cameraPos, normalizedPlayerPos, effectiveViewDistance, sunDotProduct, 
            upDotProduct, ditherNoise
        );
    #else
        // Dual layer rendering with altitude-based prioritization
        int primaryAltitude = max(cloudAlt1i, cloudAlt2i);
        int secondaryAltitude = min(cloudAlt1i, cloudAlt2i);
        
        if (abs(cameraPos.y - secondaryAltitude) < abs(cameraPos.y - primaryAltitude)) {
            // Render closer layer first
            atmosphericResult = GetVolumetricClouds(
                secondaryAltitude, viewThreshold, atmosphericDepth, skyFade, skyFadeMultiplier,
                cameraPos, normalizedPlayerPos, effectiveViewDistance, sunDotProduct, 
                upDotProduct, ditherNoise
            );
            
            // Fallback to farther layer if no contribution
            if (atmosphericResult.a == 0.0) {
                atmosphericResult = GetVolumetricClouds(
                    primaryAltitude, viewThreshold, atmosphericDepth, skyFade, skyFadeMultiplier,
                    cameraPos, normalizedPlayerPos, effectiveViewDistance, sunDotProduct, 
                    upDotProduct, ditherNoise
                );
            }
        } else {
            // Render farther layer first
            atmosphericResult = GetVolumetricClouds(
                primaryAltitude, viewThreshold, atmosphericDepth, skyFade, skyFadeMultiplier,
                cameraPos, normalizedPlayerPos, effectiveViewDistance, sunDotProduct, 
                upDotProduct, ditherNoise
            );
            
            // Fallback to closer layer if no contribution
            if (atmosphericResult.a == 0.0) {
                atmosphericResult = GetVolumetricClouds(
                    secondaryAltitude, viewThreshold, atmosphericDepth, skyFade, skyFadeMultiplier,
                    cameraPos, normalizedPlayerPos, effectiveViewDistance, sunDotProduct, 
                    upDotProduct, ditherNoise
                );
            }
        }
    #endif
    
    // Apply atmospheric color modifications
    #ifdef ATM_COLOR_MULTS
        atmosphericResult.rgb *= sqrtAtmColorMult;
    #endif
    
    #ifdef MOON_PHASE_INF_ATMOSPHERE
        atmosphericResult.rgb *= moonPhaseInfluence;
    #endif
    
    // Add special atmospheric effects
    #if AURORA_STYLE > 0
        atmosphericResult.rgb += auroraContribution * 0.1;
    #endif
    
    #ifdef NIGHT_NEBULA
        atmosphericResult.rgb += nebulaContribution * 0.2;
    #endif
    
    return atmosphericResult;
}

//═══════════════════════════════════════════════════════════════════════════════════════
//                               LEGACY COMPATIBILITY ALIASES
//═══════════════════════════════════════════════════════════════════════════════════════

// Maintain compatibility with existing shader code
#define InterleavedGradientNoiseForClouds GenerateAtmosphericNoise
#define GetShadowOnCloudPosition TransformToShadowSpace
#define GetShadowOnCloud TestAtmosphericShadow
#define GetClouds RenderAtmosphericEffects
