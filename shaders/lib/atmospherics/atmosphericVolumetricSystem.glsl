/*
 * ═══════════════════════════════════════════════════════════════════════════════════════
 * 
 *                ATMOSPHERIC, VOLUMETRIC & ENVIRONMENTAL SYSTEM
 *                        Luminara Shader - Complete Atmospheric Effects
 * 
 * ═══════════════════════════════════════════════════════════════════════════════════════
 * 
 * Copyright (c) 2025 VcorA Development
 * All rights reserved. Unauthorized reproduction or distribution is prohibited.
 * 
 * This comprehensive unified module combines all atmospheric rendering systems:
 * - Atmospheric horizon rendering with realistic scattering simulation
 * - Volumetric fog with atmospheric scattering simulation
 * - Volumetric light shafts with realistic shadow casting
 * - Dynamic lighting with quality-adaptive sampling
 * - Environmental effects integration (rain, biome-specific)
 * - Sky rendering with day/night transitions and weather effects
 * - Celestial effects including stars, aurora borealis, and night nebula
 * - End dimension star systems with magical coloring
 * - Rainbow effects and environmental weather systems
 * - Disabled volumetric effects (ender beams) for cleaner visuals
 * 
 * Based on volumetric tracing techniques from Robobo1221, extensively modified
 * and enhanced for optimal performance and visual quality.
 * 
 * ═══════════════════════════════════════════════════════════════════════════════════════
 */

#ifndef INCLUDE_ATMOSPHERIC_VOLUMETRIC_SYSTEM
#define INCLUDE_ATMOSPHERIC_VOLUMETRIC_SYSTEM

//═══════════════════════════════════════════════════════════════════════════════════════
//                                   DEPENDENCIES
//═══════════════════════════════════════════════════════════════════════════════════════

#include "/lib/atmospherics/atmosphere/skyCoord.glsl"
#include "/lib/color_schemes/core_color_system.glsl"


#ifdef CAVE_FOG
    #include "/lib/atmospherics/particles/depthFactor.glsl"
#endif

//═══════════════════════════════════════════════════════════════════════════════════════
//                             VOLUMETRIC CONFIGURATION
//═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Vertical stretch factor for atmospheric layers
 * Controls the thickness and distribution of volumetric effects
 */
const float volumetricStretch = 5.5;

/**
 * Total height of volumetric atmospheric layer
 * Calculated as double the stretch factor for symmetric distribution
 */
const float volumetricHeight = volumetricStretch * 2.0;

//═══════════════════════════════════════════════════════════════════════════════════════
//                            DEPTH AND DISTANCE UTILITIES
//═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Converts depth buffer value to linear depth distance
 * Essential for accurate volumetric sampling calculations
 * @param depth: Depth buffer value (0.0 - 1.0)
 * @return: Linear depth distance in world units
 */
float GetDepth(float depth) {
    return 2.0 * near * far / (far + near - (2.0 * depth - 1.0) * (far - near));
}

/**
 * Converts linear distance to depth buffer coordinate
 * Used for converting world distances back to screen space
 * @param dist: Linear world distance
 * @return: Depth coordinate for projection calculations
 */
float GetDistX(float dist) {
    return (far * (dist - near)) / (dist * (far - near));
}

//═══════════════════════════════════════════════════════════════════════════════════════
//                          ENVIRONMENTAL EFFECTS FUNCTIONS
//═══════════════════════════════════════════════════════════════════════════════════════

#define RAINBOW_DIAMETER 1.00 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00 2.05 2.10 2.15 2.20 2.25 2.30 2.35 2.40 2.45 2.50 2.55 2.60 2.65 2.70 2.75 2.80 2.85 2.90 2.95 3.00 3.05 3.10 3.15 3.20 3.25 3.30 3.35 3.40 3.45 3.50 3.55 3.60 3.65 3.70 3.75 3.80 3.85 3.90 3.95 4.00 4.25 4.50 4.75 5.00 5.25 5.50 5.75 6.00 6.25 6.50 6.75 7.00 7.50 8.00]
#define RAINBOW_STYLE 1 //[1 2]

/**
 * Ender Beams Effect (DISABLED)
 * Originally provided mystical light beams in End dimension
 * Disabled to remove floating volumetric effects for cleaner visuals
 * @return: Always returns vec3(0.0) - no effect
 */
vec3 DrawEnderBeams(float VdotU, vec3 playerPos) {
    // Luminara Shader: Disabled ender beams to remove floating light beams
    return vec3(0.0);
}

/**
 * Rainbow Effects System
 * Advanced atmospheric rainbow rendering with post-rain conditions
 * @param translucentMult: Translucent material interaction factor
 * @param z0: Near depth buffer value
 * @param z1: Far depth buffer value  
 * @param lViewPos: View space distance to near surface
 * @param lViewPos1: View space distance to far surface
 * @param VdotL: View-light dot product for rainbow positioning
 * @param dither: Temporal dithering value
 * @return: RGB rainbow color contribution
 */
vec3 GetRainbow(vec3 translucentMult, float z0, float z1, float lViewPos, float lViewPos1, float VdotL, float dither) {
    vec3 rainbow = vec3(0.0);

    float rainbowTime = min1(max0(SdotU - 0.1) / 0.15);
    rainbowTime = clamp(rainbowTime - pow2(pow2(pow2(noonFactor))) * 8.0, 0.0, 0.85);
    
    #if RAINBOWS == 1 // After Rain
        rainbowTime *= sqrt2(max0(wetness - 0.333) * 1.5) * invRainFactor * inRainy;
    #endif

    if (rainbowTime > 0.001) {
        float cloudLinearDepth = texelFetch(colortex4, texelCoord, 0).r;
        float cloudDistance = pow2(cloudLinearDepth + OSIEBCA * dither) * far;
        if (cloudDistance < lViewPos1) lViewPos = cloudDistance;

        float rainbowLength = max(far, 128.0) * 0.9;

        float rainbowCoord = clamp01(1.0 - (VdotL + 0.75) / (0.0625 * RAINBOW_DIAMETER));
        float rainbowFactor = rainbowCoord * (1.0 - rainbowCoord);
              rainbowFactor = pow2(pow2(rainbowFactor * 3.7));
              rainbowFactor *= pow2(min1(lViewPos / rainbowLength));
              rainbowFactor *= rainbowTime;
              #ifdef CAVE_FOG
                  rainbowFactor *= 1.0 - GetDepthFactor();
              #endif

        if (rainbowFactor > 0.0) {
            #if RAINBOW_STYLE == 1
                // Enhanced rainbow with multiple layers
                float rainbowCoordM = pow(rainbowCoord, 1.4 + max(rainbowCoord - 0.5, 0.0) * 1.6);
                rainbowCoordM = smoothstep(0.0, 1.0, rainbowCoordM) * 0.85;
                rainbowCoordM += (dither - 0.5) * 0.1;
                
                // Triple-layer rainbow for enhanced realism
                rainbow += clamp(abs(mod(rainbowCoordM * 6.0 + vec3(-0.55,4.3,2.2) ,6.0)-3.0)-1.0, 0.0, 1.0);
                rainbowCoordM += 0.1;
                rainbow += clamp(abs(mod(rainbowCoordM * 6.0 + vec3(-0.55,4.3,2.2) ,6.0)-3.0)-1.0, 0.0, 1.0);
                rainbowCoordM -= 0.2;
                rainbow += clamp(abs(mod(rainbowCoordM * 6.0 + vec3(-0.55,4.3,2.2) ,6.0)-3.0)-1.0, 0.0, 1.0);
                rainbow /= 3.0;
                
                // Red enhancement for outer edge
                rainbow.r += pow2(max(rainbowCoord - 0.5, 0.0)) * (max(1.0 - rainbowCoord, 0.0)) * 26.0;
                rainbow = pow(rainbow, vec3(2.2)) * vec3(0.25, 0.075, 0.25) * 3.0;
            #else
                // Simple rainbow style
                float rainbowCoordM = pow(rainbowCoord, 1.35);
                rainbowCoordM = smoothstep(0.0, 1.0, rainbowCoordM);
                rainbow += clamp(abs(mod(rainbowCoordM * 6.0 + vec3(0.0,4.0,2.0) ,6.0)-3.0)-1.0, 0.0, 1.0);
                rainbow *= rainbow * (3.0 - 2.0 * rainbow);
                rainbow = pow(rainbow, vec3(2.2)) * vec3(0.25, 0.075, 0.25) * 3.0;
            #endif

            // Apply translucent material interaction
            if (z1 > z0 && lViewPos < rainbowLength)
                rainbow *= mix(translucentMult, vec3(1.0), lViewPos / rainbowLength);

            rainbow *= rainbowFactor;
        }
    }

    return rainbow;
}

