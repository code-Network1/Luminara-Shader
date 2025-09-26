/*
═══════════════════════════════════════════════════════════════════════════════════════
                            PBR REFLECTION MODEL SYSTEM
                          Enhanced & Organized by VcorA
═══════════════════════════════════════════════════════════════════════════════════════

  This file implements Physically Based Rendering (PBR) reflection calculations
  using GGX distribution and area light approximation from Horizon Zero Dawn.
  
  Features:
  - GGX area light approximation for realistic reflections
  - Advanced roughness and smoothness calculations
  - Half-vector based reflection modeling
  - Water reflection quality optimization
  - Horizon Zero Dawn inspired algorithms

  Copyright © 2025 VcorA - Enhanced Organization & Comments
  Part of Luminara Shader Pack - PBR Reflection Management System

═══════════════════════════════════════════════════════════════════════════════════════
*/

//═══════════════════════════════════════════════════════════════════════════════════════
//                           GGX AREA LIGHT APPROXIMATION
//                    VcorA Enhanced: Horizon Zero Dawn Algorithm
//═══════════════════════════════════════════════════════════════════════════════════════

/**
 * GGX area light approximation from Horizon Zero Dawn
 * Calculates NoH squared for area lighting with proper sphere light handling
 * 
 * @param radiusTan: Tangent of the light radius
 * @param NoL: Normal dot Light vector
 * @param NoV: Normal dot View vector  
 * @param VoL: View dot Light vector
 * @return: NoH squared value for GGX distribution
 */
float GetNoHSquared(float radiusTan, float NoL, float NoV, float VoL) {
    // Convert radius tangent to cosine for sphere light calculations
    float radiusCos = 1.0 / sqrt(1.0 + radiusTan * radiusTan);

    // Reflection vector calculation - sphere light intersection
    float RoL = 2.0 * NoL * NoV - VoL;
    if (RoL >= radiusCos)
        return 1.0;

    // Tangent space calculations for sphere light approximation
    float rOverLengthT = radiusCos * radiusTan / sqrt(1.0 - RoL * RoL);
    float NoTr = rOverLengthT * (NoV - RoL * NoL);
    float VoTr = rOverLengthT * (2.0 * NoV * NoV - 1.0 - RoL * VoL);

    // Triple product for orthogonal component calculation
    float triple = sqrt(clamp(1.0 - NoL * NoL - NoV * NoV - VoL * VoL + 2.0 * NoL * NoV * VoL, 0.0, 1.0));

    // Binormal space calculations
    float NoBr = rOverLengthT * triple, VoBr = rOverLengthT * (2.0 * triple * NoV);
    float NoLVTr = NoL * radiusCos + NoV + NoTr, VoLVTr = VoL * radiusCos + 1.0 + VoTr;
    
    // Quadratic equation solving for optimal reflection point
    float p = NoBr * VoLVTr, q = NoLVTr * VoLVTr, s = VoBr * NoLVTr;
    float xNum = q * (-0.5 * p + 0.25 * VoBr * NoLVTr);
    float xDenom = p * p + s * ((s - 2.0 * p)) + NoLVTr * ((NoL * radiusCos + NoV) * VoLVTr * VoLVTr +
                   q * (-0.5 * (VoLVTr + VoL * radiusCos) - 0.5));
    
    // Convert to angle space and apply rotation
    float twoX1 = 2.0 * xNum / (xDenom * xDenom + xNum * xNum);
    float sinTheta = twoX1 * xDenom;
    float cosTheta = 1.0 - twoX1 * xNum;
    NoTr = cosTheta * NoTr + sinTheta * NoBr;
    VoTr = cosTheta * VoTr + sinTheta * VoBr;

    // Final half-vector calculation for area light
    float newNoL = NoL * radiusCos + NoTr;
    float newVoL = VoL * radiusCos + VoTr;
    float NoH = NoV + newNoL;
    float HoH = 2.0 * newVoL + 2.0;
    
    return clamp(NoH * NoH / HoH, 0.0, 1.0);
}

//═══════════════════════════════════════════════════════════════════════════════════════
//                              GGX DISTRIBUTION FUNCTION
//                     VcorA Enhanced: Advanced Reflection Calculation
//═══════════════════════════════════════════════════════════════════════════════════════

/**
 * GGX distribution function for physically based reflections
 * Implements microfacet distribution with quality-based optimizations
 * 
 * @param normalM: Modified surface normal
 * @param viewPos: View position vector
 * @param lightVec: Light direction vector
 * @param NdotLmax0: Clamped Normal dot Light (max 0)
 * @param smoothnessG: Surface smoothness parameter [0.0, 1.0]
 * @return: GGX distribution value for specular reflection
 */
float GGX(vec3 normalM, vec3 viewPos, vec3 lightVec, float NdotLmax0, float smoothnessG) {
    // Smoothness adjustment - square root for more linear response
    smoothnessG = sqrt1(smoothnessG * 0.9 + 0.1);
    float roughnessP = (1.35 - smoothnessG);                    // Primary roughness calculation
    float roughness = pow2(pow2(roughnessP));                   // Fourth power for smooth falloff

    // Half-vector calculation - bisector of view and light vectors
    vec3 halfVec = normalize(lightVec - viewPos);

    // Dot product calculations for GGX distribution
    float dotLH = clamp(dot(halfVec, lightVec), 0.0, 1.0);     // Light-Half angle
    float dotNV = dot(normalM, -viewPos);                       // Normal-View angle

    // Quality-based Normal-Half calculation
    #if WATER_REFLECT_QUALITY >= 2
        // High quality: Use area light approximation
        float dotNH = GetNoHSquared(0.01, NdotLmax0, dotNV, dot(-viewPos, lightVec));
    #else
        // Standard quality: Simplified calculation
        float dotNH = pow2(min1(2.0 * NdotLmax0 * dotNV * length(halfVec) - dot(-viewPos, lightVec)));
    #endif

    // GGX distribution denominator calculation
    float denom = dotNH * roughness - dotNH + 1.0;
    float D = roughness / (3.141592653589793 * pow2(denom));   // Distribution term
    
    //═══════════════════════════════════════════════════════════════════════════════════════
    //                            FRESNEL TERM CALCULATION
    //                   VcorA Enhanced: Schlick's Fresnel Approximation
    //═══════════════════════════════════════════════════════════════════════════════════════
    
    float f0 = 0.05;                                          // Base reflectance at normal incidence
    // Schlick's approximation for Fresnel term
    float F = exp2((-5.55473 * dotLH - 6.98316) * dotLH) * (1.0 - f0) + f0;

    //═══════════════════════════════════════════════════════════════════════════════════════
    //                           FINAL SPECULAR CALCULATION
    //                    VcorA Enhanced: Complete BRDF Implementation
    //═══════════════════════════════════════════════════════════════════════════════════════
    
    // Enhanced normal-light calculation for better material response
    float NdotLmax0M = sqrt3(NdotLmax0 * max0(dot(normal, lightVec)));
    
    // Complete BRDF calculation: Distribution * Fresnel / Geometry
    float specular = max0(NdotLmax0M * D * F / pow2(dotLH));
    
    // Tone mapping to prevent over-bright highlights
    specular = specular / (0.125 * specular + 1.0);

    return specular;                                          // Return final specular contribution
}

/*
═══════════════════════════════════════════════════════════════════════════════════════
                             END OF PBR REFLECTION MODEL
                        Enhanced & Organized by VcorA © 2025
═══════════════════════════════════════════════════════════════════════════════════════
*/
