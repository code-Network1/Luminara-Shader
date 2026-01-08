
#include "/lib/shader_modules/aqua_settings.glsl"


#include "/lib/shader_modules/illumination_system.glsl"


#include "/lib/shader_modules/core_definitions.glsl"


#include "/lib/shader_modules/visual_enhancements.glsl"


#include "/lib/shader_modules/sky_atmosphere.glsl"


#include "/lib/shader_modules/user_preferences.glsl"


#ifdef END
    const float sunPathRotation = 0.0;
#else
    #if SUN_ANGLE == -1
        #if SHADER_STYLE == 1
            const float sunPathRotation = 0.0;
            #define PERPENDICULAR_TWEAKS
        #elif SHADER_STYLE == 4
            const float sunPathRotation = -40.0;
        #endif
    #elif SUN_ANGLE == 0
        const float sunPathRotation = 0.0;
        #define PERPENDICULAR_TWEAKS
    #elif SUN_ANGLE == 20
        const float sunPathRotation = 20.0;
    #elif SUN_ANGLE == 30
        const float sunPathRotation = 30.0;
    #elif SUN_ANGLE == 40
        const float sunPathRotation = 40.0;
    #elif SUN_ANGLE == 50
        const float sunPathRotation = 50.0;
    #elif SUN_ANGLE == 60
        const float sunPathRotation = 60.0;
    #elif SUN_ANGLE == -20
        const float sunPathRotation = -20.0;
    #elif SUN_ANGLE == -30
        const float sunPathRotation = -30.0;
    #elif SUN_ANGLE == -40
        const float sunPathRotation = -40.0;
    #elif SUN_ANGLE == -50
        const float sunPathRotation = -50.0;
    #elif SUN_ANGLE == -60
        const float sunPathRotation = -60.0;
    #endif
#endif


#if SUN_MOON_STYLE_DEFINE == -1
    #define SUN_MOON_STYLE SUN_MOON_STYLE_DEFAULT
#else
    #define SUN_MOON_STYLE SUN_MOON_STYLE_DEFINE
#endif


#if RP_MODE >= 2
    #define CUSTOM_PBR
    #define POM
#endif
#if RP_MODE == 1
    #define IPBR
    #define IPBR_PARTICLE_FEATURES
    //#define GENERATED_NORMALS
    //#define COATED_TEXTURES
    //#define FANCY_GLASS
    //#define GREEN_SCREEN_LIME
#endif


#if CLOUD_STYLE_DEFINE == -1
    #define CLOUD_STYLE CLOUD_STYLE_DEFAULT
#else
    #define CLOUD_STYLE CLOUD_STYLE_DEFINE
#endif


#if WATER_CAUSTIC_STYLE_DEFINE == -1
    #define WATER_CAUSTIC_STYLE WATER_STYLE
#else
    #define WATER_CAUSTIC_STYLE WATER_CAUSTIC_STYLE_DEFINE
#endif


#if AURORA_STYLE_DEFINE == -1
    #define AURORA_STYLE AURORA_STYLE_DEFAULT
#else
    #define AURORA_STYLE AURORA_STYLE_DEFINE
#endif


#if WATER_STYLE_DEFINE == -1
    #define WATER_STYLE WATER_STYLE_DEFAULT
#else
    #define WATER_STYLE WATER_STYLE_DEFINE
#endif


#if SHADER_STYLE == 1
    #define WATER_STYLE_DEFAULT 1
    //#define WATER_CAUSTIC_STYLE_DEFAULT 1
    #define AURORA_STYLE_DEFAULT 1
    #define SUN_MOON_STYLE_DEFAULT 1
    #define CLOUD_STYLE_DEFAULT 1
#elif SHADER_STYLE == 4
    #define WATER_STYLE_DEFAULT 3
    //#define WATER_CAUSTIC_STYLE_DEFAULT 3
    #define AURORA_STYLE_DEFAULT 2
    #define SUN_MOON_STYLE_DEFAULT 2
    #define CLOUD_STYLE_DEFAULT 3
#endif