/**
 * Nether Storm Effect (DISABLED)
 * Originally provided volumetric storm effects in Nether dimension
 * Disabled to remove floating volumetric effects for cleaner visuals
 * @param color: Base color
 * @param translucentMult: Translucent material multiplier
 * @param nPlayerPos: Normalized player position
 * @param playerPos: Player world position
 * @param lViewPos: View position length
 * @param lViewPos1: Extended view position length
 * @param dither: Temporal dithering value
 * @return: Always returns vec4(0.0) - no effect
 */
vec4 GetNetherStorm(vec3 color, vec3 translucentMult, vec3 nPlayerPos, vec3 playerPos, float lViewPos, float lViewPos1, float dither) {
    // Luminara Shader: Disabled nether storm to remove floating volumetric effects
    return vec4(0.0);
}

//═══════════════════════════════════════════════════════════════════════════════════════
//                             SHADOW PROCESSING FUNCTIONS
//═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Applies shadow map distortion for accurate shadow sampling
 * Compensates for perspective distortion in shadow mapping
 * @param shadowpos: Shadow space position
 * @param distortFactor: Distortion compensation factor
 * @return: Corrected shadow position for sampling
 */
vec4 DistortShadow(vec4 shadowpos, float distortFactor) {
    shadowpos.xy *= 1.0 / distortFactor;
    shadowpos.z = shadowpos.z * 0.2;
    shadowpos = shadowpos * 0.5 + 0.5;
    return shadowpos;
}

//═══════════════════════════════════════════════════════════════════════════════════════
//                              NOISE GENERATION FUNCTIONS
//═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Generates 3D noise for volumetric effects
 * Creates realistic atmospheric turbulence and variation
 * @param p: 3D position for noise sampling
 * @return: Noise value (0.0 - 1.0) for volumetric calculations
 */
float Noise3D(vec3 p) {
    p.z = fract(p.z) * 128.0;
    float iz = floor(p.z);
    float fz = fract(p.z);
    vec2 a_off = vec2(23.0, 29.0) * (iz) / 128.0;
    vec2 b_off = vec2(23.0, 29.0) * (iz + 1.0) / 128.0;
    float a = texture2D(noisetex, p.xy + a_off).r;
    float b = texture2D(noisetex, p.xy + b_off).r;
    return mix(a, b, fz);
}

//═══════════════════════════════════════════════════════════════════════════════════════
//                            HIGH QUALITY SKY RENDERING MODULE
//═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Main atmospheric horizon rendering function with advanced scattering simulation
 * @param VdotU: View direction dot up vector [-1.0, 1.0]
 * @param VdotS: View direction dot sun/moon vector [-1.0, 1.0]
 * @param dither: Temporal dithering value [0.0, 1.0]
 * @param doGlare: Enable celestial glare effects (sun/moon)
 * @param doGround: Enable ground horizon effects
 * @return: RGB sky color with realistic atmospheric scattering
 * 
 * Features:
 * - Realistic atmospheric Rayleigh scattering
 * - Dynamic day/night color transitions
 * - Weather-based atmospheric modifications
 * - Underwater fog integration
 * - Cave environment compatibility
 * - Celestial glare with procedural sun/moon support
 */
