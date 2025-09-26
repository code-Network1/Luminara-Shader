/*
 * ═══════════════════════════════════════════════════════════════════════════════════════
 * 
 *                           SKY COORDINATE SYSTEM MODULE
 *                         Luminara Shader - Atmosphere System
 * 
 * ═══════════════════════════════════════════════════════════════════════════════════════
 * 
 * Copyright (c) 2025 VcorA Development
 * All rights reserved. Unauthorized reproduction or distribution is prohibited.
 * 
 * This module handles atmospheric coordinate transformations and positioning calculations
 * for volumetric atmospheric effects including cloud formations and weather systems.
 * 
 * ═══════════════════════════════════════════════════════════════════════════════════════
 */

#ifndef INCLUDE_SKY_COORDINATE_SYSTEM
#define INCLUDE_SKY_COORDINATE_SYSTEM

//═══════════════════════════════════════════════════════════════════════════════════════
//                                  CONSTANTS SECTION
//═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Controls the horizontal compression factor for atmospheric layers
 * Lower values = more compressed, Higher values = more stretched
 * @range: 0.01 - 0.1 (recommended: 0.04)
 */
const float atmosphericNarrowness = 0.04;

//═══════════════════════════════════════════════════════════════════════════════════════
//                              COORDINATE TRANSFORMATION FUNCTIONS
//═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Calculates rounded atmospheric coordinates with smoothing
 * @param pos: World position coordinates (2D)
 * @param smoothness: Smoothing factor for coordinate rounding
 *                   - 0.125 for standard atmospheric effects
 *                   - 0.35 for shadow calculations
 * @return: Transformed coordinates scaled for atmospheric sampling
 * @credit: Original algorithm by SixthSurge
 */
vec2 GetRoundedAtmosphericCoord(vec2 pos, float smoothness) 
{
    // Offset coordinates to center grid
    vec2 coord = pos.xy + 0.5;
    
    // Store sign for later restoration
    vec2 signCoord = sign(coord);
    
    // Work with absolute values
    coord = abs(coord) + 1.0;
    
    // Separate integer and fractional parts
    vec2 integerPart, fractionalPart = modf(coord, integerPart);
    
    // Apply smooth interpolation based on smoothness parameter
    fractionalPart = smoothstep(0.5 - smoothness, 0.5 + smoothness, fractionalPart);
    
    // Reconstruct coordinate
    coord = integerPart + fractionalPart;
    
    // Restore sign and apply final scaling
    return (coord - 0.5) * signCoord / 256.0;
}

/**
 * Modifies trace position for atmospheric layer sampling
 * @param tracePos: Original trace position in world space
 * @param altitudeLevel: Altitude level identifier for layer offset
 * @return: Modified position for atmospheric sampling
 */
vec3 ModifyAtmosphericTracePosition(vec3 tracePos, int altitudeLevel) 
{
    // Calculate wind displacement based on time
    float windOffset;
    
    #if CLOUD_SPEED_MULT == 100
        // Use synchronized time for consistent movement
        windOffset = syncedTime;
    #else
        // Use frame time with speed multiplier
        #define CLOUD_SPEED_MULT_M CLOUD_SPEED_MULT * 0.01
        windOffset = frameTimeCounter * CLOUD_SPEED_MULT_M;
    #endif
    
    // Apply wind displacement to X axis
    tracePos.x += windOffset;
    
    // Apply altitude-based offset to Z axis (layer separation)
    tracePos.z += altitudeLevel * 64.0;
    
    // Apply horizontal compression
    tracePos.xz *= atmosphericNarrowness;
    
    return tracePos.xyz;
}

//═══════════════════════════════════════════════════════════════════════════════════════
//                               LEGACY COMPATIBILITY ALIASES
//═══════════════════════════════════════════════════════════════════════════════════════

// Maintain compatibility with existing code
#define GetRoundedCloudCoord GetRoundedAtmosphericCoord
#define ModifyTracePos ModifyAtmosphericTracePosition

#endif // INCLUDE_SKY_COORDINATE_SYSTEM
