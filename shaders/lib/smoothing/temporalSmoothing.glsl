/*
=============================================================================
    TEMPORAL SMOOTHING (TAA) - Luminara Shader Pack
    © 2024 VcorA. All Rights Reserved.
    
    DEVELOPER TIPS:
    • Advanced Temporal Anti-Aliasing with motion vector reprojection
    • Accumulates multiple frames for superior edge smoothing
    • TAA_MODE 1: Balanced quality/performance for most systems
    • TAA_MODE 2: Higher quality with increased GPU load
    
    PERFORMANCE NOTES:
    • Requires stable framerate for optimal results (60+ FPS recommended)
    • Higher blend factors = more temporal stability but potential ghosting
    • Motion detection prevents artifacts during camera movement
    • Catmull-Rom sampling provides superior subpixel reconstruction
    
    TECHNICAL FEATURES:
    • AABB clamping prevents color bleeding and temporal artifacts
    • Neighborhood sampling with depth-aware edge detection
    • Motion-compensated blending for smooth camera transitions
    • Support for Distant Horizons integration
    
    QUALITY SETTINGS:
    • blendMinimum: Minimum temporal accumulation (stability vs. sharpness)
    • blendVariable: Motion-based blend adjustment
    • regularEdge: Edge detection sensitivity
    • extraEdgeMult: Enhanced detection for special materials
    
    COPYRIGHT NOTICE:
    This TAA implementation is proprietary to VcorA and Luminara Shader Pack.
    Advanced algorithms and optimizations are protected intellectual property.
    Redistribution or modification without permission is prohibited.
=============================================================================
*/

#if TAA_MODE == 1
    // VcorA's TAA Mode 1: Balanced settings for optimal quality/performance
    float blendMinimum = 0.3;    // Minimum blend factor for temporal stability
    float blendVariable = 0.2;   // Variable blend based on motion vectors
    float blendConstant = 0.7;   // Base blending strength

    float regularEdge = 20.0;      // Standard edge detection threshold
    float extraEdgeMult = 3.0;     // Multiplier for enhanced edge materials
#elif TAA_MODE == 2
    // VcorA's TAA Mode 2: High quality settings for premium systems
    float blendMinimum = 0.6;    // Higher minimum for more aggressive smoothing
    float blendVariable = 0.2;   // Consistent motion response
    float blendConstant = 0.7;   // Maintained base strength

    float regularEdge = 5.0;       // More sensitive edge detection
    float extraEdgeMult = 3.0;     // Enhanced material detection
#endif

#ifdef TAA_MOVEMENT_IMPROVEMENT_FILTER
    // VcorA's Catmull-Rom bicubic interpolation for superior TAA quality
    // Provides smoother temporal reconstruction compared to linear sampling
    // @param colortex: Source texture sampler
    // @param texcoord: UV coordinates for sampling
    // @param view: Screen resolution for proper scaling
    // @return: Bicubic-interpolated color sample
    vec3 textureCatmullRom(sampler2D colortex, vec2 texcoord, vec2 view) {
        vec2 position = texcoord * view;
        vec2 centerPosition = floor(position - 0.5) + 0.5;
        vec2 f = position - centerPosition;
        vec2 f2 = f * f;
        vec2 f3 = f * f2;

        float c = 0.7; // Catmull-Rom parameter for optimal sharpness/smoothness balance
        
        // Calculate Catmull-Rom weights for bicubic interpolation
        vec2 w0 =        -c  * f3 +  2.0 * c         * f2 - c * f;
        vec2 w1 =  (2.0 - c) * f3 - (3.0 - c)        * f2         + 1.0;
        vec2 w2 = -(2.0 - c) * f3 + (3.0 -  2.0 * c) * f2 + c * f;
        vec2 w3 =         c  * f3 -                c * f2;

        vec2 w12 = w1 + w2;
        vec2 tc12 = (centerPosition + w2 / w12) / view;

        vec2 tc0 = (centerPosition - 1.0) / view;
        vec2 tc3 = (centerPosition + 2.0) / view;
        
        // Sample texture with computed weights for smooth reconstruction
        vec4 color = vec4(texture2DLod(colortex, vec2(tc12.x, tc0.y ), 0).rgb, 1.0) * (w12.x * w0.y ) +
                    vec4(texture2DLod(colortex, vec2(tc0.x,  tc12.y), 0).rgb, 1.0) * (w0.x  * w12.y) +
                    vec4(texture2DLod(colortex, vec2(tc12.x, tc12.y), 0).rgb, 1.0) * (w12.x * w12.y) +
                    vec4(texture2DLod(colortex, vec2(tc3.x,  tc12.y), 0).rgb, 1.0) * (w3.x  * w12.y) +
                    vec4(texture2DLod(colortex, vec2(tc12.x, tc3.y ), 0).rgb, 1.0) * (w12.x * w3.y );
        return color.rgb / color.a;
    }
#endif

// VcorA's motion vector reprojection for temporal consistency
// Calculates previous frame screen position for TAA accumulation
// @param viewPos1: Current frame view-space position
// @return: Previous frame UV coordinates
vec2 Reprojection(vec4 viewPos1) {
    vec4 pos = gbufferModelViewInverse * viewPos1;
    vec4 previousPosition = pos + vec4(cameraPosition - previousCameraPosition, 0.0);
    previousPosition = gbufferPreviousModelView * previousPosition;
    previousPosition = gbufferPreviousProjection * previousPosition;
    return previousPosition.xy / previousPosition.w * 0.5 + 0.5;
}

