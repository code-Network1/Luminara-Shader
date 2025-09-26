/*============================================
 * Luminara Shader - Pipeline Stage Alpha
 * Main Post-Processing Stage
 * Atmospheric & Volumetric Effects by VcorA
 *============================================*/

// Core Libraries
#include "/lib/shader_modules/shader_master.glsl"

/**
 * FRAGMENT SHADER - Main Processing Stage
 * Handles atmospheric effects, volumetrics, and core post-processing
 */
#ifdef FRAGMENT_SHADER

// Input Variables
noperspective in vec2 texCoord;     // Screen texture coordinates
flat in vec3 upVec, sunVec;         // Normalized up and sun direction vectors

#ifdef LIGHTSHAFTS_ACTIVE
    flat in float vlFactor;         // Volumetric light factor for lightshafts
#endif

/* ==========================================
 * CORE VARIABLES - Lighting & Atmosphere
 * ========================================== */

// Screen dimensions vector
vec2 view = vec2(viewWidth, viewHeight);

// Sun-up dot product for lighting calculations
float SdotU = dot(sunVec, upVec);

// Dynamic sun visibility calculations
float sunVisibility = clamp(SdotU + 0.0625, 0.0, 0.125) / 0.125;
float sunVisibility2 = sunVisibility * sunVisibility;

// Advanced sun factor computation for day/night transitions
float sunFactor = SdotU < 0.0 ? clamp(SdotU + 0.375, 0.0, 0.75) / 0.75 : clamp(SdotU + 0.03125, 0.0, 0.0625) / 0.0625;

// World-specific lighting vector determination
#ifdef OVERWORLD
    vec3 lightVec = sunVec * ((timeAngle < 0.5325 || timeAngle > 0.9675) ? 1.0 : -1.0);
#else
    vec3 lightVec = sunVec;
#endif

// Advanced shadow time calculations for atmospheric effects - VcorA Enhancement
float shadowTimeVar1 = abs(sunVisibility - 0.5) * 2.0;
float shadowTimeVar2 = shadowTimeVar1 * shadowTimeVar1;
float shadowTime = shadowTimeVar2 * shadowTimeVar2;

#ifdef LIGHTSHAFTS_ACTIVE
    // Volumetric light timing calculations
    float vlTime = min(abs(SdotU) - 0.05, 0.15) / 0.15;
#endif

//========================================
// Common Functions Section
//========================================

//========================================
// Atmospheric & Effects Libraries - VcorA Organization
//========================================
#include "/lib/atmospherics/particles/liquidEffects.glsl"
#include "/lib/atmospherics/particles/depthFactor.glsl"

#ifdef BLOOM_FOG_COMPOSITE
    #include "/lib/atmospherics/particles/lightBloom.glsl"
#endif

#include "/lib/atmospherics/atmosphericVolumetricSystem.glsl"

#if WATER_MAT_QUALITY >= 3 || defined NETHER_STORM || defined COLORED_LIGHT_FOG
    #include "/lib/atmospherics/luminara_atmospheric_core.glsl"
#endif

#if WATER_MAT_QUALITY >= 3
    #include "/lib/materialMethods/refraction.glsl"
#endif

#ifdef NETHER_STORM
    // Nether storm effects are disabled in environmentalEffects.glsl
#endif

#ifdef ATM_COLOR_MULTS
    #include "/lib/color_schemes/color_effects_system.glsl"
#endif
#ifdef MOON_PHASE_INF_ATMOSPHERE
    #include "/lib/color_schemes/color_effects_system.glsl"
#endif

#if RAINBOWS > 0 && defined OVERWORLD
    // Rainbow effects integrated in atmosphericVolumetricSystem.glsl
#endif

#ifdef COLORED_LIGHT_FOG
    #include "/lib/effects/effects_unified.glsl"
    #include "/lib/atmospherics/particles/coloredParticles.glsl"
#endif

/**
 * MAIN PROGRAM - Atmospheric Processing
 * Comprehensive post-processing with volumetrics and effects
 */