#ifdef OVERWORLD
vec3 GetSkyHorizon(float VdotU, float VdotS, float dither, bool doGlare, bool doGround) {
    //═══════════════════════════════════════════════════════════════════════════════════
    //                            ATMOSPHERIC VARIABLE PREPARATION
    //═══════════════════════════════════════════════════════════════════════════════════
    
    // Night factor calculations for smooth transitions
    float nightFactorSqrt2 = sqrt2(nightFactor);
    float nightFactorM = sqrt2(nightFactorSqrt2) * 0.4;
    
    // Sun direction calculations with enhanced precision
    float VdotSM1 = pow2(max(VdotS, 0.0));      // Sun intensity factor
    float VdotSM2 = pow2(VdotSM1);              // Enhanced sun effect
    float VdotSM3 = pow2(pow2(max(-VdotS, 0.0))); // Anti-sun direction
    float VdotSML = sunVisibility > 0.5 ? VdotS : -VdotS; // Light source selection
    
    // View direction calculations for horizon effects
    float VdotUmax0 = max(VdotU, 0.0);          // Above horizon only
    float VdotUmax0M = 1.0 - pow2(VdotUmax0);   // Inverted horizon factor

    //═══════════════════════════════════════════════════════════════════════════════════
    //                               SKY COLOR PREPARATION
    //═══════════════════════════════════════════════════════════════════════════════════
    
    // Dynamic sky color mixing based on time of day and sun position
    vec3 upColor = mix(
        nightUpSkyColor * (1.5 - 0.5 * nightFactorSqrt2 + nightFactorM * VdotSM3 * 1.5),
        dayUpSkyColor,
        sunFactor
    );
    
    vec3 middleColor = mix(
        nightMiddleSkyColor * (3.0 - 2.0 * nightFactorSqrt2),
        dayMiddleSkyColor * (1.0 + VdotSM2 * 0.3),
        sunFactor
    );
    
    vec3 downColor = mix(
        nightDownSkyColor,
        dayDownSkyColor,
        (sunFactor + sunVisibility) * 0.5
    );

    //═══════════════════════════════════════════════════════════════════════════════════
    //                            ATMOSPHERIC SCATTERING SIMULATION
    //═══════════════════════════════════════════════════════════════════════════════════
    
    // === PRIMARY SKY GRADIENT ===
    // Simulate atmospheric density gradient from zenith to horizon
    float VdotUM1 = pow2(1.0 - VdotUmax0);
    VdotUM1 = pow(VdotUM1, 1.0 - VdotSM2 * 0.4);  // Sun influence on gradient
    VdotUM1 = mix(VdotUM1, 1.0, rainFactor2 * 0.15); // Weather modification
    vec3 finalSky = mix(upColor, middleColor, VdotUM1);

    // === SUNSET/SUNRISE SCATTERING ===
    // Enhanced Rayleigh scattering during golden hour
    float VdotUM2 = pow2(1.0 - abs(VdotU));
    VdotUM2 = VdotUM2 * VdotUM2 * (3.0 - 2.0 * VdotUM2); // Smoothstep for natural transition
    VdotUM2 *= (0.7 - nightFactorM + VdotSM1 * (0.3 + nightFactorM)) * invNoonFactor * sunFactor;
    finalSky = mix(finalSky, sunsetDownSkyColorP * (1.0 + VdotSM1 * 0.3), VdotUM2 * invRainFactor);

    // === HORIZON GROUND SCATTERING ===
    // Simulate atmospheric perspective and ground interaction
    float VdotUM3 = min(max0(-VdotU + 0.08) / 0.35, 1.0);
    VdotUM3 = smoothstep1(VdotUM3);
    
    // Advanced RGB scattering simulation
    vec3 scatteredGroundMixer = vec3(
        VdotUM3 * VdotUM3,  // Red scattering (longer wavelength)
        sqrt1(VdotUM3),     // Green scattering (medium wavelength)
        sqrt3(VdotUM3)      // Blue scattering (shorter wavelength)
    );
    scatteredGroundMixer = mix(vec3(VdotUM3), scatteredGroundMixer, 0.75 - 0.5 * rainFactor);
    finalSky = mix(finalSky, downColor, scatteredGroundMixer);

    //═══════════════════════════════════════════════════════════════════════════════════
    //                              ENVIRONMENTAL EFFECTS
    //═══════════════════════════════════════════════════════════════════════════════════
    
    // === GROUND HORIZON EFFECTS ===
    if (doGround) {
        // Darken sky below horizon for realistic ground interaction
        finalSky *= smoothstep1(pow2(1.0 + min(VdotU, 0.0)));
    }

    // === UNDERWATER FOG INTEGRATION ===
    if (isEyeInWater == 1) {
        // Enhanced underwater visibility with realistic fog mixing
        finalSky = mix(finalSky * 3.0, waterFogColor, VdotUmax0M);
    }

    //═══════════════════════════════════════════════════════════════════════════════════
    //                               CELESTIAL GLARE SYSTEM
    //═══════════════════════════════════════════════════════════════════════════════════
    
    // Enhanced sun/moon glare with procedural support
    #if !(defined(DISABLE_UNBOUND_SUN_MOON) && (SUN_MOON_STYLE >= 2))
    if (doGlare && 0.0 < VdotSML) {
        // Advanced atmospheric scattering for glare
        float glareScatter = 4.0 * (2.0 - clamp01(VdotS * 1000.0));
        float VdotSM4 = pow(abs(VdotS), glareScatter);

        // Realistic glare intensity calculation
        float visfactor = 0.075;
        float glare = visfactor / (1.0 - (1.0 - visfactor) * VdotSM4) - visfactor;

        // Time-based glare modulation
        glare *= 0.5 + pow2(noonFactor) * 1.2;
        glare *= 1.0 - rainFactor * 0.5;

        // Dynamic glare color based on conditions
        float glareWaterFactor = isEyeInWater * sunVisibility;
        vec3 glareColor = mix(vec3(0.38, 0.4, 0.5) * 0.7, vec3(0.5), sunVisibility);
        glareColor = glareColor + glareWaterFactor * vec3(7.0);

        // Apply glare to final sky
        finalSky += glare * shadowTime * glareColor;
    }
    #endif

    //═══════════════════════════════════════════════════════════════════════════════════
    //                            CAVE ENVIRONMENT INTEGRATION
    //═══════════════════════════════════════════════════════════════════════════════════
    
    #ifdef CAVE_FOG
        // Blend sky with cave fog for underground environments
        finalSky = mix(finalSky, caveFogColor, GetCaveFactor() * VdotUmax0M);
    #endif

    //═══════════════════════════════════════════════════════════════════════════════════
    //                               FINAL PROCESSING
    //═══════════════════════════════════════════════════════════════════════════════════
    
    // Apply temporal dithering to reduce color banding
    finalSky += (dither - 0.5) / 128.0;

    return finalSky;
}
#else
vec3 GetSkyHorizon(float VdotU, float VdotS, float dither, bool doGlare, bool doGround) {
    // Fallback for non-overworld dimensions
    return vec3(0.1, 0.1, 0.2);
}
#endif

//═══════════════════════════════════════════════════════════════════════════════════════
//                           PERFORMANCE OPTIMIZED SKY MODULE
//═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Lightweight sky rendering for performance-critical scenarios
 * @param VdotU: View direction dot up vector [-1.0, 1.0]
 * @param VdotS: View direction dot sun/moon vector [-1.0, 1.0]
 * @param dither: Temporal dithering value [0.0, 1.0]
 * @param doGlare: Enable simplified celestial glare
 * @param doGround: Enable basic ground effects
 * @return: RGB sky color with simplified scattering
 * 
 * Features:
 * - Simplified atmospheric calculations
 * - Basic day/night transitions
 * - Reduced computational overhead
 * - Maintained visual quality for distant views
 */
#ifdef OVERWORLD
vec3 GetOptimizedSkyHorizon(float VdotU, float VdotS, float dither, bool doGlare, bool doGround) {
    //═══════════════════════════════════════════════════════════════════════════════════
    //                            SIMPLIFIED VARIABLE SETUP
    //═══════════════════════════════════════════════════════════════════════════════════
    
    float VdotUmax0 = max(VdotU, 0.0);
    float VdotUmax0M = 1.0 - pow2(VdotUmax0);

    //═══════════════════════════════════════════════════════════════════════════════════
    //                            BASIC COLOR PREPARATION
    //═══════════════════════════════════════════════════════════════════════════════════
    
    vec3 upColor = mix(nightUpSkyColor, dayUpSkyColor, sunFactor);
    vec3 middleColor = mix(nightMiddleSkyColor, dayMiddleSkyColor, sunFactor);

    //═══════════════════════════════════════════════════════════════════════════════════
    //                            SIMPLIFIED SKY GRADIENT
    //═══════════════════════════════════════════════════════════════════════════════════
    
    // Basic sky gradient with weather influence
    float VdotUM1 = pow2(1.0 - VdotUmax0);
    VdotUM1 = mix(VdotUM1, 1.0, rainFactor2 * 0.2);
    vec3 finalSky = mix(upColor, middleColor, VdotUM1);

    // Simplified sunset effects
    float VdotUM2 = pow2(1.0 - abs(VdotU));
    VdotUM2 *= invNoonFactor * sunFactor * (0.8 + 0.2 * VdotS);
    finalSky = mix(finalSky, sunsetDownSkyColorP * (shadowTime * 0.6 + 0.2), VdotUM2 * invRainFactor);

    //═══════════════════════════════════════════════════════════════════════════════════
    //                            BASIC ENVIRONMENTAL EFFECTS
    //═══════════════════════════════════════════════════════════════════════════════════
    
    // Simplified ground darkening
    finalSky *= pow2(pow2(1.0 + min(VdotU, 0.0)));

    // Basic underwater fog
    if (isEyeInWater == 1) {
        finalSky = mix(finalSky, waterFogColor, VdotUmax0M);
    }

    // Simplified celestial glare
    #if !(defined(DISABLE_UNBOUND_SUN_MOON) && (SUN_MOON_STYLE >= 2))
    finalSky *= 1.0 + mix(nightFactor, 0.5 + 0.7 * noonFactor, VdotS * 0.5 + 0.5) * pow2(pow2(pow2(VdotS)));
    #endif

    // Basic cave fog integration
    #ifdef CAVE_FOG
        finalSky = mix(finalSky, caveFogColor, GetCaveFactor() * VdotUmax0M);
    #endif

    return finalSky;
}
#else
vec3 GetOptimizedSkyHorizon(float VdotU, float VdotS, float dither, bool doGlare, bool doGround) {
    // Fallback for non-overworld dimensions
    return vec3(0.1, 0.1, 0.2);
}
#endif

