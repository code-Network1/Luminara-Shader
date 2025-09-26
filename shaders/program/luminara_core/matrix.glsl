/*
===============================================================================
   MATRIX GLSL - Luminara Shader Advanced Block Entity Rendering System
===============================================================================
   Comprehensive Block Entity and Advanced Material Rendering Pipeline
   
   ● Purpose: Advanced rendering for block entities, portals, and complex materials
   ● Features: PBR materials, portal effects, custom textures, normal mapping
   ● Performance: Optimized for real-time complex block entity rendering
   
   Credits & Rights:
   • VcorA - Advanced block entity rendering system development
   • Sophisticated End Portal effect algorithms
   • Multi-dimensional material handling systems
   • Advanced PBR integration and reflection processing
   • Custom texture coating and normal generation systems
   • Optimized lighting calculations for complex geometry
   
   Technical Specifications:
   - Comprehensive IPBR material system integration
   - Advanced End Portal and Gateway effect rendering
   - Sophisticated sign text rendering with dynamic lighting
   - Support for generated normals and parallax occlusion mapping
   - Multi-stage reflection and material processing
   - Custom texture coating with noise factor modulation
   - TAA compatibility for temporal stability
   - Extensive debugging and development support systems
===============================================================================
*/

// Core shader library integration
#include "/lib/shader_modules/shader_master.glsl"

/*
===============================================================================
   FRAGMENT SHADER PIPELINE
===============================================================================
   Advanced block entity and material processing system
*/
#ifdef FRAGMENT_SHADER

/*
   INPUT VERTEX DATA
   ────────────────────────────────────────────────────────────────────────────
   Comprehensive vertex data for advanced material processing
*/
in vec2 texCoord;                   // Primary texture coordinates
in vec2 lmCoord;                    // Light map coordinates for lighting

flat in vec3 upVec, sunVec, northVec, eastVec; // Directional vectors for calculations
in vec3 normal;                     // Surface normal vector

in vec4 glColor;                    // Vertex color from OpenGL state

// Advanced material processing support
#if defined GENERATED_NORMALS || defined COATED_TEXTURES || defined POM
    in vec2 signMidCoordPos;        // Texture coordinate signs for POM
    flat in vec2 absMidCoordPos;    // Absolute texture coordinate positions
#endif

// Normal mapping and PBR support
#if defined GENERATED_NORMALS || defined CUSTOM_PBR
    flat in vec3 binormal, tangent; // Tangent space vectors for normal mapping
#endif

// Parallax Occlusion Mapping support
#ifdef POM
    in vec3 viewVector;             // View direction in tangent space
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
#if defined GENERATED_NORMALS || defined CUSTOM_PBR
    mat3 tbnMatrix = mat3(
        tangent.x, binormal.x, normal.x,
        tangent.y, binormal.y, normal.y,
        tangent.z, binormal.z, normal.z
    );
#endif

/*
   COMPREHENSIVE LIBRARY INTEGRATION
   ────────────────────────────────────────────────────────────────────────────
   Advanced rendering systems for block entities and materials
*/
#include "/lib/atmospherics/luminara_atmospheric_core.glsl"
#include "/lib/illumination_systems/core_illumination_system.glsl"

// Temporal Anti-Aliasing support
#ifdef TAA
    #include "/lib/smoothing/sampleOffset.glsl"
#endif

// Advanced texture processing systems
#if defined GENERATED_NORMALS || defined COATED_TEXTURES
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

#ifdef COATED_TEXTURES
    #include "/lib/materialMethods/coatedTextures.glsl"
#endif

// Custom emission and material systems
#if IPBR_EMISSIVE_MODE != 1
    #include "/lib/materialMethods/customEmission.glsl"
#endif

#ifdef CUSTOM_PBR
    #include "/lib/materialHandling/customMaterials.glsl"
#endif

// Development and special effects
#ifdef COLOR_CODED_PROGRAMS
    #include "/lib/effects/effects_unified.glsl"
#endif

