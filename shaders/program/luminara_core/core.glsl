/*
===============================================================================
   CORE GLSL - Luminara Shader Foundation
===============================================================================
   Universal Basic Rendering Pipeline
   
   ● Purpose: Core shader system for basic geometry and line rendering
   ● Features: Advanced lighting, selection outlines, line rendering
   ● Compatibility: Supports all world types and rendering modes
   
   Credits & Rights:
   • VcorA - Core architecture and lighting system development
   • Advanced selection outline system
   • Optimized line rendering algorithms
   • Multi-dimensional lighting support
   
   Technical Specifications:
   - Universal shader for basic geometry and lines
   - Supports TAA (Temporal Anti-Aliasing) integration
   - Advanced selection outline system with multiple modes
   - Optimized for both solid and transparent rendering
   - Cross-dimensional compatibility (Overworld, Nether, End)
===============================================================================
*/

// Core library integration for universal functionality
#include "/lib/shader_modules/shader_master.glsl"

/*
===============================================================================
   FRAGMENT SHADER PIPELINE
===============================================================================
   Advanced fragment processing with lighting and outline systems
*/
#ifdef FRAGMENT_SHADER

/*
   INPUT VERTEX DATA
   ────────────────────────────────────────────────────────────────────────────
   Data received from vertex shader stage
*/
flat in vec2 lmCoord;                          // Light map coordinates for lighting
flat in vec3 upVec, sunVec, northVec, eastVec; // Directional vectors for calculations
in vec3 normal;                                // Surface normal vector
flat in vec4 glColor;                          // Vertex color from OpenGL state

/*
   LIGHTING CALCULATIONS
   ────────────────────────────────────────────────────────────────────────────
   @VcorA: Advanced directional lighting system
   
   Features:
   • Dynamic sun positioning based on time
   • Shadow transition calculations
   • Multi-dimensional light vector support
*/
float NdotU = dot(normal, upVec);              // Normal-Up angle for surface orientation
float NdotUmax0 = max(NdotU, 0.0);            // Clamped upward normal component
float SdotU = dot(sunVec, upVec);              // Sun-Up angle for time calculations

// Advanced sun visibility system with smooth transitions
float sunFactor = SdotU < 0.0 ? clamp(SdotU + 0.375, 0.0, 0.75) / 0.75 : clamp(SdotU + 0.03125, 0.0, 0.0625) / 0.0625;
float sunVisibility = clamp(SdotU + 0.0625, 0.0, 0.125) / 0.125;
float sunVisibility2 = sunVisibility * sunVisibility;
float shadowTimeVar1 = abs(sunVisibility - 0.5) * 2.0;
float shadowTimeVar2 = shadowTimeVar1 * shadowTimeVar1;
float shadowTime = shadowTimeVar2 * shadowTimeVar2;

/*
   ADAPTIVE LIGHT VECTOR SYSTEM
   ────────────────────────────────────────────────────────────────────────────
   @VcorA: Dynamic light direction based on world type and time
*/
#ifdef OVERWORLD
    // Day/night cycle support with smooth transitions
    vec3 lightVec = sunVec * ((timeAngle < 0.5325 || timeAngle > 0.9675) ? 1.0 : -1.0);
#else
    // Static lighting for Nether and End dimensions
    vec3 lightVec = sunVec;
#endif

/*
   UTILITY SYSTEMS INTEGRATION
   ────────────────────────────────────────────────────────────────────────────
   Space conversion and lighting systems
*/
#include "/lib/atmospherics/luminara_atmospheric_core.glsl"
#include "/lib/illumination_systems/core_illumination_system.glsl"

// Temporal Anti-Aliasing support for stable rendering
#ifdef TAA
    #include "/lib/smoothing/sampleOffset.glsl"
#endif

// Development debugging system
#ifdef COLOR_CODED_PROGRAMS
    #include "/lib/effects/effects_unified.glsl"
#endif

