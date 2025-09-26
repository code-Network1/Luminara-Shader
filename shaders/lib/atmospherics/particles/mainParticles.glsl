/*
 * ═══════════════════════════════════════════════════════════════════════════════════════
 * 
 *                                MAIN PARTICLES SYSTEM
 *                         Luminara Shader - Atmospheric Particle Effects
 * 
 * ═══════════════════════════════════════════════════════════════════════════════════════
 * 
 * Copyright (c) 2025 VcorA Development
 * All rights reserved. Unauthorized reproduction or distribution is prohibited.
 * 
 * This module implements the comprehensive particle effects system including atmospheric
 * fog, border fog, cave fog, water/lava effects, and special condition fog systems.
 * Features quality-adaptive rendering and dimensional-specific effects.
 * 
 * ═══════════════════════════════════════════════════════════════════════════════════════
 */

//═══════════════════════════════════════════════════════════════════════════════════════
//                                 DEPENDENCY INCLUDES
//═══════════════════════════════════════════════════════════════════════════════════════

#ifdef ATM_COLOR_MULTS
    #include "/lib/color_schemes/color_effects_system.glsl"
#endif
#ifdef MOON_PHASE_INF_ATMOSPHERE
    #include "/lib/color_schemes/color_effects_system.glsl"
#endif

//═══════════════════════════════════════════════════════════════════════════════════════
//                              BORDER FOG SYSTEM MODULE
//═══════════════════════════════════════════════════════════════════════════════════════

#ifdef BORDER_FOG
    #ifdef OVERWORLD
        #include "/lib/atmospherics/atmosphericVolumetricSystem.glsl"
    #elif defined NETHER
        #include "/lib/color_schemes/core_color_system.glsl"
    #endif

    /**
     * Processes dimensional border fog effects for world boundaries
     * @param color: Input color to be modified [RGB]
     * @param skyFade: Sky fade factor output [0.0, 1.0]
     * @param lPos: Distance from viewer
     * @param VdotU: View direction dot up vector
     * @param VdotS: View direction dot sun vector
     * @param dither: Temporal dithering value
     * 
     * Features:
     * - Overworld: Exponential distance-based fog with horizon effects
     * - Nether: Optimized fog with greatly reduced density for better visibility
     * - End: Enhanced magical fog with shimmer effects
     */
    void DoBorderFog(inout vec3 color, inout float skyFade, float lPos, float VdotU, float VdotS, float dither) {
        #ifdef OVERWORLD
            // === OVERWORLD FOG CALCULATION ===
            // Progressive fog intensity based on render distance
            float fog = lPos / renderDistance;
            fog = pow2(pow2(fog));
            #ifndef DISTANT_HORIZONS
                fog = pow2(pow2(fog));  // Additional density for standard rendering
            #endif
            fog = 1.0 - exp(-3.0 * fog);
        #endif
        
        #ifdef NETHER
            // === NETHER FOG CALCULATION ===
            // Luminara Shader: Greatly reduced Nether fog for clear view
            float farM = min(renderDistance, NETHER_VIEW_LIMIT);
            float fog = lPos / farM;
            // Minimal fog values for enhanced visibility
            fog = fog * 0.05 + 0.02 * pow(fog, 512.0 / max(farM, 512.0));
        #endif
        
        #ifdef END
            // === END DIMENSION FOG CALCULATION ===
            float fog = lPos / renderDistance;
            fog = pow2(pow2(fog));
            fog = 1.0 - exp(-3.0 * fog);
            // Luminara Shader: Enhanced End fog effect with better visibility
            fog *= 0.8;
        #endif

        #ifdef DREAM_TWEAKED_BORDERFOG
            fog *= fog * 0.5;  // Dream dimension adjustment
        #endif

        if (fog > 0.0) {
            fog = clamp(fog, 0.0, 1.0);

            #ifdef OVERWORLD
                // Dynamic sky-based fog color
                vec3 fogColorM = GetSky(VdotU, VdotS, dither, true, false);
            #elif defined NETHER
                // Static nether-themed fog color
                vec3 fogColorM = netherColor;
            #else
                // === ENHANCED MAGICAL END FOG COLOR ===
                vec3 fogColorM = endSkyColor;
                float magicalShimmer = 0.8 + 0.3 * sin(frameTimeCounter * 2.0 + fog * 10.0);
                fogColorM *= magicalShimmer;
                fogColorM += vec3(0.1, 0.05, 0.15) * (1.0 - fog) * magicalShimmer;
            #endif

            // Apply atmospheric color multipliers
            #ifdef ATM_COLOR_MULTS
                fogColorM *= atmColorMult;
            #endif
            #ifdef MOON_PHASE_INF_ATMOSPHERE
                fogColorM *= moonPhaseInfluence;
            #endif

            // Blend fog color with existing color
            color = mix(color, fogColorM, fog);

            // Set sky fade factor (water-aware)
            #ifndef GBUFFERS_WATER
                skyFade = fog;
            #else
                skyFade = fog * (1.0 - isEyeInWater);
            #endif
        }
    }