//═══════════════════════════════════════════════════════════════════════════════════════
//                            VOLUMETRIC FOG SAMPLING FUNCTIONS
//═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Samples volumetric noise at specified position
 * @param tracePos: World position for sampling
 * @param modifiedPos: Output modified position for coordinate calculations
 * @param altitudeLevel: Atmospheric altitude level
 * @return: true if volumetric effect should be rendered at this position
 */
bool SampleVolumetricNoise(vec3 tracePos, out vec3 modifiedPos, float altitudeLevel) {
    vec3 tracePosition = tracePos;
    tracePosition.xz += 0.6 * cameraPosition.xz;
    
    modifiedPos = tracePosition;
    modifiedPos.xz *= 1.0 + 0.2 * altitudeLevel;
    
    float windOffset = frameTimeCounter * 0.003;
    modifiedPos.x += windOffset;
    modifiedPos.z += windOffset * 0.5;
    
    float layerNoise = Noise3D(modifiedPos * vec3(0.002, 0.04, 0.002));
    float detailNoise = Noise3D(modifiedPos * vec3(0.008, 0.16, 0.008));
    
    float combinedNoise = layerNoise * 0.7 + detailNoise * 0.3;
    float altitudeFactor = 1.0 - smoothstep(0.0, volumetricHeight, abs(tracePos.y - altitudeLevel));
    
    return (combinedNoise * altitudeFactor) > 0.4;
}

/**
 * Main volumetric fog rendering function
 * Handles atmospheric fog with lighting and shadow integration
 * @param depthOutput: Output depth value for fog layer
 * @param ditherNoise: Temporal dithering for smooth sampling
 * @param altitudeLevel: Current atmospheric altitude level
 * @param renderDistance: Maximum rendering distance
 * @param viewPosition: Camera view direction
 * @param maxSamples: Maximum number of samples for quality control
 * @return: Volumetric fog color and opacity
 */
vec4 GetVolumetricFog(out float depthOutput, float ditherNoise, float altitudeLevel, float renderDistance,
                      vec3 viewPosition, int maxSamples) {
    vec4 volumetricResult = vec4(0.0);
    depthOutput = 1.0;
    
    // Early exit conditions for performance optimization
    if (abs(altitudeLevel - cameraPosition.y) > volumetricHeight) return volumetricResult;
    
    // Initialize sampling parameters
    float maxDistance = min(renderDistance * 0.8, 320.0);
    float rayStep = maxDistance / float(maxSamples);
    vec3 rayDirection = normalize(viewPosition);
    
    // Atmospheric alignment calculations
    float upDotProduct = dot(rayDirection, upVector);
    float sunDotProduct = dot(rayDirection, sunVector);
    float sunAlignment = sunDotProduct * 0.5 + 0.5;
    
    // Quality-based distance adjustments
    #ifdef DISTANT_HORIZONS
        if (abs(cameraPosition.y - altitudeLevel) < volumetricStretch) {
            maxDistance = min(maxDistance, renderDistance * 0.6);
        }
    #endif
    
    // Ray marching through volumetric space
    for (int sampleIndex = 0; sampleIndex < maxSamples; sampleIndex++) {
        float sampleDistance = (float(sampleIndex) + ditherNoise) * rayStep;
        if (sampleDistance > maxDistance) break;
        
        vec3 samplePosition = cameraPosition + rayDirection * sampleDistance;
        vec3 modifiedPosition;
        
        // Sample volumetric noise at current position
        if (SampleVolumetricNoise(samplePosition, modifiedPosition, altitudeLevel)) {
            // Calculate horizontal distance for fog density
            vec2 horizontalOffset = samplePosition.xz - cameraPosition.xz;
            float horizontalDistance = length(horizontalOffset);
            float distanceThreshold = maxDistance * 0.85;
            
            if (horizontalDistance > distanceThreshold) continue;
            
            // Lighting calculations
            float heightShading = 1.0;
            float distanceMultiplier = 1.0;
            
            #ifdef DEFERRED1
                // Advanced lighting with shadow sampling
                vec3 lightRayDirection = sunVector * rayStep * 0.5;
                vec3 lightSamplePos = samplePosition;
                float lightAccumulation = 0.0;
                float lightRayStep = rayStep * 0.25;
                float lightingMultiplier = 0.8 + 0.2 * sunVisibility;
                float shadingMultiplier = 0.4;
                
                // Sample lighting along sun direction
                lightSamplePos += gradientNoise * lightRayStep;
                #ifdef DEFERRED1
                    lightAccumulation -= texture2D(colortex3, GetRoundedAtmosphericCoord(lightSamplePos.xz, 0.125)).b * shadingMultiplier;
                #else
                    lightAccumulation -= texture2D(gaux4, GetRoundedAtmosphericCoord(lightSamplePos.xz, 0.125)).b * shadingMultiplier;
                #endif
                
                // Second light sample with offset
                lightSamplePos += gradientNoise * lightRayStep;
                #ifdef DEFERRED1
                    lightAccumulation -= texture2D(colortex3, GetRoundedAtmosphericCoord(lightSamplePos.xz, 0.125)).b * shadingMultiplier;
                #else
                    lightAccumulation -= texture2D(gaux4, GetRoundedAtmosphericCoord(lightSamplePos.xz, 0.125)).b * shadingMultiplier;
                #endif
                
                // Combine lighting factors
                float sunContribution = sunAlignment * shadowTime * 0.25;
                sunContribution += 0.5 * heightShading + 0.08;
                heightShading = sunContribution * lightAccumulation * lightingMultiplier;
            #endif
            
            // Calculate final volumetric color
            vec3 volumetricColor = cloudAmbientColor + cloudLightColor * (0.07 + heightShading);
            
            // Blend with sky color based on distance
            vec3 skyColor = GetSkyHorizon(upDotProduct, sunDotProduct, ditherNoise, true, false);
            #ifdef ATM_COLOR_MULTS
                skyColor *= sqrtAtmColorMult;
            #endif
            
            float distanceRatio = (distanceThreshold - horizontalDistance) / distanceThreshold;
            float fogBlendFactor = clamp(distanceRatio, 0.0, 0.75);
            
            #ifndef DISTANT_HORIZONS
                float fogDistance = fogBlendFactor;
            #else
                float fogDistance = pow1_5(clamp(distanceRatio, 0.0, 1.0)) * 0.75;
            #endif
            
            // Apply sky and visibility multipliers
            float skyMultiplier1 = 1.0 - 0.2 * (1.0 - skyFade) * max(sunVisibility2, nightFactor);
            float skyMultiplier2 = 1.0 - 0.33333 * skyFade;
            
            volumetricColor = mix(skyColor, volumetricColor * skyMultiplier1, fogDistance * skyMultiplier2);
            volumetricColor *= pow2(1.0 - maxBlindnessDarkness);
            
            // Set output values and return
            depthOutput = sqrt(sampleDistance / renderDistance);
            volumetricResult.a = pow(fogBlendFactor * 1.33333, 0.5 + 10.0 * pow(abs(sunAlignment), 90.0)) * distanceMultiplier;
            volumetricResult.rgb = volumetricColor;
            break;
        }
    }
    
    return volumetricResult;
}