/*
   MAIN FRAGMENT PROCESSING
   ────────────────────────────────────────────────────────────────────────────
   @VcorA: Universal fragment rendering with advanced features
   
   Processing Pipeline:
   1. Coordinate system setup
   2. Material preparation
   3. Lighting calculations
   4. Selection outline processing
   5. Color output
*/
void main() {
    // Initialize base color from vertex data
    vec4 color = glColor;
    
    /*
       COORDINATE SYSTEM TRANSFORMATION
       ──────────────────────────────────────────────────────────────────────────
       Convert screen coordinates to world space for lighting calculations
    */
    vec3 screenPos = vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z);
    #ifdef TAA
        vec3 viewPos = ScreenToView(vec3(TAAJitter(screenPos.xy, -0.5), screenPos.z));
    #else
        vec3 viewPos = ScreenToView(screenPos);
    #endif
    
    float lViewPos = length(viewPos);          // Distance from camera
    vec3 playerPos = ViewToPlayer(viewPos);    // World position relative to player
    
    /*
       MATERIAL AND SURFACE PREPARATION
       ──────────────────────────────────────────────────────────────────────────
       Setup material properties and surface normals for lighting
    */
    float materialMask = 0.0;                  // Material identification mask
    vec3 normalM = normal;                     // Modified normal for calculations
    vec3 geoNormal = normal;                   // Geometric surface normal
    vec3 shadowMult = vec3(1.0);              // Shadow multiplication factor
    vec3 worldGeoNormal = normalize(ViewToPlayer(geoNormal * 10000.0)); // World-space normal
    
    /*
       ADVANCED LIGHTING SYSTEM
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Core illumination system integration
       
       Features:
       • Dynamic shadow calculation
       • Multi-light source support
       • Material-aware lighting
       • Performance-optimized for real-time rendering
    */
    #ifndef GBUFFERS_LINE
        DoLighting(color, shadowMult, playerPos, viewPos, lViewPos, geoNormal, normalM, 0.5,
                   worldGeoNormal, lmCoord, false, false, false,
                   false, 0, 0.0, 0.0, 0.0);
    #endif
    
    /*
       SELECTION OUTLINE SYSTEM
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Advanced block selection visualization
       
       Supported Modes:
       • Mode 0: Disabled (discard transparent pixels)
       • Mode 1: Standard outline
       • Mode 2: Rainbow animated outline
       • Mode 3: Custom color outline
       • Mode 4: Versatile outline with material masking
    */
    #if SELECT_OUTLINE != 1 || defined SELECT_OUTLINE_AUTO_HIDE
    if (abs(color.a - 0.4) + dot(color.rgb, color.rgb) < 0.01) {
        #if SELECT_OUTLINE == 0
            // Mode 0: Disable selection outline
            discard;
        #elif SELECT_OUTLINE == 2
            // Mode 2: Rainbow animated outline
            float posFactor = playerPos.x + playerPos.y + playerPos.z + cameraPosition.x + cameraPosition.y + cameraPosition.z;
            color.rgb = clamp(abs(mod(fract(frameTimeCounter*0.25 + posFactor*0.2) * 6.0 + vec3(0.0,4.0,2.0), 6.0) - 3.0) - 1.0,
                        0.0, 1.0) * vec3(3.0, 2.0, 3.0) * SELECT_OUTLINE_I;
        #elif SELECT_OUTLINE == 3
            // Mode 3: Custom color outline
            color.rgb = vec3(SELECT_OUTLINE_R, SELECT_OUTLINE_G, SELECT_OUTLINE_B) * SELECT_OUTLINE_I;
        #elif SELECT_OUTLINE == 4
            // Mode 4: Versatile outline with material masking
            color.a = 0.1;
            materialMask = OSIEBCA * 252.0; // Versatile Selection Outline identifier
        #endif
        
        /*
           AUTO-HIDE FUNCTIONALITY
           ──────────────────────────────────────────────────────────────────────
           @VcorA: Intelligent outline hiding based on held items
           
           Automatically hides selection outline when:
           • Both hands are empty
           • Only light sources, totems, or shields in off-hand
        */
        #ifdef SELECT_OUTLINE_AUTO_HIDE
            if (heldItemId == 40008 && (
                heldItemId2 == 40008 ||
                heldItemId2 == 45060 ||
                heldItemId2 == 45108 ||
                heldItemId2 >= 44000 &&
                heldItemId2 < 45000)) {
                // Both hands hold nothing or only a light/totem/shield in off-hand
                discard;
            }
        #endif
    }
    #endif
    
    // Development debugging system integration
    #ifdef COLOR_CODED_PROGRAMS
        ColorCodeProgram(color, -1);
    #endif
    
    /*
       NETHER DIMENSION COMPATIBILITY
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Special handling for Nether dimension rendering
       
       Activates shadowmap in Nether for colored lighting when enabled
    */
    #if COLORED_LIGHTING_INTERNAL > 0 && defined NETHER
        if (gl_FragCoord.x < 0.0)
        color = shadow2D(shadowtex0, vec3(0.5)); // Activate shadowmap in Nether
    #endif
    
    /*
       OUTPUT BUFFER ASSIGNMENT
       ──────────────────────────────────────────────────────────────────────────
       Multiple render targets for deferred shading pipeline
    */
    /* DRAWBUFFERS:06 */
    gl_FragData[0] = color;                    // Main color output
    gl_FragData[1] = vec4(0.0, materialMask, 0.0, 1.0); // Material data for post-processing
}