// VcorA's AABB color clamping for temporal artifact prevention
// Clips previous frame colors to current neighborhood bounds
// @param q: Previous frame color to be clamped
// @param aabb_min: Minimum color bounds from neighborhood
// @param aabb_max: Maximum color bounds from neighborhood
// @return: Clamped color within neighborhood bounds
vec3 ClipAABB(vec3 q, vec3 aabb_min, vec3 aabb_max){
    vec3 p_clip = 0.5 * (aabb_max + aabb_min);
    vec3 e_clip = 0.5 * (aabb_max - aabb_min) + 0.00000001;

    vec3 v_clip = q - vec3(p_clip);
    vec3 v_unit = v_clip.xyz / e_clip;
    vec3 a_unit = abs(v_unit);
    float ma_unit = max(a_unit.x, max(a_unit.y, a_unit.z));

    if (ma_unit > 1.0)
        return vec3(p_clip) + v_clip / ma_unit;
    else
        return q;
}

// 8-directional neighborhood sampling pattern for edge detection
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

// VcorA's neighborhood clamping with depth-aware edge detection
// Analyzes surrounding pixels to prevent temporal bleeding
// @param color: Current frame center pixel color
// @param tempColor: Previous frame color (modified by reference)
// @param z0: Depth buffer 0 value for edge detection
// @param z1: Depth buffer 1 value for transparency handling
// @param edge: Edge factor (modified by reference)
void NeighbourhoodClamping(vec3 color, inout vec3 tempColor, float z0, float z1, inout float edge) {
    vec3 minclr = color;
    vec3 maxclr = minclr;

    int cc = 2; // Border clamp to prevent out-of-bounds sampling
    ivec2 texelCoordM1 = clamp(texelCoord, ivec2(cc), ivec2(view) - cc); 
    
    // Sample 8-neighborhood for min/max color bounds and edge detection
    for (int i = 0; i < 8; i++) {
        ivec2 texelCoordM2 = texelCoordM1 + neighbourhoodOffsets[i];

        // Depth-based edge detection using linear depth comparison
        float z0Check = texelFetch(depthtex0, texelCoordM2, 0).r;
        float z1Check = texelFetch(depthtex1, texelCoordM2, 0).r;
        if (max(abs(GetLinearDepth(z0Check) - GetLinearDepth(z0)), abs(GetLinearDepth(z1Check) - GetLinearDepth(z1))) > 0.09) {
            edge = regularEdge;

            // Enhanced edge detection for special materials (translucent objects)
            if (int(texelFetch(colortex6, texelCoordM2, 0).g * 255.1) == 253) 
                edge *= extraEdgeMult;
        }

        vec3 clr = texelFetch(colortex3, texelCoordM2, 0).rgb;
        minclr = min(minclr, clr); maxclr = max(maxclr, clr);
    }

    // Apply AABB clamping to prevent temporal color bleeding
    tempColor = ClipAABB(tempColor, minclr, maxclr);
}

// VcorA's main TAA function with advanced motion compensation
// Performs temporal accumulation with artifact prevention
// @param color: Current frame color (modified by reference)
// @param temp: Temporal accumulation buffer (modified by reference)
// @param z1: Depth value for reprojection and material detection
void DoTAA(inout vec3 color, inout vec3 temp, float z1) {
    int materialMask = int(texelFetch(colortex6, texelCoord, 0).g * 255.1);

    vec4 screenPos1 = vec4(texCoord, z1, 1.0);
    vec4 viewPos1 = gbufferProjectionInverse * (screenPos1 * 2.0 - 1.0);
    viewPos1 /= viewPos1.w;

    #ifdef ENTITY_TAA_NOISY_CLOUD_FIX
        float cloudLinearDepth =  texture2D(colortex4, texCoord).r;
        float lViewPos1 = length(viewPos1);

        if (pow2(cloudLinearDepth) * renderDistance < min(lViewPos1, renderDistance)) {
            
            materialMask = 0;
        }
    #endif

    if (materialMask == 254) { 
        #ifndef CUSTOM_PBR
            if (z1 <= 0.56) return;
        #endif
        int i = 0;
        while (i < 4) {
            int mms = int(texelFetch(colortex6, texelCoord + neighbourhoodOffsets[i], 0).g * 255.1);
            if (mms != materialMask) break;
            i++;
        } 
        if (i == 4) return;
    }

    float z0 = texelFetch(depthtex0, texelCoord, 0).r;

    vec2 prvCoord = texCoord;
    if (z1 > 0.56) prvCoord = Reprojection(viewPos1);

    #ifndef TAA_MOVEMENT_IMPROVEMENT_FILTER
        vec3 tempColor = texture2D(colortex2, prvCoord).rgb;
    #else
        vec3 tempColor = textureCatmullRom(colortex2, prvCoord, view);
    #endif

    if (tempColor == vec3(0.0) || any(isnan(tempColor))) { 
        temp = color;
        return;
    }

    float edge = 0.0;
    NeighbourhoodClamping(color, tempColor, z0, z1, edge);

    if (materialMask == 253) 
        edge *= extraEdgeMult;

    #ifdef DISTANT_HORIZONS
        if (z0 == 1.0) {
            blendMinimum = 0.75;
            blendVariable = 0.05;
            blendConstant = 0.9;
            edge = 1.0;
        }
    #endif

    vec2 velocity = (texCoord - prvCoord.xy) * view;
    float blendFactor = float(prvCoord.x > 0.0 && prvCoord.x < 1.0 &&
                              prvCoord.y > 0.0 && prvCoord.y < 1.0);
    float velocityFactor = dot(velocity, velocity) * 10.0;
    blendFactor *= max(exp(-velocityFactor) * blendVariable + blendConstant - length(cameraPosition - previousCameraPosition) * edge, blendMinimum);

    color = mix(color, tempColor, blendFactor);
    temp = color;

    
}
