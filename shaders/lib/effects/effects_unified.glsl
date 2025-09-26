/*
════════════════════════════════════════════════════════════════════════════════
    Luminara Shader - Effects Unified System
    نظام التأثيرات الموحد - شيدر زينيث
════════════════════════════════════════════════════════════════════════════════
    
    📋 This file contains all miscellaneous effects previously scattered across:
    هذا الملف يحتوي على جميع التأثيرات المتنوعة التي كانت موزعة على:
    
    • colorCodedPrograms.glsl - نظام ترميز البرامج بالألوان
    • darkOutline.glsl - تأثير الحدود المظلمة  
    • distantLightBokeh.glsl - تأثير البوكيه للأضواء البعيدة
    • handSway.glsl - تأثير تحريك اليد
    • lensFlare.glsl - تأثير وهج العدسة
    • pixelation.glsl - تأثير البكسلة
    • puddleVoxelization.glsl - نظام فوكسل البرك
    • showLightLevels.glsl - عرض مستويات الإضاءة
    • voxelization.glsl - نظام الفوكسل الأساسي
    • worldOutline.glsl - تأثير حدود العالم
    
    ✨ Built by VcorA with care and precision
    تم البناء بواسطة VcorA بعناية ودقة ✨
════════════════════════════════════════════════════════════════════════════════
*/

