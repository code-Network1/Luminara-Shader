/*
===============================================================================
   SHINE GLSL - Luminara Shader Advanced Glint and Enchantment Effects System
===============================================================================
   Sophisticated Enchantment Glint and Magical Effect Rendering Pipeline
   
   ● Purpose: Advanced enchantment glint effects and magical item rendering
   ● Features: Dynamic glint strength, hand swaying, enchantment animations
   ● Performance: Optimized for real-time magical effect rendering
   
   Credits & Rights:
   • VcorA - Advanced enchantment glint system development
   • Sophisticated magical effect rendering algorithms
   • Dynamic glint strength processing for Minecraft compatibility
   • Advanced hand swaying system for immersive first-person effects
   • Optimized rendering pipeline for enchanted items and tools
   • Enhanced visual effects for magical and special items
   
   Technical Specifications:
   - Dynamic glint strength processing for Minecraft's enchantment system
   - Advanced hand swaying effects for enhanced immersion
   - Optimized rendering for enchanted items and magical effects
   - Support for color-coded program debugging
   - High-performance vertex transformation for glint effects
   - Seamless integration with Minecraft's enchantment rendering
   - Enhanced visual feedback for magical item interactions
===============================================================================
*/

// Core shader library integration
#include "/lib/shader_modules/shader_master.glsl"

/*
===============================================================================
   FRAGMENT SHADER PIPELINE
===============================================================================
   Advanced enchantment glint and magical effect rendering system
*/
#ifdef FRAGMENT_SHADER

/*
   INPUT DATA FROM VERTEX SHADER
   ────────────────────────────────────────────────────────────────────────────
   Essential data for enchantment glint rendering
*/
in vec2 texCoord;                   // Primary texture coordinates for glint texture sampling
flat in vec4 glColor;               // Vertex color containing glint strength and tinting

/*
   ADVANCED EFFECT LIBRARY INTEGRATION
   ────────────────────────────────────────────────────────────────────────────
   Development and debugging systems for enchantment effects
*/
#ifdef COLOR_CODED_PROGRAMS
    #include "/lib/effects/effects_unified.glsl"
#endif

/*
   MAIN ENCHANTMENT GLINT RENDERING SYSTEM
   ────────────────────────────────────────────────────────────────────────────
   @VcorA: Advanced enchantment glint and magical effect rendering pipeline
   
   Features:
   • High-quality enchantment glint texture sampling
   • Dynamic glint strength processing for Minecraft compatibility
   • Advanced color modulation for magical effects
   • Optimized rendering for performance and visual quality
   
   Processing Pipeline:
   1. Sample enchantment glint texture at specified coordinates
   2. Apply vertex color modulation for base glint effects
   3. Process dynamic glint strength for Minecraft compatibility
   4. Integrate development debugging systems when enabled
   5. Output final enchantment glint for composite rendering
*/
void main() {
    /*
       ENCHANTMENT GLINT TEXTURE SAMPLING
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Sample enchantment glint texture with high precision
       
       The glint texture contains the magical shimmer patterns that create
       the characteristic enchantment effect on items and tools.
    */
    vec4 color = texture2D(tex, texCoord);
    
    /*
       BASE COLOR MODULATION
       ──────────────────────────────────────────────────────────────────────────
       Apply vertex color to enchantment glint for base effects
       
       This applies the fundamental color properties to the glint effect,
       including basic tinting and alpha values from the vertex processing stage.
    */
    color *= glColor;
    
    /*
       DYNAMIC GLINT STRENGTH PROCESSING
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Advanced glint strength system for Minecraft compatibility
       
       This crucial processing step implements Minecraft's "Glint Strength" system,
       which allows for dynamic control of enchantment effect intensity.
       The alpha channel contains the strength value that modulates the glint visibility.
    */
    color.rgb *= glColor.a; // Essential for Minecraft's "Glint Strength" system
    
    /*
       DEVELOPMENT DEBUGGING INTEGRATION
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Color-coded program identification for development
       
       When enabled, this system provides visual debugging information
       to help developers identify which shader program is rendering specific
       enchantment effects and magical elements.
    */
    #ifdef COLOR_CODED_PROGRAMS
        ColorCodeProgram(color, -1);  // -1 indicates enchantment/glint program
    #endif
    
    /*
       FINAL OUTPUT BUFFER ASSIGNMENT
       ──────────────────────────────────────────────────────────────────────────
       Output enchantment glint to primary color buffer
       
       The processed enchantment glint is rendered directly to the main color buffer
       where it will be composited with the underlying item texture by the
       Minecraft rendering engine to create the final enchanted appearance.
    */
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = color;
}

