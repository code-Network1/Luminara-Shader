/*
 * ═══════════════════════════════════════════════════════════════════════════════════════
 * 
 *                              CELESTIAL EFFECTS MODULE
 *                         Luminara Shader - Sky & Space Visual Effects
 * 
 * ═══════════════════════════════════════════════════════════════════════════════════════
 * 
 * Copyright (c) 2025 VcorA Development
 * All rights reserved. Unauthorized reproduction or distribution is prohibited.
 * 
 * This consolidated module handles all celestial and space-based atmospheric effects
 * including aurora borealis, night nebula, stars systems, and dimensional star effects.
 * Optimized for performance with quality-adaptive rendering.
 * 
 * ═══════════════════════════════════════════════════════════════════════════════════════
 */

#ifndef INCLUDE_CELESTIAL_EFFECTS
#define INCLUDE_CELESTIAL_EFFECTS

#include "/lib/color_schemes/core_color_system.glsl"

//═══════════════════════════════════════════════════════════════════════════════════════
//                                 STARS SYSTEM MODULE
//═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Generates pseudo-random noise for star placement
 * @param pos: 2D position coordinate
 * @return: Random value [0.0, 1.0] for star generation
 */
float GetStarNoise(vec2 pos) {
    return fract(sin(dot(pos, vec2(12.9898, 4.1414))) * 43758.54953);
}

/**
 * Calculates star coordinate mapping from view position
 * @param viewPos: View space position vector
 * @param sphereness: Spherical projection factor [0.0, 1.0]
 * @return: 2D star coordinate for texture sampling
 */
vec2 GetStarCoord(vec3 viewPos, float sphereness) {
    vec3 wpos = normalize((gbufferModelViewInverse * vec4(viewPos * 1000.0, 1.0)).xyz);
    vec3 starCoord = wpos / (wpos.y + length(wpos.xz) * sphereness);
    starCoord.x += 0.006 * syncedTime;  // Subtle star movement
    return starCoord.xz;
}

/**
 * Generates overworld star field with configurable density
 * @param starCoord: 2D star coordinate from GetStarCoord
 * @param VdotU: View direction dot up vector
 * @param VdotS: View direction dot sun vector
 * @return: RGB star color contribution
 */
vec3 GetStars(vec2 starCoord, float VdotU, float VdotS) {
    if (VdotU < 0.0) return vec3(0.0);  // No stars below horizon

    starCoord *= 0.2;
    float starFactor = 1024.0;
    starCoord = floor(starCoord * starFactor) / starFactor;

    // Multi-layer star noise for realistic distribution
    float star = 1.0;
    star *= GetStarNoise(starCoord.xy);
    star *= GetStarNoise(starCoord.xy + 0.1);
    star *= GetStarNoise(starCoord.xy + 0.23);

    #if NIGHT_STAR_AMOUNT == 2
        star -= 0.7;  // High star density
    #else
        star -= 0.6;  // Standard star density
        star *= 0.65;
    #endif
    star = max0(star);
    star *= star;  // Square for more dramatic falloff

    // Apply atmospheric and lighting conditions
    star *= min1(VdotU * 3.0) * max0(1.0 - pow(abs(VdotS) * 1.002, 100.0));
    star *= invRainFactor * pow2(pow2(invNoonFactor2)) * (1.0 - 0.5 * sunVisibility);

    return 40.0 * star * vec3(0.38, 0.4, 0.5);
}

//═══════════════════════════════════════════════════════════════════════════════════════
//                               END DIMENSION STARS MODULE
//═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Generates End dimension stars with magical coloring
 * @param viewPos: View space position vector
 * @param VdotU: View direction dot up vector
 * @return: RGB End star color with magical enhancement
 */
vec3 GetEnderStars(vec3 viewPos, float VdotU) {
    vec3 wpos = normalize((gbufferModelViewInverse * vec4(viewPos * 1000.0, 1.0)).xyz);

    vec3 starCoord = 0.65 * wpos / (abs(wpos.y) + length(wpos.xz));
    vec2 starCoord2 = starCoord.xz * 0.5;
    if (VdotU < 0.0) starCoord2 += 100.0;
    float starFactor = 1024.0;
    starCoord2 = floor(starCoord2 * starFactor) / starFactor;

    // Triple-layer End star generation
    float star = 1.0;
    star *= GetStarNoise(starCoord2.xy);
    star *= GetStarNoise(starCoord2.xy + 0.1);
    star *= GetStarNoise(starCoord2.xy + 0.23);
    star = max(star - 0.6, 0.0);  // More visible End stars
    star *= star;

    // Enhanced magical End star colors
    vec3 baseStarColor = endSkyColor * mix(
        vec3(3500.0, 2800.0, 4500.0), 
        vec3(4200.0, 3500.0, 2200.0), 
        GetStarNoise(starCoord2.xy + 0.5)
    );
    vec3 enderStars = star * baseStarColor;

    // Apply directional visibility factors
    float VdotUM1 = abs(VdotU);
    float VdotUM2 = pow2(1.0 - VdotUM1);
    enderStars *= VdotUM1 * VdotUM1 * (VdotUM2 + 0.015) + 0.015;

    return enderStars;
}

