/**
 * ═══════════════════════════════════════════════════════════════════════════════════════
 *                        LUMINARA SHADER - CORE COLOR SYSTEM
 *                    Comprehensive Environmental Color Management Suite
 * ═══════════════════════════════════════════════════════════════════════════════════════
 * 
 * Advanced color management system combining multiple environmental factors for
 * realistic and immersive visual rendering across all dimensions and weather conditions.
 * 
 * Integrated Color Systems:
 * - Sky Color Dynamics (time-based progression)
 * - Cloud Color Rendering (weather-responsive)  
 * - Light & Ambient Color Calculation (dimensional variation)
 * - Environmental Weather Effects (rain, snow, biome-specific)
 * - Time-of-Day Color Temperature Shifts
 * 
 * Key Features:
 * - Seamless day/night transitions
 * - Weather-responsive color adaptation
 * - Biome-specific environmental modifiers
 * - Dimensional color characteristics
 * - Performance-optimized calculations
 * 
 * Enhanced by VcorA - Part of Luminara Shader Pack
 * ═══════════════════════════════════════════════════════════════════════════════════════
 */

// ═══════════════════════════════════════════════════════════════════════════════════════
//                           DYNAMIC SKY COLOR RENDERING SYSTEM
// ═══════════════════════════════════════════════════════════════════════════════════════

