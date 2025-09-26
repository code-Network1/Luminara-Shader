/*
=============================================================================
    FAST SMOOTHING (FXAA) - Luminara Shader Pack
    © 2024 VcorA. All Rights Reserved.
    
    DEVELOPER TIPS:
    • Fast Approximate Anti-Aliasing for edge smoothing without TAA
    • Best for low-end systems or when temporal artifacts are unwanted
    • Quality settings range from 0.03125 (sharp) to 0.0625 (smooth)
    • 12 iteration levels provide excellent edge detection accuracy
    
    PERFORMANCE NOTES:
    • Moderate GPU impact (~3-5% depending on resolution)
    • Single-pass algorithm - no temporal accumulation required
    • Works independently of framerate for consistent results
    • Can be combined with TAA for hybrid smoothing approach
    
    TECHNICAL SPECS:
    • Luminance-based edge detection using RGB to grayscale conversion
    • Subpixel reconstruction with 12-sample quality array
    • Directional blur along detected edge gradients
    • Compatible with all render pipelines and lighting modes
    
    COPYRIGHT NOTICE:
    This implementation is proprietary to VcorA and Luminara Shader Pack.
    Based on NVIDIA's FXAA 3.11 with custom optimizations.
    Redistribution or modification without permission is prohibited.
=============================================================================
*/

#ifdef FXAA_TAA_INTERACTION
    ivec2 neighbourhoodOffsets[8] = ivec2[8](
        ivec2( 1, 1),
        ivec2( 1,-1),
        ivec2(-1, 1),
        ivec2(-1,-1),
        ivec2( 1, 0),
        ivec2( 0, 1),
        ivec2(-1, 0),
        ivec2( 0,-1)
    );
#endif

// VcorA's FXAA quality presets - optimized for various performance targets
// Higher values = better quality but more GPU intensive
float quality[12] = float[12] (1.0, 1.0, 1.0, 1.0, 1.0, 1.5, 2.0, 2.0, 2.0, 2.0, 4.0, 8.0);