#ifdef PORTAL_EDGE_EFFECT
    // Voxelization remains as separate include due to its complexity
    #include "/lib/effects/effects_unified.glsl"
#endif

/*
   MAIN BLOCK ENTITY PROCESSING
   ────────────────────────────────────────────────────────────────────────────
   @VcorA: Advanced block entity and material rendering system
   
   Processing Pipeline:
   1. Texture sampling and color preparation
   2. Coordinate system setup and position calculations
   3. Material property initialization and setup
   4. IPBR or custom PBR material processing
   5. Block entity specific effect handling
   6. Advanced lighting and surface processing
   7. Reflection and material output preparation
*/
void main() {
    /*
       TEXTURE SAMPLING AND COLOR PREPARATION
       ──────────────────────────────────────────────────────────────────────────
       Sample base texture and prepare color data for processing
    */
    vec4 color = texture2D(tex, texCoord);
    #ifdef GENERATED_NORMALS
        vec3 colorP = color.rgb;               // Preserve original color for normal generation
    #endif
    color *= glColor;                          // Apply vertex color modulation
    
    /*
       COORDINATE SYSTEM AND POSITION SETUP
       ──────────────────────────────────────────────────────────────────────────
       Convert screen coordinates to view and world space for advanced calculations
    */
    vec3 screenPos = vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z);
    #ifdef TAA
        vec3 viewPos = ScreenToView(vec3(TAAJitter(screenPos.xy, -0.5), screenPos.z));
    #else
        vec3 viewPos = ScreenToView(screenPos);
    #endif
    float lViewPos = length(viewPos);
    vec3 playerPos = ViewToPlayer(viewPos);
    
    /*
       MATERIAL PROPERTY INITIALIZATION
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Setup comprehensive material properties for advanced rendering
    */
    bool noSmoothLighting = false, noDirectionalShading = false;
    float smoothnessD = 0.0, skyLightFactor = 0.0, materialMask = 0.0;
    float smoothnessG = 0.0, highlightMult = 1.0, emission = 0.0, noiseFactor = 1.0;
    vec2 lmCoordM = lmCoord;
    vec3 normalM = normal, geoNormal = normal, shadowMult = vec3(1.0);
    vec3 worldGeoNormal = normalize(ViewToPlayer(geoNormal * 10000.0));
    
    /*
       ADVANCED MATERIAL PROCESSING SYSTEM
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Comprehensive material handling with IPBR or custom PBR support
    */
    #ifdef IPBR
        #include "/lib/materialHandling/blockEntityMaterials.glsl"
        
        #if IPBR_EMISSIVE_MODE != 1
            emission = GetCustomEmissionForIPBR(color, emission);
        #endif
    #else
        #ifdef CUSTOM_PBR
            GetCustomMaterials(color, normalM, lmCoordM, NdotU, shadowMult, smoothnessG, smoothnessD, highlightMult, emission, materialMask, viewPos, lViewPos);
        #endif
        
        /*
           BLOCK ENTITY SPECIFIC PROCESSING
           ──────────────────────────────────────────────────────────────────────
           @VcorA: Specialized rendering for different block entity types
        */
        if (blockEntityId == 5025) { // End Portal and End Gateway
            #ifdef SPECIAL_PORTAL_EFFECTS
                #include "/lib/specificMaterials/others/endPortalEffect.glsl"
            #endif
        } else if (blockEntityId == 5004) { // Signs and Text
            noSmoothLighting = true;
            if (glColor.r + glColor.g + glColor.b <= 2.99 || lmCoord.x > 0.999) { // Sign Text Detection
                #include "/lib/specificMaterials/others/signText.glsl"
            }
        } else {
            noSmoothLighting = true;           // Default for other block entities
        }
    #endif
    
    /*
       ADVANCED SURFACE PROCESSING
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Generated normals and texture coating systems
    */
    #ifdef GENERATED_NORMALS
        GenerateNormals(normalM, colorP);
    #endif
    
    #ifdef COATED_TEXTURES
        CoatTextures(color.rgb, noiseFactor, playerPos, false);
    #endif
    
    /*
       COMPREHENSIVE LIGHTING SYSTEM
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Advanced lighting with material-aware processing
    */
    DoLighting(color, shadowMult, playerPos, viewPos, lViewPos, geoNormal, normalM, 0.5,
               worldGeoNormal, lmCoordM, noSmoothLighting, noDirectionalShading, false,
               false, 0, smoothnessG, highlightMult, emission);
    
    /*
       REFLECTION PREPARATION SYSTEM
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Sky light factor calculation for reflection processing
    */
    #ifdef PBR_REFLECTIONS
        #ifdef OVERWORLD
            skyLightFactor = pow2(max(lmCoord.y - 0.7, 0.0) * 3.33333);
        #else
            skyLightFactor = dot(shadowMult, shadowMult) / 3.0;
        #endif
    #endif
    
    /*
       DEVELOPMENT DEBUGGING INTEGRATION
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Color-coded program identification for development
    */
    #ifdef COLOR_CODED_PROGRAMS
        ColorCodeProgram(color, blockEntityId);
    #endif
    
    /*
       OUTPUT BUFFER ASSIGNMENT
       ──────────────────────────────────────────────────────────────────────────
       Multiple render targets for deferred shading pipeline
    */
    /* DRAWBUFFERS:06 */
    gl_FragData[0] = color;                                    // Main color output
    gl_FragData[1] = vec4(smoothnessD, materialMask, skyLightFactor, 1.0); // Material properties
    
    // High-quality reflection normal output
    #if BLOCK_REFLECT_QUALITY >= 2 && RP_MODE != 0
        /* DRAWBUFFERS:065 */
        gl_FragData[2] = vec4(mat3(gbufferModelViewInverse) * normalM, 1.0); // World-space normals
    #endif
}

