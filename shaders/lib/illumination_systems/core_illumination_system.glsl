/*
█████████████████████████████████████████████████████████████████████████████████████████
█                                                                                       █
█    ██████╗ ██████╗ ██████╗ ███████╗    ██╗██╗     ██╗     ██╗   ██╗███╗   ███╗       █
█   ██╔════╝██╔═══██╗██╔══██╗██╔════╝    ██║██║     ██║     ██║   ██║████╗ ████║       █
█   ██║     ██║   ██║██████╔╝█████╗      ██║██║     ██║     ██║   ██║██╔████╔██║       █
█   ██║     ██║   ██║██╔══██╗██╔══╝      ██║██║     ██║     ██║   ██║██║╚██╔╝██║       █
█   ╚██████╗╚██████╔╝██║  ██║███████╗    ██║███████╗███████╗╚██████╔╝██║ ╚═╝ ██║       █
█    ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝    ╚═╝╚══════╝╚══════╝ ╚═════╝ ╚═╝     ╚═╝       █
█                                                                                       █
█              ██╗███╗   ██╗ █████╗ ████████╗██╗ ██████╗ ███╗   ██╗                   █
█              ██║████╗  ██║██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║                   █
█              ██║██╔██╗ ██║███████║   ██║   ██║██║   ██║██╔██╗ ██║                   █
█              ██║██║╚██╗██║██╔══██║   ██║   ██║██║   ██║██║╚██╗██║                   █
█              ██║██║ ╚████║██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║                   █
█              ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝                   █
█                                                                                       █
█                              ███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗   █
█                              ██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝████╗ ████║   █
█                              ███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██╔████╔██║   █
█                              ╚════██║  ╚██╔╝  ╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║   █
█                              ███████║   ██║   ███████║   ██║   ███████╗██║ ╚═╝ ██║   █
█                              ╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝   █
█                                                                                       █
█████████████████████████████████████████████████████████████████████████████████████████

    ╔═══════════════════════════════════════════════════════════════════════════════════╗
    ║                       LUMINARA SHADER PACK - CORE ILLUMINATION                     ║
    ║                                                                                   ║
    ║  Author: VcorA                                                                    ║
    ║  Version: Enhanced Edition 2025                                                  ║
    ║  License: Enhanced & Restructured by VcorA                                       ║
    ║                                                                                   ║
    ║  Description: Advanced lighting and illumination system featuring:               ║
    ║  • Physical Based Rendering (PBR) with GGX distribution                          ║
    ║  • Advanced shadow mapping with TAA filtering                                    ║
    ║  • Dynamic ambient occlusion and directional shading                             ║
    ║  • Subsurface scattering for translucent materials                               ║
    ║  • Colored lighting with blocklight management                                   ║
    ║  • Volumetric and atmospheric lighting effects                                   ║
    ║                                                                                   ║
    ╚═══════════════════════════════════════════════════════════════════════════════════╝

*/

// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
// ▓                             EXTERNAL DEPENDENCIES                                ▓
// ▓                        VcorA - Modular Shader Architecture                        ▓
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

// Core color management system
#include "/lib/color_schemes/core_color_system.glsl"

// Physical Based Rendering reflection model
#include "/lib/illumination_systems/pbr_reflection_model.glsl"

// Conditional shadow sampling for quality optimization
#if SHADOW_QUALITY > -1 && (defined OVERWORLD || defined END)
    #include "/lib/illumination_systems/shadow_sampling.glsl"
#endif

// Advanced cloud shadows for atmospheric realism
#if defined CLOUDS_REIMAGINED && defined CLOUD_SHADOWS
    #include "/lib/atmospherics/atmosphere/skyCoord.glsl"
#endif

// Dynamic light color multiplication system
#ifdef LIGHT_COLOR_MULTS
    #include "/lib/color_schemes/color_effects_system.glsl"
#endif

// Moon phase influence on lighting and atmosphere
#if defined MOON_PHASE_INF_LIGHT || defined MOON_PHASE_INF_REFLECTION || defined MOON_PHASE_INF_ATMOSPHERE
    #include "/lib/color_schemes/color_effects_system.glsl"
#endif

// Advanced colored lighting with voxelization
#if COLORED_LIGHTING_INTERNAL > 0
    #include "/lib/effects/effects_unified.glsl"
#endif

// Pixelation effects for artistic rendering
#ifdef DO_PIXELATION_EFFECTS
    #include "/lib/effects/effects_unified.glsl"
#endif

// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
// ▓                            GLOBAL ILLUMINATION VARIABLES                         ▓
// ▓                         VcorA - Pre-computed Light Data                          ▓
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

/**
 * ╔════════════════════════════════════════════════════════════════════════════════════╗
 * ║ HIGHLIGHT COLOR CALCULATION                                                        ║
 * ║ Computes the base color for specular highlights based on:                         ║
 * ║ • Sun visibility and atmospheric conditions                                        ║
 * ║ • Weather factor (rain reduces highlights)                                        ║
 * ║ • Gamma-corrected light color normalization                                       ║
 * ╚════════════════════════════════════════════════════════════════════════════════════╝
 */
vec3 highlightColor = normalize(pow(lightColor, vec3(0.37))) * 
                     (0.3 + 1.5 * sunVisibility2) * 
                     (1.0 - 0.85 * rainFactor);

// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
// ▓                              MAIN LIGHTING FUNCTION                              ▓
// ▓                          VcorA - Advanced Illumination Engine                    ▓
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

