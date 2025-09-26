/*
===============================================================================
   GAZE GLSL - Luminara Shader Special Entity Effects System
===============================================================================
   Advanced Special Entity Eye Effects and Luminous Rendering Pipeline
   
   ● Purpose: Specialized rendering for entity eyes and luminous effects
   ● Features: Dynamic eye glow, entity-specific visual enhancements, brightness control
   ● Performance: Optimized for real-time entity effect rendering
   
   Credits & Rights:
   • VcorA - Advanced entity eye effect system development
   • Specialized Enderman eye rendering algorithms
   • Dynamic luminosity control for special entities
   • Breeze entity brightness correction system
   • Enhanced color processing for supernatural effects
   
   Technical Specifications:
   - Intelligent color detection and replacement for entity eyes
   - Advanced luminosity analysis and brightness correction
   - Dynamic color enhancement for supernatural entities
   - Support for IPBR material system integration
   - Optimized rendering for glowing entity features
   - Color-coded program support for development debugging
   - High-performance real-time entity effect processing
===============================================================================
*/

// Core shader library integration
#include "/lib/shader_modules/shader_master.glsl"

/*
===============================================================================
   FRAGMENT SHADER PIPELINE
===============================================================================
   Advanced entity eye effects and luminous rendering system
*/
#ifdef FRAGMENT_SHADER

/*
   INPUT DATA FROM VERTEX SHADER
   ────────────────────────────────────────────────────────────────────────────
   Essential data for entity effect rendering
*/
in vec2 texCoord;                   // Primary texture coordinates for entity texture sampling
in vec4 glColor;                    // Vertex color from OpenGL state for entity coloring

/*
   ADVANCED EFFECT LIBRARY INTEGRATION
   ────────────────────────────────────────────────────────────────────────────
   Development and debugging systems for entity effects
*/
#ifdef COLOR_CODED_PROGRAMS
    #include "/lib/effects/effects_unified.glsl"
#endif

/*
   MAIN ENTITY EFFECT RENDERING SYSTEM
   ────────────────────────────────────────────────────────────────────────────
   @VcorA: Advanced entity eye effects and luminous rendering pipeline
   
   Features:
   • Intelligent Enderman eye effect system
   • Dynamic brightness correction for ultra-bright entities
   • Advanced color enhancement for supernatural effects
   • Optimized luminosity analysis and control
   
   Processing Pipeline:
   1. Sample entity texture and apply vertex coloring
   2. Detect and enhance specific entity eye colors (Enderman)
   3. Apply brightness correction for problematic entities (Breeze)
   4. Enhance color saturation for supernatural glow effects
   5. Integrate development debugging systems when enabled
*/
void main() {
    /*
       ENTITY TEXTURE SAMPLING AND BASE COLORING
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Sample entity texture and apply vertex color modulation
       
       This combines the base entity texture with vertex colors to create
       the foundation for all subsequent entity effect processing.
    */
    vec4 color = texture2D(tex, texCoord) * glColor;
    
    /*
       SPECIALIZED ENDERMAN EYE EFFECT SYSTEM
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Advanced Enderman eye detection and enhancement
       
       When IPBR is enabled, this system intelligently detects the characteristic
       purple color of Enderman eyes and replaces it with an enhanced version
       for improved visual impact and supernatural appearance.
    */
    #ifdef IPBR
        if (CheckForColor(color.rgb, vec3(224, 121, 250))) { // Enderman Eye Edge Detection
            color.rgb = vec3(0.8, 0.25, 0.8);  // Enhanced purple glow for supernatural effect
        }
    #endif
    
    /*
       ULTRA-BRIGHT ENTITY CORRECTION SYSTEM
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Dynamic brightness correction for problematic entities
       
       This system specifically addresses the ultra-bright Breeze entity and similar
       cases where default rendering produces visually overwhelming brightness.
       The correction uses luminance analysis to selectively reduce brightness
       while preserving color information and visual detail.
    */
    color.rgb *= 1.0 - 0.6 * pow2(pow2(min1(GetLuminance(color.rgb) * 1.2))); // Breeze brightness fix
    
    /*
       SUPERNATURAL COLOR ENHANCEMENT SYSTEM
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Advanced color processing for entity glow effects
       
       This two-stage enhancement system creates more vibrant and supernatural
       appearance for special entities:
       
       Stage 1: Gamma correction for improved color response
       Stage 2: Blue and green channel enhancement for otherworldly glow
    */
    // Stage 1: Apply gamma correction for enhanced color response
    color.rgb = pow1_5(color.rgb);
    
    // Stage 2: Enhanced supernatural glow with blue/green emphasis
    color.rgb *= pow2(1.0 + color.b + 0.5 * color.g) * 1.5;
    
    /*
       DEVELOPMENT DEBUGGING INTEGRATION
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Color-coded program identification for development
       
       When enabled, this system provides visual debugging information
       to help developers identify which shader program is rendering specific
       entity effects and special visual elements.
    */
    #ifdef COLOR_CODED_PROGRAMS
        ColorCodeProgram(color, -1);  // -1 indicates special entity/gaze program
    #endif
    
    /*
       FINAL OUTPUT BUFFER ASSIGNMENT
       ──────────────────────────────────────────────────────────────────────────
       Output enhanced entity effects to primary color buffer
       
       The processed entity effects are rendered directly to the main color buffer
       where they integrate seamlessly with the overall rendering pipeline.
    */
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = color;
}

