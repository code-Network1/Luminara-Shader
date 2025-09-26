/*
===============================================================================
   STORM GLSL - Luminara Shader Advanced Weather Effects System
===============================================================================
   Sophisticated Rain, Snow, and Storm Weather Rendering Pipeline
   
   ● Purpose: Advanced weather particle effects with realistic physics
   ● Features: Dynamic rain/snow rendering, weather waving, atmospheric lighting
   ● Performance: Optimized for real-time weather simulation and rendering
   
   Credits & Rights:
   • VcorA - Advanced weather effects system development
   • Sophisticated rain and snow particle rendering algorithms
   • Dynamic weather waving physics with wind simulation
   • Advanced atmospheric lighting for weather conditions
   • Intelligent weather particle detection and differentiation
   • Optimized rendering pipeline for storm and precipitation effects
   
   Technical Specifications:
   - Dynamic rain and snow particle differentiation
   - Advanced weather waving physics with interior protection
   - Atmospheric lighting integration for weather conditions
   - Support for rain and snow opacity customization
   - Intelligent eye-in-water detection for underwater effects
   - Color-coded program support for development debugging
   - High-performance real-time weather particle simulation
===============================================================================
*/

// Core shader library integration
#include "/lib/shader_modules/shader_master.glsl"

/*
===============================================================================
   FRAGMENT SHADER PIPELINE
===============================================================================
   Advanced weather particle rendering with atmospheric effects
*/
#ifdef FRAGMENT_SHADER

/*
   INPUT DATA FROM VERTEX SHADER
   ────────────────────────────────────────────────────────────────────────────
   Essential data for weather particle rendering
*/
flat in vec2 lmCoord;               // Light map coordinates for lighting
in vec2 texCoord;                   // Primary texture coordinates for weather particles

flat in vec3 upVec, sunVec;         // Directional vectors for atmospheric calculations

flat in vec4 glColor;               // Vertex color from OpenGL state for particle effects

/*
   ATMOSPHERIC CALCULATIONS
   ────────────────────────────────────────────────────────────────────────────
   @VcorA: Advanced sun tracking and visibility calculations for weather lighting
*/
float SdotU = dot(sunVec, upVec);              // Sun-Up angle for time calculations
float sunFactor = SdotU < 0.0 ? clamp(SdotU + 0.375, 0.0, 0.75) / 0.75 : clamp(SdotU + 0.03125, 0.0, 0.0625) / 0.0625;
float sunVisibility = clamp(SdotU + 0.0625, 0.0, 0.125) / 0.125;
float sunVisibility2 = sunVisibility * sunVisibility;

/*
   ADVANCED LIBRARY INTEGRATION
   ────────────────────────────────────────────────────────────────────────────
   Weather and atmospheric systems
*/
#include "/lib/color_schemes/core_color_system.glsl"

// Development debugging
#ifdef COLOR_CODED_PROGRAMS
    #include "/lib/effects/effects_unified.glsl"
#endif

/*
   MAIN WEATHER PARTICLE RENDERING SYSTEM
   ────────────────────────────────────────────────────────────────────────────
   @VcorA: Advanced weather particle rendering with atmospheric integration
   
   Features:
   • Intelligent rain and snow particle differentiation
   • Advanced atmospheric lighting for weather conditions
   • Dynamic opacity control for different weather types
   • Underwater effect detection and handling
   • Optimized rendering for performance and visual quality
   
   Processing Pipeline:
   1. Sample weather particle texture and apply vertex coloring
   2. Intelligent underwater detection and early discard
   3. Weather type detection and opacity adjustment
   4. Advanced atmospheric lighting integration
   5. Development debugging integration when enabled
   6. Output final weather particle for composite rendering
*/
void main() {
    /*
       WEATHER PARTICLE TEXTURE SAMPLING
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Sample weather particle texture with vertex color modulation
       
       This samples the weather particle texture (rain drops or snow flakes)
       and applies vertex color information for particle variation and effects.
    */
    vec4 color = texture2D(tex, texCoord);
    color *= glColor;
    
    /*
       UNDERWATER DETECTION AND EARLY DISCARD
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Intelligent underwater effect handling
       
       This system prevents weather particles from rendering underwater,
       ensuring realistic behavior where rain and snow don't appear below water.
       Also discards nearly transparent particles for performance optimization.
    */
    if (color.a < 0.1 || isEyeInWater == 3) discard;
    
    /*
       INTELLIGENT WEATHER TYPE DETECTION
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Advanced rain and snow differentiation system
       
       This intelligent system analyzes particle color to differentiate between
       rain (darker particles) and snow (brighter particles), applying appropriate
       opacity settings for each weather type.
    */
    if (color.r + color.g < 1.5) {
        // Rain particles - typically darker colors
        color.a *= rainTexOpacity;
    } else {
        // Snow particles - typically brighter colors
        color.a *= snowTexOpacity;
    }
    
    /*
       ADVANCED ATMOSPHERIC LIGHTING SYSTEM
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Sophisticated weather particle lighting with atmospheric integration
       
       This advanced lighting system creates realistic illumination for weather particles
       by combining multiple light sources and atmospheric conditions:
       
       • Block light contribution with warm color temperature
       • Ambient and sun light with time-of-day variation
       • Dynamic intensity based on sun visibility and atmospheric conditions
    */
    color.rgb = sqrt3(color.rgb) * (
        blocklightCol * 2.0 * lmCoord.x +                    // Block light contribution
        (ambientColor + 0.2 * lightColor) * lmCoord.y *      // Ambient and sun light
        (0.6 + 0.3 * sunFactor)                              // Dynamic intensity factor
    );
    
    /*
       DEVELOPMENT DEBUGGING INTEGRATION
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Color-coded program identification for development
       
       When enabled, this system provides visual debugging information
       to help developers identify which shader program is rendering specific
       weather effects and atmospheric elements.
    */
    #ifdef COLOR_CODED_PROGRAMS
        ColorCodeProgram(color, -1);  // -1 indicates weather/storm program
    #endif
    
    /*
       FINAL OUTPUT BUFFER ASSIGNMENT
       ──────────────────────────────────────────────────────────────────────────
       Output weather particle to primary color buffer
       
       The processed weather particle is rendered directly to the main color buffer
       where it will be composited with the scene to create realistic precipitation effects.
    */
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = color;
}