//═══════════════════════════════════════════════════════════════════════════════════════
//                           VOLUMETRIC LIGHT SHAFT RENDERING
//═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Advanced volumetric light shaft rendering system
 * Creates realistic light beams through atmospheric particles with shadow casting
 * @param color: Scene color to modify (input/output)
 * @param vlFactor: Volumetric light intensity factor (input/output)
 * @param translucentMult: Translucent surface color multiplier
 * @param lViewPos0: Linear view position (near)
 * @param lViewPos1: Linear view position (far)
 * @param nViewPos: Normalized view position
 * @param VdotL: View direction dot light direction
 * @param VdotU: View direction dot up vector
 * @param texCoord: Screen texture coordinates
 * @param z0: Near depth value
 * @param z1: Far depth value
 * @param dither: Temporal dithering for smooth sampling
 * @return: Volumetric light contribution (RGB + alpha)
 */
vec4 GetVolumetricLight(inout vec3 color, inout float vlFactor, vec3 translucentMult, float lViewPos0, float lViewPos1, 
                        vec3 nViewPos, float VdotL, float VdotU, vec2 texCoord, float z0, float z1, float dither) {
    vec4 volumetricLight = vec4(0.0);
    float vlMult = 1.0 - maxBlindnessDarkness;

    #if SHADOW_QUALITY > -1
        // Optifine shadow map resolution handling
        vec2 shadowMapResolutionM = textureSize(shadowtex0, 0);
    #endif

    #ifdef OVERWORLD
        vec3 vlColor = lightColor;
        vec3 vlColorReducer = vec3(1.0);
        float vlSceneIntensity = isEyeInWater != 1 ? vlFactor : 1.0;

        #ifdef SPECIAL_BIOME_WEATHER
            vlSceneIntensity = mix(vlSceneIntensity, 1.0, inDry * rainFactor);
        #endif

        // Night-time light shaft adjustments
        if (sunVisibility < 0.5) {
            vlSceneIntensity = 0.0;
            
            float vlMultNightModifier = 0.6 + 0.4 * max0(far - lViewPos1) / far;
            #ifdef SPECIAL_PALE_GARDEN_LIGHTSHAFTS
                vlMultNightModifier = mix(vlMultNightModifier, 1.0, inPaleGarden);
            #endif
            vlMult *= vlMultNightModifier;

            vlColor = normalize(pow(vlColor, vec3(1.0 - max0(1.0 - 1.5 * nightFactor))));
            vlColor *= 0.0766 + 0.0766 * vsBrightness;
        } else {
            vlColorReducer = 1.0 / sqrt(vlColor);
        }

        #ifdef SPECIAL_PALE_GARDEN_LIGHTSHAFTS
            vlSceneIntensity = mix(vlSceneIntensity, 1.0, inPaleGarden);
            vlMult *= 1.0 + (3.0 * inPaleGarden) * (1.0 - sunVisibility);
        #endif

        // Atmospheric alignment calculations
        float rainyNight = (1.0 - sunVisibility) * rainFactor;
        float VdotLM = max((VdotL + 1.0) / 2.0, 0.0);
        float VdotUmax0 = max(VdotU, 0.0);
        float VdotUM = mix(pow2(1.0 - VdotUmax0), 1.0, 0.5 * vlSceneIntensity);
              VdotUM = smoothstep1(VdotUM);
              VdotUM = pow(VdotUM, min(lViewPos1 / far, 1.0) * (3.0 - 2.0 * vlSceneIntensity));
        vlMult *= mix(VdotUM * VdotLM, 1.0, 0.4 * rainyNight) * vlTime;
        vlMult *= mix(invNoonFactor2 * 0.875 + 0.125, 1.0, max(vlSceneIntensity, rainFactor2));

        // Quality-based sample count determination
        #if LIGHTSHAFT_QUALI == 4
            int sampleCount = vlSceneIntensity < 0.5 ? 30 : 50;
        #elif LIGHTSHAFT_QUALI == 3
            int sampleCount = vlSceneIntensity < 0.5 ? 15 : 30;
        #elif LIGHTSHAFT_QUALI == 2
            int sampleCount = vlSceneIntensity < 0.5 ? 10 : 20;
        #elif LIGHTSHAFT_QUALI == 1
            int sampleCount = vlSceneIntensity < 0.5 ? 6 : 12;
        #endif

        #ifdef LIGHTSHAFT_SMOKE
            float totalSmoke = 0.0;
        #endif
    #else
        // End dimension light shaft handling
        translucentMult = sqrt(translucentMult);
        float vlSceneIntensity = 0.0;

        #ifndef LOW_QUALITY_ENDER_NEBULA
            int sampleCount = 16;
        #else
            int sampleCount = 10;
        #endif
    #endif

    // Distance and sampling calculations
    float addition = 1.0;
    float maxDist = mix(max(far, 96.0) * 0.55, 80.0, vlSceneIntensity);

    #if WATER_FOG_MULT != 100
        if (isEyeInWater == 1) {
            #define WATER_FOG_MULT_M WATER_FOG_MULT * 0.01;
            maxDist /= WATER_FOG_MULT_M;
        }
    #endif

    float distMult = maxDist / (sampleCount + addition);
    float sampleMultIntense = isEyeInWater != 1 ? 1.0 : 0.85;
    float viewFactor = 1.0 - 0.7 * pow2(dot(nViewPos.xy, nViewPos.xy));

    // Depth calculations
    float depth0 = GetDepth(z0);
    float depth1 = GetDepth(z1);
    #ifdef END
        if (z0 == 1.0) depth0 = 1000.0;
        if (z1 == 1.0) depth1 = 1000.0;
    #endif

    // Perspective distortion approximation
    maxDist *= viewFactor;
    distMult *= viewFactor;

    #ifdef OVERWORLD
        float maxCurrentDist = min(depth1, maxDist);
    #else
        float maxCurrentDist = min(depth1, far);
    #endif

    // Ray marching for volumetric light sampling
    for (int i = 0; i < sampleCount; i++) {
        float currentDist = (i + dither) * distMult + addition;
        if (currentDist > maxCurrentDist) break;

        // Calculate world position for current sample
        vec4 viewPos = gbufferProjectionInverse * (vec4(texCoord, GetDistX(currentDist), 1.0) * 2.0 - 1.0);
        viewPos /= viewPos.w;
        vec4 wpos = gbufferModelViewInverse * viewPos;
        vec3 playerPos = wpos.xyz / wpos.w;
        
        #ifdef END
            #ifdef DISTANT_HORIZONS
                playerPos *= sqrt(renderDistance / far);
            #endif
            vec4 enderBeamSample = vec4(DrawEnderBeams(VdotU, playerPos), 1.0);
            enderBeamSample /= sampleCount;
        #endif

        float shadowSample = 1.0;
        vec3 vlSample = vec3(1.0);
        
        #if SHADOW_QUALITY > -1
            // Shadow map sampling and calculations
            wpos = shadowModelView * wpos;
            wpos = shadowProjection * wpos;
            wpos /= wpos.w;
            float distb = sqrt(wpos.x * wpos.x + wpos.y * wpos.y);
            float distortFactor = 1.0 - shadowMapBias + distb * shadowMapBias;
            vec4 shadowPosition = DistortShadow(wpos, distortFactor);

            #ifdef OVERWORLD
                float percentComplete = currentDist / maxDist;
                float sampleMult = mix(percentComplete * 3.0, sampleMultIntense, max(rainFactor, vlSceneIntensity));
                if (currentDist < 5.0) sampleMult *= smoothstep1(clamp(currentDist / 5.0, 0.0, 1.0));
                sampleMult /= sampleCount;
            #endif

            if (length(shadowPosition.xy * 2.0 - 1.0) < 1.0) {
                // Shadow texture sampling with GPU compatibility fix
                shadowSample = texelFetch(shadowtex0, ivec2(shadowPosition.xy * shadowMapResolutionM), 0).x;
                shadowSample = clamp((shadowSample - shadowPosition.z) * 65536.0, 0.0, 1.0);
                vlSample = vec3(shadowSample);

                #if SHADOW_QUALITY >= 1
                    if (shadowSample == 0.0) {
                        float testsample = shadow2D(shadowtex1, shadowPosition.xyz).z;
                        if (testsample == 1.0) {
                            vec3 colsample = texture2D(shadowcolor1, shadowPosition.xy).rgb * 4.0;
                            colsample *= colsample;
                            vlSample = colsample;
                            shadowSample = 1.0;
                            #ifdef OVERWORLD
                                vlSample *= vlColorReducer;
                            #endif
                        }
                    } else {
                        #ifdef OVERWORLD
                            // Water surface tinting for underwater observations
                            if (translucentMult != vec3(1.0) && currentDist > depth0) {
                                vec3 tinter = vec3(1.0);
                                if (isEyeInWater == 1) {
                                    vec3 translucentMultM = translucentMult * 2.8;
                                    tinter = pow(translucentMultM, vec3(sunVisibility * 3.0 * clamp01(playerPos.y * 0.03)));
                                } else {
                                    tinter = 0.1 + 0.9 * pow2(pow2(translucentMult * 1.7));
                                }
                                vlSample *= mix(vec3(1.0), tinter, clamp01(oceanAltitude - cameraPosition.y));
                            }
                        #endif

                        if (isEyeInWater == 1 && translucentMult == vec3(1.0)) vlSample = vec3(0.0);
                    }
                #endif
            }
        #endif

        // Apply translucency effects beyond depth
        if (currentDist > depth0) vlSample *= translucentMult;

        #ifdef OVERWORLD
            #ifdef LIGHTSHAFT_SMOKE
                // Procedural smoke generation for enhanced atmospheric effects
                vec3 smokePos = 0.0015 * (playerPos + cameraPosition);
                vec3 smokeWind = frameTimeCounter * vec3(0.002, 0.001, 0.0);
                float smoke = 0.65 * Noise3D(smokePos + smokeWind)
                            + 0.25 * Noise3D((smokePos - smokeWind) * 3.0)
                            + 0.10 * Noise3D((smokePos + smokeWind) * 9.0);
                smoke = smoothstep1(smoothstep1(smoothstep1(smoke)));
                totalSmoke += smoke * shadowSample * sampleMult;
            #endif

            volumetricLight += vec4(vlSample, shadowSample) * sampleMult;
        #else
            volumetricLight += vec4(vlSample, shadowSample) * enderBeamSample;
        #endif
    }

    #ifdef LIGHTSHAFT_SMOKE
        volumetricLight *= pow(totalSmoke / volumetricLight.a, min(1.0 - volumetricLight.a, 0.5));
        volumetricLight.rgb /= pow(0.5, 1.0 - volumetricLight.a);
    #endif

    // Scene-aware light shaft intensity adjustment
    #if defined OVERWORLD && LIGHTSHAFT_BEHAVIOUR == 1 && SHADOW_QUALITY >= 1
        if (viewWidth + viewHeight - gl_FragCoord.x - gl_FragCoord.y < 1.5) {
            if (frameCounter % int(0.06666 / frameTimeSmooth + 0.5) == 0) {
                int salsX = 5;
                int salsY = 5;
                float heightThreshold = 6.0;

                vec2 viewM = 1.0 / vec2(salsX, salsY);
                float salsSampleSum = 0.0;
                int salsSampleCount = 0;
                
                for (float i = 0.25; i < salsX; i++) {
                    for (float h = 0.45; h < salsY; h++) {
                        vec2 coord = 0.3 + 0.4 * viewM * vec2(i, h);
                        ivec2 icoord = ivec2(coord * shadowMapResolutionM);
                        float salsSample = texelFetch(shadowtex0, icoord, 0).x;
                        
                        if (salsSample < 0.55) {
                            float sampledHeight = texture2D(shadowcolor1, coord).a;
                            if (sampledHeight > 0.0) {
                                sampledHeight = max0(sampledHeight - 0.25) / 0.05;
                                salsSampleSum += sampledHeight;
                                salsSampleCount++;
                            }
                        }
                    }
                }

                float salsCheck = salsSampleSum / salsSampleCount;
                int reduceAmount = 2;

                int skyCheck = 0;
                for (float i = 0.1; i < 1.0; i += 0.2) {
                    skyCheck += int(texelFetch(depthtex0, ivec2(view.x * i, view.y * 0.9), 0).x == 1.0);
                }
                
                if (skyCheck >= 4) {
                    salsCheck = 0.0;
                    reduceAmount = 3;
                }

                if (salsCheck > heightThreshold) {
                    vlFactor = min(vlFactor + OSIEBCA, 1.0);
                } else {
                    vlFactor = max(vlFactor - OSIEBCA * reduceAmount, 0.0);
                }
            }
        } else {
            vlFactor = 0.0;
        }
    #endif

    #ifdef OVERWORLD
        // Final color adjustments based on atmospheric conditions
        vlColor = pow(vlColor, vec3(0.5 + 0.5 * invNoonFactor * invRainFactor + 0.3 * rainFactor));
        vlColor *= 1.0 - (0.3 + 0.3 * noonFactor) * rainFactor - 0.5 * rainyNight;

        #if LIGHTSHAFT_DAY_I != 100 || LIGHTSHAFT_NIGHT_I != 100 || LIGHTSHAFT_RAIN_I != 100
            #define LIGHTSHAFT_DAY_IM LIGHTSHAFT_DAY_I * 0.01
            #define LIGHTSHAFT_NIGHT_IM LIGHTSHAFT_NIGHT_I * 0.01
            #define LIGHTSHAFT_RAIN_IM LIGHTSHAFT_RAIN_I * 0.01

            if (isEyeInWater == 0) {
                #if LIGHTSHAFT_DAY_I != 100 || LIGHTSHAFT_NIGHT_I != 100
                    vlColor.rgb *= mix(LIGHTSHAFT_NIGHT_IM, LIGHTSHAFT_DAY_IM, sunVisibility);
                #endif
                #if LIGHTSHAFT_RAIN_I != 100
                    vlColor.rgb *= mix(1.0, LIGHTSHAFT_RAIN_IM, rainFactor);
                #endif
            }
        #endif

        volumetricLight.rgb *= vlColor;
    #endif

    volumetricLight.rgb *= vlMult;
    volumetricLight = max(volumetricLight, vec4(0.0));

    #ifdef DISTANT_HORIZONS
        if (isEyeInWater == 0) {
            #ifdef OVERWORLD
                float lViewPosM = lViewPos0;
                if (z0 >= 1.0) {
                    float z0DH = texelFetch(dhDepthTex, texelCoord, 0).r;
                    vec4 screenPosDH = vec4(texCoord, z0DH, 1.0);
                    vec4 viewPosDH = dhProjectionInverse * (screenPosDH * 2.0 - 1.0);
                    viewPosDH /= viewPosDH.w;
                    lViewPosM = length(viewPosDH.xyz);
                }
                lViewPosM = min(lViewPosM, renderDistance * 0.6);

                float dhVlStillIntense = max(max(vlSceneIntensity, rainFactor), nightFactor * 0.5);
                volumetricLight *= mix(0.0003 * lViewPosM, 1.0, dhVlStillIntense);
            #else
                volumetricLight *= min1(lViewPos1 * 3.0 / renderDistance);
            #endif
        }
    #endif

    return volumetricLight;
}