#endif

//═══════════════════════════════════════════════════════════════════════════════════════
//                               CAVE FOG SYSTEM MODULE
//═══════════════════════════════════════════════════════════════════════════════════════

#ifdef CAVE_FOG
    #include "/lib/atmospherics/particles/depthFactor.glsl"

    /**
     * Processes underground cave fog effects
     * @param color: Input color to be modified [RGB]
     * @param lViewPos: View distance for fog calculation
     * 
     * Features:
     * - Luminara Shader: Lighter cave fog for improved underground visibility
     * - Distance-based fog accumulation with exponential falloff
     * - Cave depth factor integration for realistic underground atmosphere
     */
    void DoCaveFog(inout vec3 color, float lViewPos) {
        // Calculate cave fog intensity based on depth and distance
        float fog = GetCaveFactor() * (0.6 - 0.6 * exp(- lViewPos * 0.01));
        
        // Apply reduced fog intensity for better underground visibility
        color = mix(color, caveFogColor, fog * 0.7);
    }
#endif

//═══════════════════════════════════════════════════════════════════════════════════════
//                            ATMOSPHERIC FOG SYSTEM MODULE
//═══════════════════════════════════════════════════════════════════════════════════════

#ifdef ATMOSPHERIC_FOG
    #include "/lib/color_schemes/core_color_system.glsl"

    // SRATA: Atmospheric fog starts reducing above this altitude
    // CRFTM: Atmospheric fog continues reducing for this distance in meters
    #ifdef OVERWORLD
        #define atmFogSRATA ATM_FOG_ALTITUDE + 0.1
        #ifndef DISTANT_HORIZONS
            float atmFogCRFTM = 60.0;   // Standard rendering range
        #else
            float atmFogCRFTM = 90.0;   // Extended range for distant horizons
        #endif

        /**
         * Calculates atmospheric fog color based on altitude and sun position
         * @param altitudeFactorRaw: Raw altitude factor [0.0, 1.0]
         * @param VdotS: View direction dot sun vector
         * @return: RGB fog color with day/night blending
         * 
         * Features:
         * - Dynamic day/night fog color transitions
         * - Altitude-based color intensity adjustments
         * - Sun visibility influence on fog appearance
         */
        vec3 GetAtmFogColor(float altitudeFactorRaw, float VdotS) {
            float nightFogMult = 2.5 - 0.625 * max(pow2(pow2(altitudeFactorRaw)), rainFactor);
            float dayNightFogBlend = pow(invNightFactor, 4.0 - VdotS - 2.5 * sunVisibility2);
            return mix(
                nightUpSkyColor * (nightFogMult - dayNightFogBlend * nightFogMult),
                dayDownSkyColor * (0.9 + 0.2 * noonFactor),
                dayNightFogBlend
            );
        }
    #else
        // Non-overworld atmospheric fog parameters
        float atmFogSRATA = 55.1;
        float atmFogCRFTM = 30.0;
    #endif

    /**
     * Calculates altitude-based atmospheric fog factor
     * @param altitude: Current altitude position
     * @return: Fog intensity factor [0.0, 1.0] based on altitude
     * 
     * Features:
     * - Exponential altitude-based fog reduction
     * - Rain factor integration for weather effects
     * - Light shaft compatibility adjustments
     */
    float GetAtmFogAltitudeFactor(float altitude) {
        float altitudeFactor = pow2(1.0 - clamp(altitude - atmFogSRATA, 0.0, atmFogCRFTM) / atmFogCRFTM);
        #ifndef LIGHTSHAFTS_ACTIVE
            altitudeFactor = mix(altitudeFactor, 1.0, rainFactor * 0.2);
        #endif
        return altitudeFactor;
    }

    /**
     * Main atmospheric fog processing function
     * @param color: Input color to be modified [RGB]
     * @param playerPos: Player world position
     * @param lViewPos: View distance for fog calculation
     * @param VdotS: View direction dot sun vector
     * 
     * Features:
     * - Quality-adaptive fog rendering (standard vs distant horizons)
     * - Weather-based fog intensity adjustments
     * - Special biome weather effects integration
     * - Cave fog compatibility and eye brightness modulation
     */
    void DoAtmosphericFog(inout vec3 color, vec3 playerPos, float lViewPos, float VdotS) {
        #ifndef DISTANT_HORIZONS
            // === STANDARD RENDERING MODE ===
            float renDisFactor = min1(192.0 / renderDistance);

            #if ATM_FOG_DISTANCE != 100
                #define ATM_FOG_DISTANCE_M 100.0 / ATM_FOG_DISTANCE;
                renDisFactor *= ATM_FOG_DISTANCE_M;
            #endif

            // Exponential fog calculation with rain factor influence
            float fog = 1.0 - exp(-pow(lViewPos * (0.001 - 0.0007 * rainFactor), 2.0 - rainFactor2) * lViewPos * renDisFactor);
        #else
            // === DISTANT HORIZONS RENDERING MODE ===
            float fog = pow2(1.0 - exp(-max0(lViewPos - 40.0) * (0.7 + 0.7 * rainFactor) / ATM_FOG_DISTANCE));
        #endif
        
        // Apply atmospheric fog multiplier with weather adjustments
        fog *= ATM_FOG_MULT - 0.1 - 0.15 * invRainFactor;

        // Calculate altitude-based fog reduction
        float altitudeFactorRaw = GetAtmFogAltitudeFactor(playerPos.y + cameraPosition.y);
        
        #ifndef DISTANT_HORIZONS
            float altitudeFactor = altitudeFactorRaw * 0.9 + 0.1;  // Standard altitude blending
        #else
            float altitudeFactor = altitudeFactorRaw * 0.8 + 0.2;  // Enhanced altitude blending
        #endif

        #ifdef OVERWORLD
            // Camera altitude influence on fog density
            altitudeFactor *= 1.0 - 0.75 * GetAtmFogAltitudeFactor(cameraPosition.y) * invRainFactor;

            #if defined SPECIAL_BIOME_WEATHER || RAIN_STYLE == 2
                #if RAIN_STYLE == 2
                    float factor = 1.0;  // Universal rain effect
                #else
                    float factor = max(inSnowy, inDry);  // Biome-specific effects
                #endif

                // Enhanced fog intensity calculation for weather effects
                float fogFactor = 4.0;
                #ifdef SPECIAL_BIOME_WEATHER
                    fogFactor += 2.0 * inDry;  // Additional dry biome fog
                #endif

                float fogIntense = pow2(1.0 - exp(-lViewPos * fogFactor / ATM_FOG_DISTANCE));
                fog = mix(fog, fogIntense / altitudeFactor, 0.8 * rainFactor * factor);
            #endif

            #ifdef CAVE_FOG
                // Cave-aware fog adjustment with eye brightness modulation
                fog *= 0.2 + 0.8 * sqrt2(eyeBrightnessM);
                fog *= 1.0 - GetCaveFactor();
            #else
                // Standard eye brightness modulation
                fog *= eyeBrightnessM;
            #endif
        #else
            // Non-overworld fog intensity reduction
            fog *= 0.5;
        #endif

        // Apply final altitude factor
        fog *= altitudeFactor;

        if (fog > 0.0) {
            fog = clamp(fog, 0.0, 1.0);

            #ifdef OVERWORLD
                // Dynamic atmospheric fog color
                vec3 fogColorM = GetAtmFogColor(altitudeFactorRaw, VdotS);
            #else
                // End dimension fog color
                vec3 fogColorM = endSkyColor * 1.5;
            #endif

            // Apply color multipliers
            #ifdef ATM_COLOR_MULTS
                fogColorM *= atmColorMult;
            #endif
            #ifdef MOON_PHASE_INF_ATMOSPHERE
                fogColorM *= moonPhaseInfluence;
            #endif

            // Blend atmospheric fog with existing color
            color = mix(color, fogColorM, fog);
        }
    }