/**
 * ╔════════════════════════════════════════════════════════════════════════════════════╗
 * ║                              DoLighting - MASTER FUNCTION                         ║
 * ╠════════════════════════════════════════════════════════════════════════════════════╣
 * ║                                                                                    ║
 * ║ This is the core illumination function that handles all aspects of lighting       ║
 * ║ calculation for the Luminara Shader Pack. It processes:                             ║
 * ║                                                                                    ║
 * ║ LIGHTING COMPONENTS:                                                               ║
 * ║ ├─ Shadow calculation and filtering                                                ║
 * ║ ├─ Ambient occlusion processing                                                   ║
 * ║ ├─ Directional lighting with normal mapping                                       ║
 * ║ ├─ Blocklight (torch/lava) color management                                       ║
 * ║ ├─ Subsurface scattering for translucent materials                                ║
 * ║ ├─ Specular highlights with PBR model                                             ║
 * ║ └─ Atmospheric and volumetric effects                                             ║
 * ║                                                                                    ║
 * ║ PARAMETERS:                                                                        ║
 * ║ ├─ color [INOUT]         : Surface color to be illuminated                        ║
 * ║ ├─ shadowMult [INOUT]    : Shadow multiplier for shadow effects                   ║
 * ║ ├─ playerPos            : World position relative to player                       ║
 * ║ ├─ viewPos              : View space position vector                              ║
 * ║ ├─ lViewPos             : Length/distance of view position                        ║
 * ║ ├─ geoNormal            : Geometric surface normal                                ║
 * ║ ├─ normalM              : Modified normal for lighting calculations               ║
 * ║ ├─ dither               : Noise value for dithering effects                      ║
 * ║ ├─ worldGeoNormal       : World-space geometric normal                           ║
 * ║ ├─ lightmap             : Minecraft lightmap coordinates [sky, block]            ║
 * ║ ├─ noSmoothLighting     : Flag to disable smooth lighting                        ║
 * ║ ├─ noDirectionalShading : Flag to disable directional shading                    ║
 * ║ ├─ noVanillaAO          : Flag to disable vanilla ambient occlusion              ║
 * ║ ├─ centerShadowBias     : Flag for center-based shadow bias                      ║
 * ║ ├─ subsurfaceMode       : Subsurface scattering mode [0=none, 1=leaves, 2=trans]║
 * ║ ├─ smoothnessG          : Surface smoothness for reflections [0.0-1.0]           ║
 * ║ ├─ highlightMult        : Specular highlight intensity multiplier                ║
 * ║ └─ emission             : Surface emission/glow intensity                        ║
 * ║                                                                                    ║
 * ║ AUTHOR: VcorA - Enhanced Lighting System                                          ║
 * ║ VERSION: Luminara Enhanced Edition 2025                                             ║
 * ║                                                                                    ║
 * ╚════════════════════════════════════════════════════════════════════════════════════╝
 */
