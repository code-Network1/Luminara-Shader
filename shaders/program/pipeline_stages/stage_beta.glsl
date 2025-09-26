/*============================================
 * Luminara Shader - Pipeline Stage Beta
 * Motion Blur Processing Stage
 * Camera Movement & Blur Enhancement by VcorA
 *============================================*/

// Core Libraries
#include "/lib/shader_modules/shader_master.glsl"

/**
 * FRAGMENT SHADER - Motion Blur Implementation
 * Advanced camera-based motion blur with temporal sampling
 */
#ifdef FRAGMENT_SHADER

#ifdef MOTION_BLURRING
    // Input Variables
    noperspective in vec2 texCoord;     // Screen texture coordinates

    #ifdef BLOOM_FOG_COMPOSITE2
        flat in vec3 upVec, sunVec;     // Direction vectors for bloom fog
    #endif
#endif

//========================================
// Pipeline Constants Section
//========================================

//========================================
// Motion Blur Variables - VcorA Enhancement
//========================================
#if defined MOTION_BLURRING && defined BLOOM_FOG_COMPOSITE2
    // Sun-up dot product for bloom fog calculations
    float SdotU = dot(sunVec, upVec);
    // Advanced sun factor for dynamic bloom adjustment
    float sunFactor = SdotU < 0.0 ? clamp(SdotU + 0.375, 0.0, 0.75) / 0.75 : clamp(SdotU + 0.03125, 0.0, 0.0625) / 0.0625;
#endif

/* ==========================================
 * MOTION BLUR CORE FUNCTION - VcorA Algorithm
 * Advanced temporal sampling with camera compensation
 * ========================================== */
#ifdef MOTION_BLURRING
    vec3 MotionBlur(vec3 color, float z, float dither) {
        // Depth-based motion blur activation threshold
        if (z > 0.56) {
            float mbwg = 0.0;
            vec2 doublePixel = 2.0 / vec2(viewWidth, viewHeight);
            vec3 mblur = vec3(0.0);

            // Current screen position in NDC space
            vec4 currentPosition = vec4(texCoord, z, 1.0) * 2.0 - 1.0;

            // Transform to world space - VcorA Algorithm
            vec4 viewPos = gbufferProjectionInverse * currentPosition;
            viewPos = gbufferModelViewInverse * viewPos;
            viewPos /= viewPos.w;

            // Camera movement compensation
            vec3 cameraOffset = cameraPosition - previousCameraPosition;

            // Previous frame position calculation
            vec4 previousPosition = viewPos + vec4(cameraOffset, 0.0);
            previousPosition = gbufferPreviousModelView * previousPosition;
            previousPosition = gbufferPreviousProjection * previousPosition;
            previousPosition /= previousPosition.w;

            // Motion vector calculation with strength modulation - VcorA
            vec2 velocity = (currentPosition - previousPosition).xy;
            velocity = velocity / (1.0 + length(velocity)) * MOTION_BLURRING_STRENGTH * 0.02;

            // Motion blur sampling with dithering - VcorA Enhancement
            vec2 coord = texCoord - velocity * (3.5 + dither);
            for (int i = 0; i < 9; i++, coord += velocity) {
                vec2 coordb = clamp(coord, doublePixel, 1.0 - doublePixel);
                mblur += texture2DLod(colortex0, coordb, 0).rgb;
                mbwg += 1.0;
            }
            mblur /= mbwg;

            return mblur;
        } else return color;    // No motion blur for near objects
    }
#endif

//========================================
// Required Libraries - VcorA Organization
//========================================
#ifdef MOTION_BLURRING
    #include "/lib/atmospherics/luminara_atmospheric_core.glsl"

    #ifdef BLOOM_FOG_COMPOSITE2
        #include "/lib/atmospherics/particles/lightBloom.glsl"
    #endif
#endif

//========================================
// Main Motion Blur Program - VcorA Implementation
//========================================
void main() {
    // Primary color buffer sampling
    vec3 color = texelFetch(colortex0, texelCoord, 0).rgb;

    #ifdef MOTION_BLURRING
        // Depth sampling for motion blur calculation
        float z = texture2D(depthtex1, texCoord).x;
        // High-quality dithering for smooth motion blur - VcorA
        float dither = Bayer64(gl_FragCoord.xy);

        // Apply motion blur effect with depth consideration
        color = MotionBlur(color, z, dither);

        #ifdef BLOOM_FOG_COMPOSITE2
            // Additional bloom fog processing - VcorA Enhancement
            float z0 = texelFetch(depthtex0, texelCoord, 0).r;
            vec4 screenPos = vec4(texCoord, z0, 1.0);
            vec4 viewPos = gbufferProjectionInverse * (screenPos * 2.0 - 1.0);
            viewPos /= viewPos.w;
            float lViewPos = length(viewPos.xyz);

            #if defined DISTANT_HORIZONS && defined NETHER
                // Distant Horizons integration for Nether dimension
                float z0DH = texelFetch(dhDepthTex, texelCoord, 0).r;
                vec4 screenPosDH = vec4(texCoord, z0DH, 1.0);
                vec4 viewPosDH = dhProjectionInverse * (screenPosDH * 2.0 - 1.0);
                viewPosDH /= viewPosDH.w;
                lViewPos = min(lViewPos, length(viewPosDH.xyz));
            #endif

            // Distance-based bloom fog application
            color *= GetBloomFog(lViewPos);
        #endif
    #endif

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(color, 1.0);
}

#endif

/*============================================
 * VERTEX SHADER - Screen Pass Setup
 *============================================*/
#ifdef VERTEX_SHADER

#ifdef MOTION_BLURRING
    // Output Variables Declaration - VcorA
    noperspective out vec2 texCoord;    // Screen texture coordinates

    #ifdef BLOOM_FOG_COMPOSITE2
        flat out vec3 upVec, sunVec;    // Direction vectors for bloom calculations
    #endif
#endif

//========================================
// Attributes Section
//========================================

//========================================
// Common Variables Section
//========================================

//========================================
// Common Functions Section
//========================================

//========================================
// Includes Section
//========================================

//========================================
// Vertex Program - VcorA Implementation
//========================================
void main() {
    // Standard vertex transformation
    gl_Position = ftransform();

    #ifdef MOTION_BLURRING
        // Texture coordinate setup for motion blur
        texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

        #ifdef BLOOM_FOG_COMPOSITE2
            // Direction vector calculations for bloom fog - VcorA
            upVec = normalize(gbufferModelView[1].xyz);
            sunVec = GetSunVector();
        #endif
    #endif
}

#endif