//═══════════════════════════════════════════════════════════════════════════════════════
//                                 STARS SYSTEM MODULE
//═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Generates pseudo-random noise for star placement
 * @param pos: 2D position coordinate
 * @return: Random value [0.0, 1.0] for star generation
 */
float GetStarNoise(vec2 pos) {
    return fract(sin(dot(pos, vec2(12.9898, 4.1414))) * 43758.54953);
}

/**
 * Calculates star coordinate mapping from view position
 * @param viewPos: View space position vector
 * @param sphereness: Spherical projection factor [0.0, 1.0]
 * @return: 2D star coordinate for texture sampling
 */
vec2 GetStarCoord(vec3 viewPos, float sphereness) {
    vec3 wpos = normalize((gbufferModelViewInverse * vec4(viewPos * 1000.0, 1.0)).xyz);
    vec3 starCoord = wpos / (wpos.y + length(wpos.xz) * sphereness);
    starCoord.x += 0.006 * syncedTime;  // Subtle star movement
    return starCoord.xz;
}

/**
 * Generates overworld star field with configurable density
 * @param starCoord: 2D star coordinate from GetStarCoord
 * @param VdotU: View direction dot up vector
 * @param VdotS: View direction dot sun vector
 * @return: RGB star color contribution
 */
vec3 GetStars(vec2 starCoord, float VdotU, float VdotS) {
    if (VdotU < 0.0) return vec3(0.0);  // No stars below horizon

    starCoord *= 0.2;
    float starFactor = 1024.0;
    starCoord = floor(starCoord * starFactor) / starFactor;

    // Multi-layer star noise for realistic distribution
    float star = 1.0;
    star *= GetStarNoise(starCoord.xy);
    star *= GetStarNoise(starCoord.xy + 0.1);
    star *= GetStarNoise(starCoord.xy + 0.23);

    #if NIGHT_STAR_AMOUNT == 2
        star -= 0.7;  // High star density
    #else
        star -= 0.6;  // Standard star density
        star *= 0.65;
    #endif
    star = max0(star);
    star *= star;  // Square for more dramatic falloff

    // Apply atmospheric and lighting conditions
    star *= min1(VdotU * 3.0) * max0(1.0 - pow(abs(VdotS) * 1.002, 100.0));
    star *= invRainFactor * pow2(pow2(invNoonFactor2)) * (1.0 - 0.5 * sunVisibility);

    return 40.0 * star * vec3(0.38, 0.4, 0.5);
}