#endif

//═══════════════════════════════════════════════════════════════════════════════════════
//                               LIQUID FOG EFFECTS MODULE
//═══════════════════════════════════════════════════════════════════════════════════════

#include "/lib/atmospherics/particles/liquidEffects.glsl"

/**
 * Processes underwater fog effects with realistic color blending
 * @param color: Input color to be modified [RGB]
 * @param lViewPos: View distance for fog calculation
 * 
 * Features:
 * - Quality-adaptive water fog rendering
 * - Realistic underwater visibility simulation
 * - Water color integration with fog effects
 */
void DoWaterFog(inout vec3 color, float lViewPos) {
    float fog = GetWaterFog(lViewPos);
    color = mix(color, waterFogColor, fog);
}

/**
 * Processes lava fog effects with intense heat distortion
 * @param color: Input color to be modified [RGB]
 * @param lViewPos: View distance for fog calculation
 * 
 * Features:
 * - Intense lava fog with heat-based color scaling
 * - Optional reduced lava fog for better visibility
 * - OpenGL fog integration for compatibility
 */
void DoLavaFog(inout vec3 color, float lViewPos) {
    float fog = (lViewPos * 3.0 - gl_Fog.start) * gl_Fog.scale;

    #ifdef LESS_LAVA_FOG
        fog = sqrt(fog) * 0.4;  // Reduced intensity option
    #endif

    fog = 1.0 - exp(-fog);
    fog = clamp(fog, 0.0, 1.0);
    
    // Intense heat-based color scaling
    color = mix(color, fogColor * 5.0, fog);
}