#if DETAIL_QUALITY >= 3 // High
    #undef WATER_MAT_QUALITY
    #define WATER_MAT_QUALITY 3 // we use DETAIL_QUALITY >= 3 when writing in gbuffers_water because optifine bad
    #define HQ_NIGHT_NEBULA
    #define SKY_EFFECT_REFLECTION
    #define CONNECTED_GLASS_CORNER_FIX
    #define ACL_CORNER_LEAK_FIX
    #define DO_NETHER_VINE_WAVING_OUTSIDE_NETHER
    #define DO_MORE_FOLIAGE_WAVING
    #if defined IRIS_FEATURE_CUSTOM_IMAGES && SHADOW_QUALITY > -1 && RAIN_PUDDLES > 0 && COLORED_LIGHTING_INTERNAL > 0
        #define PUDDLE_VOXELIZATION
    #endif
    #if CLOUD_QUALITY >= 3 && CLOUD_STYLE > 0 && CLOUD_STYLE != 50
        #define ENTITY_TAA_NOISY_CLOUD_FIX
    #endif
#endif

#if DETAIL_QUALITY == 0 // Potato
    #undef PERPENDICULAR_TWEAKS
    #define LOW_QUALITY_NETHER_STORM
    #define LOW_QUALITY_ENDER_NEBULA
    #define WATER_MAT_QUALITY 1
#endif

#if DETAIL_QUALITY >= 2 // Medium
    #undef WATER_MAT_QUALITY
    #define WATER_MAT_QUALITY 2
    #define FXAA_TAA_INTERACTION
    #define TAA_MOVEMENT_IMPROVEMENT_FILTER
#endif

#if DETAIL_QUALITY >= 1 // not an option for now
    #if TAA_MODE >= 1
        #define TAA
    #endif
    #define WATER_MAT_QUALITY 1
#endif


#if BLOCK_REFLECT_QUALITY >= 3 && RP_MODE >= 1
    #define TEMPORAL_FILTER
#endif
#if BLOCK_REFLECT_QUALITY >= 1
    #define LIGHT_HIGHLIGHT
#endif
#if BLOCK_REFLECT_QUALITY >= 2 && RP_MODE >= 1
    #define PBR_REFLECTIONS
#endif


#if SHADOW_QUALITY >= 1
    #if SHADOW_QUALITY > 4 || SHADOW_SMOOTHING < 3
        const int shadowMapResolution = 4096;
    #else
        const int shadowMapResolution = 2048;
    #endif
#else
    const int shadowMapResolution = 1024;
#endif


#if LIGHTSHAFT_BEHAVIOUR > 0
    #define LIGHTSHAFT_QUALI LIGHTSHAFT_QUALI_DEFINE
#else
    #define LIGHTSHAFT_QUALI 0
#endif
#if SSAO_I > 0
    #define SSAO_QUALI SSAO_QUALI_DEFINE
#else
    #define SSAO_QUALI 0
#endif

