/*============================================
 * Luminara Shader - Pipeline Stage Eta
 * Anti-Aliasing Final Stage
 * FXAA Implementation by VcorA
 *============================================*/

// Core Libraries
#include "/lib/shader_modules/shader_master.glsl"

/**
 * FRAGMENT SHADER - Anti-Aliasing
 * Fast Approximate Anti-Aliasing for smooth edges
 */
#ifdef FRAGMENT_SHADER

// Input Variables
noperspective in vec2 texCoord;     // Screen texture coordinates

/* ==========================================
 * UTILITY FUNCTIONS - Depth Processing
 * ========================================== */
float GetLinearDepth(float depth) {
    // Convert non-linear depth to linear depth space
    return (2.0 * near) / (far + near - depth * (far - near));
}

// Anti-Aliasing Library
#if FXAA_DEFINE == 1
    #include "/lib/smoothing/fastSmoothing.glsl"
#endif

/**
 * MAIN PROGRAM - FXAA Processing
 * Apply fast anti-aliasing to final render
 */
void main() {
    // Sample the final color buffer
    vec3 color = texelFetch(colortex3, texelCoord, 0).rgb;
        
    #if FXAA_DEFINE == 1
        // Apply Fast Approximate Anti-Aliasing - VcorA
        FXAA311(color);
    #endif

    /* DRAWBUFFERS:3 */
    gl_FragData[0] = vec4(color, 1.0);
}

#endif

/*============================================
 * VERTEX SHADER - Screen Pass Setup
 *============================================*/
#ifdef VERTEX_SHADER

noperspective out vec2 texCoord;

/**
 * MAIN VERTEX PROGRAM - VcorA Implementation
 */
void main() {
    gl_Position = ftransform();

    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif
