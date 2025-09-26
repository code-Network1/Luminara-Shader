/*
 * ═══════════════════════════════════════════════════════════════════════════════════════
 * 
 *                            LIQUID EFFECTS SYSTEM MODULE
 *                         Luminara Shader - Underwater & Liquid Rendering
 * 
 * ═══════════════════════════════════════════════════════════════════════════════════════
 * 
 * Copyright (c) 2025 VcorA Development
 * All rights reserved. Unauthorized reproduction or distribution is prohibited.
 * 
 * This module implements liquid environment effects including underwater fog,
 * distance-based opacity calculations, and quality-adaptive rendering for various
 * liquid mediums including water, lava, and other fluid substances.
 * 
 * ═══════════════════════════════════════════════════════════════════════════════════════
 */

#ifndef INCLUDE_LIQUID_EFFECTS
#define INCLUDE_LIQUID_EFFECTS

//═══════════════════════════════════════════════════════════════════════════════════════
//                            LIQUID EFFECTS CALCULATION FUNCTION
//═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Calculates liquid environment effects based on viewing distance and quality settings
 * @param lViewPos: Current viewing distance for liquid effect calculation
 * @return: Liquid effect intensity [0.0, 1.0] where:
 *          - 0.0 = No liquid effects (clear visibility)
 *          - 1.0 = Maximum liquid effects (heavy fog/distortion)
 * 
 * Features:
 * - Quality-adaptive distance scaling
 * - Enhanced effects with light shaft rendering
 * - Exponential falloff for realistic liquid density
 */
float GetLiquidEffects(float lViewPos) 
{
    // Apply user-defined liquid effect intensity multiplier
    #if WATER_FOG_MULT != 100
        #define WATER_FOG_MULT_M WATER_FOG_MULT * 0.01;
        lViewPos *= WATER_FOG_MULT_M;
    #endif
    
    float liquidDensity;
    
    // Quality-based liquid effect calculation
    #if LIGHTSHAFT_QUALI > 0 && SHADOW_QUALITY > -1
        // === HIGH QUALITY MODE ===
        // Enhanced liquid effects with light shaft integration
        // Shorter effective range with squared falloff for more dramatic effects
        liquidDensity = lViewPos / 48.0;
        liquidDensity *= liquidDensity;  // Quadratic falloff for enhanced realism
        
    #else
        // === STANDARD QUALITY MODE ===
        // Optimized liquid effects for performance
        // Linear falloff with extended range for smoother transitions
        liquidDensity = lViewPos / 32.0;
    #endif
    
    // Apply exponential liquid density calculation
    // This creates realistic liquid medium effects with natural falloff
    return 1.0 - exp(-liquidDensity);
}

//═══════════════════════════════════════════════════════════════════════════════════════
//                               LEGACY COMPATIBILITY
//═══════════════════════════════════════════════════════════════════════════════════════

// Maintain backward compatibility with existing water fog systems
#define GetWaterFog GetLiquidEffects

#endif // INCLUDE_LIQUID_EFFECTS