//Define Handling//
    #ifdef OVERWORLD
        #if CLOUD_STYLE > 0 && CLOUD_STYLE != 50 && CLOUD_QUALITY > 0
            #define VL_CLOUDS_ACTIVE
            #if CLOUD_STYLE == 1
                #define CLOUDS_REIMAGINED
            #endif
            #if CLOUD_STYLE == 3
                #define CLOUDS_UNBOUND
            #endif
        #endif
    #else
        #undef LIGHT_HIGHLIGHT
        #undef CAVE_FOG
        #undef CLOUD_SHADOWS
        #undef SNOWY_WORLD
        #undef LIGHTSHAFT_SMOKE
    #endif
    #ifdef NETHER
        #undef ATMOSPHERIC_FOG
        #undef NO_WAVING_INDOORS
    #else
        #undef NETHER_STORM
    #endif
    #ifdef END
        #undef BLOOM_FOG
    #endif

    #ifndef BLOOM
        #undef BLOOM_FOG
    #endif

    #if defined PIXELATED_SHADOWS || defined PIXELATED_BLOCKLIGHT || defined PIXELATED_AO
        #if !defined GBUFFERS_BASIC && !defined DH_TERRAIN && !defined DH_WATER
            #define DO_PIXELATION_EFFECTS
        #endif
    #endif

    #ifndef GBUFFERS_TERRAIN
        #undef PIXELATED_BLOCKLIGHT
    #endif

    #ifdef BLOOM_FOG
        #if WORLD_BLUR > 0
            #define BLOOM_FOG_COMPOSITE3
        #elif defined MOTION_BLURRING
            #define BLOOM_FOG_COMPOSITE2
        #else
            #define BLOOM_FOG_COMPOSITE
        #endif
    #endif

    #if defined GBUFFERS_HAND || defined GBUFFERS_ENTITIES
        #undef SNOWY_WORLD
        #undef DISTANT_LIGHT_BOKEH
    #endif
    #if defined GBUFFERS_TEXTURED || defined GBUFFERS_BASIC
        #undef LIGHT_HIGHLIGHT
        #undef DIRECTIONAL_SHADING
        #undef SIDE_SHADOWING
    #endif
    #ifdef GBUFFERS_WATER
        #undef LIGHT_HIGHLIGHT
    #endif

    #ifndef GLOWING_ENTITY_FIX
        #undef GBUFFERS_ENTITIES_GLOWING
    #endif

    #if LIGHTSHAFT_QUALI > 0 && defined OVERWORLD && SHADOW_QUALITY > -1 || defined END
        #define LIGHTSHAFTS_ACTIVE
    #endif

    #if defined WAVING_FOLIAGE || defined WAVING_LEAVES || defined WAVING_LAVA || defined WAVING_LILY_PAD
        #define WAVING_ANYTHING_TERRAIN
    #endif

    #if WATERCOLOR_R != 100 || WATERCOLOR_G != 100 || WATERCOLOR_B != 100
        #define WATERCOLOR_RM WATERCOLOR_R * 0.01
        #define WATERCOLOR_GM WATERCOLOR_G * 0.01
        #define WATERCOLOR_BM WATERCOLOR_B * 0.01
        #define WATERCOLOR_CHANGED
    #endif

    #if UNDERWATERCOLOR_R != 100 || UNDERWATERCOLOR_G != 100 || UNDERWATERCOLOR_B != 100
        #define UNDERWATERCOLOR_RM UNDERWATERCOLOR_R * 0.01
        #define UNDERWATERCOLOR_GM UNDERWATERCOLOR_G * 0.01
        #define UNDERWATERCOLOR_BM UNDERWATERCOLOR_B * 0.01
        #define UNDERWATERCOLOR_CHANGED
    #endif

    #if defined IS_IRIS && !defined IRIS_HAS_TRANSLUCENCY_SORTING
        #undef FANCY_GLASS
    #endif

    #ifdef DISTANT_HORIZONS
        #undef DISTANT_LIGHT_BOKEH
    #endif

    #if defined MC_GL_VENDOR_AMD || defined MC_GL_VENDOR_ATI
        #ifndef DEFERRED1
            #define FIX_AMD_REFLECTION_CRASH //BFARC: Fixes a driver crashing problem on AMD GPUs
        #endif
    #endif

//Activate Settings//
    #ifdef POM_ALLOW_CUTOUT
    #endif
    #ifdef BRIGHT_CAVE_WATER
    #endif
    #ifdef IPBR_PARTICLE_FEATURES
    #endif
    #ifdef COLORED_CANDLE_LIGHT
    #endif
    #ifdef PIXELATED_AO
    #endif

//Very Common Stuff//
    #include "/lib/unified_rendering_core.glsl"

    #if SHADOW_QUALITY == -1
      float timeAngle = worldTime / 24000.0;
    #else
      float tAmin     = fract(sunAngle - 0.033333333);
      float tAlin     = tAmin < 0.433333333 ? tAmin * 1.15384615385 : tAmin * 0.882352941176 + 0.117647058824;
      float hA        = tAlin > 0.5 ? 1.0 : 0.0;
      float tAfrc     = fract(tAlin * 2.0);
      float tAfrs     = tAfrc*tAfrc*(3.0-2.0*tAfrc);
      float tAmix     = hA < 0.5 ? 0.3 : -0.1;
      float timeAngle = (tAfrc * (1.0-tAmix) + tAfrs * tAmix + hA) * 0.5;
    #endif

    #include "/lib/atmospherics/luminara_atmospheric_core.glsl"

    #ifndef DISTANT_HORIZONS
        float renderDistance = far;
    #else
        float renderDistance = float(dhRenderDistance);
    #endif

    const float shadowMapBias = 1.0 - 25.6 / shadowDistance;
    #ifndef DREAM_TWEAKED_LIGHTING
        float noonFactor = sqrt(max(sin(timeAngle*6.28318530718),0.0));
    #else
        float noonFactor = pow(max(sin(timeAngle*6.28318530718),0.0), 0.2);
    #endif