//═══════════════════════════════════════════════════════════════════════════════════════
//                              AURORA BOREALIS MODULE
//═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Generates aurora borealis effects with configurable conditions
 * @param viewPos: View space position vector
 * @param VdotU: View direction dot up vector
 * @param dither: Temporal dithering value
 * @return: RGB aurora color contribution
 */
vec3 GetAuroraBorealis(vec3 viewPos, float VdotU, float dither) {
    float visibility = sqrt1(clamp01(VdotU * 1.5 - 0.225)) - sunVisibility - rainFactor - maxBlindnessDarkness;
    visibility *= 1.0 - VdotU * 0.9;

    // Apply aurora visibility conditions
    #if AURORA_CONDITION == 1 || AURORA_CONDITION == 3
        visibility -= moonPhase;
    #endif
    #if AURORA_CONDITION == 2 || AURORA_CONDITION == 3
        visibility *= inSnowy;
    #endif
    #if AURORA_CONDITION == 4
        visibility = max(visibility * inSnowy, visibility - moonPhase);
    #endif

    if (visibility > 0.0) {
        vec3 aurora = vec3(0.0);

        vec3 wpos = mat3(gbufferModelViewInverse) * viewPos;
             wpos.xz /= wpos.y;
        vec2 cameraPositionM = cameraPosition.xz * 0.0075;
             cameraPositionM.x += syncedTime * 0.04;

        // Quality-adaptive sample count
        #ifdef DEFERRED1
            int sampleCount = 25;
            int sampleCountP = sampleCount + 5;
        #else
            int sampleCount = 10;
            int sampleCountP = sampleCount + 10;
        #endif

        float ditherM = dither + 5.0;
        float auroraAnimate = frameTimeCounter * 0.001;
        
        // Multi-layer aurora generation
        for (int i = 0; i < sampleCount; i++) {
            float current = pow2((i + ditherM) / sampleCountP);

            vec2 planePos = wpos.xz * (0.8 + current) * 11.0 + cameraPositionM;
            
            #if AURORA_STYLE == 1
                // Pixelated aurora style
                planePos = floor(planePos) * 0.0007;
                float noise = texture2D(noisetex, planePos).b;
                noise = pow2(pow2(pow2(pow2(1.0 - 2.0 * abs(noise - 0.5)))));
                noise *= pow1_5(texture2D(noisetex, planePos * 100.0 + auroraAnimate).b);
            #else
                // Smooth aurora style
                planePos *= 0.0007;
                float noise = texture2D(noisetex, planePos).r;
                noise = pow2(pow2(pow2(pow2(1.0 - 2.0 * abs(noise - 0.5)))));
                noise *= texture2D(noisetex, planePos * 3.0 + auroraAnimate).b;
                noise *= texture2D(noisetex, planePos * 5.0 - auroraAnimate).b;
            #endif

            float currentM = 1.0 - current;
            aurora += noise * currentM * mix(
                vec3(7.0, 2.2, 12.0), 
                vec3(6.0, 16.0, 12.0), 
                pow2(pow2(currentM))
            );
        }

        #if AURORA_STYLE == 1
            aurora *= 1.3;
        #else
            aurora *= 1.8;
        #endif

        #ifdef ATM_COLOR_MULTS
            aurora *= sqrtAtmColorMult;
        #endif

        return aurora * visibility / sampleCount;
    }

    return vec3(0.0);
}

//═══════════════════════════════════════════════════════════════════════════════════════
//                                NIGHT NEBULA MODULE
//═══════════════════════════════════════════════════════════════════════════════════════

#ifndef HQ_NIGHT_NEBULA
    const int OCTAVE = 5;
#else
    const int OCTAVE = 8;
#endif
const float timescale = 5.0;
const float zoomScale = 3.5;
const vec4 CLOUD1_COL = vec4(0.41, 0.64, 0.97, 0.4);
const vec4 CLOUD2_COL = vec4(0.81, 0.55, 0.21, 0.2);
const vec4 CLOUD3_COL = vec4(0.51, 0.81, 0.98, 1.0);

float sinM(float x) {
    return sin(mod(x, 2.0 * pi));
}

float cosM(float x) {
    return cos(mod(x, 2.0 * pi));
}

