/*
===============================================================================
   SOULS GLSL - Luminara Shader Advanced Entity Rendering System
===============================================================================
   Comprehensive Entity Rendering and Soul-like Effect Pipeline
   
   ● Purpose: Advanced rendering for all entities with soul-like visual effects
   ● Features: IPBR materials, entity-specific effects, advanced lighting
   ● Performance: Optimized for real-time entity rendering with complex materials
   
   Credits & Rights:
   • VcorA - Advanced entity rendering system development
   • Sophisticated entity material handling algorithms
   • Lightning bolt and special entity effect systems
   • Advanced normal mapping and PBR integration for entities
   • Entity reflection handling and lighting optimization
   • Flickering fix systems for stable entity rendering
   
   Technical Specifications:
   - Comprehensive IPBR material system for entities
   - Advanced entity-specific effect processing
   - Lightning bolt rendering with specialized effects
   - Support for generated normals and parallax occlusion mapping
   - Entity reflection and material masking systems
   - Iris shader compatibility with material recoloring
   - Flickering fix systems for item frames and special entities
   - Multi-dimensional lighting support for all entity types
===============================================================================
*/

// Core shader library integration
#include "/lib/shader_modules/shader_master.glsl"

/*
===============================================================================
   FRAGMENT SHADER PIPELINE
===============================================================================
   Advanced entity rendering with soul-like effects and materials
*/
#ifdef FRAGMENT_SHADER

/*
   INPUT VERTEX DATA
   ────────────────────────────────────────────────────────────────────────────
   Comprehensive vertex data for advanced entity material processing
*/
in vec2 texCoord;                   // Primary texture coordinates
in vec2 lmCoord;                    // Light map coordinates for lighting

flat in vec3 upVec, sunVec, northVec, eastVec; // Directional vectors for calculations
in vec3 normal;                     // Surface normal vector

in vec4 glColor;                    // Vertex color from OpenGL state

// Advanced material processing support
#if defined GENERATED_NORMALS || defined COATED_TEXTURES || defined POM || defined IPBR && defined IS_IRIS
    in vec2 signMidCoordPos;        // Texture coordinate signs for POM
    flat in vec2 absMidCoordPos;    // Absolute texture coordinate positions
    flat in vec2 midCoord;          // Middle texture coordinates
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
   @VcorA: Advanced normal mapping transformation matrix for entity surfaces
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
   Advanced rendering systems for entity materials and effects
*/
#include "/lib/atmospherics/luminara_atmospheric_core.glsl"
#include "/lib/illumination_systems/core_illumination_system.glsl"

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

// Development and debugging
#ifdef COLOR_CODED_PROGRAMS
    #include "/lib/effects/effects_unified.glsl"
#endif