#endif

/*
===============================================================================
   VERTEX SHADER PIPELINE
===============================================================================
   Advanced vertex processing with line rendering support
*/
#ifdef VERTEX_SHADER

/*
   OUTPUT DATA TO FRAGMENT SHADER
   ────────────────────────────────────────────────────────────────────────────
   Vertex data to be interpolated across triangle surface
*/
flat out vec2 lmCoord;                          // Light map coordinates
flat out vec3 upVec, sunVec, northVec, eastVec; // Directional vectors
out vec3 normal;                                // Surface normal
flat out vec4 glColor;                          // Vertex color

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
   @VcorA: Universal vertex transformation with line rendering support
   
   Features:
   • Standard triangle rendering
   • Advanced line rendering with width control
   • TAA jittering for temporal stability
   • Directional vector calculation for lighting
*/
void main() {
    /*
       POSITION TRANSFORMATION SYSTEM
       ──────────────────────────────────────────────────────────────────────────
       Handles both standard geometry and line rendering
    */
    #ifndef GBUFFERS_LINE
        // Standard vertex transformation for solid geometry
        gl_Position = ftransform();
    #else
        /*
           ADVANCED LINE RENDERING
           ──────────────────────────────────────────────────────────────────────
           @VcorA: Screen-space line width calculation with proper scaling
           
           Algorithm:
           1. Transform line endpoints to NDC space
           2. Calculate screen-space direction
           3. Generate perpendicular offset for width
           4. Apply vertex-specific offset based on vertex ID
        */
        float lineWidth = 2.0;                                    // Line width in pixels
        vec2 screenSize = vec2(viewWidth, viewHeight);            // Screen resolution
        const mat4 VIEW_SCALE = mat4(mat3(1.0 - (1.0 / 256.0))); // View scaling matrix
        
        // Transform line start and end points
        vec4 linePosStart = projectionMatrix * VIEW_SCALE * modelViewMatrix * vec4(vaPosition, 1.0);
        vec4 linePosEnd = projectionMatrix * VIEW_SCALE * modelViewMatrix * (vec4(vaPosition + vaNormal, 1.0));
        
        // Convert to normalized device coordinates
        vec3 ndc1 = linePosStart.xyz / linePosStart.w;
        vec3 ndc2 = linePosEnd.xyz / linePosEnd.w;
        
        // Calculate screen-space line direction and perpendicular offset
        vec2 lineScreenDirection = normalize((ndc2.xy - ndc1.xy) * screenSize);
        vec2 lineOffset = vec2(-lineScreenDirection.y, lineScreenDirection.x) * lineWidth / screenSize;
        
        // Ensure consistent winding order
        if (lineOffset.x < 0.0)
            lineOffset *= -1.0;
        
        // Apply vertex-specific offset for line width
        if (gl_VertexID % 2 == 0)
            gl_Position = vec4((ndc1 + vec3(lineOffset, 0.0)) * linePosStart.w, linePosStart.w);
        else
            gl_Position = vec4((ndc1 - vec3(lineOffset, 0.0)) * linePosStart.w, linePosStart.w);
    #endif
    
    // Apply TAA jittering for temporal stability
    #ifdef TAA
        gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
    #endif
    
    /*
       LIGHTING DATA PREPARATION
       ──────────────────────────────────────────────────────────────────────────
       Calculate lighting coordinates and surface properties
    */
    lmCoord = GetLightMapCoordinates();         // Light map texture coordinates
    glColor = gl_Color;                         // Vertex color from OpenGL state
    normal = normalize(gl_NormalMatrix * gl_Normal); // Transform surface normal to view space
    
    /*
       DIRECTIONAL VECTOR SETUP
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: World-space directional vectors for lighting calculations
       
       These vectors are used for:
       • Sun/moon position tracking
       • Atmospheric calculations
       • Shadow direction determination
       • Compass-based effects
    */
    upVec = normalize(gbufferModelView[1].xyz);    // World up direction
    eastVec = normalize(gbufferModelView[0].xyz);  // World east direction
    northVec = normalize(gbufferModelView[2].xyz); // World north direction
    sunVec = GetSunVector();                       // Current sun/moon position
}

#endif

/*
===============================================================================
   END OF CORE SHADER
   @VcorA - Universal foundation shader with advanced rendering capabilities
===============================================================================
*/