#ifndef INCLUDE_SKY_COLORS
    #define INCLUDE_SKY_COLORS

    #if defined OVERWORLD
        /**
         * Advanced Sky Color Processing Pipeline
         * 
         * Processes raw sky color data through gamma correction and environmental
         * modifiers to create realistic sky appearance under various conditions.
         */
        
        // Foundation: Gamma-corrected sky color base
        vec3 skyColorSqrt = sqrt(skyColor);
        
        /**
         * Thunderstorm Sky Color Protection
         * Prevents sky color from reaching complete darkness during severe weather
         */
        float invRainStrength2 = (1.0 - rainStrength) * (1.0 - rainStrength);
        vec3 skyColorM = mix(max(skyColorSqrt, vec3(0.63, 0.67, 0.73)), skyColorSqrt, invRainStrength2);
        vec3 skyColorM2 = mix(max(skyColor, sunFactor * vec3(0.265, 0.295, 0.35)), skyColor, invRainStrength2);

        /**
         * Biome-Specific Weather Modifiers
         * Adjusts sky colors based on local environmental conditions
         */
        #ifdef SPECIAL_BIOME_WEATHER
            vec3 nmscSnowM = inSnowy * vec3(-0.3, 0.05, 0.2);    // Snow biome: Cool blue shift
            vec3 nmscDryM = inDry * vec3(-0.3);                  // Desert biome: Warm desaturation
            vec3 ndscSnowM = inSnowy * vec3(-0.25, -0.01, 0.25); // Snow biome lower sky
            vec3 ndscDryM = inDry * vec3(-0.05, -0.09, -0.1);    // Desert biome lower sky
        #else
            vec3 nmscSnowM = vec3(0.0), nmscDryM = vec3(0.0), ndscSnowM = vec3(0.0), ndscDryM = vec3(0.0);
        #endif
        
        /**
         * Advanced Rain Style Color Modifications
         * Style 2: Enhanced precipitation color effects
         */
        #if RAIN_STYLE == 2
            vec3 nmscRainMP = vec3(-0.15, 0.025, 0.1);    // Rain color shift for upper sky
            vec3 ndscRainMP = vec3(-0.125, -0.005, 0.125); // Rain color shift for lower sky
            #ifdef SPECIAL_BIOME_WEATHER
                vec3 nmscRainM = inRainy * nmscRainMP;        // Biome-specific rain upper sky
                vec3 ndscRainM = inRainy * ndscRainMP;        // Biome-specific rain lower sky
            #else
                vec3 nmscRainM = nmscRainMP;                  // Global rain upper sky
                vec3 ndscRainM = ndscRainMP;                  // Global rain lower sky
            #endif
        #else
            vec3 nmscRainM = vec3(0.0), ndscRainM = vec3(0.0);
        #endif
        
        /**
         * Weather Color Modifiers
         * Base weather influence calculations for sky color temperature
         */
        vec3 nmscWeatherM = vec3(-0.1, -0.4, -0.6) + vec3(0.0, 0.06, 0.12) * noonFactor;
        vec3 ndscWeatherM = vec3(-0.15, -0.3, -0.42) + vec3(0.0, 0.02, 0.08) * noonFactor;

        /**
         * Time-Based Sky Color Calculations
         * Creates realistic color progression throughout the day/night cycle
         */
        
        // Noon Sky Colors: Bright, saturated, clear conditions
        vec3 noonUpSkyColor = pow(skyColorM, vec3(2.9));
        vec3 noonMiddleSkyColor = skyColorM * (vec3(1.15) + rainFactor * (nmscWeatherM + nmscRainM + nmscSnowM + nmscDryM))
                                + noonUpSkyColor * 0.6;
        vec3 noonDownSkyColor = skyColorM * (vec3(0.9) + rainFactor * (ndscWeatherM + ndscRainM + ndscSnowM + ndscDryM))
                              + noonUpSkyColor * 0.25;

        // Sunset/Sunrise Sky Colors: Warm, dramatic color transitions
        vec3 sunsetUpSkyColor = skyColorM2 * (vec3(0.8, 0.58, 0.58) + vec3(0.1, 0.2, 0.35) * rainFactor2);
        vec3 sunsetMiddleSkyColor = skyColorM2 * (vec3(1.8, 1.3, 1.2) + vec3(0.15, 0.25, -0.05) * rainFactor2);
        vec3 sunsetDownSkyColorP = vec3(1.45, 0.86, 0.5) - vec3(0.8, 0.3, 0.0) * rainFactor;
        vec3 sunsetDownSkyColor = sunsetDownSkyColorP * 0.5 + 0.25 * sunsetMiddleSkyColor;

        // Day Sky Colors: Smooth interpolation between noon and sunset
        vec3 dayUpSkyColor = mix(noonUpSkyColor, sunsetUpSkyColor, invNoonFactor2);
        vec3 dayMiddleSkyColor = mix(noonMiddleSkyColor, sunsetMiddleSkyColor, invNoonFactor2);
        vec3 dayDownSkyColor = mix(noonDownSkyColor, sunsetDownSkyColor, invNoonFactor2);

        /**
         * Night Sky Colors: Deep, atmospheric nighttime appearance
         * Incorporates subtle variations for realism
         */
        vec3 nightColFactor = vec3(0.07, 0.14, 0.24) * (1.0 - 0.5 * rainFactor) + skyColor;
        vec3 nightUpSkyColor = pow(nightColFactor, vec3(0.90)) * 0.4;
        vec3 nightMiddleSkyColor = sqrt(nightUpSkyColor) * 0.68;
        vec3 nightDownSkyColor = nightMiddleSkyColor * vec3(0.82, 0.82, 0.88);
    #endif

#endif //INCLUDE_SKY_COLORS

// ═══════════════════════════════════════════════════════════════════════════════════════
//                        ADVANCED LIGHTING & AMBIENT COLOR SYSTEM
// ═══════════════════════════════════════════════════════════════════════════════════════

