/*
===============================================================================
   FLOW GLSL - Luminara Shader Water & Translucent System
===============================================================================
   Advanced Water and Translucent Material Rendering Pipeline
   
   ● Purpose: Comprehensive water physics, reflections, and translucent materials
   ● Features: Dynamic waves, realistic reflections, PBR materials, portal effects
   ● Performance: Optimized for real-time water simulation and rendering
   
   Credits & Rights:
   • VcorA - Advanced water physics and reflection system development
   • Realistic wave simulation algorithms
   • Multi-layer translucent material handling
   • Dynamic reflection and refraction systems
   • Portal and special effect integration
   
   Technical Specifications:
   - Advanced water material system with multiple quality levels
   - Real-time reflection and refraction calculations
   - Support for Nether portals with special effects
   - PBR material integration for realistic translucents
   - Optimized fog and atmospheric integration
   - TAA compatibility for temporal stability
   - Connected glass and voxelization effects
===============================================================================
*/

// Core shader library integration
#include "/lib/shader_modules/shader_master.glsl"

/*
===============================================================================
   FRAGMENT SHADER PIPELINE
===============================================================================
   Advanced translucent material processing with water physics
*/
#ifdef FRAGMENT_SHADER

/*
   INPUT VERTEX DATA
   ────────────────────────────────────────────────────────────────────────────
   Comprehensive vertex data for advanced material processing
*/
flat in int mat;                    // Material identification ID

in vec2 texCoord;                   // Primary texture coordinates
in vec2 lmCoord;                    // Light map coordinates for lighting
in vec2 signMidCoordPos;            // Texture coordinate signs for POM
flat in vec2 absMidCoordPos;        // Absolute texture coordinate positions

flat in vec3 upVec, sunVec, northVec, eastVec; // Directional vectors for calculations
in vec3 playerPos;                  // World position relative to player
in vec3 normal;                     // Surface normal vector
in vec3 viewVector;                 // View direction in tangent space

in vec4 glColor;                    // Vertex color from OpenGL state

// Advanced normal mapping support for high-quality materials
#if WATER_STYLE >= 2 || RAIN_PUDDLES >= 1 && WATER_STYLE == 1 && WATER_MAT_QUALITY >= 2 || defined GENERATED_NORMALS || defined CUSTOM_PBR
    flat in vec3 binormal, tangent; // Tangent space vectors for normal mapping
#endif

// Parallax Occlusion Mapping support
#ifdef POM
    in vec4 vTexCoordAM;            // Advanced texture coordinates for POM
#endif

/*
   ATMOSPHERIC AND LIGHTING CALCULATIONS
   ────────────────────────────────────────────────────────────────────────────
   @VcorA: Advanced lighting system with sun tracking and visibility
*/
float NdotU = dot(normal, upVec);              // Normal-Up angle for surface orientation
float NdotUmax0 = max(NdotU, 0.0);            // Clamped upward normal component
float SdotU = dot(sunVec, upVec);              // Sun-Up angle for time calculations

// Complex sun visibility system with smooth day/night transitions
float sunFactor = SdotU < 0.0 ? clamp(SdotU + 0.375, 0.0, 0.75) / 0.75 : clamp(SdotU + 0.03125, 0.0, 0.0625) / 0.0625;
float sunVisibility = clamp(SdotU + 0.0625, 0.0, 0.125) / 0.125;
float sunVisibility2 = sunVisibility * sunVisibility;
float shadowTimeVar1 = abs(sunVisibility - 0.5) * 2.0;
float shadowTimeVar2 = shadowTimeVar1 * shadowTimeVar1;
float shadowTime = shadowTimeVar2 * shadowTimeVar2;

/*
   ADAPTIVE LIGHT VECTOR SYSTEM
   ────────────────────────────────────────────────────────────────────────────
   Dynamic light direction based on world type and time
*/
#ifdef OVERWORLD
    vec3 lightVec = sunVec * ((timeAngle < 0.5325 || timeAngle > 0.9675) ? 1.0 : -1.0);
#else
    vec3 lightVec = sunVec;
#endif