#endif

/*
===============================================================================
   VERTEX SHADER PIPELINE
===============================================================================
   Advanced vertex processing for enchantment glint and hand effects
*/
#ifdef VERTEX_SHADER

/*
   OUTPUT DATA TO FRAGMENT SHADER
   ────────────────────────────────────────────────────────────────────────────
   Essential vertex data for enchantment glint processing
*/
out vec2 texCoord;                  // Texture coordinates for glint texture sampling
flat out vec4 glColor;              // Vertex color for glint effects and strength

/*
   MAIN VERTEX PROCESSING SYSTEM
   ────────────────────────────────────────────────────────────────────────────
   @VcorA: Efficient vertex transformation for enchantment glint effects
   
   Features:
   • Optimized vertex transformation using fixed-function pipeline
   • Accurate texture coordinate mapping for glint patterns
   • Advanced hand swaying effects for immersive first-person experience
   • Preservation of vertex colors for glint strength processing
   • High-performance processing for real-time enchantment rendering
   
   Processing Pipeline:
   1. Transform vertex position using optimized fixed-function transform
   2. Map texture coordinates for enchantment glint sampling
   3. Transfer vertex color data for glint strength processing
   4. Apply advanced hand swaying effects when enabled and appropriate
*/
void main() {
    /*
       OPTIMIZED VERTEX TRANSFORMATION
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: High-performance vertex position transformation
       
       Using ftransform() for optimal performance in enchantment glint rendering.
       This function combines modelview and projection transformations efficiently,
       providing the best performance for magical effect geometric transformations.
    */
    gl_Position = ftransform();
    
    /*
       TEXTURE COORDINATE MAPPING
       ──────────────────────────────────────────────────────────────────────────
       Map texture coordinates for enchantment glint sampling
       
       The texture matrix transformation ensures proper alignment of enchantment
       glint patterns with the underlying item geometry, maintaining visual consistency
       across different items, tools, and enchantment levels.
    */
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    
    /*
       VERTEX COLOR TRANSFER
       ──────────────────────────────────────────────────────────────────────────
       Transfer vertex color data for enchantment effects
       
       Vertex colors carry important information about:
       • Enchantment glint strength and intensity
       • Base color tinting for different enchantment types
       • Alpha values for glint visibility control
       • Animation parameters for dynamic magical effects
    */
    glColor = gl_Color;
    
    /*
       ADVANCED HAND SWAYING SYSTEM
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Immersive first-person hand movement effects
       
       When hand swaying is enabled and the projection matrix indicates first-person
       rendering (projection matrix [2][2] > -0.5), this system applies realistic
       hand movement effects to enhance immersion and visual appeal.
    */
    #if HAND_SWAYING > 0
        if (gl_ProjectionMatrix[2][2] > -0.5) {
            // Hand sway code is now directly in effects_unified.glsl as comments
            #if HAND_SWAYING == 1
                const float handSwayMult = 0.5;
            #elif HAND_SWAYING == 2
                const float handSwayMult = 1.0;
            #elif HAND_SWAYING == 3
                const float handSwayMult = 2.0;
            #endif
            gl_Position.x += handSwayMult * (sin(frameTimeCounter * 0.86)) / 256.0;
            gl_Position.y += handSwayMult * (cos(frameTimeCounter * 1.5)) / 64.0;
        }
    #endif
}

#endif

/*
===============================================================================
   END OF SHINE SHADER
   @VcorA - Advanced enchantment glint and magical effect rendering system
===============================================================================
*/