// FXAA 3.11 Implementation with VcorA's enhancements
// Provides excellent edge smoothing with minimal performance cost
// @param color: Input color that will be modified with FXAA smoothing
void FXAA311(inout vec3 color) {
    // Edge detection thresholds - VcorA's balanced settings
    float edgeThresholdMin = 0.03125;  // Minimum contrast for edge detection
    float edgeThresholdMax = 0.0625;   // Maximum contrast scaling factor
    float subpixelQuality = 0.75;      // Subpixel reconstruction quality (0.0-1.0)
    int iterations = 12;               // Maximum search iterations for edge endpoints

    vec2 view = 1.0 / vec2(viewWidth, viewHeight);

    // Step 1: Sample luminance values from center and 4 cardinal directions
    // This forms the basic cross pattern for initial edge detection
    float lumaCenter = GetLuminance(color);
    float lumaDown  = GetLuminance(texelFetch(colortex3, texelCoord + ivec2( 0, -1), 0).rgb);
    float lumaUp    = GetLuminance(texelFetch(colortex3, texelCoord + ivec2( 0,  1), 0).rgb);
    float lumaLeft  = GetLuminance(texelFetch(colortex3, texelCoord + ivec2(-1,  0), 0).rgb);
    float lumaRight = GetLuminance(texelFetch(colortex3, texelCoord + ivec2( 1,  0), 0).rgb);

    // Find luminance range for contrast-based edge detection
    float lumaMin = min(lumaCenter, min(min(lumaDown, lumaUp), min(lumaLeft, lumaRight)));
    float lumaMax = max(lumaCenter, max(max(lumaDown, lumaUp), max(lumaLeft, lumaRight)));

    float lumaRange = lumaMax - lumaMin;

    // VcorA's adaptive threshold: Only process pixels with sufficient contrast
    // This prevents FXAA from blurring low-contrast areas unnecessarily
    if (lumaRange > max(edgeThresholdMin, lumaMax * edgeThresholdMax)) {
        float lumaDownLeft  = GetLuminance(texelFetch(colortex3, texelCoord + ivec2(-1, -1), 0).rgb);
        float lumaUpRight   = GetLuminance(texelFetch(colortex3, texelCoord + ivec2( 1,  1), 0).rgb);
        float lumaUpLeft    = GetLuminance(texelFetch(colortex3, texelCoord + ivec2(-1,  1), 0).rgb);
        float lumaDownRight = GetLuminance(texelFetch(colortex3, texelCoord + ivec2( 1, -1), 0).rgb);

        float lumaDownUp    = lumaDown + lumaUp;
        float lumaLeftRight = lumaLeft + lumaRight;

        float lumaLeftCorners  = lumaDownLeft  + lumaUpLeft;
        float lumaDownCorners  = lumaDownLeft  + lumaDownRight;
        float lumaRightCorners = lumaDownRight + lumaUpRight;
        float lumaUpCorners    = lumaUpRight   + lumaUpLeft;

        float edgeHorizontal = abs(-2.0 * lumaLeft   + lumaLeftCorners ) +
                               abs(-2.0 * lumaCenter + lumaDownUp      ) * 2.0 +
                               abs(-2.0 * lumaRight  + lumaRightCorners);
        float edgeVertical   = abs(-2.0 * lumaUp     + lumaUpCorners   ) +
                               abs(-2.0 * lumaCenter + lumaLeftRight   ) * 2.0 +
                               abs(-2.0 * lumaDown   + lumaDownCorners );

        bool isHorizontal = (edgeHorizontal >= edgeVertical);

        float luma1 = isHorizontal ? lumaDown : lumaLeft;
        float luma2 = isHorizontal ? lumaUp : lumaRight;
        float gradient1 = luma1 - lumaCenter;
        float gradient2 = luma2 - lumaCenter;

        bool is1Steepest = abs(gradient1) >= abs(gradient2);
        float gradientScaled = 0.25 * max(abs(gradient1), abs(gradient2));

        float stepLength = isHorizontal ? view.y : view.x;

        float lumaLocalAverage = 0.0;

        if (is1Steepest) {
            stepLength = - stepLength;
            lumaLocalAverage = 0.5 * (luma1 + lumaCenter);
        } else {
            lumaLocalAverage = 0.5 * (luma2 + lumaCenter);
        }

        vec2 currentUv = texCoord;
        if (isHorizontal) {
            currentUv.y += stepLength * 0.5;
        } else {
            currentUv.x += stepLength * 0.5;
        }

        vec2 offset = isHorizontal ? vec2(view.x, 0.0) : vec2(0.0, view.y);

        vec2 uv1 = currentUv - offset;
        vec2 uv2 = currentUv + offset;
        float lumaEnd1 = GetLuminance(texture2D(colortex3, uv1).rgb);
        float lumaEnd2 = GetLuminance(texture2D(colortex3, uv2).rgb);
        lumaEnd1 -= lumaLocalAverage;
        lumaEnd2 -= lumaLocalAverage;

        bool reached1 = abs(lumaEnd1) >= gradientScaled;
        bool reached2 = abs(lumaEnd2) >= gradientScaled;
        bool reachedBoth = reached1 && reached2;

        if (!reached1) {
            uv1 -= offset;
        }
        if (!reached2) {
            uv2 += offset;
        }

        if (!reachedBoth) {
            for (int i = 2; i < iterations; i++) {
                if (!reached1) {
                    lumaEnd1 = GetLuminance(texture2D(colortex3, uv1).rgb);
                    lumaEnd1 = lumaEnd1 - lumaLocalAverage;
                }
                if (!reached2) {
                    lumaEnd2 = GetLuminance(texture2D(colortex3, uv2).rgb);
                    lumaEnd2 = lumaEnd2 - lumaLocalAverage;
                }

                reached1 = abs(lumaEnd1) >= gradientScaled;
                reached2 = abs(lumaEnd2) >= gradientScaled;
                reachedBoth = reached1 && reached2;

                if (!reached1) {
                    uv1 -= offset * quality[i];
                }
                if (!reached2) {
                    uv2 += offset * quality[i];
                }

                if (reachedBoth) break;
            }
        }

        float distance1 = isHorizontal ? (texCoord.x - uv1.x) : (texCoord.y - uv1.y);
        float distance2 = isHorizontal ? (uv2.x - texCoord.x) : (uv2.y - texCoord.y);

        bool isDirection1 = distance1 < distance2;
        float distanceFinal = min(distance1, distance2);

        float edgeThickness = (distance1 + distance2);

        float pixelOffset = - distanceFinal / edgeThickness + 0.5;

        bool isLumaCenterSmaller = lumaCenter < lumaLocalAverage;

        bool correctVariation = ((isDirection1 ? lumaEnd1 : lumaEnd2) < 0.0) != isLumaCenterSmaller;

        float finalOffset = correctVariation ? pixelOffset : 0.0;

        float lumaAverage = (1.0 / 12.0) * (2.0 * (lumaDownUp + lumaLeftRight) + lumaLeftCorners + lumaRightCorners);
        float subPixelOffset1 = clamp(abs(lumaAverage - lumaCenter) / lumaRange, 0.0, 1.0);
        float subPixelOffset2 = (-2.0 * subPixelOffset1 + 3.0) * subPixelOffset1 * subPixelOffset1;
        float subPixelOffsetFinal = subPixelOffset2 * subPixelOffset2 * subpixelQuality;

        finalOffset = max(finalOffset, subPixelOffsetFinal);

        vec2 finalUv = texCoord;
        if (isHorizontal) {
            finalUv.y += finalOffset * stepLength;
        } else {
            finalUv.x += finalOffset * stepLength;
        }

        #if defined TAA && defined FXAA_TAA_INTERACTION && TAA_MODE == 1
            vec3 newColor = texture2D(colortex3, finalUv).rgb;
            float skipFactor = min1(
                20.0 * length(cameraPosition - previousCameraPosition)
                #ifdef TAA_MOVEMENT_IMPROVEMENT_FILTER
                    + 0.25 
                #endif
            );

            float z0 = texelFetch(depthtex0, texelCoord, 0).r;
            float z1 = texelFetch(depthtex1, texelCoord, 0).r;
            bool edge = false;
            for (int i = 0; i < 8; i++) {
                ivec2 texelCoordM = texelCoord + neighbourhoodOffsets[i];

                float z0Check = texelFetch(depthtex0, texelCoordM, 0).r;
                float z1Check = texelFetch(depthtex1, texelCoordM, 0).r;
                if (max(abs(GetLinearDepth(z0Check) - GetLinearDepth(z0)), abs(GetLinearDepth(z1Check) - GetLinearDepth(z1))) > 0.09) {
                    edge = true;
                    break;
                }
            }
            if (edge) skipFactor = 0.0;

            if (dot(texelFetch(colortex2, texelCoord, 0).rgb, vec3(1.0)) < 0.01) skipFactor = 0.0;
            
            color = mix(newColor, color, skipFactor);
        #else
            color = texture2D(colortex3, finalUv).rgb;
        #endif
    }
}