float nightFactor = max(sin(timeAngle*(-6.28318530718)),0.0);
float invNightFactor = 1.0 - nightFactor;
float rainFactor2 = rainFactor * rainFactor;
float invRainFactor = 1.0 - rainFactor;
float invNoonFactor = 1.0 - noonFactor;
float invNoonFactor2 = invNoonFactor * invNoonFactor;


float vsBrightness = clamp(screenBrightness, 0.0, 1.0);


int modifiedWorldDay = int(mod(worldDay, 100) + 5.0);
float syncedTime = (worldTime + modifiedWorldDay * 24000) * 0.05;


#if IRIS_VERSION >= 10800
    vec3 cameraPositionBestFract = cameraPositionFract;
#else
    vec3 cameraPositionBestFract = fract(cameraPosition);
#endif


#include "/lib/color_schemes/block_light_colors.glsl"


#if CAVE_LIGHTING < 100
    vec3 caveFogColor = caveFogColorRaw * 0.7;
#elif CAVE_LIGHTING == 100
    vec3 caveFogColor = caveFogColorRaw * (0.7 + 0.3 * vsBrightness); // Default
#elif CAVE_LIGHTING > 100
    vec3 caveFogColor = caveFogColorRaw;
#endif


#if WATERCOLOR_MODE >= 2
    vec3 underwaterColorM1 = pow(fogColor, vec3(0.33, 0.21, 0.26));
#else
    vec3 underwaterColorM1 = vec3(0.46, 0.62, 1.0);
#endif
#ifndef UNDERWATERCOLOR_CHANGED
    vec3 underwaterColorM2 = underwaterColorM1;
#else
    vec3 underwaterColorM2 = underwaterColorM1 * vec3(UNDERWATERCOLOR_RM, UNDERWATERCOLOR_GM, UNDERWATERCOLOR_BM);
#endif
vec3 waterFogColor = underwaterColorM2 * vec3(0.2 + 0.1 * vsBrightness);


#if NETHER_COLOR_MODE == 3
    float netherColorMixer = inNetherWastes + inCrimsonForest + inWarpedForest + inBasaltDeltas + inSoulValley;
    vec3 netherColor = mix(
        fogColor * 0.6 + 0.2 * normalize(fogColor + 0.0001),
        (
            inNetherWastes * vec3(0.38, 0.15, 0.05) + inCrimsonForest * vec3(0.33, 0.07, 0.04) +
            inWarpedForest * vec3(0.18, 0.1, 0.25) + inBasaltDeltas * vec3(0.25, 0.235, 0.23) +
            inSoulValley * vec3(0.1, vec2(0.24))
        ),
        netherColorMixer
    );
#elif NETHER_COLOR_MODE == 2
    vec3 netherColor = fogColor * 0.6 + 0.2 * normalize(fogColor + 0.0001);
#elif NETHER_COLOR_MODE == 0
    vec3 netherColor = vec3(0.7, 0.26, 0.08) * 0.6;
#endif


#if WEATHER_TEX_OPACITY == 100
    const float rainTexOpacity = 0.25;
    const float snowTexOpacity = 0.5;
#else
    #define WEATHER_TEX_OPACITY_M 100.0 / WEATHER_TEX_OPACITY
    const float rainTexOpacity = pow(0.25, WEATHER_TEX_OPACITY_M);
    const float snowTexOpacity = pow(0.5, WEATHER_TEX_OPACITY_M);
#endif


#ifdef FRAGMENT_SHADER
    ivec2 texelCoord = ivec2(gl_FragCoord.xy);
#endif
