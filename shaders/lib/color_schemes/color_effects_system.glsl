/**
 * ═══════════════════════════════════════════════════════════════════════════════════════
 *                          LUMINARA SHADER - COLOR EFFECTS SYSTEM
 *                         Advanced Color Modifiers & Environmental Effects
 * ═══════════════════════════════════════════════════════════════════════════════════════
 * 
 * Comprehensive color modification system for dynamic lighting and atmospheric effects.
 * Combines multiple environmental factors to create realistic lighting conditions.
 * 
 * Unified System Components:
 * - Time-based color modifiers (dawn, noon, dusk, night)
 * - Dimensional lighting adjustments (Overworld, Nether, End)
 * - Weather-dependent color shifts (rain, storm, clear)
 * - Moon phase influence calculations
 * - Atmospheric color multipliers
 * 
 * Enhanced by VcorA - Part of Luminara Shader Pack
 * ═══════════════════════════════════════════════════════════════════════════════════════
 */

// ═══════════════════════════════════════════════════════════════════════════════════════
//                           DYNAMIC LIGHT COLOR MODIFIER SYSTEM
// ═══════════════════════════════════════════════════════════════════════════════════════

#ifndef INCLUDE_LIGHT_AND_AMBIENT_MULTIPLIERS
    #define INCLUDE_LIGHT_AND_AMBIENT_MULTIPLIERS

    /**
     * Advanced Light Color Multiplier Calculator
     * 
     * Calculates dynamic light color multipliers based on environmental conditions
     * including time of day, dimension, and weather patterns.
     * 
     * @return vec3 - Normalized light color multiplier (0.0-2.0 range typical)
     * 
     * Algorithm Flow:
     * 1. Determine current dimension context
     * 2. Calculate time-based color temperature shifts
     * 3. Apply weather-based modifications
     * 4. Blend between environmental states
     */
    vec3 GetLightColorMult() {
        vec3 lightColorMult;

        #ifdef OVERWORLD
            // Time-of-Day Light Temperature System
            vec3 morningLightMult = vec3(LIGHT_MORNING_R, LIGHT_MORNING_G, LIGHT_MORNING_B) * LIGHT_MORNING_I;
            vec3 noonLightMult = vec3(LIGHT_NOON_R, LIGHT_NOON_G, LIGHT_NOON_B) * LIGHT_NOON_I;
            vec3 nightLightMult = vec3(LIGHT_NIGHT_R, LIGHT_NIGHT_G, LIGHT_NIGHT_B) * LIGHT_NIGHT_I;
            vec3 rainLightMult = vec3(LIGHT_RAIN_R, LIGHT_RAIN_G, LIGHT_RAIN_B) * LIGHT_RAIN_I;

            // Smooth transitions between lighting periods
            lightColorMult = mix(noonLightMult, morningLightMult, invNoonFactor2);
            lightColorMult = mix(nightLightMult, lightColorMult, sunVisibility2);
            
            // Weather influence on light color temperature
            lightColorMult = mix(lightColorMult, dot(lightColorMult, vec3(0.33333)) * rainLightMult, rainFactor);
            
        #elif defined NETHER
            // Nether Environment: Consistent warm/hellish lighting
            vec3 netherLightMult = vec3(LIGHT_NETHER_R, LIGHT_NETHER_G, LIGHT_NETHER_B) * LIGHT_NETHER_I;
            lightColorMult = netherLightMult;
            
        #elif defined END
            // End Dimension: Ethereal purple-tinted lighting
            vec3 endLightMult = vec3(LIGHT_END_R, LIGHT_END_G, LIGHT_END_B) * LIGHT_END_I;
            lightColorMult = endLightMult;
        #endif

        return lightColorMult;
    }

    /**
     * Advanced Atmospheric Color Multiplier Calculator
     * 
     * Calculates atmospheric color influence for ambient lighting and sky colors.
     * Provides seamless transitions between environmental conditions.
     * 
     * @return vec3 - Atmospheric color multiplier for ambient calculations
     * 
     * Features:
     * - Time-based atmospheric color shifts
     * - Weather-dependent atmospheric tinting
     * - Dimensional atmospheric characteristics
     */
    vec3 GetAtmColorMult() {
        vec3 atmColorMult;

        #ifdef OVERWORLD
            // Atmospheric Color Temperature System
            vec3 morningAtmMult = vec3(ATM_MORNING_R, ATM_MORNING_G, ATM_MORNING_B) * ATM_MORNING_I;
            vec3 noonAtmMult = vec3(ATM_NOON_R, ATM_NOON_G, ATM_NOON_B) * ATM_NOON_I;
            vec3 nightAtmMult = vec3(ATM_NIGHT_R, ATM_NIGHT_G, ATM_NIGHT_B) * ATM_NIGHT_I;
            vec3 rainAtmMult = vec3(ATM_RAIN_R, ATM_RAIN_G, ATM_RAIN_B) * ATM_RAIN_I;

            // Smooth atmospheric transitions
            atmColorMult = mix(noonAtmMult, morningAtmMult, invNoonFactor2);
            atmColorMult = mix(nightAtmMult, atmColorMult, sunVisibility2);
            
            // Weather influence on atmospheric color
            atmColorMult = mix(atmColorMult, dot(atmColorMult, vec3(0.33333)) * rainAtmMult, rainFactor);
            
        #elif defined NETHER
            // Nether Atmosphere: Dense, hellish ambiance
            vec3 netherAtmMult = vec3(ATM_NETHER_R, ATM_NETHER_G, ATM_NETHER_B) * ATM_NETHER_I;
            atmColorMult = netherAtmMult;
            
        #elif defined END
            // End Atmosphere: Void-like, mystical ambiance
            vec3 endAtmMult = vec3(ATM_END_R, ATM_END_G, ATM_END_B) * ATM_END_I;
            atmColorMult = endAtmMult;
        #endif

        return atmColorMult;
    }

    // Global Environmental Color Variables
    // Updated dynamically based on current environmental conditions
    vec3 lightColorMult;       // Primary light source color multiplier
    vec3 atmColorMult;         // Atmospheric/ambient color multiplier  
    vec3 sqrtAtmColorMult;     // Square root of atmospheric multiplier for special calculations