/*
   TANGENT-BINORMAL-NORMAL MATRIX
   ────────────────────────────────────────────────────────────────────────────
   @VcorA: Advanced normal mapping transformation matrix for surface detail
*/
#if WATER_STYLE >= 2 || RAIN_PUDDLES >= 1 && WATER_STYLE == 1 && WATER_MAT_QUALITY >= 2 || defined GENERATED_NORMALS || defined CUSTOM_PBR
    mat3 tbnMatrix = mat3(
        tangent.x, binormal.x, normal.x,
        tangent.y, binormal.y, normal.y,
        tangent.z, binormal.z, normal.z
    );
#endif

/*
   UTILITY FUNCTIONS
   ────────────────────────────────────────────────────────────────────────────
   Essential calculation functions for water rendering
*/
float GetLinearDepth(float depth) {
    return (2.0 * near) / (far + near - depth * (far - near));
}

/*
   COMPREHENSIVE LIBRARY INTEGRATION
   ────────────────────────────────────────────────────────────────────────────
   Advanced rendering systems for water and translucent materials
*/
#include "/lib/atmospherics/luminara_atmospheric_core.glsl"
#include "/lib/illumination_systems/core_illumination_system.glsl"
#include "/lib/atmospherics/particles/mainParticles.glsl"

// Overworld-specific atmospheric systems
#ifdef OVERWORLD
    #include "/lib/atmospherics/atmosphericVolumetricSystem.glsl"
#endif

// Advanced reflection systems
#if WATER_REFLECT_QUALITY >= 0
    #if defined SKY_EFFECT_REFLECTION && defined OVERWORLD
        #include "/lib/atmospherics/atmosphericVolumetricSystem.glsl"

        #ifdef VL_CLOUDS_ACTIVE 
            #include "/lib/atmospherics/atmosphere/mainAtmosphere.glsl"
        #endif
    #endif

    #include "/lib/materialMethods/reflections.glsl"
#endif

// Temporal Anti-Aliasing support
#ifdef TAA
    #include "/lib/smoothing/sampleOffset.glsl"
#endif

// Advanced material processing systems
#if defined GENERATED_NORMALS || defined COATED_TEXTURES || WATER_STYLE >= 2
    // Mip level calculations (inline)
    vec2 dcdx = dFdx(texCoord.xy);
    vec2 dcdy = dFdy(texCoord.xy);
    vec2 midCoordPos = absMidCoordPos * signMidCoordPos;
    
    vec2 mipx = dcdx / absMidCoordPos * 8.0;
    vec2 mipy = dcdy / absMidCoordPos * 8.0;
    
    float mipDelta = max(dot(mipx, mipx), dot(mipy, mipy));
    float miplevel = max(0.5 * log2(mipDelta), 0.0);
    
    #if !defined GBUFFERS_ENTITIES && !defined GBUFFERS_HAND
        vec2 atlasSizeM = atlasSize;
    #else
        vec2 atlasSizeM = atlasSize.x + atlasSize.y > 0.5 ? atlasSize : textureSize(tex, 0);
    #endif
#endif

#ifdef GENERATED_NORMALS
    #include "/lib/materialMethods/generatedNormals.glsl"
#endif

#if IPBR_EMISSIVE_MODE != 1
    #include "/lib/materialMethods/customEmission.glsl"
#endif

#ifdef CUSTOM_PBR
    #include "/lib/materialHandling/customMaterials.glsl"
#endif

// Atmospheric color and lighting effects
#ifdef ATM_COLOR_MULTS
    #include "/lib/color_schemes/color_effects_system.glsl"
#endif
#ifdef MOON_PHASE_INF_ATMOSPHERE
    #include "/lib/color_schemes/color_effects_system.glsl"
#endif

// Development and special effects
#ifdef COLOR_CODED_PROGRAMS
    #include "/lib/effects/effects_unified.glsl"
#endif

#ifdef PORTAL_EDGE_EFFECT
    // Voxelization remains as separate include due to its complexity
    #include "/lib/effects/effects_unified.glsl"
#endif

#ifdef CONNECTED_GLASS_EFFECT
    #include "/lib/materialMethods/connectedGlass.glsl"