#endif

/*
===============================================================================
   VERTEX SHADER PIPELINE
===============================================================================
   Optimized vertex processing for entity effect rendering
*/
#ifdef VERTEX_SHADER

/*
   OUTPUT DATA TO FRAGMENT SHADER
   ────────────────────────────────────────────────────────────────────────────
   Essential vertex data for entity effect processing
*/
out vec2 texCoord;                  // Texture coordinates for entity texture sampling
out vec4 glColor;                   // Vertex color for entity coloring and effects

/*
   MAIN VERTEX PROCESSING SYSTEM
   ────────────────────────────────────────────────────────────────────────────
   @VcorA: Efficient vertex transformation for entity effects
   
   Features:
   • Optimized vertex transformation using fixed-function pipeline
   • Accurate texture coordinate mapping for entity textures
   • Preservation of vertex colors for entity-specific effects
   • High-performance processing for real-time entity rendering
   
   Processing Pipeline:
   1. Transform vertex position using optimized fixed-function transform
   2. Map texture coordinates for entity texture sampling
   3. Transfer vertex color data for fragment shader processing
*/
void main() {
    /*
       OPTIMIZED VERTEX TRANSFORMATION
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: High-performance vertex position transformation
       
       Using ftransform() for optimal performance in entity effect rendering.
       This function combines modelview and projection transformations efficiently,
       providing the best performance for entity geometric transformations.
    */
    gl_Position = ftransform();
    
    /*
       TEXTURE COORDINATE MAPPING
       ──────────────────────────────────────────────────────────────────────────
       Map texture coordinates for entity texture sampling
       
       The texture matrix transformation ensures proper alignment of entity
       textures with the geometry, maintaining visual consistency across
       different entity types, animations, and rendering contexts.
    */
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    
    /*
       VERTEX COLOR TRANSFER
       ──────────────────────────────────────────────────────────────────────────
       Transfer vertex color data for entity effect processing
       
       Vertex colors carry important information about:
       • Entity-specific coloring and tinting
       • Dynamic lighting effects on entities
       • Special effect parameters for supernatural entities
       • Animation state and transition information
    */
    glColor = gl_Color;
}

#endif

/*
===============================================================================
   END OF GAZE SHADER
   @VcorA - Advanced entity eye effects and luminous rendering system
===============================================================================
*/
