/*============================================
 * Luminara Shader - Pipeline Stage Delta
 * Bloom Processing Stage
 * Advanced Bloom System by VcorA
 *============================================*/

// Core Libraries
#include "/lib/shader_modules/shader_master.glsl"

// Input/Output Variables
varying vec2 texCoord;      // Screen texture coordinates

/**
 * FRAGMENT SHADER - Bloom Implementation
 * Multi-level bloom with Gaussian blur sampling
 */
#ifdef FRAGMENT_SHADER

/* ==========================================
 * BLOOM CONFIGURATION - VcorA Enhancement
 * ========================================== */
const bool colortex0MipmapEnabled = true;    // Enable mipmapping for bloom

// Gaussian blur weights for 7x7 kernel
float weight[7] = float[7](1.0, 6.0, 15.0, 20.0, 15.0, 6.0, 1.0);

// Screen dimensions vector
vec2 view = vec2(viewWidth, viewHeight);

//Common Functions//
vec3 BloomTile(float lod, vec2 offset, vec2 scaledCoord) {
    vec3 bloom = vec3(0.0);
    float scale = exp2(lod);
    vec2 coord = (scaledCoord - offset) * scale;
    float padding = 0.5 + 0.005 * scale;

    if (abs(coord.x - 0.5) < padding && abs(coord.y - 0.5) < padding) {
        for (int i = -3; i <= 3; i++) {
            for (int j = -3; j <= 3; j++) {
                float wg = weight[i + 3] * weight[j + 3];
                vec2 pixelOffset = vec2(i, j) / view;
                vec2 bloomCoord = (scaledCoord - offset + pixelOffset) * scale;
                bloom += texture2D(colortex0, bloomCoord).rgb * wg;
            }
        }
        bloom /= 4096.0;
    }

    return pow(bloom / 128.0, vec3(0.25));
}

//Includes//

//Program//
void main() {
    vec3 blur = vec3(0.0);

    #ifdef BLOOM
        vec2 scaledCoord = texCoord * max(vec2(viewWidth, viewHeight) / vec2(1920.0, 1080.0), vec2(1.0));

        #if defined OVERWORLD || defined END
            blur += BloomTile(2.0, vec2(0.0      , 0.0   ), scaledCoord);
            blur += BloomTile(3.0, vec2(0.0      , 0.26  ), scaledCoord);
            blur += BloomTile(4.0, vec2(0.135    , 0.26  ), scaledCoord);
            blur += BloomTile(5.0, vec2(0.2075   , 0.26  ), scaledCoord) * 0.8;
            blur += BloomTile(6.0, vec2(0.135    , 0.3325), scaledCoord) * 0.8;
            blur += BloomTile(7.0, vec2(0.160625 , 0.3325), scaledCoord) * 0.6;
            blur += BloomTile(8.0, vec2(0.1784375, 0.3325), scaledCoord) * 0.4;
        #else
            blur += BloomTile(2.0, vec2(0.0      , 0.0   ), scaledCoord);
            blur += BloomTile(3.0, vec2(0.0      , 0.26  ), scaledCoord);
            blur += BloomTile(4.0, vec2(0.135    , 0.26  ), scaledCoord);
            blur += BloomTile(5.0, vec2(0.2075   , 0.26  ), scaledCoord);
            blur += BloomTile(6.0, vec2(0.135    , 0.3325), scaledCoord);
            blur += BloomTile(7.0, vec2(0.160625 , 0.3325), scaledCoord);
            blur += BloomTile(8.0, vec2(0.1784375, 0.3325), scaledCoord) * 0.6;
        #endif
    #endif

    /* DRAWBUFFERS:3 */
    gl_FragData[0] = vec4(blur, 1.0);
}

#endif

/*============================================
 * VERTEX SHADER - Screen Pass Setup
 *============================================*/
#ifdef VERTEX_SHADER

//Attributes//

//Common Variables//

//Common Functions//

//Includes//

//Program//
void main() {
    texCoord = gl_MultiTexCoord0.xy;

    gl_Position = ftransform();
}

#endif