//═══════════════════════════════════════════════════════════════════════════════════════
//                               END DIMENSION STARS MODULE
//═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Generates End dimension stars with magical coloring
 * @param viewPos: View space position vector
 * @param VdotU: View direction dot up vector
 * @return: RGB End star color with magical enhancement
 */
vec3 GetEnderStars(vec3 viewPos, float VdotU) {
    vec3 wpos = normalize((gbufferModelViewInverse * vec4(viewPos * 1000.0, 1.0)).xyz);

    vec3 starCoord = 0.65 * wpos / (abs(wpos.y) + length(wpos.xz));
    vec2 starCoord2 = starCoord.xz * 0.5;
    if (VdotU < 0.0) starCoord2 += 100.0;
    float starFactor = 1024.0;
    starCoord2 = floor(starCoord2 * starFactor) / starFactor;

    // Triple-layer End star generation
    float star = 1.0;
    star *= GetStarNoise(starCoord2.xy);
    star *= GetStarNoise(starCoord2.xy + 0.1);
    star *= GetStarNoise(starCoord2.xy + 0.23);
    star = max(star - 0.6, 0.0);  // More visible End stars
    star *= star;

    // Enhanced magical End star colors
    vec3 baseStarColor = endSkyColor * mix(
        vec3(3500.0, 2800.0, 4500.0), 
        vec3(4200.0, 3500.0, 2200.0), 
        GetStarNoise(starCoord2.xy + 0.5)
    );
    vec3 enderStars = star * baseStarColor;

    // Apply directional visibility factors
    float VdotUM1 = abs(VdotU);
    float VdotUM2 = pow2(1.0 - VdotUM1);
    enderStars *= VdotUM1 * VdotUM1 * (VdotUM2 + 0.015) + 0.015;

    return enderStars;
}

//═══════════════════════════════════════════════════════════════════════════════════════
//                              AURORA BOREALIS MODULE
//═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Generates aurora borealis effects with configurable conditions
 * @param viewPos: View space position vector
 * @param VdotU: View direction dot up vector
 * @param dither: Temporal dithering value
 * @return: RGB aurora color contribution
 */
vec3 GetAuroraBorealis(vec3 viewPos, float VdotU, float dither) {
    float visibility = sqrt1(clamp01(VdotU * 1.5 - 0.225)) - sunVisibility - rainFactor - maxBlindnessDarkness;
    visibility *= 1.0 - VdotU * 0.9;

    // Apply aurora visibility conditions
    #if AURORA_CONDITION == 1 || AURORA_CONDITION == 3
        visibility -= moonPhase;
    #endif
    #if AURORA_CONDITION == 2 || AURORA_CONDITION == 3
        visibility *= inSnowy;
    #endif
    #if AURORA_CONDITION == 4
        visibility = max(visibility * inSnowy, visibility - moonPhase);
    #endif

    if (visibility > 0.0) {
        vec3 aurora = vec3(0.0);

        vec3 wpos = mat3(gbufferModelViewInverse) * viewPos;
             wpos.xz /= wpos.y;
        vec2 cameraPositionM = cameraPosition.xz * 0.0075;
             cameraPositionM.x += syncedTime * 0.04;

        // Quality-adaptive sample count
        #ifdef DEFERRED1
            int sampleCount = 25;
            int sampleCountP = sampleCount + 5;
        #else
            int sampleCount = 10;
            int sampleCountP = sampleCount + 10;
        #endif

        float ditherM = dither + 5.0;
        float auroraAnimate = frameTimeCounter * 0.001;
        
        // Multi-layer aurora generation
        for (int i = 0; i < sampleCount; i++) {
            float current = pow2((i + ditherM) / sampleCountP);

            vec2 planePos = wpos.xz * (0.8 + current) * 11.0 + cameraPositionM;
            
            #if AURORA_STYLE == 1
                // Pixelated aurora style
                planePos = floor(planePos) * 0.0007;
                float noise = texture2D(noisetex, planePos).b;
                noise = pow2(pow2(pow2(pow2(1.0 - 2.0 * abs(noise - 0.5)))));
                noise *= pow1_5(texture2D(noisetex, planePos * 100.0 + auroraAnimate).b);
            #else
                // Smooth aurora style
                planePos *= 0.0007;
                float noise = texture2D(noisetex, planePos).r;
                noise = pow2(pow2(pow2(pow2(1.0 - 2.0 * abs(noise - 0.5)))));
                noise *= texture2D(noisetex, planePos * 3.0 + auroraAnimate).b;
                noise *= texture2D(noisetex, planePos * 5.0 - auroraAnimate).b;
            #endif

            float currentM = 1.0 - current;
            aurora += noise * currentM * mix(
                vec3(7.0, 2.2, 12.0), 
                vec3(6.0, 16.0, 12.0), 
                pow2(pow2(currentM))
            );
        }

        #if AURORA_STYLE == 1
            aurora *= 1.3;
        #else
            aurora *= 1.8;
        #endif

        #ifdef ATM_COLOR_MULTS
            aurora *= sqrtAtmColorMult;
        #endif

        return aurora * visibility / sampleCount;
    }

    return vec3(0.0);
}