#endif

/*
===============================================================================
   VERTEX SHADER PIPELINE
===============================================================================
   Advanced vertex processing for block entities and complex materials
*/
#ifdef VERTEX_SHADER

/*
   OUTPUT DATA TO FRAGMENT SHADER
   ────────────────────────────────────────────────────────────────────────────
   Comprehensive vertex data for advanced material processing
*/
out vec2 texCoord;                  // Primary texture coordinates
out vec2 lmCoord;                   // Light map coordinates

flat out vec3 upVec, sunVec, northVec, eastVec; // Directional vectors
out vec3 normal;                    // Surface normal vector

out vec4 glColor;                   // Vertex color from OpenGL state

// Advanced material processing support
#if defined GENERATED_NORMALS || defined COATED_TEXTURES || defined POM
    out vec2 signMidCoordPos;       // Texture coordinate signs for POM
    flat out vec2 absMidCoordPos;   // Absolute texture coordinate positions
#endif

// Normal mapping and PBR support
#if defined GENERATED_NORMALS || defined CUSTOM_PBR
    flat out vec3 binormal, tangent; // Tangent space vectors
#endif

// Parallax Occlusion Mapping support
#ifdef POM
    out vec3 viewVector;            // View direction in tangent space
    out vec4 vTexCoordAM;           // Advanced texture coordinates for POM
#endif

/*
   VERTEX ATTRIBUTES
   ────────────────────────────────────────────────────────────────────────────
   Input attributes from Minecraft's vertex data
*/
#if defined GENERATED_NORMALS || defined COATED_TEXTURES || defined POM
    attribute vec4 mc_midTexCoord;  // Middle texture coordinates for POM
#endif

#if defined GENERATED_NORMALS || defined CUSTOM_PBR
    attribute vec4 at_tangent;      // Tangent vector with handedness
#endif

/*
   VERTEX PROCESSING UTILITIES
   ────────────────────────────────────────────────────────────────────────────
   TAA support for temporal stability
*/
#ifdef TAA
    #include "/lib/smoothing/sampleOffset.glsl"
#endif