void main() {
    // Primary color and depth buffer sampling
    vec3 color = texelFetch(colortex0, texelCoord, 0).rgb;
    float z0 = texelFetch(depthtex0, texelCoord, 0).r;
    float z1 = texelFetch(depthtex1, texelCoord, 0).r;

    // Screen to view space transformation - VcorA Enhancement
    vec4 screenPos = vec4(texCoord, z0, 1.0);
    vec4 viewPos = gbufferProjectionInverse * (screenPos * 2.0 - 1.0);
    viewPos /= viewPos.w;
    float lViewPos = length(viewPos.xyz);

    #if defined DISTANT_HORIZONS && !defined OVERWORLD
        // Distant Horizons depth integration
        float z0DH = texelFetch(dhDepthTex, texelCoord, 0).r;
        vec4 screenPosDH = vec4(texCoord, z0DH, 1.0);
        vec4 viewPosDH = dhProjectionInverse * (screenPosDH * 2.0 - 1.0);
        viewPosDH /= viewPosDH.w;
        lViewPos = min(lViewPos, length(viewPosDH.xyz));
    #endif

    // Temporal dithering for noise reduction - VcorA
    float dither = texture2D(noisetex, texCoord * view / 128.0).b;
    #ifdef TAA
        dither = fract(dither + goldenRatio * mod(float(frameCounter), 3600.0));
    #endif

    /* TM5723: Translucent multiplier correction for glass rendering
    The "1.0 - translucentMult" ensures proper transparency handling - VcorA */
    vec3 translucentMult = 1.0 - texelFetch(colortex3, texelCoord, 0).rgb;
    vec4 volumetricEffect = vec4(0.0);

    #if WATER_MAT_QUALITY >= 3
        // High-quality water refraction processing
        DoRefraction(color, z0, z1, viewPos.xyz, lViewPos);
    #endif

    // Secondary depth processing for translucent materials
    vec4 screenPos1 = vec4(texCoord, z1, 1.0);
    vec4 viewPos1 = gbufferProjectionInverse * (screenPos1 * 2.0 - 1.0);
    viewPos1 /= viewPos1.w;
    float lViewPos1 = length(viewPos1.xyz);

    #if defined DISTANT_HORIZONS && !defined OVERWORLD
        // Extended distance rendering support
        float z1DH = texelFetch(dhDepthTex1, texelCoord, 0).r;
        vec4 screenPos1DH = vec4(texCoord, z1DH, 1.0);
        vec4 viewPos1DH = dhProjectionInverse * (screenPos1DH * 2.0 - 1.0);
        viewPos1DH /= viewPos1DH.w;
        lViewPos1 = min(lViewPos1, length(viewPos1DH.xyz));
    #endif

    #if defined LIGHTSHAFTS_ACTIVE || RAINBOWS > 0 && defined OVERWORLD
        // View direction and light dot product for atmospheric effects
        vec3 nViewPos = normalize(viewPos1.xyz);
        float VdotL = dot(nViewPos, lightVec);
    #endif

    #if defined NETHER_STORM || defined COLORED_LIGHT_FOG
        // Player position calculations for world-space effects
        vec3 playerPos = ViewToPlayer(viewPos1.xyz);
        vec3 nPlayerPos = normalize(playerPos);
    #endif

    #if RAINBOWS > 0 && defined OVERWORLD
        // Rainbow atmospheric phenomena processing - VcorA
        if (isEyeInWater == 0) color += GetRainbow(translucentMult, z0, z1, lViewPos, lViewPos1, VdotL, dither);
    #endif

    #ifdef LIGHTSHAFTS_ACTIVE
        // Volumetric lighting computation - VcorA Enhancement
        float vlFactorM = vlFactor;
        float VdotU = dot(nViewPos, upVec);
        volumetricEffect = GetVolumetricLight(color, vlFactorM, translucentMult, lViewPos, lViewPos1, nViewPos, VdotL, VdotU, texCoord, z0, z1, dither);
    #endif

    #ifdef NETHER_STORM
        // Nether dimension storm effects
        volumetricEffect = GetNetherStorm(color, translucentMult, nPlayerPos, playerPos, lViewPos, lViewPos1, dither);
    #endif

    #ifdef ATM_COLOR_MULTS
        // Atmospheric color multiplication effects
        volumetricEffect.rgb *= GetAtmColorMult();
    #endif
    #ifdef MOON_PHASE_INF_ATMOSPHERE
        // Moon phase atmospheric influence - VcorA
        volumetricEffect.rgb *= moonPhaseInfluence;
    #endif

    #ifdef NETHER_STORM
        // Storm color blending
        color = mix(color, volumetricEffect.rgb, volumetricEffect.a);
    #endif

    #ifdef COLORED_LIGHT_FOG
        // Advanced colored lighting fog system - VcorA Implementation
        vec3 lightFog = GetColoredLightFog(nPlayerPos, translucentMult, lViewPos, lViewPos1, dither);
        float lightFogMult = COLORED_LIGHT_FOG_I;
        //if (heldItemId == 40000 && heldItemId2 != 40000) lightFogMult = 0.0; // Spider eye debug disable

        #ifdef OVERWORLD
            // Overworld-specific fog intensity modulation
            lightFogMult *= 0.2 + 0.6 * mix(1.0, 1.0 - sunFactor * invRainFactor, eyeBrightnessM);
        #endif
    #endif

    // Underwater and lava rendering adjustments - VcorA Enhancement
    if (isEyeInWater == 1) {
        if (z0 == 1.0) color.rgb = waterFogColor;

        // Underwater color correction and atmospheric adjustments
        vec3 underwaterMult = vec3(0.80, 0.87, 0.97);
        color.rgb *= underwaterMult * 0.85;
        volumetricEffect.rgb *= pow2(underwaterMult * 0.71);

        #ifdef COLORED_LIGHT_FOG
            lightFog *= underwaterMult;
        #endif
    } else if (isEyeInWater == 2) {
        if (z1 == 1.0) color.rgb = fogColor * 5.0;

        // Lava submersion effects
        volumetricEffect.rgb *= 0.0;
        #ifdef COLORED_LIGHT_FOG
            lightFog *= 0.0;
        #endif
    }

    #ifdef COLORED_LIGHT_FOG
        // Advanced light fog integration - VcorA Algorithm
        color /= 1.0 + pow2(GetLuminance(lightFog)) * lightFogMult * 2.0;
        color += lightFog * lightFogMult * 0.5;
    #endif

    // Gamma correction for proper color space
    color = pow(color, vec3(2.2));

    #ifdef LIGHTSHAFTS_ACTIVE
        #ifdef END
            // End dimension volumetric enhancement
            volumetricEffect.rgb *= volumetricEffect.rgb;
        #endif

        // Final volumetric light application
        color += volumetricEffect.rgb;
    #endif

    #ifdef BLOOM_FOG_COMPOSITE
        // Distance-based bloom fog application
        color *= GetBloomFog(lViewPos);
    #endif

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(color, 1.0);

    // Advanced lightshaft quality control - VcorA Optimization
    #if LIGHTSHAFT_QUALI_DEFINE > 0 && LIGHTSHAFT_BEHAVIOUR == 1 && SHADOW_QUALITY >= 1 && defined OVERWORLD || defined END
        #if LENSFLARE_MODE > 0 || defined ENTITY_TAA_NOISY_CLOUD_FIX
            // Screen edge volumetric factor optimization
            if (viewWidth + viewHeight - gl_FragCoord.x - gl_FragCoord.y > 1.5)
                vlFactorM = texelFetch(colortex4, texelCoord, 0).r;
        #endif

        /* DRAWBUFFERS:04 */
        gl_FragData[1] = vec4(vlFactorM, 0.0, 0.0, 1.0);
    #endif
}