#ifndef INCLUDE_LIGHT_AND_AMBIENT_COLORS
    #define INCLUDE_LIGHT_AND_AMBIENT_COLORS

    #if defined OVERWORLD
        
        /**
         * Noon Clear Weather Lighting
         * Establishes baseline lighting conditions for optimal visibility
         */
        #ifndef COMPOSITE
            vec3 noonClearLightColor = vec3(0.7, 0.55, 0.4) * 1.9;    // Ground and cloud lighting
        #else
            vec3 noonClearLightColor = vec3(0.4, 0.7, 1.4);           // Light shaft rendering
        #endif
        vec3 noonClearAmbientColor = pow(skyColor, vec3(0.65)) * 0.85;

        /**
         * Sunset Clear Weather Lighting
         * Creates dramatic warm lighting during golden hour
         */
        #ifndef COMPOSITE
            vec3 sunsetClearLightColor = pow(vec3(0.64, 0.45, 0.3), vec3(1.5 + invNoonFactor)) * 5.0;
        #else
            vec3 sunsetClearLightColor = pow(vec3(0.62, 0.39, 0.24), vec3(1.5 + invNoonFactor)) * 6.8;
        #endif
        vec3 sunsetClearAmbientColor = noonClearAmbientColor * vec3(1.21, 0.92, 0.76) * 0.95;

        /**
         * Night Clear Weather Lighting
         * Provides subtle moonlight illumination with brightness adjustment
         */
        #if !defined COMPOSITE && !defined DEFERRED1
            vec3 nightClearLightColor = vec3(0.15, 0.14, 0.20) * (0.4 + vsBrightness * 0.4);
        #elif defined DEFERRED1
            vec3 nightClearLightColor = vec3(0.11, 0.14, 0.20);
        #else
            vec3 nightClearLightColor = vec3(0.07, 0.12, 0.27);
        #endif
        vec3 nightClearAmbientColor = vec3(0.09, 0.12, 0.17) * (1.55 + vsBrightness * 0.77);

        /**
         * Biome-Specific Lighting Modifiers
         * Fine-tunes lighting based on local environmental conditions
         */
        #ifdef SPECIAL_BIOME_WEATHER
            vec3 drlcSnowM = inSnowy * vec3(-0.06, 0.0, 0.04);    // Snow biome: Cool light shift
            vec3 drlcDryM = inDry * vec3(0.0, -0.03, -0.05);      // Desert biome: Warm light shift
        #else
            vec3 drlcSnowM = vec3(0.0), drlcDryM = vec3(0.0);
        #endif
        
        /**
         * Advanced Rain Lighting System (Style 2)
         * Provides enhanced precipitation lighting effects
         */
        #if RAIN_STYLE == 2
            vec3 drlcRainMP = vec3(-0.03, 0.0, 0.02);
            #ifdef SPECIAL_BIOME_WEATHER
                vec3 drlcRainM = inRainy * drlcRainMP;             // Biome-specific rain lighting
            #else
                vec3 drlcRainM = drlcRainMP;                       // Global rain lighting
            #endif
        #else
            vec3 drlcRainM = vec3(0.0);
        #endif

        /**
         * Rainy Weather Lighting Conditions
         * Creates overcast, diffused lighting during precipitation
         */
        vec3 dayRainLightColor = vec3(0.21, 0.16, 0.13) * 0.85 + noonFactor * vec3(0.0, 0.02, 0.06)
                               + rainFactor * (drlcRainM + drlcSnowM + drlcDryM);
        vec3 dayRainAmbientColor = vec3(0.2, 0.2, 0.25) * (1.8 + 0.5 * vsBrightness);

        vec3 nightRainLightColor = vec3(0.03, 0.035, 0.05) * (0.5 + 0.5 * vsBrightness);
        vec3 nightRainAmbientColor = vec3(0.16, 0.20, 0.3) * (0.75 + 0.6 * vsBrightness);

        /**
         * Dynamic Color Blending & Interpolation
         * Seamlessly transitions between lighting conditions
         */
        #ifndef COMPOSITE
            float noonFactorDM = noonFactor;                      // Ground and cloud factor
        #else
            float noonFactorDM = noonFactor * noonFactor;         // Light shaft factor (squared for emphasis)
        #endif
        
        // Day-time color interpolation
        vec3 dayLightColor = mix(sunsetClearLightColor, noonClearLightColor, noonFactorDM);
        vec3 dayAmbientColor = mix(sunsetClearAmbientColor, noonClearAmbientColor, noonFactorDM);

        // Clear weather color blending
        vec3 clearLightColor = mix(nightClearLightColor, dayLightColor, sunVisibility2);
        vec3 clearAmbientColor = mix(nightClearAmbientColor, dayAmbientColor, sunVisibility2);

        // Rainy weather color blending
        vec3 rainLightColor = mix(nightRainLightColor, dayRainLightColor, sunVisibility2) * 2.5;
        vec3 rainAmbientColor = mix(nightRainAmbientColor, dayRainAmbientColor, sunVisibility2);

        // Final lighting color calculation
        vec3 lightColor = mix(clearLightColor, rainLightColor, rainFactor);
        vec3 ambientColor = mix(clearAmbientColor, rainAmbientColor, rainFactor);
        
    #elif defined NETHER
        /**
         * Nether Dimension Lighting
         * Provides hellish, fire-based environmental lighting
         */
        vec3 lightColor = vec3(0.0);
        vec3 ambientColor = (netherColor + 0.5 * lavaLightColor) * (0.9 + 0.45 * vsBrightness);
        
    #elif defined END
        /**
         * End Dimension Lighting
         * Creates ethereal, otherworldly lighting atmosphere
         */
        vec3 endLightColor = vec3(0.68, 0.51, 1.07);
        float endLightBalancer = 0.2 * vsBrightness;
        
        vec3 lightColor = endLightColor * (0.35 - endLightBalancer);
        vec3 ambientColor = endLightColor * (0.2 + endLightBalancer);
    #endif