void DoLighting(inout vec4 color, inout vec3 shadowMult, vec3 playerPos, vec3 viewPos, 
                float lViewPos, vec3 geoNormal, vec3 normalM, float dither,
                vec3 worldGeoNormal, vec2 lightmap, bool noSmoothLighting, 
                bool noDirectionalShading, bool noVanillaAO, bool centerShadowBias, 
                int subsurfaceMode, float smoothnessG, float highlightMult, float emission) {

    // ██████████████████████████████████████████████████████████████████████████████████
    // █                         STAGE 1: PIXELATION PREPROCESSING                     █
    // █                      VcorA - Artistic Rendering Effects                       █
    // ██████████████████████████████████████████████████████████████████████████████████
    
    #ifdef DO_PIXELATION_EFFECTS
        // Calculate texel offset for consistent pixelation across frames
        vec2 pixelationOffset = ComputeTexelOffset(tex, texCoord);

        #ifdef PIXELATED_SHADOWS
            // Apply pixelation to player position for shadow consistency
            vec3 playerPosPixelated = TexelSnap(playerPos, pixelationOffset);

            // Special handling for boat entities to prevent visual glitches
            #ifdef GBUFFERS_ENTITIES
                if (entityId == 50076) { // Boat entity ID
                    playerPosPixelated.y += 0.38; // Boat height compensation
                }
            #endif
            
            // Fix dark bottom pixels on grounded foliage
            #ifdef GBUFFERS_TERRAIN
                if (subsurfaceMode == 1) { // Foliage subsurface mode
                    playerPosPixelated.y += 0.05; // Slight height offset
                }
            #endif
        #endif
        
        #ifdef PIXELATED_BLOCKLIGHT
            if (!noSmoothLighting) {
                // Apply pixelation to lighting coordinates
                lightmap = clamp(TexelSnap(lightmap, pixelationOffset), 0.0, 1.0);
                lViewPos = TexelSnap(lViewPos, pixelationOffset);
            }
        #endif
    #endif

    // ██████████████████████████████████████████████████████████████████████████████████
    // █                       STAGE 2: CORE VARIABLE INITIALIZATION                   █
    // █                        VcorA - Foundation Calculations                        █
    // ██████████████████████████████████████████████████████████████████████████████████
    
    // Pre-compute frequently used lightmap values for performance
    float lightmapY2 = pow2(lightmap.y);                    // Squared sky light for curves
    float lightmapYM = smoothstep1(lightmap.y);             // Smooth sky light transition
    
    // Initialize lighting accumulators
    float subsurfaceHighlight = 0.0;                        // Subsurface scattering accumulator
    float ambientMult = 1.0;                                 // Ambient light multiplier
    vec3 lightColorM = lightColor;                           // Working copy of light color
    vec3 ambientColorM = ambientColor;                       // Working copy of ambient color
    vec3 nViewPos = normalize(viewPos);                      // Normalized view direction

    // Dynamic light color adjustments (time of day, weather, etc.)
    #if defined LIGHT_COLOR_MULTS && !defined GBUFFERS_WATER
        lightColorMult = GetLightColorMult();
    #endif

    // Calculate sky light shadow factor based on dimension
    #ifdef OVERWORLD
        float skyLightShadowMult = pow2(pow2(lightmapY2));   // Fourth power for smooth falloff
    #else
        float skyLightShadowMult = 1.0;                      // No sky shadows in Nether/End
    #endif

    // Pre-calculate normal vectors for directional effects
    #if defined SIDE_SHADOWING || defined DIRECTIONAL_SHADING
        float NdotN = dot(normalM, northVec);                // Normal · North vector
        float absNdotN = abs(NdotN);                         // Absolute value for bidirectional use
    #endif

    // Custom PBR and generated normals setup
    #if defined CUSTOM_PBR || defined GENERATED_NORMALS
        float NPdotU = abs(dot(geoNormal, upVec));           // Geometric normal · Up vector
    #endif

    // ██████████████████████████████████████████████████████████████████████████████████
    // █                        STAGE 3: DIRECTIONAL LIGHTING SETUP                    █
    // █                       VcorA - Surface Normal Calculations                      █
    // ██████████████████████████████████████████████████████████████████████████████████
    
    #if defined OVERWORLD || defined END
        // Calculate primary lighting angle
        float NdotL = dot(normalM, lightVec);                // Normal · Light vector
        
        #ifdef GBUFFERS_WATER
            // Water transparency could modify lighting (currently disabled)
            // NdotL = mix(NdotL, 1.0, 1.0 - color.a);
        #endif
        
        #ifdef CUSTOM_PBR
            // Enhanced PBR lighting calculations
            float geoNdotL = dot(geoNormal, lightVec);        // Geometric normal lighting
            float geoNdotLM = geoNdotL > 0.0 ? geoNdotL * 10.0 : geoNdotL;
            NdotL = min(geoNdotLM, NdotL);                    // Use most restrictive lighting

            // Vertical surface adjustment for realistic PBR response
            NdotL *= 1.0 - 0.7 * (1.0 - pow2(pow2(NdotUmax0))) * NPdotU;
        #endif
        
        // Special subsurface scattering handling
        #if SHADOW_QUALITY == -1 && defined GBUFFERS_TERRAIN || defined DREAM_TWEAKED_LIGHTING
            if (subsurfaceMode == 1) {
                // Foliage: light comes from above primarily
                NdotU = 1.0;
                NdotUmax0 = 1.0;
                NdotL = dot(upVec, lightVec);
            } else if (subsurfaceMode == 2) {
                // Translucent materials: mixed lighting model
                highlightMult *= NdotL;
                NdotL = mix(NdotL, 1.0, 0.35);
            }
            subsurfaceMode = 0; // Reset after processing
        #endif
        
        // Final lighting calculations
        float NdotLmax0 = max0(NdotL);                        // Clamped positive lighting
        float NdotLM = NdotLmax0 * 0.9999;                   // Slightly reduced for stability

        #ifdef GBUFFERS_TEXTURED
            NdotLM = 1.0; // Full lighting for textured elements
        #else
            #ifdef GBUFFERS_TERRAIN
                if (subsurfaceMode != 0) {
                    // Enhanced POM lighting for parallax surfaces
                    #if defined CUSTOM_PBR && defined POM && POM_QUALITY >= 128 && POM_LIGHTING_MODE == 2
                        shadowMult *= max(pow2(pow2(dot(normalM, geoNormal))), sqrt2(NdotLmax0));
                    #endif
                    NdotLM = 1.0;
                }
                #ifdef SIDE_SHADOWING
                    else
                #endif
            #endif
            #ifdef SIDE_SHADOWING
                // Directional shading with offset for realism
                NdotLM = max0(NdotL + 0.4) * 0.714;

                #ifdef END
                    // Enhanced contrast in The End dimension
                    NdotLM = sqrt3(NdotLM);
                #endif
            #endif
        #endif

        // ██████████████████████████████████████████████████████████████████████████████████
        // █                         STAGE 4: SHADOW PROCESSING SYSTEM                     █
        // █                        VcorA - Advanced Shadow Management                      █
        // ██████████████████████████████████████████████████████████████████████████████████

        // Entity-specific lighting adjustments
        #if ENTITY_SHADOWS_DEFINE == -1 && (defined GBUFFERS_ENTITIES || defined GBUFFERS_BLOCK)
            lightColorM = mix(lightColorM * 0.75, ambientColorM, 0.5 * pow2(pow2(1.0 - NdotLM)));
            NdotLM = NdotLM * 0.75 + 0.25;
        #endif

        // Main shadow calculation branch
        if (shadowMult.r > 0.00001) {
            #if SHADOW_QUALITY > -1
                if (NdotLM > 0.0001) {
                    vec3 shadowMultBeforeLighting = shadowMult;
                    float shadowLength = min(shadowDistance, far) * 0.9166667 - lViewPos;

                    if (shadowLength > 0.000001) {
                        // Quality-based shadow offset calculation
                        #if SHADOW_SMOOTHING == 4 || SHADOW_QUALITY == 0
                            float offset = 0.00098;         // Maximum softness
                        #elif SHADOW_SMOOTHING == 3
                            float offset = 0.00075;         // High softness
                        #elif SHADOW_SMOOTHING == 2
                            float offset = 0.0005;          // Medium softness
                        #elif SHADOW_SMOOTHING == 1
                            float offset = 0.0003;          // Low softness
                        #endif

                        vec3 playerPosM = playerPos;
                        vec3 centerPlayerPos = floor(playerPos + cameraPosition + worldGeoNormal * 0.01) 
                                             - cameraPosition + 0.5;

                        #if defined DO_PIXELATION_EFFECTS && defined PIXELATED_SHADOWS
                            playerPosM = playerPosPixelated;
                            offset *= 0.75; // Reduce offset for pixelated shadows
                        #endif

                        // ████████████████████████████████████████████████████████████████████████
                        // █                    CAVE LIGHT LEAK PREVENTION                       █
                        // █                  VcorA - Advanced Shadow Bias                       █
                        // ████████████████████████████████████████████████████████████████████████
                        
                        #ifdef GBUFFERS_TERRAIN
                            if (centerShadowBias || subsurfaceMode == 1) {
                                #ifdef OVERWORLD
                                    playerPosM = mix(centerPlayerPos, playerPosM, 0.5 + 0.5 * lightmapYM);
                                #endif
                            } else {
                                #if !defined DO_PIXELATION_EFFECTS || !defined PIXELATED_SHADOWS
                                    float centerFactor = max(glColor.a, lightmapYM);

                                    #if defined PERPENDICULAR_TWEAKS && SHADOW_QUALITY >= 2
                                        // Variable Penumbra Shadows for vertical surfaces
                                        if (NdotU > 0.99) {
                                            vec3 aoGradView = dFdx(glColor.a) * normalize(dFdx(playerPos.xyz))
                                                            + dFdy(glColor.a) * normalize(dFdy(playerPos.xyz));
                                            if (dot(normalize(aoGradView.xz), normalize(ViewToPlayer(lightVec).xz)) < 0.3 + 0.4 * dither)
                                                if (dot(lightVec, upVec) < 0.99999) 
                                                    centerFactor = sqrt1(max0(glColor.a - 0.55) / 0.45);
                                        }
                                    #endif
                                #else
                                    // Optimized factor for pixelated shadows
                                    float centerFactor = 1.0 - (1.0 - glColor.a) * max(max0(signMidCoordPos.y), NdotUmax0);
                                #endif

                                playerPosM = mix(playerPosM, centerPlayerPos, 0.2 * (1.0 - pow2(pow2(centerFactor))));
                            }
                        #elif defined GBUFFERS_HAND
                            // Hand/held item shadow bias
                            playerPosM = mix(vec3(0.0), playerPosM, 0.2 + 0.8 * lightmapYM);
                        #elif defined GBUFFERS_TEXTURED
                            // Textured element shadow bias
                            playerPosM = mix(centerPlayerPos, playerPosM + vec3(0.0, 0.02, 0.0), lightmapYM);
                        #else
                            // General entity shadow bias
                            playerPosM = mix(playerPosM, centerPlayerPos, 0.2 * (1.0 - lightmapYM));
                        #endif

                        // ████████████████████████████████████████████████████████████████████████
                        // █                     SHADOW BIAS CALCULATION                         █
                        // █                   VcorA - Peter-Panning Prevention                  █
                        // ████████████████████████████████████████████████████████████████████████
                        
                        #ifndef GBUFFERS_TEXTURED
                            #ifdef GBUFFERS_TERRAIN
                                if (subsurfaceMode != 1)
                            #endif
                            {
                                // Distance-based bias to prevent shadow acne
                                float distanceBias = pow(dot(playerPos, playerPos), 0.75);
                                distanceBias = 0.12 + 0.0008 * distanceBias;
                                vec3 bias = worldGeoNormal * distanceBias * (2.0 - 0.95 * NdotLmax0);

                                #ifdef GBUFFERS_TERRAIN
                                    if (subsurfaceMode == 2) {
                                        bias *= vec3(0.0, 0.0, -0.75); // Special bias for translucent materials
                                    }
                                #endif

                                playerPosM += bias;
                            }
                        #endif

                        // Transform to shadow space
                        vec3 shadowPos = GetShadowPos(playerPosM);

                        // ████████████████████████████████████████████████████████████████████████
                        // █                  SUBSURFACE SCATTERING SETUP                        █
                        // █                 VcorA - Material-Specific Lighting                  █
                        // ████████████████████████████████████████████████████████████████████████
                        
                        bool leaves = false;
                        #ifdef GBUFFERS_TERRAIN
                            if (subsurfaceMode == 0) {
                                // Standard terrain shadow handling
                                #if defined PERPENDICULAR_TWEAKS && defined SIDE_SHADOWING
                                    offset *= 1.0 + pow2(absNdotN); // Increase offset for perpendicular surfaces
                                #endif
                            } else {
                                // Subsurface scattering calculations
                                float VdotL = dot(nViewPos, lightVec);
                                float lightFactor = pow(max(VdotL, 0.0), 10.0) * float(isEyeInWater == 0);
                                
                                if (subsurfaceMode == 1) {
                                    // Foliage subsurface scattering
                                    offset = 0.0010235 * lightmapYM + 0.0009765;
                                    shadowPos.z -= max(NdotL * 0.0001, 0.0) * lightmapYM;
                                    subsurfaceHighlight = lightFactor * 0.8;
                                    #ifndef SHADOW_FILTERING
                                        shadowPos.z -= 0.0002;
                                    #endif
                                } else if (subsurfaceMode == 2) {
                                    // Translucent material handling
                                    leaves = true;
                                    offset = 0.0005235 * lightmapYM + 0.0009765;
                                    shadowPos.z -= 0.000175 * lightmapYM;
                                    subsurfaceHighlight = lightFactor * 0.6;
                                    #ifndef SHADOW_FILTERING
                                        NdotLM = mix(NdotL, NdotLM, 0.5);
                                    #endif
                                }
                            }
                        #endif

                        // Apply shadow sampling
                        shadowMult *= GetShadow(shadowPos, lViewPos, lightmap.y, offset, leaves);
                    }

                    // ████████████████████████████████████████████████████████████████████████
                    // █                     SHADOW DISTANCE BLENDING                        █
                    // █                    VcorA - Smooth Shadow Transitions                █
                    // ████████████████████████████████████████████████████████████████████████
                    
                    float shadowSmooth = 16.0;
                    if (shadowLength < shadowSmooth) {
                        float shadowMixer = max0(shadowLength / shadowSmooth);

                        #ifdef GBUFFERS_TERRAIN
                            if (subsurfaceMode != 0) {
                                float shadowMixerM = pow2(shadowMixer);

                                if (subsurfaceMode == 1) {
                                    // Foliage shadow blending
                                    skyLightShadowMult *= mix(0.6 + 0.3 * pow2(noonFactor), 1.0, shadowMixerM);
                                } else {
                                    // Translucent shadow blending
                                    skyLightShadowMult *= mix(NdotL * 0.4999 + 0.5, 1.0, shadowMixerM);
                                }

                                subsurfaceHighlight *= shadowMixer;
                            }
                        #endif

                        shadowMult = mix(vec3(skyLightShadowMult * shadowMultBeforeLighting), shadowMult, shadowMixer);
                    }
                }
            #else
                // Low quality shadow fallback
                shadowMult *= skyLightShadowMult;
            #endif

            // ████████████████████████████████████████████████████████████████████████
            // █                        CLOUD SHADOW SYSTEM                          █
            // █                    VcorA - Atmospheric Shadows                      █
            // ████████████████████████████████████████████████████████████████████████
            
            #ifdef CLOUD_SHADOWS
                vec3 worldPos = playerPos + cameraPosition;
                #if defined DO_PIXELATION_EFFECTS && defined PIXELATED_SHADOWS
                    worldPos = playerPosPixelated + cameraPosition;
                #endif

                #ifdef CLOUDS_REIMAGINED
                    // Advanced reimagined cloud shadows
                    float EdotL = dot(eastVec, lightVec);
                    float EdotLM = tan(acos(EdotL));

                    #if SUN_ANGLE != 0
                        float NVdotLM = tan(acos(dot(northVec, lightVec)));
                    #endif

                    // Primary cloud layer
                    float distToCloudLayer1 = cloudAlt1i - worldPos.y;
                    vec3 cloudOffset1 = vec3(distToCloudLayer1 / EdotLM, 0.0, 0.0);
                    #if SUN_ANGLE != 0
                        cloudOffset1.z += distToCloudLayer1 / NVdotLM;
                    #endif
                    vec2 cloudPos1 = GetRoundedCloudCoord(ModifyTracePos(worldPos + cloudOffset1, cloudAlt1i).xz, 0.35);
                    float cloudSample = texture2D(gaux4, cloudPos1).b;
                    cloudSample *= clamp(distToCloudLayer1 * 0.1, 0.0, 1.0);

                    #ifdef DOUBLE_REIM_CLOUDS
                        // Secondary cloud layer for depth
                        float distToCloudLayer2 = cloudAlt2i - worldPos.y;
                        vec3 cloudOffset2 = vec3(distToCloudLayer2 / EdotLM, 0.0, 0.0);
                        #if SUN_ANGLE != 0
                            cloudOffset2.z += distToCloudLayer2 / NVdotLM;
                        #endif
                        vec2 cloudPos2 = GetRoundedCloudCoord(ModifyTracePos(worldPos + cloudOffset2, cloudAlt2i).xz, 0.35);
                        float cloudSample2 = texture2D(gaux4, cloudPos2).b;
                        cloudSample2 *= clamp(distToCloudLayer2 * 0.1, 0.0, 1.0);

                        cloudSample = 1.0 - (1.0 - cloudSample) * (1.0 - cloudSample2);
                    #endif

                    cloudSample *= sqrt3(1.0 - abs(EdotL));
                    shadowMult *= 1.0 - 0.85 * cloudSample;
                #else
                    // Standard cloud shadows using noise
                    vec2 csPos = worldPos.xz + worldPos.y * 0.25;
                    csPos.x += syncedTime;
                    csPos *= 0.000002 * CLOUD_UNBOUND_SIZE_MULT;

                    vec2 shadowoffsets[8] = vec2[8](
                        vec2( 0.0   , 1.0   ), vec2( 0.7071, 0.7071),
                        vec2( 1.0   , 0.0   ), vec2( 0.7071,-0.7071),
                        vec2( 0.0   ,-1.0   ), vec2(-0.7071,-0.7071),
                        vec2(-1.0   , 0.0   ), vec2(-0.7071, 0.7071));
                    
                    float cloudSample = 0.0;
                    for (int i = 0; i < 8; i++) {
                        cloudSample += texture2D(noisetex, csPos + 0.005 * shadowoffsets[i]).b;
                    }

                    shadowMult *= smoothstep1(pow2(min1(cloudSample * 0.2)));
                #endif
            #endif

            // Apply final shadow calculations
            shadowMult *= max(NdotLM * shadowTime, 0.0);
        }
        #ifdef GBUFFERS_WATER
            else {
                // Low quality water shadow fallback
                shadowMult = vec3(pow2(lightmapY2) * max(NdotLM * shadowTime, 0.0));
            }
        #endif
    #endif

    // ██████████████████████████████████████████████████████████████████████████████████
    // █                         STAGE 5: BLOCKLIGHT PROCESSING                        █
    // █                         VcorA - Torch and Lava Lighting                       █
    // ██████████████████████████████████████████████████████████████████████████████████
    
    float lightmapXM; // Processed blocklight intensity
    
    if (!noSmoothLighting) {
        // Advanced blocklight curve with brightness compensation
        float lightmapXMSteep = pow2(pow2(lightmap.x * lightmap.x)) * (3.8 - 0.6 * vsBrightness);
        float lightmapXMCalm = (lightmap.x) * (1.8 + 0.6 * vsBrightness);
        lightmapXM = pow(lightmapXMSteep + lightmapXMCalm, 2.25);
    } else {
        // Simple blocklight for performance mode
        lightmapXM = pow2(lightmap.x) * lightmap.x * 10.0;
    }

    // Dynamic torch flickering effect
    #if BLOCKLIGHT_FLICKERING > 0
        vec2 flickerNoise = texture2D(noisetex, vec2(frameTimeCounter * 0.06)).rb;
        lightmapXM *= mix(1.0, min1(max(flickerNoise.r, flickerNoise.g) * 1.7), 
                         pow2(BLOCKLIGHT_FLICKERING * 0.1));
    #endif

    // Apply blocklight color
    vec3 blockLighting = lightmapXM * blocklightCol;

        
        // ████████████████████████████████████████████████████████████████████████
        // █                    ADVANCED COLORED LIGHTING                        █
        // █                  VcorA - Voxel-Based Color System                   █
        // ████████████████████████████████████████████████████████████████████████

        #if COLORED_LIGHTING_INTERNAL > 0
            // Calculate voxel position for colored lighting sampling
            #if defined GBUFFERS_HAND
                vec3 voxelPos = SceneToVoxel(vec3(0.0));      // Hand items use origin
            #elif defined GBUFFERS_TEXTURED
                vec3 voxelPos = SceneToVoxel(playerPos);       // Textured elements use player pos
            #else
                vec3 voxelPos = SceneToVoxel(playerPos);
                voxelPos = voxelPos + worldGeoNormal * 0.55;   // Normal offset for leak prevention
            #endif

            vec3 specialLighting = vec3(0.0);
            vec4 lightVolume = vec4(0.0);
            
            if (CheckInsideVoxelVolume(voxelPos)) {
                vec3 voxelPosM = clamp01(voxelPos / vec3(voxelVolumeSize));
                lightVolume = GetLightVolume(voxelPosM);
                lightVolume = sqrt(lightVolume);               // Gamma correction
                specialLighting = lightVolume.rgb;
            }

            // Enhanced artificial lighting for special blocks
            lightmapXM = max(lightmapXM, mix(lightmapXM, 10.0, lightVolume.a));
            specialLighting *= 1.0 + 50.0 * lightVolume.a;

            // Color balance and luminance correction
            specialLighting = lightmapXM * 0.13 * DoLuminanceCorrection(specialLighting + blocklightCol * 0.05);

            // Add non-contrasty detail enhancement
            AddSpecialLightDetail(specialLighting, color.rgb, emission);

            #if COLORED_LIGHT_SATURATION != 100
                specialLighting = mix(blockLighting, specialLighting, COLORED_LIGHT_SATURATION * 0.01);
            #endif

            // Distance-based fading for performance optimization
            vec3 absPlayerPosM = abs(playerPos);
            #if COLORED_LIGHTING_INTERNAL <= 512
                absPlayerPosM.y *= 2.0;                        // 2x vertical scaling
            #elif COLORED_LIGHTING_INTERNAL == 768
                absPlayerPosM.y *= 3.0;                        // 3x vertical scaling
            #elif COLORED_LIGHTING_INTERNAL == 1024
                absPlayerPosM.y *= 4.0;                        // 4x vertical scaling
            #endif
            
            float maxPlayerPos = max(absPlayerPosM.x, max(absPlayerPosM.y, absPlayerPosM.z));
            float blocklightDecider = pow2(min1(maxPlayerPos / effectiveACLdistance * 2.0));
            blockLighting = mix(specialLighting, blockLighting, blocklightDecider);
        #endif

        // ████████████████████████████████████████████████████████████████████████
        // █                       HELD ITEM LIGHTING                            █
        // █                  VcorA - Dynamic Torch System                       █
        // ████████████████████████████████████████████████████████████████████████

        #if HELD_LIGHTING_MODE >= 1
            float heldLight = heldBlockLightValue; 
            float heldLight2 = heldBlockLightValue2;

            #ifndef IS_IRIS
                if (heldLight > 15.1) heldLight = 0.0;        // Clamp invalid values
                if (heldLight2 > 15.1) heldLight2 = 0.0;
            #endif

            #if COLORED_LIGHTING_INTERNAL == 0
                // Standard blocklight color for held items
                vec3 heldLightCol = blocklightCol; 
                vec3 heldLightCol2 = blocklightCol;

                // Special handling for lava bucket
                if (heldItemId == 45032) heldLight = 15; 
                if (heldItemId2 == 45032) heldLight2 = 15;
            #else
                // Advanced colored lighting for held items
                vec3 heldLightCol = GetSpecialBlocklightColor(heldItemId - 44000).rgb;
                vec3 heldLightCol2 = GetSpecialBlocklightColor(heldItemId2 - 44000).rgb;

                if (heldItemId == 45032) { 
                    heldLightCol = lavaSpecialLightColor; 
                    heldLight = 15; 
                }
                if (heldItemId2 == 45032) { 
                    heldLightCol2 = lavaSpecialLightColor; 
                    heldLight2 = 15; 
                }

                #if COLORED_LIGHT_SATURATION != 100
                    heldLightCol = mix(blocklightCol, heldLightCol, COLORED_LIGHT_SATURATION * 0.01);
                    heldLightCol2 = mix(blocklightCol, heldLightCol2, COLORED_LIGHT_SATURATION * 0.01);
                #endif
            #endif

            // Calculate held light position and distance
            vec3 playerPosLightM = playerPos + relativeEyePosition;
            playerPosLightM.y += 0.7;                          // Height offset for hand position
            float lViewPosL = length(playerPosLightM) + 6.0;
            
            #if HELD_LIGHTING_MODE == 1
                lViewPosL *= 1.5;                              // Reduced range mode
            #endif

            // Calculate light falloff with distance
            heldLight = pow2(pow2(heldLight * 0.47 / lViewPosL));
            heldLight2 = pow2(pow2(heldLight2 * 0.47 / lViewPosL));

            // Combine held lighting with luminance correction
            vec3 heldLighting = pow2(heldLight * DoLuminanceCorrection(heldLightCol + 0.001))
                              + pow2(heldLight2 * DoLuminanceCorrection(heldLightCol2 + 0.001));

            #if COLORED_LIGHTING_INTERNAL > 0
                AddSpecialLightDetail(heldLighting, color.rgb, emission);
            #endif

            #ifdef GBUFFERS_HAND
                blockLighting *= 0.5;                          // Reduce blocklight for held items
                heldLighting *= 2.0;                           // Enhance held lighting
            #endif
        #endif

        // ████████████████████████████████████████████████████████████████████████
        // █                      MINIMUM CAVE LIGHTING                          █
        // █                   VcorA - Darkness Prevention                       █
        // ████████████████████████████████████████████████████████████████████████

        #if !defined END && CAVE_LIGHTING > 0
            vec3 minLighting = vec3(0.005625 + vsBrightness * 0.043);
            
            #if CAVE_LIGHTING != 100
                #define CAVE_LIGHTING_M CAVE_LIGHTING * 0.01
                minLighting *= CAVE_LIGHTING_M;
            #endif
            
            minLighting *= vec3(0.45, 0.475, 0.6);            // Bluish cave light
            minLighting *= 1.0 - lightmapYM;                  // Reduce in daylight
        #else
            vec3 minLighting = vec3(0.0);
        #endif

        // Night vision enhancement
        minLighting += nightVision * vec3(0.5, 0.5, 0.75);

        // ████████████████████████████████████████████████████████████████████████
        // █                     ADVANCED LIGHTING TWEAKS                        █
        // █                   VcorA - Environmental Adjustments                 █
        // ████████████████████████████████████████████████████████████████████████

        #ifdef OVERWORLD
            // Rain-based ambient adjustment
            ambientMult = mix(lightmapYM, pow2(lightmapYM) * lightmapYM, rainFactor);

            #if SHADOW_QUALITY == -1
                // Low quality shadow compensation
                float tweakFactor = 1.0 + 0.6 * (1.0 - pow2(pow2(pow2(noonFactor))));
                lightColorM /= tweakFactor;
                ambientMult *= mix(tweakFactor, 1.0, 0.5 * NdotUmax0);
            #endif

            #if AMBIENT_MULT != 100
                // Custom ambient multiplier
                #define AMBIENT_MULT_M (AMBIENT_MULT - 100) * 0.006
                vec3 shadowMultP = shadowMult / (0.1 + 0.9 * sqrt2(max0(NdotLM)));
                ambientMult *= 1.0 + pow2(pow2(max0(1.0 - dot(shadowMultP, shadowMultP)))) * AMBIENT_MULT_M *
                               (0.5 + 0.2 * sunFactor + 0.8 * noonFactor) * (1.0 - rainFactor * 0.5);
            #endif

            // Atmospheric perspective and fog effects
            if (isEyeInWater != 1) {
                float lxFactor = (sunVisibility2 * 0.4 + (0.6 - 0.6 * pow2(invNoonFactor))) * 
                                (6.0 - 5.0 * rainFactor);
                lxFactor *= lightmapY2 + lightmapY2 * 2.0 * pow2(shadowMult.r);
                lxFactor = max0(lxFactor - emission * 1000000.0);
                blockLighting *= pow(lightmapXM / 60.0 + 0.001, 0.09 * lxFactor);

                // Distance-based fog simulation
                float rainLF = 0.1 * rainFactor;
                float lightFogTweaks = 1.0 + max0(96.0 - lViewPos) * 
                                      (0.002 * (1.0 - sunVisibility2) + 0.0104 * rainLF) - rainLF;
                ambientMult *= lightFogTweaks;
                lightColorM *= lightFogTweaks;
            }
        #endif

        #ifdef GBUFFERS_HAND
            ambientMult *= 1.3;                                // Improve held map visibility
        #endif

    // ██████████████████████████████████████████████████████████████████████████████████
    // █                        STAGE 7: SCENE LIGHTING CALCULATION                    █
    // █                        VcorA - Ambient and Sky Lighting                       █
    // ██████████████████████████████████████████████████████████████████████████████████
    
    // Enhanced scene lighting with proper color mixing
    vec3 sceneLighting = lightColorM * shadowMult + ambientColorM * ambientMult;
    float dotSceneLighting = dot(sceneLighting, sceneLighting);

    #if HELD_LIGHTING_MODE >= 1
        // Combine held lighting with blocklight using proper blending
        blockLighting = sqrt(pow2(blockLighting) + heldLighting);
    #endif

    // Apply intensity multiplier
    blockLighting *= XLIGHT_I;

    // Apply dynamic color multipliers
    #ifdef LIGHT_COLOR_MULTS
        sceneLighting *= lightColorMult;
    #endif
    
    #ifdef MOON_PHASE_INF_LIGHT
        sceneLighting *= moonPhaseInfluence;
    #endif

    // ██████████████████████████████████████████████████████████████████████████████████
    // █                      STAGE 8: AMBIENT OCCLUSION PROCESSING                    █
    // █                        VcorA - Enhanced AO Calculation                        █
    // ██████████████████████████████████████████████████████████████████████████████████
    
    float vanillaAO = 1.0;
    
    #if VANILLAAO_I > 0
        vanillaAO = glColor.a;

        #if defined DO_PIXELATION_EFFECTS && defined PIXELATED_AO
            vanillaAO = TexelSnap(vanillaAO, pixelationOffset);
        #endif

        if (subsurfaceMode != 0) {
            // Enhanced AO for subsurface materials
            vanillaAO = mix(min1(vanillaAO * 1.15), 1.0, shadowMult.g);
        } else if (!noVanillaAO) {
            #ifdef GBUFFERS_TERRAIN
                vanillaAO = min1(vanillaAO + 0.08);
                
                #ifdef OVERWORLD
                    // Dynamic AO based on lighting conditions and time of day
                    vanillaAO = pow(
                        pow1_5(vanillaAO),
                        1.0 + dotSceneLighting * 0.02 + NdotUmax0 * (0.15 + 0.25 * pow2(noonFactor * pow2(lightmapY2)))
                    );
                #elif defined NETHER
                    // Enhanced contrast for Nether dimension
                    vanillaAO = pow(
                        pow1_5(vanillaAO),
                        1.0 + NdotUmax0 * 0.5
                    );
                #else
                    // Standard AO for End dimension
                    vanillaAO = pow(
                        vanillaAO,
                        0.75 + NdotUmax0 * 0.25
                    );
                #endif
            #endif
            
            vanillaAO = vanillaAO * 0.9 + 0.1;                // Prevent pure black AO

            #if VANILLAAO_I != 100
                #define VANILLAAO_IM VANILLAAO_I * 0.01
                vanillaAO = pow(vanillaAO, VANILLAAO_IM);      // Apply intensity adjustment
            #endif
        }
    #endif

    // ██████████████████████████████████████████████████████████████████████████████████
    // █                      STAGE 9: DIRECTIONAL SHADING SYSTEM                      █
    // █                        VcorA - Advanced Normal Shading                        █
    // ██████████████████████████████████████████████████████████████████████████████████
    
    float directionShade = 1.0;
    
    #ifdef DIRECTIONAL_SHADING
        if (!noDirectionalShading) {
            float NdotE = dot(normalM, eastVec);
            float absNdotE = abs(NdotE);
            float absNdotE2 = pow2(absNdotE);

            #if !defined NETHER
                float NdotUM = 0.75 + NdotU * 0.25;
            #else
                float NdotUM = 0.75 + abs(NdotU + 0.5) * 0.16666;
            #endif
            
            float NdotNM = 1.0 + 0.075 * absNdotN;
            float NdotEM = 1.0 - 0.1 * absNdotE2;
            directionShade = NdotUM * NdotEM * NdotNM;

            #ifdef OVERWORLD
                // Enhanced lighting variation in Overworld
                lightColorM *= 1.0 + absNdotE2 * 0.75;
            #elif defined NETHER
                // Special Nether lighting effects
                directionShade *= directionShade;
                ambientColorM += lavaLightColor * pow2(absNdotN * 0.5 + max0(-NdotU)) * 
                                (0.7 + 0.35 * vsBrightness);
            #endif

            #if defined CUSTOM_PBR || defined GENERATED_NORMALS
                // Custom PBR ambient factor
                float cpbrAmbFactor = NdotN * NPdotU;
                cpbrAmbFactor = 1.0 - 0.3 * cpbrAmbFactor;
                ambientColorM *= cpbrAmbFactor;
                minLighting *= cpbrAmbFactor;
            #endif

            #if defined OVERWORLD && defined PERPENDICULAR_TWEAKS && defined SIDE_SHADOWING
                // Simulated bounced light for realism
                ambientColorM = mix(ambientColorM, lightColorM, 
                                   (0.05 + 0.03 * subsurfaceMode) * absNdotN * lightmapY2);

                // Enhanced noon lighting for natural appearance
                lightColorM *= 1.0 + max0(1.0 - subsurfaceMode) * pow(noonFactor, 20.0) * 
                              (pow2(absNdotN) - absNdotE2 * 0.1);
            #endif
        }
    #endif

    #ifdef DREAM_TWEAKED_LIGHTING
        // Special dream-like lighting mode
        ambientColorM = mix(ambientColorM, lightColorM, 0.25) * 1.5;
        lightColorM = lightColorM * 0.3;
    #endif

    // Apply intensity multiplier
    blockLighting *= XLIGHT_I;

    // Apply dynamic color multipliers
    #ifdef LIGHT_COLOR_MULTS
        sceneLighting *= lightColorMult;
    #endif
    
    #ifdef MOON_PHASE_INF_LIGHT
        sceneLighting *= moonPhaseInfluence;
    #endif

    // ██████████████████████████████████████████████████████████████████████████████████
    // █                       STAGE 10: SPECULAR HIGHLIGHT SYSTEM                     █
    // █                        VcorA - PBR Reflection Calculation                      █
    // ██████████████████████████████████████████████████████████████████████████████████
    
    vec3 lightHighlight = vec3(0.0);
    
    #ifdef LIGHT_HIGHLIGHT
        // Calculate GGX specular highlights
        float specularHighlight = GGX(normalM, nViewPos, lightVec, NdotLmax0, smoothnessG);
        specularHighlight *= highlightMult;

        // Shadow modulation for highlights
        lightHighlight = isEyeInWater != 1 ? shadowMult : pow(shadowMult, vec3(0.25)) * 0.35;
        lightHighlight *= (subsurfaceHighlight + specularHighlight) * highlightColor;

        // Apply dynamic color multipliers
        #ifdef LIGHT_COLOR_MULTS
            lightHighlight *= lightColorMult;
        #endif
        
        #ifdef MOON_PHASE_INF_REFLECTION
            lightHighlight *= pow2(moonPhaseInfluence);
        #endif
    #endif

    // ██████████████████████████████████████████████████████████████████████████████████
    // █                        STAGE 11: FINAL COLOR COMPOSITION                      █
    // █                         VcorA - Advanced Light Mixing                         █
    // ██████████████████████████████████████████████████████████████████████████████████
    
    // Combine all lighting components with proper gamma correction
    vec3 finalDiffuse = pow2(directionShade * vanillaAO) * 
                       (blockLighting + pow2(sceneLighting) + minLighting) + 
                       pow2(emission);
    
    // Apply square root for realistic light mixing and prevent NaN values
    finalDiffuse = sqrt(max(finalDiffuse, vec3(0.0)));

    // ██████████████████████████████████████████████████████████████████████████████████
    // █                          STAGE 12: FINAL APPLICATION                          █
    // █                        VcorA - Complete Illumination                          █
    // ██████████████████████████████████████████████████████████████████████████████████
    
    // Apply all calculated lighting to the surface color
    color.rgb *= finalDiffuse;                              // Multiply base color with diffuse
    color.rgb += lightHighlight;                            // Add specular highlights
    color.rgb *= pow2(1.0 - darknessLightFactor);          // Apply darkness effect

    /*
     * ╔══════════════════════════════════════════════════════════════════════════════════╗
     * ║                            LIGHTING COMPLETE                                    ║
     * ║                                                                                  ║
     * ║  The surface has been fully illuminated using the advanced Luminara lighting      ║
     * ║  system. All components including shadows, ambient occlusion, blocklight,       ║
     * ║  directional shading, and specular highlights have been applied.                ║
     * ║                                                                                  ║
     * ║  Enhanced & Optimized by VcorA - Luminara Shader Pack 2025                        ║
     * ╚══════════════════════════════════════════════════════════════════════════════════╝
     */
}

/*
█████████████████████████████████████████████████████████████████████████████████████████
█                                                                                       █
█                             END OF CORE ILLUMINATION                                 █
█                                                                                       █
█  This file represents the culmination of advanced lighting technology in Minecraft   █
█  shaders. Every line has been carefully crafted and optimized for maximum visual     █
█  fidelity while maintaining excellent performance across all hardware configurations.█
█                                                                                       █
█  Author: VcorA                                                                        █
█  Project: Luminara Shader Pack - Enhanced Edition                                       █
█  Year: 2025                                                                           █
█                                                                                       █
█  "Where technology meets artistry in the realm of digital illumination"              █
█                                                                                       █
█████████████████████████████████████████████████████████████████████████████████████████
*/