/**
 * Processes powder snow fog effects for blizzard conditions
 * @param color: Input color to be modified [RGB]
 * @param lViewPos: View distance for fog calculation
 * 
 * Features:
 * - Quadratic fog intensity for realistic snow visibility
 * - Optional reduced intensity for gameplay balance
 * - White-out effect simulation
 */
void DoPowderSnowFog(inout vec3 color, float lViewPos) {
    float fog = lViewPos;

    #ifdef LESS_LAVA_FOG  // Reuse setting for powder snow
        fog = sqrt(fog) * 0.4;
    #endif

    fog *= fog;  // Quadratic falloff
    fog = 1.0 - exp(-fog);
    fog = clamp(fog, 0.0, 1.0);
    
    color = mix(color, fogColor, fog);
}

/**
 * Processes blindness effect fog for status effect
 * @param color: Input color to be modified [RGB]
 * @param lViewPos: View distance for fog calculation
 * 
 * Features:
 * - Blindness status effect integration
 * - Progressive darkening based on distance
 * - Complete vision obstruction at maximum intensity
 */
void DoBlindnessFog(inout vec3 color, float lViewPos) {
    float fog = lViewPos * 0.3 * blindness;
    fog *= fog;  // Quadratic intensity
    fog = 1.0 - exp(-fog);
    fog = clamp(fog, 0.0, 1.0);
    
    // Darken to black for blindness effect
    color = mix(color, vec3(0.0), fog);
}

/**
 * Processes darkness effect fog for sculk-based darkness
 * @param color: Input color to be modified [RGB]
 * @param lViewPos: View distance for fog calculation
 * 
 * Features:
 * - Sculk darkness status effect integration
 * - Exponential darkness accumulation
 * - Multiplicative color reduction for realistic darkness
 */
void DoDarknessFog(inout vec3 color, float lViewPos) {
    float fog = lViewPos * 0.075 * darknessFactor;
    fog *= fog;
    fog *= fog;  // Quartic falloff for intense darkness
    
    // Multiplicative darkening effect
    color *= exp(-fog);
}

//═══════════════════════════════════════════════════════════════════════════════════════
//                              MAIN FOG PROCESSING FUNCTION
//═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Master fog processing function that coordinates all fog effects
 * @param color: Input color to be modified [RGB]
 * @param skyFade: Sky fade factor output [0.0, 1.0]
 * @param lViewPos: View distance for fog calculations
 * @param playerPos: Player world position
 * @param VdotU: View direction dot up vector
 * @param VdotS: View direction dot sun vector
 * @param dither: Temporal dithering value
 * 
 * Processing Order:
 * 1. Cave fog (underground environments)
 * 2. Atmospheric fog (general air particles)
 * 3. Border fog (world boundaries)
 * 4. Liquid fog (water/lava/powder snow submersion)
 * 5. Status effect fog (blindness/darkness)
 * 
 * Features:
 * - Hierarchical fog processing for realistic layering
 * - Liquid medium detection and appropriate fog application
 * - Status effect integration with conditional processing
 */
void DoFog(inout vec3 color, inout float skyFade, float lViewPos, vec3 playerPos, float VdotU, float VdotS, float dither) {
    // Process environmental fog effects in order
    #ifdef CAVE_FOG
        DoCaveFog(color, lViewPos);
    #endif
    
    #ifdef ATMOSPHERIC_FOG
        DoAtmosphericFog(color, playerPos, lViewPos, VdotS);
    #endif
    
    #ifdef BORDER_FOG
        DoBorderFog(color, skyFade, max(length(playerPos.xz), abs(playerPos.y)), VdotU, VdotS, dither);
    #endif

    // Process liquid medium fog effects
    if (isEyeInWater == 1) DoWaterFog(color, lViewPos);
    else if (isEyeInWater == 2) DoLavaFog(color, lViewPos);
    else if (isEyeInWater == 3) DoPowderSnowFog(color, lViewPos);

    // Process status effect fog (conditional)
    if (blindness > 0.00001) DoBlindnessFog(color, lViewPos);
    if (darknessFactor > 0.00001) DoDarknessFog(color, lViewPos);
}

//═══════════════════════════════════════════════════════════════════════════════════════
//                               LEGACY COMPATIBILITY
//═══════════════════════════════════════════════════════════════════════════════════════

// Maintain backward compatibility with existing fog systems
#define GetMainFog DoFog
#define ProcessAtmosphericEffects DoFog