#endif //INCLUDE_LIGHT_AND_AMBIENT_COLORS

// ═══════════════════════════════════════════════════════════════════════════════════════
//                           ADVANCED CLOUD COLOR RENDERING SYSTEM
//                      (Depends on lightColor & ambientColor calculations)
// ═══════════════════════════════════════════════════════════════════════════════════════

#ifndef INCLUDE_CLOUD_COLORS
    #define INCLUDE_CLOUD_COLORS

    #if defined OVERWORLD
        /**
         * Weather-Responsive Cloud Color System
         * Creates dynamic cloud appearance based on environmental conditions
         */
        
        // Rain Cloud Color: Atmospheric blending between day and night sky
        vec3 cloudRainColor = mix(nightMiddleSkyColor, dayMiddleSkyColor, sunFactor);

        /**
         * Ambient Cloud Color Calculation
         * Provides base illumination for cloud surfaces with weather responsiveness
         */
        vec3 cloudAmbientColor = mix(
            ambientColor * (sunVisibility2 * (0.55 + 0.1 * noonFactor) + 0.35), 
            cloudRainColor * 0.5, 
            rainFactor
        );

        /**
         * Direct Cloud Light Color Calculation  
         * Handles direct lighting on cloud surfaces with time-based enhancement
         */
        vec3 cloudLightColor = mix(
            lightColor * (0.9 + 0.2 * noonFactor), 
            cloudRainColor * 0.25, 
            noonFactor * rainFactor
        );
    #else
        /**
         * Non-Overworld Dimension Cloud Colors
         * Provides consistent cloud appearance for Nether and End dimensions
         */
        vec3 cloudRainColor = vec3(0.4, 0.3, 0.3);              // Neutral grayish color
        vec3 cloudAmbientColor = ambientColor * 0.7;            // Reduced ambient influence
        vec3 cloudLightColor = lightColor * 0.8;                // Reduced direct lighting
    #endif

#endif //INCLUDE_CLOUD_COLORS

/**
 * ═══════════════════════════════════════════════════════════════════════════════════════
 *                            END OF CORE COLOR SYSTEM
 *                         Enhanced Luminara Shader Pack Component
 * ═══════════════════════════════════════════════════════════════════════════════════════
 * 
 * This comprehensive core color system provides:
 * 
 * Sky Color Management:
 * - Realistic day/night progression with smooth transitions
 * - Weather-responsive color adaptation (rain, storms, clear)
 * - Biome-specific environmental modifiers
 * - Advanced gamma correction and color processing
 * 
 * Lighting System:
 * - Time-based color temperature adjustments
 * - Dimensional lighting characteristics (Overworld, Nether, End)
 * - Weather-dependent light quality changes
 * - Performance-optimized calculation paths
 * 
 * Cloud Rendering:
 * - Dynamic cloud color based on atmospheric conditions
 * - Separate ambient and direct lighting for realistic depth
 * - Weather-responsive cloud appearance
 * - Cross-dimensional compatibility
 * 
 * Key Features:
 * - Seamless environmental transitions
 * - Realistic atmospheric simulation
 * - Optimized performance through efficient algorithms
 * - Modular design for easy maintenance and expansion
 * - Comprehensive weather and time-of-day support
 * 
 * Maintained by VcorA - Luminara Shader Development Team
 * ═══════════════════════════════════════════════════════════════════════════════════════
 */