#endif

/*
   MAIN FRAGMENT PROCESSING
   ────────────────────────────────────────────────────────────────────────────
   @VcorA: Advanced water and translucent material rendering system
   
   Processing Pipeline:
   1. Texture sampling and color preparation
   2. Coordinate system setup and depth calculations
   3. Material identification and property setup
   4. Advanced lighting calculations
   5. Reflection and refraction processing
   6. Atmospheric integration and fog effects
*/
void main() {
    /*
       TEXTURE SAMPLING AND COLOR PREPARATION
       ──────────────────────────────────────────────────────────────────────────
       Sample base texture and apply vertex coloring
    */
    vec4 colorP = texture2D(tex, texCoord);    // Preserve original color for calculations
    vec4 color = colorP * vec4(glColor.rgb, 1.0);
    
    /*
       COORDINATE SYSTEM AND DEPTH SETUP
       ──────────────────────────────────────────────────────────────────────────
       Convert screen coordinates to view space for advanced calculations
    */
    vec3 screenPos = vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z);
    #ifdef TAA
        vec3 viewPos = ScreenToView(vec3(TAAJitter(screenPos.xy, -0.5), screenPos.z));
    #else
        vec3 viewPos = ScreenToView(screenPos);
    #endif
    float lViewPos = length(viewPos);
    
    /*
       DITHERING SYSTEM FOR SMOOTH TRANSITIONS
       ──────────────────────────────────────────────────────────────────────────
       Temporal dithering for smooth water surface transitions
    */
    float dither = Bayer64(gl_FragCoord.xy);
    #ifdef TAA
        dither = fract(dither + goldenRatio * mod(float(frameCounter), 3600.0));
    #endif
    
    /*
       ATMOSPHERIC COLOR SYSTEM
       ──────────────────────────────────────────────────────────────────────────
       Dynamic color correction based on atmospheric conditions
    */
    #ifdef LIGHT_COLOR_MULTS
        lightColorMult = GetLightColorMult();
    #endif
    #ifdef ATM_COLOR_MULTS
        atmColorMult = GetAtmColorMult();
        sqrtAtmColorMult = sqrt(atmColorMult);
    #endif
    
    /*
       VOLUMETRIC CLOUD INTEGRATION
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Advanced cloud occlusion for water surface rendering
    */
    #ifdef VL_CLOUDS_ACTIVE
        float cloudLinearDepth = texelFetch(gaux1, texelCoord, 0).r;
        
        if (pow2(cloudLinearDepth + OSIEBCA * dither) * renderDistance < min(lViewPos, renderDistance)) discard;
    #endif
    
    /*
       MATERIAL PREPARATION SYSTEM
       ──────────────────────────────────────────────────────────────────────────
       Setup material properties for advanced rendering
    */
    #if WATER_MAT_QUALITY >= 3
        float materialMask = 0.0;              // Material identification mask
    #endif
    
    vec3 nViewPos = normalize(viewPos);        // Normalized view direction
    float VdotU = dot(nViewPos, upVec);        // View-Up angle for atmospheric effects
    float VdotS = dot(nViewPos, sunVec);       // View-Sun angle for lighting
    float VdotN = dot(nViewPos, normal);       // View-Normal angle for surface effects
    
    /*
       ADVANCED MATERIAL PROPERTY SETUP
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Comprehensive material system for realistic water rendering
    */
    vec4 translucentMult = vec4(1.0);          // Translucency multiplier
    bool noSmoothLighting = false;             // Lighting mode flags
    bool noDirectionalShading = false;
    bool translucentMultCalculated = false;
    bool noGeneratedNormals = false;
    
    int subsurfaceMode = 0;                    // Subsurface scattering mode
    float smoothnessG = 0.0;                   // Surface smoothness for reflections
    float highlightMult = 1.0;                 // Specular highlight multiplier
    float reflectMult = 0.0;                   // Reflection strength
    float emission = 0.0;                      // Emission intensity
    
    vec2 lmCoordM = lmCoord;                   // Modified light map coordinates
    vec3 normalM = VdotN > 0.0 ? -normal : normal; // Inverted Iris Water Normal Workaround
    vec3 geoNormal = normalM;                  // Geometric surface normal
    vec3 worldGeoNormal = normalize(ViewToPlayer(geoNormal * 10000.0)); // World-space normal
    vec3 shadowMult = vec3(1.0);               // Shadow multiplication factor
    float fresnel = clamp(1.0 + dot(normalM, nViewPos), 0.0, 1.0); // Fresnel effect
    
    /*
       ADVANCED MATERIAL PROCESSING
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: PBR and material-specific rendering systems
    */
    #ifdef IPBR
        #include "/lib/materialHandling/translucentMaterials.glsl"
        
        #ifdef GENERATED_NORMALS
            if (!noGeneratedNormals) GenerateNormals(normalM, colorP.rgb * colorP.a * 1.5);
        #endif
        
        #if IPBR_EMISSIVE_MODE != 1
            emission = GetCustomEmissionForIPBR(color, emission);
        #endif
    #else
        #ifdef CUSTOM_PBR
            float smoothnessD, materialMaskPh;
            GetCustomMaterials(color, normalM, lmCoordM, NdotU, shadowMult, smoothnessG, smoothnessD, highlightMult, emission, materialMaskPh, viewPos, lViewPos);
            reflectMult = smoothnessD;
        #endif
        
        /*
           MATERIAL-SPECIFIC PROCESSING
           ──────────────────────────────────────────────────────────────────────
           @VcorA: Specialized rendering for different material types
        */
        if (mat == 32000) { // Water Material
            #include "/lib/specificMaterials/translucents/water.glsl"
        } else if (mat == 30020) { // Nether Portal
            #ifdef SPECIAL_PORTAL_EFFECTS
                #include "/lib/specificMaterials/translucents/netherPortal.glsl"
            #endif
        }
    #endif
    
    /*
       SELECTION OUTLINE INTEGRATION
       ──────────────────────────────────────────────────────────────────────────
       Support for versatile selection outline system
    */
    #if WATER_MAT_QUALITY >= 3 && SELECT_OUTLINE == 4
        int materialMaskInt = int(texelFetch(colortex6, texelCoord, 0).g * 255.1);
        if (materialMaskInt == 252) {
            materialMask = OSIEBCA * 252.0; // Versatile Selection Outline
        }
    #endif
    
    /*
       TRANSLUCENCY BLENDING SYSTEM
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Advanced alpha blending for realistic water transparency
    */
    if (!translucentMultCalculated)
        translucentMult = vec4(mix(vec3(0.666), color.rgb * (1.0 - pow2(pow2(color.a))), color.a), 1.0);
    
    // Distance-based transparency adjustment
    translucentMult.rgb = mix(translucentMult.rgb, vec3(1.0), min1(pow2(pow2(lViewPos / far))));
    
    /*
       COMPREHENSIVE LIGHTING SYSTEM
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Advanced lighting with subsurface scattering and highlights
    */
    DoLighting(color, shadowMult, playerPos, viewPos, lViewPos, geoNormal, normalM, dither,
               worldGeoNormal, lmCoordM, noSmoothLighting, noDirectionalShading, false,
               false, subsurfaceMode, smoothnessG, highlightMult, emission);
    
    /*
       ADVANCED REFLECTION SYSTEM
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Realistic water reflections with atmospheric integration
    */
    #if WATER_REFLECT_QUALITY >= 0
        #ifdef LIGHT_COLOR_MULTS
            highlightColor *= lightColorMult;
        #endif
        #ifdef MOON_PHASE_INF_REFLECTION
            highlightColor *= pow2(moonPhaseInfluence);
        #endif
        
        float fresnelM = (pow3(fresnel) * 0.85 + 0.15) * reflectMult;
        
        float skyLightFactor = pow2(max(lmCoordM.y - 0.7, 0.0) * 3.33333);
        #if SHADOW_QUALITY > -1 && WATER_REFLECT_QUALITY >= 2 && WATER_MAT_QUALITY >= 2
            skyLightFactor = max(skyLightFactor, min1(dot(shadowMult, shadowMult)));
        #endif
        
        /*
           REFLECTION CALCULATION
           ──────────────────────────────────────────────────────────────────────
           Complex reflection system with atmospheric effects
        */
        vec4 reflection = GetReflection(normalM, viewPos.xyz, nViewPos, playerPos, lViewPos, -1.0,
                                        depthtex1, dither, skyLightFactor, fresnel,
                                        smoothnessG, geoNormal, color.rgb, shadowMult, highlightMult);
        
        color.rgb = mix(color.rgb, reflection.rgb, fresnelM);
    #endif
    
    // Development debugging system integration
    #ifdef COLOR_CODED_PROGRAMS
        ColorCodeProgram(color, mat);
    #endif
    
    /*
       ATMOSPHERIC FOG INTEGRATION
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Advanced fog system with sky interaction
    */
    float sky = 0.0;
    DoFog(color.rgb, sky, lViewPos, playerPos, VdotU, VdotS, dither);
    color.a *= 1.0 - sky;
    
    /*
       OUTPUT BUFFER ASSIGNMENT
       ──────────────────────────────────────────────────────────────────────────
       Multiple render targets for deferred shading pipeline
    */
    /* DRAWBUFFERS:03 */
    gl_FragData[0] = color;                                    // Main color output
    gl_FragData[1] = vec4(1.0 - translucentMult.rgb, translucentMult.a); // Translucency data
    
    // High-quality material masking for advanced effects
    #if DETAIL_QUALITY >= 3
        /* DRAWBUFFERS:036 */
        gl_FragData[2] = vec4(0.0, materialMask, 0.0, 1.0);    // Material identification
    #endif
}

