/*
 * ═══════════════════════════════════════════════════════════════════════════════════════
 * 
 *                            ATMOSPHERIC HORIZON MODULE
 *                         Luminara Shader - Advanced Sky Rendering System
 * 
 * ═══════════════════════════════════════════════════════════════════════════════════════
 * 
 * Copyright (c) 2025 VcorA Development
 * All rights reserved. Unauthorized reproduction or distribution is prohibited.
 * 
 * This module implements advanced sky rendering with realistic atmospheric scattering,
 * dynamic day/night transitions, weather effects, and quality-adaptive rendering.
 * Features underwater effects, cave fog integration, and celestial glare systems.
 * 
 * ═══════════════════════════════════════════════════════════════════════════════════════
 */

#ifndef INCLUDE_ATMOSPHERIC_HORIZON
#define INCLUDE_ATMOSPHERIC_HORIZON

//═══════════════════════════════════════════════════════════════════════════════════════
//                                 DEPENDENCY INCLUDES
//═══════════════════════════════════════════════════════════════════════════════════════

#include "/lib/color_schemes/core_color_system.glsl"


#ifdef CAVE_FOG
    #include "/lib/atmospherics/particles/depthFactor.glsl"
#endif

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
    // Simulate atmospheric density gradient from luminara to horizon
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

//═══════════════════════════════════════════════════════════════════════════════════════
//                               LEGACY COMPATIBILITY
//═══════════════════════════════════════════════════════════════════════════════════════

// Maintain backward compatibility with existing sky systems
#define GetSky GetSkyHorizon
#define GetLowQualitySky GetOptimizedSkyHorizon

#endif // INCLUDE_ATMOSPHERIC_HORIZON