/*
   MAIN ENTITY RENDERING SYSTEM
   ────────────────────────────────────────────────────────────────────────────
   @VcorA: Advanced entity rendering with soul-like effects and materials
   
   Processing Pipeline:
   1. Entity texture sampling and color preparation
   2. Material property initialization and setup
   3. Alpha testing and fragment validation
   4. Coordinate system setup and position calculations
   5. Entity-specific material processing (IPBR or custom)
   6. Entity-specific effect handling (lightning, boats, etc.)
   7. Advanced lighting and surface processing
   8. Reflection and material output preparation
*/
void main() {
    /*
       ENTITY TEXTURE SAMPLING AND COLOR PREPARATION
       ──────────────────────────────────────────────────────────────────────────
       Sample entity texture and prepare color data for processing
    */
    vec4 color = texture2D(tex, texCoord);
    #ifdef GENERATED_NORMALS
        vec3 colorP = color.rgb;               // Preserve original color for normal generation
    #endif
    color *= glColor;                          // Apply vertex color modulation
    
    /*
       MATERIAL PROPERTY INITIALIZATION
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Setup comprehensive material properties for entity rendering
    */
    float smoothnessD = 0.0, skyLightFactor = 0.0, materialMask = OSIEBCA * 254.0; // No SSAO, No TAA
    vec3 normalM = normal;
    
    /*
       ADVANCED ALPHA TESTING SYSTEM
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Enhanced alpha testing with pixelation artifact prevention
    */
    float alphaCheck = color.a;
    #ifdef DO_PIXELATION_EFFECTS
        // Fixes artifacts on fragment edges with non-nvidia gpus
        alphaCheck = max(fwidth(color.a), alphaCheck);
    #endif
    
    /*
       MAIN ENTITY PROCESSING BLOCK
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Core entity rendering processing with advanced materials
    */
    if (alphaCheck > 0.001) {
        /*
           COORDINATE SYSTEM AND POSITION SETUP
           ──────────────────────────────────────────────────────────────────────
           Convert screen coordinates to view and world space for advanced calculations
        */
        vec3 screenPos = vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z);
        vec3 viewPos = ScreenToView(screenPos);
        vec3 nViewPos = normalize(viewPos);
        vec3 playerPos = ViewToPlayer(viewPos);
        float lViewPos = length(viewPos);
        
        /*
           ENTITY LIGHTING CONFIGURATION
           ──────────────────────────────────────────────────────────────────────
           @VcorA: Entity-specific lighting setup and material properties
        */
        bool noSmoothLighting = atlasSize.x < 600.0; // Fire brightness fix
        bool noGeneratedNormals = false, noDirectionalShading = false, noVanillaAO = false;
        float smoothnessG = 0.0, highlightMult = 0.0, emission = 0.0, noiseFactor = 0.75;
        vec2 lmCoordM = lmCoord;
        vec3 shadowMult = vec3(1.0);
        
        /*
           ADVANCED MATERIAL PROCESSING SYSTEM
           ──────────────────────────────────────────────────────────────────────
           @VcorA: Comprehensive material handling with IPBR or custom PBR support
        */
        #ifdef IPBR
            #include "/lib/materialHandling/entityMaterials.glsl"
            
            /*
               IRIS SHADER COMPATIBILITY SYSTEM
               ──────────────────────────────────────────────────────────────────
               @VcorA: Advanced Iris integration with material recoloring
            */
            #ifdef IS_IRIS
                vec3 maRecolor = vec3(0.0);
                #include "/lib/materialHandling/irisMaterials.glsl"
            #endif
            
            // Entity reflection handling
            if (materialMask != OSIEBCA * 254.0) materialMask += OSIEBCA * 100.0;
            
            /*
               ADVANCED SURFACE PROCESSING
               ──────────────────────────────────────────────────────────────────
               @VcorA: Generated normals and texture coating systems
            */
            #ifdef GENERATED_NORMALS
                if (!noGeneratedNormals) GenerateNormals(normalM, colorP);
            #endif
            
            #ifdef COATED_TEXTURES
                CoatTextures(color.rgb, noiseFactor, playerPos, false);
            #endif
            
            #if IPBR_EMISSIVE_MODE != 1
                emission = GetCustomEmissionForIPBR(color, emission);
            #endif
        #else
            #ifdef CUSTOM_PBR
                GetCustomMaterials(color, normalM, lmCoordM, NdotU, shadowMult, smoothnessG, smoothnessD, highlightMult, emission, materialMask, viewPos, lViewPos);
            #endif
            
            /*
               ENTITY-SPECIFIC PROCESSING
               ──────────────────────────────────────────────────────────────────
               @VcorA: Specialized rendering for different entity types
            */
            if (entityId == 50004) { // Lightning Bolt
                #include "/lib/specificMaterials/entities/lightningBolt.glsl"
            } else if (entityId == 50008) { // Item Frame, Glow Item Frame
                noSmoothLighting = true;
            } else if (entityId == 50076) { // Boats
                playerPos.y += 0.38; // consistentBOAT2176
            }
        #endif
        
        /*
           ENTITY COLOR INTEGRATION
           ──────────────────────────────────────────────────────────────────────
           Apply entity-specific coloring effects
        */
        color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);
        
        /*
           NORMAL PROCESSING AND LIGHTING PREPARATION
           ──────────────────────────────────────────────────────────────────────
           @VcorA: Advanced normal processing for entity lighting
        */
        normalM = gl_FrontFacing ? normalM : -normalM; // Inverted Normal Workaround
        vec3 geoNormal = normalM;
        vec3 worldGeoNormal = normalize(ViewToPlayer(geoNormal * 10000.0));
        
        /*
           COMPREHENSIVE LIGHTING SYSTEM
           ──────────────────────────────────────────────────────────────────────
           @VcorA: Advanced lighting with entity-aware processing
        */
        DoLighting(color, shadowMult, playerPos, viewPos, lViewPos, geoNormal, normalM, 0.5,
                   worldGeoNormal, lmCoordM, noSmoothLighting, noDirectionalShading, noVanillaAO,
                   true, 0, smoothnessG, highlightMult, emission);
        
        /*
           IRIS MATERIAL RECOLORING INTEGRATION
           ──────────────────────────────────────────────────────────────────────
           @VcorA: Apply Iris-specific material recoloring effects
        */
        #if defined IPBR && defined IS_IRIS
            color.rgb += maRecolor;
        #endif
        
        /*
           REFLECTION PREPARATION SYSTEM
           ──────────────────────────────────────────────────────────────────────
           @VcorA: Sky light factor calculation for entity reflection processing
        */
        #ifdef PBR_REFLECTIONS
            #ifdef OVERWORLD
                skyLightFactor = pow2(max(lmCoord.y - 0.7, 0.0) * 3.33333);
            #else
                skyLightFactor = dot(shadowMult, shadowMult) / 3.0;
            #endif
        #endif
    }
    
    /*
       DEVELOPMENT DEBUGGING INTEGRATION
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Color-coded program identification for development
    */
    #ifdef COLOR_CODED_PROGRAMS
        ColorCodeProgram(color, -1);  // -1 indicates entity/souls program
    #endif
    
    /*
       OUTPUT BUFFER ASSIGNMENT
       ──────────────────────────────────────────────────────────────────────────
       Multiple render targets for deferred shading pipeline
    */
    /* DRAWBUFFERS:06 */
    gl_FragData[0] = color;                                    // Main entity color output
    gl_FragData[1] = vec4(smoothnessD, materialMask, skyLightFactor, 1.0); // Material properties
    
    // High-quality reflection normal output
    #if BLOCK_REFLECT_QUALITY >= 2 && RP_MODE >= 1
        /* DRAWBUFFERS:065 */
        gl_FragData[2] = vec4(mat3(gbufferModelViewInverse) * normalM, 1.0); // World-space normals
    #endif
}

