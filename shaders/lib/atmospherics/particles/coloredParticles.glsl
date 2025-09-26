/*
 * ═══════════════════════════════════════════════════════════════════════════════════════
 * 
 *                          COLORED PARTICLES SYSTEM MODULE
 *                         Luminara Shader - Dynamic Light Particles
 * 
 * ═══════════════════════════════════════════════════════════════════════════════════════
 * 
 * Copyright (c) 2025 VcorA Development
 * All rights reserved. Unauthorized reproduction or distribution is prohibited.
 * 
 * This module implements dynamic colored particle effects based on volumetric lighting
 * calculations. It creates atmospheric particle systems that respond to light sources
 * and environmental conditions for enhanced visual immersion.
 * 
 * ═══════════════════════════════════════════════════════════════════════════════════════
 */

//═══════════════════════════════════════════════════════════════════════════════════════
//                         COLORED PARTICLES RENDERING FUNCTION
//═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Generates colored particle effects based on volumetric light calculations
 * @param nPlayerPos: Normalized player view direction vector
 * @param translucentMult: Transparency multiplier for particles behind objects
 * @param lViewPos: Current view distance for primary objects
 * @param lViewPos1: Extended view distance for particle calculations
 * @param dither: Temporal dithering value for smooth particle sampling
 * @return: Final colored particle contribution as RGB vector
 */
vec3 GetColoredParticles(vec3 nPlayerPos, vec3 translucentMult, float lViewPos, float lViewPos1, float dither) 
{
    // Initialize particle accumulator
    vec3 particleAccumulation = vec3(0.0);
    
    // Define sampling parameters for particle ray marching
    const float samplingStepSize = 8.0;
    
    // Calculate maximum sampling distance with performance limits
    float maxSamplingDistance = min(effectiveACLdistance * 0.5, far);
    int totalSamples = int(maxSamplingDistance / samplingStepSize + 0.001);
    
    // Setup ray marching vectors
    vec3 rayStepVector = nPlayerPos * samplingStepSize;
    vec3 currentRayPosition = rayStepVector * dither;
    
    // Main particle sampling loop
    for (int i = 0; i < totalSamples; i++) {
        float currentDistance = length(currentRayPosition);
        
        // Early exit conditions for performance optimization
        if (currentDistance > lViewPos1) break;
        if (any(greaterThan(abs(currentRayPosition * 2.0), vec3(voxelVolumeSize)))) break;
        
        // Transform world position to voxel coordinate space
        vec3 voxelCoordinates = SceneToVoxel(currentRayPosition);
        voxelCoordinates = clamp01(voxelCoordinates / vec3(voxelVolumeSize));
        
        // Sample volumetric light data at current position
        vec4 volumetricLightData = GetLightVolume(voxelCoordinates);
        vec3 lightContribution = volumetricLightData.rgb;
        
        // Calculate distance-based attenuation with quality scaling
        float attenuationDistance = length(
            vec3(
                currentRayPosition.x,
                #if COLORED_LIGHTING_INTERNAL <= 512
                    currentRayPosition.y * 2.0,    // Standard quality scaling
                #elif COLORED_LIGHTING_INTERNAL == 768
                    currentRayPosition.y * 3.0,    // Enhanced quality scaling
                #elif COLORED_LIGHTING_INTERNAL == 1024
                    currentRayPosition.y * 4.0,    // Maximum quality scaling
                #endif
                currentRayPosition.z
            )
        );
        
        // Apply distance-based light falloff
        lightContribution *= max0(1.0 - attenuationDistance / maxSamplingDistance);
        
        // Apply distance-based particle intensity scaling
        lightContribution *= pow2(min1(currentDistance * 0.03125));
        
        // Apply transparency effects for occluded particles
        if (currentDistance > lViewPos) {
            lightContribution *= translucentMult;
        }
        
        // Accumulate particle contribution
        particleAccumulation += lightContribution;
        
        // Advance ray position for next sample
        currentRayPosition += rayStepVector;
    }
    
    // Apply environment-specific particle modifications
    #ifdef NETHER
        particleAccumulation *= netherColor * 5.0;
    #endif
    
    // Apply global visibility modifiers
    particleAccumulation *= 1.0 - maxBlindnessDarkness;
    
    // Normalize and apply gamma correction for final output
    return pow(particleAccumulation / totalSamples, vec3(0.25));
}

//═══════════════════════════════════════════════════════════════════════════════════════
//                               LEGACY COMPATIBILITY
//═══════════════════════════════════════════════════════════════════════════════════════

// Maintain backward compatibility with existing shader code
#define GetColoredLightFog GetColoredParticles
