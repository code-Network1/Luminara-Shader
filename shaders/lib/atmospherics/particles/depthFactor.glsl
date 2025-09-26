/*
 * ═══════════════════════════════════════════════════════════════════════════════════════
 * 
 *                           DEPTH FACTOR CALCULATION MODULE
 *                         Luminara Shader - Environmental Depth Analysis
 * 
 * ═══════════════════════════════════════════════════════════════════════════════════════
 * 
 * Copyright (c) 2025 VcorA Development
 * All rights reserved. Unauthorized reproduction or distribution is prohibited.
 * 
 * This module calculates environmental depth factors based on camera position relative
 * to world altitude levels. Used for cave detection, underground effects, and depth-based
 * atmospheric adjustments throughout the rendering pipeline.
 * 
 * ═══════════════════════════════════════════════════════════════════════════════════════
 */

#ifndef INCLUDE_DEPTH_FACTOR
#define INCLUDE_DEPTH_FACTOR

//═══════════════════════════════════════════════════════════════════════════════════════
//                            DEPTH CALCULATION FUNCTIONS
//═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Calculates environmental depth factor based on camera altitude
 * @return: Depth factor value [0.0, 1.0] where:
 *          - 0.0 = Surface level or above ocean altitude
 *          - 1.0 = Maximum underground depth with full cave effects
 * 
 * The calculation considers:
 * - Current camera Y position relative to ocean altitude
 * - Eye brightness modulation for lighting conditions
 * - Smooth transitions between surface and underground areas
 */
float GetDepthFactor() 
{
    // Calculate normalized depth based on camera position relative to ocean level
    float normalizedDepth = 1.0 - cameraPosition.y / oceanAltitude;
    
    // Apply eye brightness modulation to prevent extreme values in bright areas
    float brightnessModulation = 1.0 - eyeBrightnessM;
    
    // Clamp result to valid range and apply brightness constraints
    return clamp(normalizedDepth, 0.0, brightnessModulation);
}

//═══════════════════════════════════════════════════════════════════════════════════════
//                               LEGACY COMPATIBILITY
//═══════════════════════════════════════════════════════════════════════════════════════

// Maintain backward compatibility with existing cave detection systems
#define GetCaveFactor GetDepthFactor

#endif // INCLUDE_DEPTH_FACTOR