#endif

/*
===============================================================================
   VERTEX SHADER PIPELINE
===============================================================================
   Advanced vertex processing for water and translucent materials
*/
#ifdef VERTEX_SHADER

/*
   OUTPUT DATA TO FRAGMENT SHADER
   ────────────────────────────────────────────────────────────────────────────
   Comprehensive vertex data for advanced material processing
*/
flat out int mat;                   // Material identification ID

out vec2 texCoord;                  // Primary texture coordinates
out vec2 lmCoord;                   // Light map coordinates
out vec2 signMidCoordPos;           // Texture coordinate signs for POM
flat out vec2 absMidCoordPos;       // Absolute texture coordinate positions

flat out vec3 upVec, sunVec, northVec, eastVec; // Directional vectors
out vec3 playerPos;                 // World position relative to player
out vec3 normal;                    // Surface normal vector
out vec3 viewVector;                // View direction in tangent space

out vec4 glColor;                   // Vertex color from OpenGL state

// Advanced normal mapping support
#if WATER_STYLE >= 2 || RAIN_PUDDLES >= 1 && WATER_STYLE == 1 && WATER_MAT_QUALITY >= 2 || defined GENERATED_NORMALS || defined CUSTOM_PBR
    flat out vec3 binormal, tangent; // Tangent space vectors