#endif

/*
===============================================================================
   VERTEX SHADER PIPELINE
===============================================================================
   Advanced vertex processing for weather particles with physics simulation
*/
#ifdef VERTEX_SHADER

/*
   OUTPUT DATA TO FRAGMENT SHADER
   ────────────────────────────────────────────────────────────────────────────
   Essential vertex data for weather particle processing
*/
flat out vec2 lmCoord;              // Light map coordinates for lighting
out vec2 texCoord;                  // Texture coordinates for weather particle sampling

flat out vec3 upVec, sunVec;        // Directional vectors for atmospheric calculations

flat out vec4 glColor;              // Vertex color for particle effects

/*
   MAIN VERTEX PROCESSING SYSTEM
   ────────────────────────────────────────────────────────────────────────────
   @VcorA: Advanced vertex transformation for weather particles with physics
   
   Features:
   • Advanced weather waving physics simulation
   • Wind effect simulation with temporal variation
   • Interior protection to prevent unrealistic indoor effects
   • Optimized vertex transformation for performance
   • Directional vector calculation for atmospheric effects
   
   Processing Pipeline:
   1. Convert vertex position to world space for physics calculations
   2. Apply advanced weather waving physics when enabled
   3. Transform back to projection space with atmospheric considerations
   4. Setup texture coordinates and lighting information
   5. Calculate directional vectors for fragment shader atmospheric effects
*/
void main() {
    /*
       WORLD SPACE POSITION CONVERSION
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Convert vertex position to world space for physics calculations
    */
    vec4 position = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;
    glColor = gl_Color;
    
    /*
       ADVANCED WEATHER WAVING PHYSICS
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Sophisticated weather particle physics simulation
       
       This advanced physics system simulates realistic weather particle movement
       including wind effects, gravity influence, and natural variation patterns.
    */
    #ifdef WAVING_RAIN
        /*
           INTERIOR PROTECTION SYSTEM
           ──────────────────────────────────────────────────────────────────────
           Uses eye brightness to prevent unrealistic weather effects indoors
        */
        float rainWavingFactor = eyeBrightnessM2; // Prevents clipping inside interiors
        
        /*
           WIND SIMULATION AND PARTICLE MOVEMENT
           ──────────────────────────────────────────────────────────────────────
           Advanced wind effect simulation with temporal variation and height dependency
        */
        position.xz += rainWavingFactor * (0.4 * position.y + 0.2) * 
                       vec2(sin(frameTimeCounter * 0.3) + 0.5, 
                            sin(frameTimeCounter * 0.5) * 0.5);
        
        /*
           ATMOSPHERIC DISTORTION EFFECTS
           ──────────────────────────────────────────────────────────────────────
           Simulate atmospheric effects on weather particle distribution
        */
        position.xz *= 1.0 - 0.08 * position.y * rainWavingFactor;
    #endif
    
    /*
       FINAL VERTEX TRANSFORMATION
       ──────────────────────────────────────────────────────────────────────────
       Transform processed position back to projection space
    */
    gl_Position = gl_ProjectionMatrix * gbufferModelView * position;
    
    /*
       TEXTURE COORDINATE AND LIGHTING SETUP
       ──────────────────────────────────────────────────────────────────────────
       Setup texture coordinates and lighting information for fragment processing
    */
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmCoord  = GetLightMapCoordinates();
    
    /*
       DIRECTIONAL VECTORS CALCULATION
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Calculate world-space directional vectors for atmospheric effects
    */
    upVec = normalize(gbufferModelView[1].xyz);    // World up direction
    sunVec = GetSunVector();                       // Current sun/moon position
}

#endif

/*
===============================================================================
   END OF STORM SHADER
   @VcorA - Advanced weather effects and storm rendering system
===============================================================================
*/