#endif

/**
 * VERTEX SHADER - Direction Vector Setup
 * Prepares lighting vectors for atmospheric calculations
 */
#ifdef VERTEX_SHADER

// Output Variables
noperspective out vec2 texCoord;    // Screen texture coordinates
flat out vec3 upVec, sunVec;        // Direction vectors for lighting

#ifdef LIGHTSHAFTS_ACTIVE
    flat out float vlFactor;        // Volumetric light factor output
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

    // Texture coordinate passthrough
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

    // Direction vector calculations - VcorA Enhancement
    upVec = normalize(gbufferModelView[1].xyz);
    sunVec = GetSunVector();

    #ifdef LIGHTSHAFTS_ACTIVE
        #if LIGHTSHAFT_BEHAVIOUR == 1 && SHADOW_QUALITY >= 1 || defined END
            // Dynamic volumetric factor from texture
            vlFactor = texelFetch(colortex4, ivec2(viewWidth-1, viewHeight-1), 0).r;
        #else
            #if LIGHTSHAFT_BEHAVIOUR == 2
                vlFactor = 0.0;    // Disabled lightshafts
            #elif LIGHTSHAFT_BEHAVIOUR == 3
                vlFactor = 1.0;    // Maximum lightshafts
            #endif
        #endif
    #endif
}

#endif