//═══════════════════════════════════════════════════════════════════════════════════════
//                                NIGHT NEBULA MODULE
//═══════════════════════════════════════════════════════════════════════════════════════

#ifndef HQ_NIGHT_NEBULA
    const int OCTAVE = 5;
#else
    const int OCTAVE = 8;
#endif
const float timescale = 5.0;
const float zoomScale = 3.5;
const vec4 CLOUD1_COL = vec4(0.41, 0.64, 0.97, 0.4);
const vec4 CLOUD2_COL = vec4(0.81, 0.55, 0.21, 0.2);
const vec4 CLOUD3_COL = vec4(0.51, 0.81, 0.98, 1.0);

float sinM(float x) {
    return sin(mod(x, 2.0 * pi));
}

float cosM(float x) {
    return cos(mod(x, 2.0 * pi));
}

float rand(vec2 inCoord){
    return fract(sinM(dot(inCoord, vec2(23.53, 44.0))) * 42350.45);
}

float perlin(vec2 inCoord){
    vec2 i = floor(inCoord);
    vec2 j = fract(inCoord);
    vec2 coord = smoothstep(0.0, 1.0, j);

    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));

    return mix(mix(a, b, coord.x), mix(c, d, coord.x), coord.y);
}

float fbmCloud(vec2 inCoord, float minimum){
    float value = 0.0;
    float scale = 0.5;

    for (int i = 0; i < OCTAVE; i++){
        value += perlin(inCoord) * scale;
        inCoord *= 2.0;
        scale *= 0.5;
    }

    return smoothstep(0.0, 1.0, (smoothstep(minimum, 1.0, value) - minimum) / (1.0 - minimum));
}

float fbmCloud2(vec2 inCoord, float minimum){
    float value = 0.0;
    float scale = 0.5;

    for (int i = 0; i < OCTAVE; i++){
        value += perlin(inCoord) * scale;
        inCoord *= 2.0;
        scale *= 0.5;
    }

    return (smoothstep(minimum, 1.0, value) - minimum) / (1.0 - minimum);
}

/**
 * Generates night nebula effects with fractal noise
 * @param viewPos: View space position vector
 * @param VdotU: View direction dot up vector
 * @param VdotS: View direction dot sun vector
 * @return: RGB nebula color contribution
 */
vec3 GetNightNebula(vec3 viewPos, float VdotU, float VdotS) {
    float nebulaFactor = pow2(max0(VdotU) * min1(nightFactor * 2.0)) * invRainFactor - maxBlindnessDarkness;
    if (nebulaFactor < 0.001) return vec3(0.0);

    vec2 UV = GetStarCoord(viewPos, 0.75);
    float TIME = syncedTime * 0.003 + 15.0;

    float timescaled = TIME * timescale;
    vec2 zoomUV2 = vec2(
        zoomScale * UV.x + 0.03  * timescaled * sinM(0.07 * timescaled), 
        zoomScale * UV.y + 0.03  * timescaled * cosM(0.06 * timescaled)
    );
    vec2 zoomUV3 = vec2(
        zoomScale * UV.x + 0.027 * timescaled * sinM(0.07 * timescaled), 
        zoomScale * UV.y + 0.025 * timescaled * cosM(0.06 * timescaled)
    );
    vec2 zoomUV4 = vec2(
        zoomScale * UV.x + 0.021 * timescaled * sinM(0.07 * timescaled), 
        zoomScale * UV.y + 0.021 * timescaled * cosM(0.07 * timescaled)
    );
    
    float tide = 0.05 * sinM(TIME);
    float tide2 = 0.06 * cosM(0.3 * TIME);

    // Multi-layer nebula texture generation
    vec4 nebulaTexture = vec4(vec3(0.0), 0.5 + 0.2 * sinM(0.23 * TIME + UV.x - UV.y));
    nebulaTexture += fbmCloud2(zoomUV3, 0.24 + tide) * CLOUD1_COL;
    nebulaTexture += fbmCloud(zoomUV2 * 0.9, 0.33 - tide) * CLOUD2_COL;
    nebulaTexture = mix(nebulaTexture, CLOUD3_COL, fbmCloud(vec2(0.9 * zoomUV4.x, 0.9 * zoomUV4.y), 0.25 + tide2));

    nebulaFactor *= 1.0 - pow2(pow2(pow2(abs(VdotS))));
    nebulaTexture.a *= min1(pow2(pow2(nebulaTexture.a))) * nebulaFactor;

    // Add star integration
    float starFactor = 1024.0;
    vec2 starCoord = floor(UV * 0.25 * starFactor) / starFactor;
    nebulaTexture.rgb *= 1.5 + 10.0 * pow2(max0(GetStarNoise(starCoord) * GetStarNoise(starCoord + 0.1) - 0.6));

    #if NIGHT_NEBULA_I != 100
        #define NIGHT_NEBULA_IM NIGHT_NEBULA_I * 0.01
        nebulaTexture.a *= NIGHT_NEBULA_IM;
    #endif

    #ifdef ATM_COLOR_MULTS
        nebulaTexture.rgb *= sqrtAtmColorMult;
    #endif

    return max(nebulaTexture.rgb * nebulaTexture.a, vec3(0.0));
}

//═══════════════════════════════════════════════════════════════════════════════════════
//                               LEGACY COMPATIBILITY
//═══════════════════════════════════════════════════════════════════════════════════════

// Maintain backward compatibility with existing shader code
#define GetVolumetricFogRendering GetVolumetricFog
#define GetVolumetricLightShafts GetVolumetricLight
#define GetSky GetSkyHorizon
#define GetLowQualitySky GetOptimizedSkyHorizon
#define GetNightStars GetStars
#define GetCelestialEffects GetAuroraBorealis
#define GetWeatherEffects GetRainbow
#define GetEnvironmentalFog DrawEnderBeams

#endif // INCLUDE_ATMOSPHERIC_VOLUMETRIC_SYSTEM