// ═══════════════════════════════════════════════════════════════════════════════
// 🎨 Color Coded Programs System | نظام ترميز البرامج بالألوان
// ═══════════════════════════════════════════════════════════════════════════════
void ColorCodeProgram(inout vec4 color, int mat) {
    // Hold spider eyes in both hands to disable the function
    if (heldItemId == 40000 && heldItemId2 == 40000) return;

    #if defined GBUFFERS_TERRAIN // Green
        color.rgb = vec3(0.0, 1.0, 0.0);
    #elif defined GBUFFERS_WATER // Dark Blue
        color.rgb = vec3(0.0, 0.0, 1.0);
    #elif defined GBUFFERS_SKYBASIC // Light Blue
        color.rgb = vec3(0.0, 1.0, 2.0);
    #elif defined GBUFFERS_WEATHER // Magenta
        color.rgb = vec3(3.0, 0.0, 3.0);
    #elif defined GBUFFERS_BLOCK // Yellow
        color.rgb = vec3(1.5, 1.5, 0.0);
    #elif defined GBUFFERS_HAND // Orange
        color.rgb = vec3(1.5, 0.7, 0.0);
    #elif defined GBUFFERS_ENTITIES // Red
        color.rgb = vec3(1.5, 0.0, 0.0);
    #elif defined GBUFFERS_BASIC // White
        color.rgb = vec3(3.0, 3.0, 3.0);
    #elif defined GBUFFERS_SPIDEREYES // Red-Blue Vertical Stripes
        color.rgb = mix(vec3(2.0, 0.0, 0.0), vec3(0.0, 0.0, 2.0), mod(gl_FragCoord.x, 20.0) / 20.0);
    #elif defined GBUFFERS_TEXTURED   // Red-Blue Horizontal Stripes
        color.rgb = mix(vec3(2.0, 0.0, 0.0), vec3(0.0, 0.0, 2.0), mod(gl_FragCoord.y, 20.0) / 20.0);
    #elif defined GBUFFERS_CLOUDS     // Red-Green Vertical Stripes
        color.rgb = mix(vec3(2.0, 0.0, 0.0), vec3(0.0, 2.0, 0.0), mod(gl_FragCoord.x, 20.0) / 20.0);
    #elif defined GBUFFERS_BEACONBEAM // Red-Green Horizontal Stripes
        color.rgb = mix(vec3(2.0, 0.0, 0.0), vec3(0.0, 2.0, 0.0), mod(gl_FragCoord.y, 20.0) / 20.0);
    #elif defined GBUFFERS_ARMOR_GLINT  // Black-White Vertical Stripes
        color.rgb = mix(vec3(0.0, 0.0, 0.0), vec3(1.5, 1.5, 1.5), mod(gl_FragCoord.x, 20.0) / 20.0);
    #elif defined GBUFFERS_DAMAGEDBLOCK // Black-White Horizontal Stripes
        color.rgb = mix(vec3(0.0, 0.0, 0.0), vec3(1.5, 1.5, 1.5), mod(gl_FragCoord.y, 20.0) / 20.0);
    #elif defined GBUFFERS_SKYTEXTURED // Green-Blue Horizontal Stripes
        color.rgb = mix(vec3(0.0, 2.0, 0.0), vec3(0.0, 0.0, 2.0), mod(gl_FragCoord.y, 20.0) / 20.0);
    #endif

    color.rgb *= 0.75;

    // Hold spider eye in one hand to switch to ID=0 check mode
    if (heldItemId == 40000 || heldItemId2 == 40000) {
        if (mat == 0) // Magenta-Black Horizontal Stripes
        color.rgb = mix(vec3(0.0, 0.0, 0.0), vec3(3.0, 0.0, 3.0), mod(gl_FragCoord.y, 20.0) / 20.0);
        else
        color.rgb = vec3(0.25);
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 🌫️ Dark Outline Effect System | نظام تأثير الحدود المظلمة
// ═══════════════════════════════════════════════════════════════════════════════
vec2 darkOutlineOffsets[12] = vec2[12](
                               vec2( 1.0,0.0),
                               vec2(-1.0,1.0),
                               vec2( 0.0,1.0),
                               vec2( 1.0,1.0),
                               vec2(-2.0,2.0),
                               vec2(-1.0,2.0),
                               vec2( 0.0,2.0),
                               vec2( 1.0,2.0),
                               vec2( 2.0,2.0),
                               vec2(-2.0,1.0),
                               vec2( 2.0,1.0),
                               vec2( 2.0,0.0)
);

void DoDarkOutline(inout vec3 color, inout float skyFade, float z0, float dither) {
    vec2 scale = vec2(1.0 / view);

    float outline = 1.0;
    float z = GetLinearDepth(z0) * far * 2.0;
    float minZ = 1.0, sampleZA = 0.0, sampleZB = 0.0;

    #if DARK_OUTLINE_THICKNESS == 1
        int sampleCount = 4;
    #elif DARK_OUTLINE_THICKNESS == 2
        int sampleCount = 12;
    #endif

    for (int i = 0; i < sampleCount; i++) {
        vec2 offset = scale * darkOutlineOffsets[i];
        sampleZA = texture2D(depthtex0, texCoord + offset).r;
        sampleZB = texture2D(depthtex0, texCoord - offset).r;
        float sampleZsum = GetLinearDepth(sampleZA) + GetLinearDepth(sampleZB);
        outline *= clamp(1.0 - (z - sampleZsum * far), 0.0, 1.0);
        minZ = min(minZ, min(sampleZA, sampleZB));
    }

    if (outline < 0.909091) {
        vec4 viewPos = gbufferProjectionInverse * (vec4(texCoord, minZ, 1.0) * 2.0 - 1.0);
        viewPos /= viewPos.w;
        float lViewPos = length(viewPos.xyz);
        vec3 playerPos = ViewToPlayer(viewPos.xyz);
        vec3 nViewPos = normalize(viewPos.xyz);
        float VdotU = dot(nViewPos, upVec);
        float VdotS = dot(nViewPos, sunVec);

        vec3 newColor = vec3(0.0);
        DoFog(newColor, skyFade, lViewPos, playerPos, VdotU, VdotS, dither);

        color = mix(color, newColor, 1.0 - outline * 1.1);
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ✨ Distant Light Bokeh System | نظام البوكيه للأضواء البعيدة
// ═══════════════════════════════════════════════════════════════════════════════
float GetDistantLightBokehMix(float lViewPos) {
    //if (heldItemId == 40000 || heldItemId2 == 40000) return 0.0; // Hold spider eye to disable;
    return clamp01(0.005 * (lViewPos - 60.0));
}

float GetDistantLightBokehMixMipmapped(float lViewPos) {
    float dlbMix = GetDistantLightBokehMix(lViewPos);
    #ifdef GBUFFERS_TERRAIN
        return dlbMix * min1(miplevel * 0.4);
    #else
        return dlbMix;
    #endif
}

void DoDistantLightBokehMaterial(inout vec4 color, vec4 distantColor, inout float emission, float distantEmission, float lViewPos) {
    float dlbMix = GetDistantLightBokehMixMipmapped(lViewPos);
    color = mix(color, distantColor, dlbMix);
    emission = mix(emission, distantEmission, dlbMix);
}

void DoDistantLightBokehMaterial(inout float emission, float distantEmission, float lViewPos) {
    float dlbMix = GetDistantLightBokehMixMipmapped(lViewPos);
    emission = mix(emission, distantEmission, dlbMix);
}

// ═══════════════════════════════════════════════════════════════════════════════
// 🤚 Hand Sway Effect System | نظام تأثير تحريك اليد
// ═══════════════════════════════════════════════════════════════════════════════
// Note: This code should be used directly in vertex shaders
// ملاحظة: هذا الكود يجب استخدامه مباشرة في vertex shaders
/*
#if HAND_SWAYING == 1
    const float handSwayMult = 0.5;
#elif HAND_SWAYING == 2
    const float handSwayMult = 1.0;
#elif HAND_SWAYING == 3
    const float handSwayMult = 2.0;
#endif
gl_Position.x += handSwayMult * (sin(frameTimeCounter * 0.86)) / 256.0;
gl_Position.y += handSwayMult * (cos(frameTimeCounter * 1.5)) / 64.0;

//dvd screensaver
//gl_Position.x -= - 0.1 + mod(frameTimeCounter * 0.3, 1.0) * sign(mod(frameTimeCounter * 0.3, 2.0) - 1.0) + float(mod(frameTimeCounter * 0.3, 2.0) < 1.0);
//gl_Position.y += mod(frameTimeCounter * 0.61803398875, 1.0) * sign(mod(frameTimeCounter * 0.61803398875, 2.0) - 1.0) + float(mod(frameTimeCounter * 0.61803398875, 2.0) < 1.0);
*/

// ═══════════════════════════════════════════════════════════════════════════════
// 🔆 Lens Flare Effect System | نظام تأثير وهج العدسة
// ═══════════════════════════════════════════════════════════════════════════════
float fovmult = gbufferProjection[1][1] / 1.37373871;

float BaseLens(vec2 lightPos, float size, float dist, float hardness) {
    vec2 lensCoord = (texCoord + (lightPos * dist - 0.5)) * vec2(aspectRatio, 1.0);
    float lens = clamp(1.0 - length(lensCoord) / (size * fovmult), 0.0, 1.0 / hardness) * hardness;
    lens *= lens; lens *= lens;
    return lens;
}

float OverlapLens(vec2 lightPos, float size, float dista, float distb) {
    return BaseLens(lightPos, size, dista, 2.0) * BaseLens(lightPos, size, distb, 2.0);
}

float PointLens(vec2 lightPos, float size, float dist) {
    float lens = BaseLens(lightPos, size, dist, 1.5) + BaseLens(lightPos, size * 4.0, dist, 1.0) * 0.5;
    return lens * (0.5 + 0.5 * sunFactor);
}

float RingLensTransform(float lensFlare) {
    return pow(1.0 - pow(1.0 - pow(lensFlare, 0.25), 10.0), 5.0);
}

float RingLens(vec2 lightPos, float size, float distA, float distB) {
    float lensFlare1 = RingLensTransform(BaseLens(lightPos, size, distA, 1.0));
    float lensFlare2 = RingLensTransform(BaseLens(lightPos, size, distB, 1.0));

    float lensFlare = clamp(lensFlare2 - lensFlare1, 0.0, 1.0);
    lensFlare *= sqrt(lensFlare);

    lensFlare *= 1.0 - length(texCoord - lightPos - 0.5);
    return lensFlare;
}

vec2 lensFlareCheckOffsets[4] = vec2[4](
    vec2( 1.0,0.0),
    vec2(-1.0,1.0),
    vec2( 0.0,1.0),
    vec2( 1.0,1.0)
);

void DoLensFlare(inout vec3 color, vec3 viewPos, float dither) {
    #if LENSFLARE_MODE == 1
        if (sunVec.z > 0.0) return;
    #endif

    vec4 clipPosSun = gbufferProjection * vec4(sunVec + 0.001, 1.0); //+0.001 fixes black screen with camera rotation set to 0,0
    vec3 lightPos3 = clipPosSun.xyz / clipPosSun.w * 0.5;
    vec2 lightPos = lightPos3.xy;
    vec3 screenPosSun = lightPos3 + 0.5;

    float flareFactor = 1.0;
    vec2 cScale = 40.0 / vec2(viewWidth, viewHeight);
    for (int i = 0; i < 4; i++) {
        vec2 cOffset = (lensFlareCheckOffsets[i] - dither) * cScale;
        vec2 checkCoord1 = screenPosSun.xy + cOffset;
        vec2 checkCoord2 = screenPosSun.xy - cOffset;

        float zSample1 = texture2D(depthtex0, checkCoord1).r;
        float zSample2 = texture2D(depthtex0, checkCoord2).r;
        #ifdef VL_CLOUDS_ACTIVE
            float cloudLinearDepth1 = texture2D(colortex4, checkCoord1).r;
            float cloudLinearDepth2 = texture2D(colortex4, checkCoord2).r;
            zSample1 = min(zSample1, cloudLinearDepth1);
            zSample2 = min(zSample2, cloudLinearDepth2);
        #endif

        if (zSample1 < 1.0)
            flareFactor -= 0.125;
        if (zSample2 < 1.0)
            flareFactor -= 0.125;
    }

    float str = length(lightPos * vec2(aspectRatio, 1.0));
    str = pow(clamp(str * 8.0, 0.0, 1.0), 2.0) - clamp(str * 3.0 - 1.5, 0.0, 1.0);
    flareFactor *= str;

    #ifdef SUN_MOON_DURING_RAIN
        flareFactor *= 0.65 - 0.4 * rainFactor;
    #else
        flareFactor *= 1.0 - rainFactor;
    #endif

    vec3 flare = (
        BaseLens(lightPos, 0.3, -0.45, 1.0) * vec3(2.2, 1.2, 0.1) * 0.07 +
        BaseLens(lightPos, 0.3,  0.10, 1.0) * vec3(2.2, 0.4, 0.1) * 0.03 +
        BaseLens(lightPos, 0.3,  0.30, 1.0) * vec3(2.2, 0.2, 0.1) * 0.04 +
        BaseLens(lightPos, 0.3,  0.50, 1.0) * vec3(2.2, 0.4, 2.5) * 0.05 +
        BaseLens(lightPos, 0.3,  0.70, 1.0) * vec3(1.8, 0.4, 2.5) * 0.06 +
        BaseLens(lightPos, 0.3,  0.90, 1.0) * vec3(0.1, 0.2, 2.5) * 0.07 +

        OverlapLens(lightPos, 0.08, -0.28, -0.39) * vec3(2.5, 1.2, 0.1) * 0.015 +
        OverlapLens(lightPos, 0.08, -0.20, -0.31) * vec3(2.5, 0.5, 0.1) * 0.010 +
        OverlapLens(lightPos, 0.12,  0.06,  0.19) * vec3(2.5, 0.2, 0.1) * 0.020 +
        OverlapLens(lightPos, 0.12,  0.15,  0.28) * vec3(1.8, 0.1, 1.2) * 0.015 +
        OverlapLens(lightPos, 0.12,  0.24,  0.37) * vec3(1.0, 0.1, 2.5) * 0.010 +

        PointLens(lightPos, 0.03, -0.55) * vec3(2.5, 1.6, 0.0) * 0.06 +
        PointLens(lightPos, 0.02, -0.40) * vec3(2.5, 1.0, 0.0) * 0.045 +
        PointLens(lightPos, 0.04,  0.43) * vec3(2.5, 0.6, 0.6) * 0.06 +
        PointLens(lightPos, 0.02,  0.60) * vec3(0.2, 0.6, 2.5) * 0.045 +
        PointLens(lightPos, 0.03,  0.67) * vec3(0.7, 1.1, 3.0) * 0.075 +

        RingLens(lightPos, 0.22, 0.44, 0.46) * vec3(0.10, 0.35, 2.50) * 1.5 +
        RingLens(lightPos, 0.15, 0.98, 0.99) * vec3(0.15, 0.40, 2.55) * 2.5
    );

    #if LENSFLARE_MODE == 2
        if (sunVec.z > 0.0) {
            flare = flare * 0.2 + GetLuminance(flare) * vec3(0.3, 0.4, 0.6);
            flare *= clamp01(1.0 - (SdotU + 0.1) * 5.0);
            flareFactor *= LENSFLARE_I > 1.001 ? sqrt(LENSFLARE_I) : LENSFLARE_I;
        } else
    #endif
    {
        flareFactor *= LENSFLARE_I;
        flare *= clamp01((SdotU + 0.1) * 5.0);
    }

    flare *= flareFactor;

    color = mix(color, vec3(1.0), flare);
}

// ═══════════════════════════════════════════════════════════════════════════════
// 🎯 Pixelation Effect System | نظام تأثير البكسلة
// ═══════════════════════════════════════════════════════════════════════════════
#if PIXEL_SCALE == -2
    #define PIXEL_TEXEL_SCALE 4.0
#elif PIXEL_SCALE == -1
    #define PIXEL_TEXEL_SCALE 2.0
#elif PIXEL_SCALE == 2
    #define PIXEL_TEXEL_SCALE 0.5
#elif PIXEL_SCALE == 3
    #define PIXEL_TEXEL_SCALE 0.25
#elif PIXEL_SCALE == 4
    #define PIXEL_TEXEL_SCALE 0.125
#elif PIXEL_SCALE == 5
    #define PIXEL_TEXEL_SCALE 0.0625
#else // 1 or out of range
    #define PIXEL_TEXEL_SCALE 1.0
#endif

#ifdef FRAGMENT_SHADER
    // Thanks to Nestorboy

    // Computes axis-aligned screen space offset to texel center.
    // https://forum.unity.com/threads/the-quest-for-efficient-per-texel-lighting.529948/#post-7536023
    vec2 ComputeTexelOffset(vec2 uv, vec4 texelSize) {
        // 1. Calculate how much the texture UV coords need to shift to be at the center of the nearest texel.
        vec2 uvCenter = (floor(uv * texelSize.zw) + 0.5) * texelSize.xy;
        vec2 dUV = uvCenter - uv;

        // 2. Calculate how much the texture coords vary over fragment space.
        //     This essentially defines a 2x2 matrix that gets texture space (UV) deltas from fragment space (ST) deltas.
        vec2 dUVdS = dFdx(uv);
        vec2 dUVdT = dFdy(uv);

        if (abs(dUVdS) + abs(dUVdT) == vec2(0.0)) return vec2(0.0);

        // 3. Invert the texture delta from fragment delta matrix. Where the magic happens.
        mat2x2 dSTdUV = mat2x2(dUVdT[1], -dUVdT[0], -dUVdS[1], dUVdS[0]) * (1.0 / (dUVdS[0] * dUVdT[1] - dUVdT[0] * dUVdS[1]));

        // 4. Convert the texture delta to fragment delta.
        vec2 dST = dUV * dSTdUV;
        return dST;
    }

    vec2 ComputeTexelOffset(sampler2D tex, vec2 uv) {
        vec2 texSize = textureSize(tex, 0) * PIXEL_TEXEL_SCALE;
        vec4 texelSize = vec4(1.0 / texSize.xy, texSize.xy);

        return ComputeTexelOffset(uv, texelSize);
    }

    vec4 TexelSnap(vec4 value, vec2 texelOffset) {
        if (texelOffset == vec2(0.0)) return value;
        vec4 dx = dFdx(value);
        vec4 dy = dFdy(value);

        vec4 valueOffset = dx * texelOffset.x + dy * texelOffset.y;
        valueOffset = clamp(valueOffset, -1.0, 1.0);

        return value + valueOffset;
    }

    vec3 TexelSnap(vec3 value, vec2 texelOffset) {
        if (texelOffset == vec2(0.0)) return value;
        vec3 dx = dFdx(value);
        vec3 dy = dFdy(value);

        vec3 valueOffset = dx * texelOffset.x + dy * texelOffset.y;
        valueOffset = clamp(valueOffset, -1.0, 1.0);

        return value + valueOffset;
    }

    vec2 TexelSnap(vec2 value, vec2 texelOffset) {
        if (texelOffset == vec2(0.0)) return value;
        vec2 dx = dFdx(value);
        vec2 dy = dFdy(value);

        vec2 valueOffset = dx * texelOffset.x + dy * texelOffset.y;
        valueOffset = clamp(valueOffset, -1.0, 1.0);

        return value + valueOffset;
    }

    float TexelSnap(float value, vec2 texelOffset) {
        if (texelOffset == vec2(0.0)) return value;
        float dx = dFdx(value);
        float dy = dFdy(value);

        float valueOffset = dx * texelOffset.x + dy * texelOffset.y;
        valueOffset = clamp(valueOffset, -1.0, 1.0);

        return value + valueOffset;
    }
#endif

// ═══════════════════════════════════════════════════════════════════════════════
// 💧 Puddle Voxelization System | نظام فوكسل البرك
// ═══════════════════════════════════════════════════════════════════════════════
const ivec3 puddle_voxelVolumeSize = ivec3(128);

vec3 TransformMat(mat4 m, vec3 pos) {
    return mat3(m) * pos + m[3].xyz;
}

vec3 SceneToPuddleVoxel(vec3 scenePos) {
	return scenePos + fract(cameraPosition) + (0.5 * vec3(puddle_voxelVolumeSize));
}

bool CheckInsidePuddleVoxelVolume(vec3 voxelPos) {
    #ifndef SHADOW
        voxelPos -= puddle_voxelVolumeSize / 2;
        voxelPos += sign(voxelPos) * 0.95;
        voxelPos += puddle_voxelVolumeSize / 2;
    #endif
    voxelPos /= vec3(puddle_voxelVolumeSize);
	return clamp01(voxelPos) == voxelPos;
}

#if defined SHADOW && defined VERTEX_SHADER
    void UpdatePuddleVoxelMap(int mat) {
        if (renderStage != MC_RENDER_STAGE_TERRAIN_TRANSLUCENT) return;
        if (mat == 32000) return; // Water

        vec3 model_pos = gl_Vertex.xyz + at_midBlock / 64.0;
        vec3 view_pos  = TransformMat(gl_ModelViewMatrix, model_pos);
        vec3 scenePos = TransformMat(shadowModelViewInverse, view_pos);
        vec3 voxelPos = SceneToPuddleVoxel(scenePos);

        if (CheckInsidePuddleVoxelVolume(voxelPos))
            if (scenePos.y >= -3.5)
            imageStore(puddle_img, ivec2(voxelPos.xz), uvec4(10u, 0u, 0u, 0u));
    }
#endif

// ═══════════════════════════════════════════════════════════════════════════════
// 💡 Show Light Levels System | نظام عرض مستويات الإضاءة
// ═══════════════════════════════════════════════════════════════════════════════
// Note: This code should be used directly in material shaders
// ملاحظة: هذا الكود يجب استخدامه مباشرة في material shaders
/*
#if SHOW_LIGHT_LEVEL == 1
    if (heldItemId == 40000 || heldItemId2 == 40000)
#elif SHOW_LIGHT_LEVEL == 2
    if (heldBlockLightValue > 7.4 || heldBlockLightValue2 > 7.4)
#endif

if (NdotU > 0.99) {
    #ifdef OVERWORLD
        #if MC_VERSION < 11800
            float lxMin = 0.533334;
        #else
            float lxMin = 0.034; // Quite high minimum value because of an Iris/Sodium issue
        #endif
            float lyMin = 0.533334;
    #else
        float lxMin = 0.8;
        float lyMin = 0.533334;
    #endif

    bool xDanger = lmCoord.x < lxMin;
    #ifndef NETHER
        bool yDanger = lmCoord.y < lyMin;
    #else
        bool yDanger = lmCoord.x < lyMin;
    #endif

    if (xDanger) {
        vec2 indicatePos = playerPos.xz + cameraPosition.xz;
        indicatePos = 1.0 - 2.0 * abs(fract(indicatePos) - 0.5);
        float minPos = min(indicatePos.x, indicatePos.y);

        if (minPos > 0.5) {
            color.rgb = yDanger ? vec3(0.4, 0.05, 0.05) : vec3(0.3, 0.3, 0.05);

            smoothnessG = 0.5;
            highlightMult = 1.0;
            smoothnessD = 0.0;

            emission = 3.0;
        }
    }
}
*/

// ═══════════════════════════════════════════════════════════════════════════════
// 🔳 World Outline Effect System | نظام تأثير حدود العالم
// ═══════════════════════════════════════════════════════════════════════════════
vec2 worldOutlineOffset[4] = vec2[4] (
    vec2(-1.0, 1.0),
    vec2( 0,   1.0),
    vec2( 1.0, 1.0),
    vec2( 1.0, 0)
);

void DoWorldOutline(inout vec3 color, float linearZ0) {
    vec2 scale = vec2(1.0 / view);

    float outlines[2] = float[2] (0.0, 0.0);
    float outlined = 1.0;
    float z = linearZ0 * far;
    float totalz = 0.0;
    float maxz = 0.0;
    float sampleza = 0.0;
    float samplezb = 0.0;

    int sampleCount = WORLD_OUTLINE_THICKNESS * 4;

    for (int i = 0; i < sampleCount; i++) {
        vec2 offset = (1.0 + floor(i / 4.0)) * scale * worldOutlineOffset[int(mod(float(i), 4))];
        float depthCheckP = GetLinearDepth(texture2D(depthtex0, texCoord + offset).r) * far;
        float depthCheckN = GetLinearDepth(texture2D(depthtex0, texCoord - offset).r) * far;

        outlined *= clamp(1.0 - ((depthCheckP + depthCheckN) - z * 2.0) * 32.0 / z, 0.0, 1.0);

        if (i <= 4) maxz = max(maxz, max(depthCheckP, depthCheckN));
        totalz += depthCheckP + depthCheckN;
    }

    float outlinea = 1.0 - clamp((z * 8.0 - totalz) * 64.0 / z, 0.0, 1.0) * clamp(1.0 - ((z * 8.0 - totalz) * 32.0 - 1.0) / z, 0.0, 1.0);
    float outlineb = clamp(1.0 + 8.0 * (z - maxz) / z, 0.0, 1.0);
    float outlinec = clamp(1.0 + 64.0 * (z - maxz) / z, 0.0, 1.0);

    float outline = (0.35 * (outlinea * outlineb) + 0.65) * (0.75 * (1.0 - outlined) * outlinec + 1.0);
    outline -= 1.0;

    outline *= WORLD_OUTLINE_I / WORLD_OUTLINE_THICKNESS;
    if (outline < 0.0) outline = -outline * 0.25;

    color += min(color * outline * 2.5, vec3(outline));
}

/*
════════════════════════════════════════════════════════════════════════════════
    📝 Missing: Voxelization System (Too large for this unified file)
    المفقود: نظام الفوكسل (كبير جداً لهذا الملف الموحد)
    
    Note: The main voxelization.glsl system is complex and large (~326 lines).
    It should remain as a separate include due to its complexity and size.
    It contains extensive material ID mapping and voxel management functions.
    
    ملاحظة: نظام voxelization.glsl الأساسي معقد وكبير (~326 سطر).
    يجب أن يبقى كملف منفصل بسبب تعقيده وحجمه.
    يحتوي على تخطيط معرفات المواد الشامل ووظائف إدارة الفوكسل.
════════════════════════════════════════════════════════════════════════════════
*/