#endif

// Parallax Occlusion Mapping support
#ifdef POM
    out vec4 vTexCoordAM;           // Advanced texture coordinates for POM
#endif

/*
   VERTEX ATTRIBUTES
   ────────────────────────────────────────────────────────────────────────────
   Input attributes from Minecraft's vertex data
*/
attribute vec4 mc_Entity;           // Entity and material information
attribute vec4 mc_midTexCoord;      // Middle texture coordinates for POM
attribute vec4 at_tangent;          // Tangent vector with handedness

/*
   FALLBACK VARIABLE DECLARATIONS
   ────────────────────────────────────────────────────────────────────────────
   Declare variables when advanced features are disabled
*/
#if WATER_STYLE >= 2 || RAIN_PUDDLES >= 1 && WATER_STYLE == 1 && WATER_MAT_QUALITY >= 2 || defined GENERATED_NORMALS || defined CUSTOM_PBR
#else
    vec3 binormal;
    vec3 tangent;
#endif

/*
   VERTEX PROCESSING UTILITIES
   ────────────────────────────────────────────────────────────────────────────
   TAA and wave animation support
*/
#ifdef TAA
    #include "/lib/smoothing/sampleOffset.glsl"
#endif

#ifdef WAVING_WATER_VERTEX
    #include "/lib/materialMethods/wavingBlocks.glsl"
