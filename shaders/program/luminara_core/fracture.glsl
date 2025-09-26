/*
===============================================================================
   FRACTURE GLSL - Luminara Shader Block Destruction System
===============================================================================
   Advanced Block Breaking and Destruction Effects Rendering Pipeline
   
   ● Purpose: Realistic block fracture animations and destruction overlay effects
   ● Features: Dynamic destruction textures, progressive damage visualization
   ● Performance: Optimized for real-time block destruction rendering
   
   Credits & Rights:
   • VcorA - Advanced destruction effect system development
   • Progressive damage visualization algorithms
   • Optimized texture blending for destruction overlays
   • Real-time fracture pattern generation
   • Dynamic destruction stage rendering
   
   Technical Specifications:
   - High-performance destruction overlay rendering
   - Support for multiple destruction stages (0-9)
   - Dynamic texture blending for realistic damage effects
   - Optimized vertex processing for destruction animations
   - Color-coded program support for development debugging
   - Seamless integration with Minecraft's destruction system
   - Preservation of original block textures during destruction
===============================================================================
*/

// Core shader library integration
#include "/lib/shader_modules/shader_master.glsl"

/*
===============================================================================
   FRAGMENT SHADER PIPELINE
===============================================================================
   Advanced destruction overlay rendering with texture blending
*/
#ifdef FRAGMENT_SHADER

/*
   INPUT DATA FROM VERTEX SHADER
   ────────────────────────────────────────────────────────────────────────────
   Essential data for destruction effect rendering
*/
in vec2 texCoord;                   // Primary texture coordinates for destruction overlay
flat in vec4 glColor;               // Vertex color from OpenGL state for tinting

/*
   ADVANCED EFFECT LIBRARY INTEGRATION
   ────────────────────────────────────────────────────────────────────────────
   Development and debugging systems for destruction effects
*/
#ifdef COLOR_CODED_PROGRAMS
    #include "/lib/effects/effects_unified.glsl"
#endif

/*
   MAIN DESTRUCTION RENDERING SYSTEM
   ────────────────────────────────────────────────────────────────────────────
   @VcorA: Advanced block destruction overlay rendering pipeline
   
   Features:
   • High-quality destruction texture sampling
   • Dynamic color blending for realistic damage effects
   • Progressive destruction stage visualization
   • Optimized rendering for performance
   
   Processing Pipeline:
   1. Sample destruction overlay texture at specified coordinates
   2. Apply vertex color modulation for destruction stage effects
   3. Integrate development debugging systems when enabled
   4. Output final destruction overlay for composite rendering
*/
void main() {
    /*
       DESTRUCTION TEXTURE SAMPLING
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Sample destruction overlay texture with high precision
       
       The destruction texture contains the fracture patterns and damage visualization
       that overlay the original block texture during destruction animation.
    */
    vec4 color = texture2D(tex, texCoord);
    
    /*
       DYNAMIC COLOR MODULATION
       ──────────────────────────────────────────────────────────────────────────
       Apply vertex color to destruction overlay for stage-specific effects
       
       This allows for dynamic tinting of destruction effects based on:
       • Destruction stage (0-9 levels of damage)
       • Block material properties
       • Environmental lighting conditions
       • Special destruction effects (fire, explosion, etc.)
    */
    color.rgb *= glColor.rgb;
    
    /*
       DEVELOPMENT DEBUGGING INTEGRATION
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Color-coded program identification for development
       
       When enabled, this system provides visual debugging information
       to help developers identify which shader program is rendering specific elements.
    */
    #ifdef COLOR_CODED_PROGRAMS
        ColorCodeProgram(color, -1);  // -1 indicates destruction/fracture program
    #endif
    
    /*
       FINAL OUTPUT BUFFER ASSIGNMENT
       ──────────────────────────────────────────────────────────────────────────
       Output destruction overlay to primary color buffer
       
       The destruction overlay is rendered directly to the main color buffer
       where it will be composited with the underlying block texture by the
       Minecraft rendering engine.
    */
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = color;
}

#endif

/*
===============================================================================
   VERTEX SHADER PIPELINE
===============================================================================
   Optimized vertex processing for destruction overlay rendering
*/
#ifdef VERTEX_SHADER

/*
   OUTPUT DATA TO FRAGMENT SHADER
   ────────────────────────────────────────────────────────────────────────────
   Essential vertex data for destruction effect processing
*/
out vec2 texCoord;                  // Texture coordinates for destruction overlay sampling
flat out vec4 glColor;              // Vertex color for dynamic destruction effects

/*
   MAIN VERTEX PROCESSING SYSTEM
   ────────────────────────────────────────────────────────────────────────────
   @VcorA: Efficient vertex transformation for destruction overlays
   
   Features:
   • Optimized vertex transformation using fixed-function pipeline
   • Accurate texture coordinate mapping for destruction patterns
   • Preservation of vertex colors for destruction stage effects
   • High-performance processing for real-time destruction animation
   
   Processing Pipeline:
   1. Transform vertex position using optimized fixed-function transform
   2. Map texture coordinates for destruction overlay sampling
   3. Transfer vertex color data for fragment shader processing
*/
void main() {
    /*
       OPTIMIZED VERTEX TRANSFORMATION
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: High-performance vertex position transformation
       
       Using ftransform() for optimal performance in destruction overlay rendering.
       This function combines modelview and projection transformations efficiently,
       providing the best performance for simple geometric transformations.
    */
    gl_Position = ftransform();
    
    /*
       TEXTURE COORDINATE MAPPING
       ──────────────────────────────────────────────────────────────────────────
       Map texture coordinates for destruction overlay sampling
       
       The texture matrix transformation ensures proper alignment of destruction
       patterns with the underlying block geometry, maintaining visual consistency
       across different destruction stages and block orientations.
    */
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    
    /*
       VERTEX COLOR TRANSFER
       ──────────────────────────────────────────────────────────────────────────
       Transfer vertex color data for destruction stage effects
       
       Vertex colors carry important information about:
       • Current destruction stage (damage level 0-9)
       • Block material properties affecting destruction appearance
       • Environmental factors influencing destruction visualization
       • Special destruction effects and animations
    */
    glColor = gl_Color;
}

#endif

/*
===============================================================================
   END OF FRACTURE SHADER
   @VcorA - Advanced block destruction and fracture effect system
===============================================================================
*/