#endif

/*
===============================================================================
   VERTEX SHADER PIPELINE
===============================================================================
   Advanced vertex processing for entities with soul-like effects
*/
#ifdef VERTEX_SHADER

/*
   OUTPUT DATA TO FRAGMENT SHADER
   ────────────────────────────────────────────────────────────────────────────
   Comprehensive vertex data for advanced entity material processing
*/
out vec2 texCoord;                  // Primary texture coordinates
out vec2 lmCoord;                   // Light map coordinates

flat out vec3 upVec, sunVec, northVec, eastVec; // Directional vectors
out vec3 normal;                    // Surface normal vector

out vec4 glColor;                   // Vertex color from OpenGL state

// Advanced material processing support
#if defined GENERATED_NORMALS || defined COATED_TEXTURES || defined POM || defined IPBR && defined IS_IRIS
    out vec2 signMidCoordPos;       // Texture coordinate signs for POM
    flat out vec2 absMidCoordPos;   // Absolute texture coordinate positions
    flat out vec2 midCoord;         // Middle texture coordinates
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
#if defined GENERATED_NORMALS || defined COATED_TEXTURES || defined POM || defined IPBR && defined IS_IRIS
    attribute vec4 mc_midTexCoord;  // Middle texture coordinates for POM
#endif

#if defined GENERATED_NORMALS || defined CUSTOM_PBR
    attribute vec4 at_tangent;      // Tangent vector with handedness
#endif

/*
   MAIN VERTEX PROCESSING SYSTEM
   ────────────────────────────────────────────────────────────────────────────
   @VcorA: Advanced vertex transformation for entities with soul-like effects
   
   Features:
   • Optimized vertex transformation for entity geometry
   • Entity brightness control and lighting coordination
   • Texture coordinate mapping and POM setup
   • Tangent space calculation for normal mapping
   • Flickering fix systems for stable entity rendering
   • Entity-specific depth adjustments and fixes
*/
void main() {
    /*
       ENTITY VERTEX TRANSFORMATION
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: High-performance vertex position transformation for entities
    */
    gl_Position = ftransform();
    
    /*
       TEXTURE COORDINATE AND LIGHTING SETUP
       ──────────────────────────────────────────────────────────────────────────
       Map texture coordinates and setup lighting coordinates
    */
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmCoord  = GetLightMapCoordinates();
    
    /*
       ENTITY BRIGHTNESS CONTROL SYSTEM
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Advanced brightness control for entity lighting
       
       Fixes issues with servers/mods making entities insanely bright,
       while also slightly reducing the max blocklight on normal entities.
    */
    lmCoord.x = min(lmCoord.x, 0.9);
    
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
       ADVANCED TEXTURE COORDINATE PROCESSING
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: POM and texture generation coordinate setup
    */
    #if defined GENERATED_NORMALS || defined COATED_TEXTURES || defined POM || defined IPBR && defined IS_IRIS
        midCoord = (gl_TextureMatrix[0] * mc_midTexCoord).st;
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
    
    /*
       GLOWING ENTITIES DEPTH ADJUSTMENT
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Special depth handling for glowing entity effects
    */
    #ifdef GBUFFERS_ENTITIES_GLOWING
        if (glColor.a > 0.99) gl_Position.z *= 0.01;
    #endif
    
    /*
       FLICKERING FIX SYSTEM
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Advanced flickering prevention for stable entity rendering
    */
    #ifdef FLICKERING_FIX
        if (entityId == 50008 || entityId == 50012) { // Item Frame, Glow Item Frame
            if (dot(normal, upVec) > 0.99) {
                vec4 position = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;
                vec3 comPos = fract(position.xyz + cameraPosition);
                comPos = abs(comPos - vec3(0.5));
                if ((comPos.y > 0.437 && comPos.y < 0.438) || (comPos.y > 0.468 && comPos.y < 0.469)) {
                    gl_Position.z += 0.0001;
                }
            }
            if (gl_Normal.y == 1.0) { // Maps
                normal = upVec * 2.0;
            }
        } else if (entityId == 50084) { // Slime, Chicken
            gl_Position.z -= 0.00015;
        }
        
        #if SHADOW_QUALITY == -1
            if (glColor.a < 0.5) gl_Position.z += 0.0005;
        #endif
    #endif
}

#endif

/*
===============================================================================
   END OF SOULS SHADER
   @VcorA - Advanced entity rendering with soul-like effects system
===============================================================================
*/