#endif

/*
   MAIN VERTEX PROCESSING
   ────────────────────────────────────────────────────────────────────────────
   @VcorA: Advanced vertex transformation with water animation support
   
   Features:
   • Texture coordinate mapping and POM setup
   • Tangent space calculation for normal mapping
   • Dynamic water wave animation
   • TAA jittering for temporal stability
   • Directional vector calculation for atmospheric effects
*/
void main() {
    /*
       TEXTURE COORDINATE SETUP
       ──────────────────────────────────────────────────────────────────────────
       Map texture coordinates and setup lighting coordinates
    */
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmCoord  = GetLightMapCoordinates();
    
    /*
       COLOR AND MATERIAL SETUP
       ──────────────────────────────────────────────────────────────────────────
       Transfer vertex color and material identification
    */
    glColor = gl_Color;
    mat = int(mc_Entity.x + 0.5);              // Extract material ID from entity data
    
    /*
       SURFACE NORMAL AND DIRECTIONAL VECTORS
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Calculate world-space directional vectors for atmospheric effects
    */
    normal = normalize(gl_NormalMatrix * gl_Normal);
    upVec = normalize(gbufferModelView[1].xyz);    // World up direction
    eastVec = normalize(gbufferModelView[0].xyz);  // World east direction
    northVec = normalize(gbufferModelView[2].xyz); // World north direction
    sunVec = GetSunVector();                       // Current sun/moon position
    
    /*
       TANGENT SPACE SETUP
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Advanced tangent space calculation for normal mapping
    */
    binormal = normalize(gl_NormalMatrix * cross(at_tangent.xyz, gl_Normal.xyz) * at_tangent.w);
    tangent  = normalize(gl_NormalMatrix * at_tangent.xyz);
    
    /*
       TANGENT-BINORMAL-NORMAL MATRIX CONSTRUCTION
       ──────────────────────────────────────────────────────────────────────────
       Create transformation matrix for tangent space calculations
    */
    mat3 tbnMatrix = mat3(
        tangent.x, binormal.x, normal.x,
        tangent.y, binormal.y, normal.y,
        tangent.z, binormal.z, normal.z
    );
    
    /*
       VIEW VECTOR CALCULATION
       ──────────────────────────────────────────────────────────────────────────
       Transform view vector to tangent space for advanced material effects
    */
    viewVector = tbnMatrix * (gl_ModelViewMatrix * gl_Vertex).xyz;
    
    /*
       PARALLAX OCCLUSION MAPPING SETUP
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Advanced texture coordinate preparation for POM effects
    */
    vec2 midCoord = (gl_TextureMatrix[0] * mc_midTexCoord).st;
    vec2 texMinMidCoord = texCoord - midCoord;
    signMidCoordPos = sign(texMinMidCoord);
    absMidCoordPos  = abs(texMinMidCoord);
    
    #ifdef POM
        vTexCoordAM.zw  = abs(texMinMidCoord) * 2;
        vTexCoordAM.xy  = min(texCoord, midCoord - texMinMidCoord);
    #endif
    
    /*
       WORLD POSITION CALCULATION
       ──────────────────────────────────────────────────────────────────────────
       Convert to world space for wave animation and atmospheric effects
    */
    vec4 position = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;
    playerPos = position.xyz;
    
    /*
       DYNAMIC WATER WAVE ANIMATION
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Apply realistic wave physics to water vertices
    */
    #ifdef WAVING_WATER_VERTEX
        DoWave(position.xyz, mat);
    #endif
    
    /*
       FINAL VERTEX TRANSFORMATION
       ──────────────────────────────────────────────────────────────────────────
       Apply projection and TAA jittering
    */
    gl_Position = gl_ProjectionMatrix * gbufferModelView * position;
    
    #ifdef TAA
        gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
    #endif
}

#endif

/*
===============================================================================
   END OF FLOW SHADER
   @VcorA - Advanced water and translucent material rendering system
===============================================================================
*/