#endif //INCLUDE_LIGHT_AND_AMBIENT_MULTIPLIERS

// ═══════════════════════════════════════════════════════════════════════════════════════
//                            LUNAR INFLUENCE & NIGHT LIGHTING SYSTEM
// ═══════════════════════════════════════════════════════════════════════════════════════

#ifndef INCLUDE_MOON_PHASE_INF
    #define INCLUDE_MOON_PHASE_INF

    #ifdef OVERWORLD
        /**
         * Advanced Moon Phase Lighting Calculator
         * 
         * Provides realistic lunar influence on nighttime lighting conditions.
         * Creates dynamic brightness variations based on moon visibility.
         * 
         * Moon Phase System:
         * - Phase 0: Full Moon (Maximum brightness - MOON_PHASE_FULL)
         * - Phase 1-3: Waxing phases (Partial brightness - MOON_PHASE_PARTIAL)  
         * - Phase 4: New Moon (Minimum brightness - MOON_PHASE_DARK)
         * - Phase 5-7: Waning phases (Partial brightness - MOON_PHASE_PARTIAL)
         * 
         * Technical Implementation:
         * - Only affects nighttime lighting (controlled by sunVisibility2)
         * - Smooth transitions prevent jarring brightness changes
         * - Configurable through shader settings for customization
         */
        float moonPhaseInfluence = mix(
            1.0,  // Day time: No moon influence
            moonPhase == 0 ? MOON_PHASE_FULL :        // Full moon: Maximum brightness
            moonPhase != 4 ? MOON_PHASE_PARTIAL :     // Partial phases: Medium brightness
            MOON_PHASE_DARK,                          // New moon: Minimum brightness
            1.0 - sunVisibility2                      // Apply only during night
        );
    #else
        /**
         * Non-Overworld Dimensions: Static lighting
         * Nether and End dimensions maintain consistent lighting without lunar influence
         */
        const float moonPhaseInfluence = 1.0;
    #endif
    
#endif //INCLUDE_MOON_PHASE_INF

/**
 * ═══════════════════════════════════════════════════════════════════════════════════════
 *                            END OF COLOR EFFECTS SYSTEM
 *                         Enhanced Luminara Shader Pack Component
 * ═══════════════════════════════════════════════════════════════════════════════════════
 * 
 * This enhanced color effects system provides:
 * - Dynamic time-based color temperature adjustments
 * - Dimensional-specific lighting characteristics
 * - Weather-responsive color modifications
 * - Lunar phase influence on nighttime lighting
 * - Smooth environmental transitions
 * - Optimized performance through efficient calculations
 * 
 * Key Features:
 * - Realistic lighting progression throughout day/night cycle
 * - Atmospheric color depth and richness
 * - Environmental immersion through dynamic color shifts
 * - Modular design for easy maintenance and expansion
 * 
 * Maintained by VcorA - Luminara Shader Development Team
 * ═══════════════════════════════════════════════════════════════════════════════════════
 */
