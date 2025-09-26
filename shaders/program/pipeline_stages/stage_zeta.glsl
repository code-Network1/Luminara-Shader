/*============================================
 * Luminara Shader - Pipeline Stage Zeta
 * Temporal Anti-Aliasing & Smoothing Stage
 * Advanced Processing Implementation by VcorA
 *============================================*/

// Core Libraries
#include "/lib/shader_modules/shader_master.glsl"

/**
 * FRAGMENT SHADER - Temporal Processing Stage
 * Handles TAA and temporal filtering for smooth rendering
 */
#ifdef FRAGMENT_SHADER

// Input Variables
noperspective in vec2 texCoord;     // Screen texture coordinates

// Pipeline Configuration - Already included in shader_master.glsl
const bool colortex3MipmapEnabled = true;

// Screen Properties
vec2 view = vec2(viewWidth, viewHeight);

// Utility Functions
float GetLinearDepth(float depth) {
    // Convert non-linear depth buffer to linear depth space
    return (2.0 * near) / (far + near - depth * (far - near));
}

// Temporal Smoothing Library
#ifdef TAA
    #include "/lib/smoothing/temporalSmoothing.glsl"
#endif

/**
 * MAIN PROGRAM - Temporal Processing
 * Applies temporal anti-aliasing and smoothing effects
 */
void main() {
    // Sample the processed color buffer
    vec3 color = texelFetch(colortex3, texelCoord, 0).rgb;

    // Initialize temporal processing variables
    vec3 temp = vec3(0.0);
    float z1 = 0.0;

    #if defined TAA || defined TEMPORAL_FILTER
        z1 = texelFetch(depthtex1, texelCoord, 0).r;
    #endif

    #ifdef TAA
        // Apply Temporal Anti-Aliasing - VcorA Enhancement
        DoTAA(color, temp, z1);
    #endif

    /* DRAWBUFFERS:32 */
    gl_FragData[0] = vec4(color, 1.0);
    gl_FragData[1] = vec4(temp, 1.0);

    // Block reflection quality control - Optifine compatibility fix
    #if BLOCK_REFLECT_QUALITY >= 3 && RP_MODE >= 1
        /* DRAWBUFFERS:321 */
        gl_FragData[2] = vec4(z1, 1.0, 1.0, 1.0);
    #endif
}

#endif

/**
 * VERTEX SHADER - Standard Passthrough
 * Simple vertex processing for screen-space operations
 */
#ifdef VERTEX_SHADER

// Output Variables
noperspective out vec2 texCoord;    // Screen texture coordinates

/**
 * VERTEX PROGRAM - Standard Screen Transform
 * Basic vertex transformation for post-processing
 */
void main() {
    // Standard vertex transformation
    gl_Position = ftransform();

    // Pass texture coordinates through
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif
