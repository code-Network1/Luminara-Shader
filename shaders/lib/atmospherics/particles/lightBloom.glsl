/*
 * ═══════════════════════════════════════════════════════════════════════════════════════
 * 
 *                            LIGHT BLOOM EFFECTS MODULE
 *                         Luminara Shader - Advanced Bloom Processing
 * 
 * ═══════════════════════════════════════════════════════════════════════════════════════
 * 
 * Copyright (c) 2025 VcorA Development
 * All rights reserved. Unauthorized reproduction or distribution is prohibited.
 * 
 * This module implements sophisticated light bloom effects that adapt to environmental
 * conditions including weather, time of day, dimension, and underwater states.
 * Provides enhanced visual depth and atmospheric immersion.
 * 
 * ═══════════════════════════════════════════════════════════════════════════════════════
 */

//═══════════════════════════════════════════════════════════════════════════════════════
//                                   DEPENDENCIES
//═══════════════════════════════════════════════════════════════════════════════════════

#ifdef CAVE_FOG
    #include "/lib/atmospherics/particles/depthFactor.glsl"
#endif

//═══════════════════════════════════════════════════════════════════════════════════════
//                              BLOOM INTENSITY CONSTANTS
//═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Environmental bloom intensity modifiers
 * These values control how strongly bloom effects appear in different conditions
 */
const float rainBloomIntensity     = 8.0;    // Enhanced bloom during rainfall
const float nightBloomIntensity    = 3.0;    // Subtle bloom enhancement at night
const float caveBloomIntensity     = 14.0;   // Strong bloom for underground visibility
const float waterBloomIntensity    = 14.0;   // Pronounced underwater bloom effects

// Dimensional bloom configuration
#ifdef BORDER_FOG
    const float netherBloomIntensity = 14.0;  // Enhanced Nether bloom with border fog
#else
    const float netherBloomIntensity = 3.0;   // Standard Nether bloom intensity
#endif

//═══════════════════════════════════════════════════════════════════════════════════════
//                              BLOOM CALCULATION FUNCTION
//═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Calculates adaptive light bloom effects based on viewing distance and environment
 * @param lViewPos: Current viewing distance for bloom calculation
 * @return: Bloom multiplier value (1.0 = no bloom, >1.0 = bloom enhancement)
 */
float GetLightBloom(float lViewPos) 
{
    float bloomEffect;
    float bloomMultiplier;
    
    #ifdef OVERWORLD
        // === OVERWORLD BLOOM PROCESSING ===
        
        // Calculate base bloom using exponential distance falloff
        // Enhanced underwater detection for realistic refraction effects
        float underwaterModifier = 0.02 + 0.04 * float(isEyeInWater == 1);
        bloomEffect = pow2(pow2(1.0 - exp(-lViewPos * underwaterModifier)));
        
        // Determine bloom intensity based on environmental conditions
        if (isEyeInWater != 1) {
            // === SURFACE CONDITIONS ===
            
            // Weather-based bloom enhancement
            float weatherBloom = rainFactor2 * rainBloomIntensity;
            
            // Time-of-day bloom adjustment (stronger at night)
            float timeBloom = nightBloomIntensity * (1.0 - sunFactor);
            
            // Combine weather and time effects with brightness modulation
            bloomMultiplier = (weatherBloom + timeBloom) * eyeBrightnessM;
            
            // Add underground/cave bloom enhancement
            #ifdef CAVE_FOG
                bloomMultiplier += GetCaveFactor() * caveBloomIntensity;
            #endif
            
        } else {
            // === UNDERWATER CONDITIONS ===
            bloomMultiplier = waterBloomIntensity;
        }
        
    #elif defined NETHER
        // === NETHER DIMENSION BLOOM PROCESSING ===
        
        // Calculate Nether-specific viewing distance with limits
        float netherViewLimit = min(renderDistance, NETHER_VIEW_LIMIT);
        
        // Apply cubic falloff for dramatic Nether atmosphere
        bloomEffect = lViewPos / clamp(netherViewLimit, 96.0, 256.0);
        bloomEffect = bloomEffect * bloomEffect * bloomEffect;  // Cubic falloff
        
        // Apply exponential bloom with enhanced intensity
        bloomEffect = 1.0 - exp(-8.0 * bloomEffect);
        
        // Disable bloom when underwater in Nether (rare but handled)
        bloomEffect *= float(isEyeInWater == 0);
        
        // Apply Nether-specific bloom intensity
        bloomMultiplier = netherBloomIntensity;
        
    #endif
    
    // Apply global bloom strength scaling and intensity normalization
    bloomMultiplier *= BLOOM_STRENGTH * 8.33333;
    
    // Return final bloom factor (1.0 + bloom enhancement)
    return 1.0 + bloomEffect * bloomMultiplier;
}

//═══════════════════════════════════════════════════════════════════════════════════════
//                               LEGACY COMPATIBILITY
//═══════════════════════════════════════════════════════════════════════════════════════

// Maintain backward compatibility with existing bloom systems
#define GetBloomFog GetLightBloom