/*
   MAIN VERTEX PROCESSING
   ────────────────────────────────────────────────────────────────────────────
   @VcorA: Advanced vertex transformation with block entity specific handling
   
   Features:
   • Optimized vertex transformation with TAA support
   • Texture coordinate mapping and POM setup
   • Tangent space calculation for normal mapping
   • Block entity specific adjustments and fixes
   • Directional vector calculation for atmospheric effects
*/
void main() {
    /*
       VERTEX TRANSFORMATION WITH TAA SUPPORT
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: High-performance vertex position transformation
    */
    gl_Position = ftransform();
    #ifdef TAA
        gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
    #endif
    
    /*
       TEXTURE COORDINATE AND LIGHTING SETUP
       ──────────────────────────────────────────────────────────────────────────
       Map texture coordinates and setup lighting coordinates
    */
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmCoord  = GetLightMapCoordinates();
    
    /*
       COLOR AND NORMAL SETUP
       ──────────────────────────────────────────────────────────────────────────
       Transfer vertex color and calculate surface normal
    */
    glColor = gl_Color;
    normal = normalize(gl_NormalMatrix * gl_Normal);
    
    /*
       DIRECTIONAL VECTORS CALCULATION
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Calculate world-space directional vectors for atmospheric effects
    */
    upVec = normalize(gbufferModelView[1].xyz);    // World up direction
    eastVec = normalize(gbufferModelView[0].xyz);  // World east direction
    northVec = normalize(gbufferModelView[2].xyz); // World north direction
    sunVec = GetSunVector();                       // Current sun/moon position
    
    /*
       MOD COMPATIBILITY FIXES
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Compatibility fixes for modded content
    */
    if (normal != normal) normal = -upVec; // Mod Fix: Better Nether Fireflies NaN normal fix
    
    /*
       BLOCK ENTITY SPECIFIC ADJUSTMENTS
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Special handling for specific block entity types
    */
    #ifdef IPBR
        // Future: End Portal depth adjustment for proper rendering
        /*if (blockEntityId == 5024) { // End Portal, End Gateway
            gl_Position.z -= 0.002;
        }*/
    #endif
    
    /*
       ADVANCED TEXTURE COORDINATE PROCESSING
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: POM and texture generation coordinate setup
    */
    #if defined GENERATED_NORMALS || defined COATED_TEXTURES || defined POM
        // Chest rendering fix for proper depth handling
        if (blockEntityId == 5008) { // Chest
            float fractWorldPosY = fract((gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex).y + cameraPosition.y);
            if (fractWorldPosY > 0.56 && 0.57 > fractWorldPosY) gl_Position.z -= 0.0001;
        }
        
        // POM coordinate setup
        vec2 midCoord = (gl_TextureMatrix[0] * mc_midTexCoord).st;
        vec2 texMinMidCoord = texCoord - midCoord;
        signMidCoordPos = sign(texMinMidCoord);
        absMidCoordPos  = abs(texMinMidCoord);
    #endif
    
    /*
       TANGENT SPACE SETUP
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Advanced tangent space calculation for normal mapping
    */
    #if defined GENERATED_NORMALS || defined CUSTOM_PBR
        binormal = normalize(gl_NormalMatrix * cross(at_tangent.xyz, gl_Normal.xyz) * at_tangent.w);
        tangent  = normalize(gl_NormalMatrix * at_tangent.xyz);
    #endif
    
    /*
       PARALLAX OCCLUSION MAPPING SETUP
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Advanced texture coordinate preparation for POM effects
    */
    #ifdef POM
        mat3 tbnMatrix = mat3(
            tangent.x, binormal.x, normal.x,
            tangent.y, binormal.y, normal.y,
            tangent.z, binormal.z, normal.z
        );
        
        viewVector = tbnMatrix * (gl_ModelViewMatrix * gl_Vertex).xyz;
        
        vTexCoordAM.zw  = abs(texMinMidCoord) * 2;
        vTexCoordAM.xy  = min(texCoord, midCoord - texMinMidCoord);
    #endif
}

#endif

/*
===============================================================================
   END OF MATRIX SHADER
   @VcorA - Advanced block entity and material rendering system
===============================================================================
*/