float rand(vec2 inCoord){
    return fract(sinM(dot(inCoord, vec2(23.53, 44.0))) * 42350.45);
}

float perlin(vec2 inCoord){
    vec2 i = floor(inCoord);
    vec2 j = fract(inCoord);
    vec2 coord = smoothstep(0.0, 1.0, j);

    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));

    return mix(mix(a, b, coord.x), mix(c, d, coord.x), coord.y);
}

float fbmCloud(vec2 inCoord, float minimum){
    float value = 0.0;
    float scale = 0.5;

    for (int i = 0; i < OCTAVE; i++){
        value += perlin(inCoord) * scale;
        inCoord *= 2.0;
        scale *= 0.5;
    }

    return smoothstep(0.0, 1.0, (smoothstep(minimum, 1.0, value) - minimum) / (1.0 - minimum));
}

float fbmCloud2(vec2 inCoord, float minimum){
    float value = 0.0;
    float scale = 0.5;

    for (int i = 0; i < OCTAVE; i++){
        value += perlin(inCoord) * scale;
        inCoord *= 2.0;
        scale *= 0.5;
    }

    return (smoothstep(minimum, 1.0, value) - minimum) / (1.0 - minimum);
}

/**
 * Generates night nebula effects with fractal noise
 * @param viewPos: View space position vector
 * @param VdotU: View direction dot up vector
 * @param VdotS: View direction dot sun vector
 * @return: RGB nebula color contribution
 */
vec3 GetNightNebula(vec3 viewPos, float VdotU, float VdotS) {
    float nebulaFactor = pow2(max0(VdotU) * min1(nightFactor * 2.0)) * invRainFactor - maxBlindnessDarkness;
    if (nebulaFactor < 0.001) return vec3(0.0);

    vec2 UV = GetStarCoord(viewPos, 0.75);
    float TIME = syncedTime * 0.003 + 15.0;

    float timescaled = TIME * timescale;
    vec2 zoomUV2 = vec2(
        zoomScale * UV.x + 0.03  * timescaled * sinM(0.07 * timescaled), 
        zoomScale * UV.y + 0.03  * timescaled * cosM(0.06 * timescaled)
    );
    vec2 zoomUV3 = vec2(
        zoomScale * UV.x + 0.027 * timescaled * sinM(0.07 * timescaled), 
        zoomScale * UV.y + 0.025 * timescaled * cosM(0.06 * timescaled)
    );
    vec2 zoomUV4 = vec2(
        zoomScale * UV.x + 0.021 * timescaled * sinM(0.07 * timescaled), 
        zoomScale * UV.y + 0.021 * timescaled * cosM(0.07 * timescaled)
    );
    
    float tide = 0.05 * sinM(TIME);
    float tide2 = 0.06 * cosM(0.3 * TIME);

    // Multi-layer nebula texture generation
    vec4 nebulaTexture = vec4(vec3(0.0), 0.5 + 0.2 * sinM(0.23 * TIME + UV.x - UV.y));
    nebulaTexture += fbmCloud2(zoomUV3, 0.24 + tide) * CLOUD1_COL;
    nebulaTexture += fbmCloud(zoomUV2 * 0.9, 0.33 - tide) * CLOUD2_COL;
    nebulaTexture = mix(nebulaTexture, CLOUD3_COL, fbmCloud(vec2(0.9 * zoomUV4.x, 0.9 * zoomUV4.y), 0.25 + tide2));

    nebulaFactor *= 1.0 - pow2(pow2(pow2(abs(VdotS))));
    nebulaTexture.a *= min1(pow2(pow2(nebulaTexture.a))) * nebulaFactor;

    // Add star integration
    float starFactor = 1024.0;
    vec2 starCoord = floor(UV * 0.25 * starFactor) / starFactor;
    nebulaTexture.rgb *= 1.5 + 10.0 * pow2(max0(GetStarNoise(starCoord) * GetStarNoise(starCoord + 0.1) - 0.6));

    #if NIGHT_NEBULA_I != 100
        #define NIGHT_NEBULA_IM NIGHT_NEBULA_I * 0.01
        nebulaTexture.a *= NIGHT_NEBULA_IM;
    #endif

    #ifdef ATM_COLOR_MULTS
        nebulaTexture.rgb *= sqrtAtmColorMult;
    #endif

    return max(nebulaTexture.rgb * nebulaTexture.a, vec3(0.0));
}

//═══════════════════════════════════════════════════════════════════════════════════════
//                               LEGACY COMPATIBILITY
//═══════════════════════════════════════════════════════════════════════════════════════

// Maintain backward compatibility with existing celestial systems
#define GetNightStars GetStars
#define GetCelestialEffects GetAuroraBorealis

#endif // INCLUDE_CELESTIAL_EFFECTS
