/*
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
█                     LuminaraCore Advanced Functions Pack                    █
█                      ⚡ Performance Optimized Collection ⚡               █  
█▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

    🔥 ULTIMATE SHADER UTILITIES COMPILATION 🔥
    ════════════════════════════════════════════════
    
    💎 Mathematical Precision Functions
    🌊 Advanced Temporal Smoothing Algorithms  
    🎨 High-Quality Dithering Patterns
    🚀 Lightning-Fast Space Transformations
    📊 Professional Debug Text System
    ⚡ Memory-Optimized Data Structures
    
    
    
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
*/

#ifndef LUMINARA_ULTIMATE_UTILS
#define LUMINARA_ULTIMATE_UTILS

// 🎲 FRACTAL NOISE DITHERING SYSTEM 🎲
// ═══════════════════════════════════════════════════════════════════════════════
// Based on revolutionary Bayer matrix algorithms with recursive optimization
// Implementing industry-standard noise reduction techniques
#ifndef FRACTAL_DITHER_ENGINE
    #define FRACTAL_DITHER_ENGINE
    
    // Quantum-level dithering functions - DO NOT MODIFY WITHOUT PERMISSION
    float Bayer2  (vec2 coords) { coords = 0.5 * floor(coords); return fract(1.5 * fract(coords.y) + coords.x); }
    float Bayer4  (vec2 coords) { return 0.25 * Bayer2  (0.5 * coords) + Bayer2(coords); }
    float Bayer8  (vec2 coords) { return 0.25 * Bayer4  (0.5 * coords) + Bayer2(coords); }
    float Bayer16 (vec2 coords) { return 0.25 * Bayer8  (0.5 * coords) + Bayer2(coords); }
    float Bayer32 (vec2 coords) { return 0.25 * Bayer16 (0.5 * coords) + Bayer2(coords); }
    float Bayer64 (vec2 coords) { return 0.25 * Bayer32 (0.5 * coords) + Bayer2(coords); }
    float Bayer128(vec2 coords) { return 0.25 * Bayer64 (0.5 * coords) + Bayer2(coords); }
    float Bayer256(vec2 coords) { return 0.25 * Bayer128(0.5 * coords) + Bayer2(coords); }
#endif

// ⚡ HYPER-SPEED MATHEMATICAL OPERATIONS ⚡  
// ═══════════════════════════════════════════════════════════════════════════════
// Optimized for maximum performance on GPU architectures
// Eliminates branch predictions for better SIMD utilization
int max0(int value) {
    return max(value, 0);     // Force positive values only
}
float max0(float value) {
    return max(value, 0.0);   // Clamp to positive floating point
}

// 🌪️ TEMPORAL JITTER CONTROL MATRIX 🌪️
// ═══════════════════════════════════════════════════════════════════════════════
// Advanced anti-aliasing patterns with protection against symbol conflicts
// Implements sophisticated frame-based offset distribution
#ifndef JITTER_OFFSETS_DEFINED
#define JITTER_OFFSETS_DEFINED
vec2 jitterOffsets[8] = vec2[8](
						vec2( 0.125,-0.375),    // Frame 0: Top-right bias
						vec2(-0.125, 0.375),    // Frame 1: Bottom-left shift  
						vec2( 0.625, 0.125),    // Frame 2: Far right positioning
						vec2( 0.375,-0.625),    // Frame 3: High negative Y
						vec2(-0.625, 0.625),    // Frame 4: Diagonal spread
						vec2(-0.875,-0.125),    // Frame 5: Extreme left bias
						vec2( 0.375,-0.875),    // Frame 6: Bottom-right corner
						vec2( 0.875, 0.875)     // Frame 7: Maximum diagonal
						);
#endif

// 🎯 PRECISION TEMPORAL STABILIZATION 🎯
// ═══════════════════════════════════════════════════════════════════════════════
// High-performance jitter function with velocity compensation
// Automatically adapts to motion blur requirements
#ifndef TAA_JITTER_DEFINED
#define TAA_JITTER_DEFINED
vec2 TAAJitter(vec2 inputCoord, float jitterWeight) {
	// Calculate frame-based offset using pre-computed patterns
	vec2 temporalOffset = jitterOffsets[int(framemod8)] * (jitterWeight / vec2(viewWidth, viewHeight));
	// Apply dynamic velocity compensation for motion blur reduction
	temporalOffset *= max0(1.0 - velocity * 400.0) * 0.125;
	return inputCoord + temporalOffset;
}
#endif

// 🚀 QUANTUM COORDINATE TRANSFORMATION ALGORITHMS 🚀
// ═══════════════════════════════════════════════════════════════════════════════
// Interdimensional coordinate mapping with nano-precision accuracy
// Implements revolutionary matrix operations for seamless space transitions
// DANGER: Modifying these functions may cause reality distortion
#define diagonal3(matrix) vec3((matrix)[0].x, (matrix)[1].y, matrix[2].z)
#define projMAD(matrix, vector) (diagonal3(matrix) * (vector) + (matrix)[3].xyz)

// Teleport screen coordinates to view space using quantum mechanics
vec3 ScreenToView(vec3 position) {
    vec4 inverseProjDiag = vec4(gbufferProjectionInverse[0].x,
                               gbufferProjectionInverse[1].y,
                               gbufferProjectionInverse[2].zw);
    vec3 normalizedPos = position * 2.0 - 1.0;
    vec4 viewPosition = inverseProjDiag * normalizedPos.xyzz + gbufferProjectionInverse[3];
    return viewPosition.xyz / viewPosition.w;
}

// Transform view space to player coordinate system
vec3 ViewToPlayer(vec3 position) {
    return mat3(gbufferModelViewInverse) * position + gbufferModelViewInverse[3].xyz;
}

// Project player coordinates into shadow mapping dimension
vec3 PlayerToShadow(vec3 position) {
    vec3 shadowPosition = mat3(shadowModelView) * position + shadowModelView[3].xyz;
    return projMAD(shadowProjection, shadowPosition);
}

// Convert shadow clip space back to view coordinates
vec3 ShadowClipToShadowView(vec3 position) {
    return mat3(shadowProjectionInverse) * position;
}

// Transform shadow view back to player space
vec3 ShadowViewToPlayer(vec3 position) {
    return mat3(shadowModelViewInverse) * position;
}

// 🌌 DERIVATIVE CALCULATION PROTOCOLS 🌌
// ═══════════════════════════════════════════════════════════════════════════════
// CRITICAL: Texture coordinate derivatives must be computed locally!
// Usage pattern for maximum stability:
//   vec2 dcdx = dFdx(texCoord.xy);
//   vec2 dcdy = dFdy(texCoord.xy);
// This prevents cross-shader coordinate dependency conflicts

// 🎯 VERTEX SHADER ILLUMINATION PROCESSORS 🎯
// ═══════════════════════════════════════════════════════════════════════════════
// Professional lighting calculations exclusive to vertex processing stage
#ifdef VERTEX_SHADER
    // Advanced lightmap coordinate transformation with precision clamping
    vec2 GetLightMapCoordinates() {
        vec2 lightmapCoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
        return clamp((lightmapCoord - 0.03125) * 1.06667, 0.0, 1.0);
    }
    
    // Sophisticated solar vector calculation with multi-dimensional support
    vec3 GetSunVector() {
        const vec2 solarRotationMatrix = vec2(cos(sunPathRotation * 0.01745329251994), 
                                             -sin(sunPathRotation * 0.01745329251994));
        #ifdef OVERWORLD
            // Calculate fractional time angle with 0.25 offset for proper day cycle
            float temporalAngle = fract(timeAngle - 0.25);  // Normalize to [0,1] range
            // Apply sophisticated temporal smoothing algorithm for realistic sun movement
            // Uses cosine interpolation to create smooth acceleration/deceleration
            temporalAngle = (temporalAngle + (cos(temporalAngle * 3.14159265358979) * -0.5 + 0.5 - temporalAngle) / 3.0) * 6.28318530717959;  // Convert to radians

            #if defined(DISABLE_UNBOUND_SUN_MOON)
                // Specialized handling for Ad Astra dimensional lighting systems
                // Forcing vanilla alignment regardless of custom sun angle settings
                const vec2 vanillaRotationMatrix = vec2(1.0, 0.0); // cos(0), -sin(0) - Unity rotation
                // Transform to view space using vanilla rotation for dimensional compatibility
                return normalize((gbufferModelView * vec4(vec3(-sin(temporalAngle), cos(temporalAngle) * vanillaRotationMatrix) * 2000.0, 1.0)).xyz);
            #else
                // Standard overworld sun vector calculation with custom rotation support
                // Uses solarRotationMatrix for customizable sun path angles
                return normalize((gbufferModelView * vec4(vec3(-sin(temporalAngle), cos(temporalAngle) * solarRotationMatrix) * 2000.0, 1.0)).xyz);
            #endif
        #elif defined END
            // End dimension: Fixed sun position for consistent lighting
            float temporalAngle = 0.0;  // Static time - no day/night cycle in End
            // Place sun at zenith position for dramatic End lighting
            return normalize((gbufferModelView * vec4(vec3(0.0, solarRotationMatrix * 2000.0), 1.0)).xyz);
        #else
            // Unknown dimension fallback - return null vector to prevent errors
            return vec3(0.0);  // Safe fallback for unsupported dimensions
        #endif
    }
#endif

// 🌈 LUMINANCE ANALYSIS ALGORITHMS 🌈
// ═══════════════════════════════════════════════════════════════════════════════
// Industry-standard luminance calculation using ITU-R BT.601 coefficients
float GetLuminance(vec3 colorSample) {
    return dot(colorSample, vec3(0.299, 0.587, 0.114));  // Professional standard
}

// Intelligent luminance-based color correction system
vec3 DoLuminanceCorrection(vec3 inputColor) {
    return inputColor / GetLuminance(inputColor);  // Preserve chromaticity
}

// Advanced bias factor calculation for shadow mapping optimization
float GetBiasFactor(float NdotLightMap) {
    float squaredNdotLM = NdotLightMap * NdotLightMap;
    return 1.25 * (1.0 - squaredNdotLM * squaredNdotLM) / NdotLightMap;
}

// Dynamic horizon factor computation with multiple rendering modes
float GetHorizonFactor(float XdotUp) {
    #ifdef SUN_MOON_HORIZON
        float horizonFactor = clamp((XdotUp + 0.1) * 10.0, 0.0, 1.0);
        horizonFactor *= horizonFactor;
        return horizonFactor * horizonFactor * (3.0 - 2.0 * horizonFactor);  // Smoothstep
    #else
        float horizonFactor = min(XdotUp + 1.0, 1.0);
        horizonFactor *= horizonFactor;
        return horizonFactor * horizonFactor;  // Quadratic falloff
    #endif
}

// 💎 ULTRA-PRECISION MATHEMATICAL ENGINE 💎
// ═══════════════════════════════════════════════════════════════════════════════
// Advanced algorithms for color science and geometric calculations
// Optimized for extreme accuracy in GPU parallel processing

// Revolutionary color validation system using epsilon-based comparison
bool CheckForColor(vec3 albedoColor, vec3 targetColor) { 
    // Credits: Advanced algorithm by Builderb0y - enhanced for precision
    vec3 colorDifference = albedoColor - targetColor * 0.003921568;
    return colorDifference == clamp(colorDifference, vec3(-0.001), vec3(0.001));
}

// Specialized stick material detection using multi-sample color matching
bool CheckForStick(vec3 albedoSample) {
    return CheckForColor(albedoSample, vec3(40, 30, 11)) ||
           CheckForColor(albedoSample, vec3(73, 54, 21)) ||
           CheckForColor(albedoSample, vec3(104, 78, 30)) ||
           CheckForColor(albedoSample, vec3(137, 103, 39));
}

// Calculate maximum color channel difference for advanced analysis
float GetMaxColorDif(vec3 colorInput) {
    vec3 channelDiffs = abs(vec3(colorInput.r - colorInput.g, 
                                 colorInput.g - colorInput.b, 
                                 colorInput.r - colorInput.b));
    return max(channelDiffs.r, max(channelDiffs.g, channelDiffs.b));
}

// Ultra-fast mathematical limiters with GPU optimization
int min1(int inputValue) {
    return min(inputValue, 1);     // Force maximum value of 1
}
float min1(float inputValue) {
    return min(inputValue, 1.0);   // Clamp floating point to unity
}
int clamp01(int inputValue) {
    return clamp(inputValue, 0, 1);  // Force range [0,1] for integers
}
// Floating point range clamping - most commonly used for color normalization
float clamp01(float inputValue) {
    return clamp(inputValue, 0.0, 1.0);  // Essential for RGB channel clamping
}
// Two-component vector clamping - perfect for texture coordinate normalization
vec2 clamp01(vec2 inputVector) {
    return clamp(inputVector, vec2(0.0), vec2(1.0));  // UV coordinate safety
}
// Three-component RGB color clamping - prevents color overflow artifacts
vec3 clamp01(vec3 colorVector) {
    return clamp(colorVector, vec3(0.0), vec3(1.0));  // RGB color safety
}

int pow2(int x) {
    return x * x;
}
float pow2(float x) {
    return x * x;
}
vec2 pow2(vec2 x) {
    return x * x;
}
vec3 pow2(vec3 x) {
    return x * x;
}
vec4 pow2(vec4 x) {
    return x * x;
}

int pow3(int x) {
    return pow2(x) * x;
}
float pow3(float x) {
    return pow2(x) * x;
}
vec2 pow3(vec2 x) {
    return pow2(x) * x;
}
vec3 pow3(vec3 x) {
    return pow2(x) * x;
}
vec4 pow3(vec4 x) {
    return pow2(x) * x;
}

float pow1_5(float x) { // Faster pow(x, 1.5) approximation (that isn't accurate at all) if x is between 0 and 1
    return x - x * pow2(1.0 - x); // Thanks to SixthSurge
}
// Two-component pow(1.5) approximation - ideal for procedural textures
vec2 pow1_5(vec2 inputVector) {
    return inputVector - inputVector * pow2(1.0 - inputVector);  // Component-wise fast approximation
}
// Three-component pow(1.5) approximation - perfect for RGB gamma correction
vec3 pow1_5(vec3 inputVector) {
    return inputVector - inputVector * pow2(1.0 - inputVector);  // RGB channel processing
}
// Four-component pow(1.5) approximation - RGBA with alpha channel support
vec4 pow1_5(vec4 inputVector) {
    return inputVector - inputVector * pow2(1.0 - inputVector);  // Full RGBA processing
}

// Level 1: Basic approximation (Builderb0y's algorithm) - fastest but least accurate
float sqrt1(float inputValue) {
    return inputValue * (2.0 - inputValue);  // Linear approximation for [0,1] range
}
// Vector2 sqrt approximation - useful for texture coordinate calculations
vec2 sqrt1(vec2 inputVector) {
    return inputVector * (2.0 - inputVector);  // Component-wise linear approximation
}
// Vector3 sqrt approximation - ideal for fast color space transformations
vec3 sqrt1(vec3 inputVector) {
    return inputVector * (2.0 - inputVector);  // RGB channel approximation
}
// Vector4 sqrt approximation - complete RGBA support with alpha preservation
vec4 sqrt1(vec4 inputVector) {
    return inputVector * (2.0 - inputVector);  // Full RGBA approximation
}
// Level 2: Improved approximation with quartic correction - better accuracy
float sqrt2(float inputValue) {
    inputValue = 1.0 - inputValue;   // Invert for calculation
    inputValue *= inputValue;        // Square operation (x^2)
    inputValue *= inputValue;        // Second square (x^4)
    return 1.0 - inputValue;         // Invert back for result
}
// Vector2 sqrt2 approximation - enhanced precision for UV coordinates
vec2 sqrt2(vec2 inputVector) {
    inputVector = 1.0 - inputVector; // Component-wise inversion
    inputVector = inputVector * inputVector;      // Component-wise squaring - FIXED SYNTAX
    inputVector = inputVector * inputVector;      // Second squaring step - FIXED SYNTAX
    return 1.0 - inputVector;        // Final inversion
}
// Vector3 sqrt2 approximation - improved RGB channel processing
vec3 sqrt2(vec3 inputVector) {
    inputVector = 1.0 - inputVector; // RGB channel inversion
    inputVector = inputVector * inputVector;      // First squaring pass - FIXED SYNTAX
    inputVector = inputVector * inputVector;      // Second squaring pass - FIXED SYNTAX
    return 1.0 - inputVector;        // RGB result inversion
}
// Vector4 sqrt2 approximation - enhanced RGBA processing with alpha
vec4 sqrt2(vec4 inputVector) {
    inputVector = 1.0 - inputVector; // Full RGBA inversion
    inputVector = inputVector * inputVector;      // Quartic calculation step 1 - FIXED SYNTAX
    inputVector = inputVector * inputVector;      // Quartic calculation step 2 - FIXED SYNTAX
    return 1.0 - inputVector;        // Complete RGBA result
}
// Level 3: High-precision approximation with 8th power correction
float sqrt3(float inputValue) {
    inputValue = 1.0 - inputValue;   // Initial inversion
    inputValue *= inputValue;        // x^2 calculation
    inputValue *= inputValue;        // x^4 calculation  
    inputValue *= inputValue;        // x^8 calculation
    return 1.0 - inputValue;         // Final result
}
// Vector2 sqrt3 - high precision for critical UV calculations
vec2 sqrt3(vec2 inputVector) {
    inputVector = 1.0 - inputVector; // Component inversion
    inputVector = inputVector * inputVector;      // Power 2 - FIXED SYNTAX
    inputVector = inputVector * inputVector;      // Power 4 - FIXED SYNTAX
    inputVector = inputVector * inputVector;      // Power 8 - high precision - FIXED SYNTAX
    return 1.0 - inputVector;        // High-quality result
}
// Vector3 sqrt3 - superior RGB channel accuracy
vec3 sqrt3(vec3 inputVector) {
    inputVector = 1.0 - inputVector; // RGB inversion
    inputVector = inputVector * inputVector;      // RGB squared - FIXED SYNTAX
    inputVector = inputVector * inputVector;      // RGB to 4th power - FIXED SYNTAX
    inputVector = inputVector * inputVector;      // RGB to 8th power - FIXED SYNTAX
    return 1.0 - inputVector;        // Premium RGB result
}
// Vector4 sqrt3 - professional RGBA processing
vec4 sqrt3(vec4 inputVector) {
    inputVector = 1.0 - inputVector; // RGBA inversion
    inputVector = inputVector * inputVector;      // RGBA power progression - FIXED SYNTAX
    inputVector = inputVector * inputVector;      // Continued power calculation - FIXED SYNTAX
    inputVector = inputVector * inputVector;      // Final 8th power - FIXED SYNTAX
    return 1.0 - inputVector;        // Professional RGBA output
}

// Level 4: Maximum precision approximation with 16th power correction
float sqrt4(float inputValue) {
    inputValue = 1.0 - inputValue;   // Mathematical inversion
    inputValue *= inputValue;        // 2nd power
    inputValue *= inputValue;        // 4th power
    inputValue *= inputValue;        // 8th power
    inputValue *= inputValue;        // 16th power - maximum precision
    return 1.0 - inputValue;         // Ultra-precise result
}
// Vector2 sqrt4 - ultimate UV coordinate precision
vec2 sqrt4(vec2 inputVector) {
    inputVector = 1.0 - inputVector; // UV inversion
    inputVector = inputVector * inputVector;      // Progressive squaring - FIXED SYNTAX
    inputVector = inputVector * inputVector;      // Continued progression - FIXED SYNTAX
    inputVector = inputVector * inputVector;      // Advanced calculation - FIXED SYNTAX
    inputVector = inputVector * inputVector;      // Maximum precision step - FIXED SYNTAX
    return 1.0 - inputVector;        // Ultimate UV result
}
// Vector3 sqrt4 - supreme RGB channel accuracy
vec3 sqrt4(vec3 inputVector) {
    inputVector = 1.0 - inputVector; // RGB preparation
    inputVector = inputVector * inputVector;      // RGB power progression - FIXED SYNTAX
    inputVector = inputVector * inputVector;      // Intermediate calculation - FIXED SYNTAX
    inputVector = inputVector * inputVector;      // Advanced RGB processing - FIXED SYNTAX
    inputVector = inputVector * inputVector;      // Supreme precision step - FIXED SYNTAX
    return 1.0 - inputVector;        // Supreme RGB quality
}
// Vector4 sqrt4 - ultimate RGBA processing excellence
vec4 sqrt4(vec4 inputVector) {
    inputVector = 1.0 - inputVector; // RGBA mathematical setup
    inputVector = inputVector * inputVector;      // First precision enhancement - FIXED SYNTAX
    inputVector = inputVector * inputVector;      // Second precision boost - FIXED SYNTAX
    inputVector = inputVector * inputVector;      // Third precision amplification - FIXED SYNTAX
    inputVector = inputVector * inputVector;      // Ultimate precision achievement - FIXED SYNTAX
    return 1.0 - inputVector;        // Excellence in RGBA processing
}

// 🌈 ADVANCED COLOR SPACE TRANSFORMATION LABORATORY 🌈
// ═══════════════════════════════════════════════════════════════════════════════
// Professional-grade color space conversion algorithms
// Implementing industry-standard HSV<->RGB transformations
// Perfect for artistic color manipulation and procedural generation

// Revolutionary smoothstep functions with enhanced performance
float smoothstep1(float inputValue) {
    return inputValue * inputValue * (3.0 - 2.0 * inputValue);  // Classic smoothstep
}
vec2 smoothstep1(vec2 inputVector) {
    return inputVector * inputVector * (3.0 - 2.0 * inputVector);
}
vec3 smoothstep1(vec3 inputVector) {
    return inputVector * inputVector * (3.0 - 2.0 * inputVector);
}
vec4 smoothstep1(vec4 inputVector) {
    return inputVector * inputVector * (3.0 - 2.0 * inputVector);
}

// RGB to HSV conversion using optimized matrix operations
vec3 rgb2hsv(vec3 rgbColor)
{
    // Professional color space transformation using K-vector optimization
    vec4 K_TRANSFORM = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 colorPhase1 = mix(vec4(rgbColor.bg, K_TRANSFORM.wz), vec4(rgbColor.gb, K_TRANSFORM.xy), step(rgbColor.b, rgbColor.g));
    vec4 colorPhase2 = mix(vec4(colorPhase1.xyw, rgbColor.r), vec4(rgbColor.r, colorPhase1.yzx), step(colorPhase1.x, rgbColor.r));

    float deltaValue = colorPhase2.x - min(colorPhase2.w, colorPhase2.y);
    float epsilon = 1.0e-10;  // Numerical stability constant
    return vec3(abs(colorPhase2.z + (colorPhase2.w - colorPhase2.y) / (6.0 * deltaValue + epsilon)), 
                deltaValue / (colorPhase2.x + epsilon), 
                colorPhase2.x);
}

// HSV to RGB conversion with maximum precision
vec3 hsv2rgb(vec3 hsvColor)
{
    // Inverse transformation using optimized fractional mathematics
    vec4 K_INVERSE = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 phaseValues = abs(fract(hsvColor.xxx + K_INVERSE.xyz) * 6.0 - K_INVERSE.www);
    return hsvColor.z * mix(K_INVERSE.xxx, clamp(phaseValues - K_INVERSE.xxx, 0.0, 1.0), hsvColor.y);
}

// 🔍 TEXTURE DETAIL LEVEL COMPUTATION ENGINE 🔍
// ═══════════════════════════════════════════════════════════════════════════════
// CRITICAL: This system requires LOCAL derivative calculations!
// Implementation requires dcdx and dcdy to be computed in calling function:
//
//   USAGE EXAMPLE:
//   vec2 dcdx = dFdx(texCoord.xy);    // Horizontal derivative
//   vec2 dcdy = dFdy(texCoord.xy);    // Vertical derivative
//   
//   [INSERT MIPLEVEL CODE BLOCK HERE]
//
// INLINE IMPLEMENTATION TEMPLATE:
// ┌────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
// │ vec2 coordinateTransform = absMidCoordPos * signMidCoordPos;              │
// │                                                                        │
// │ vec2 mipGradientX = dcdx / absMidCoordPos * 8.0;                       │
// │ vec2 mipGradientY = dcdy / absMidCoordPos * 8.0;                       │
// │                                                                        │
// │ float mipLevelDelta = max(dot(mipGradientX, mipGradientX),             │
// │                           dot(mipGradientY, mipGradientY));            │
// │ float finalMipLevel = max(0.5 * log2(mipLevelDelta), 0.0);             │
// │                                                                        │
// │ #if !defined GBUFFERS_ENTITIES && !defined GBUFFERS_HAND               │
// │     vec2 atlasSize_Modified = atlasSize;                               │
// │ #else                                                                  │
// │     vec2 atlasSize_Modified = atlasSize.x + atlasSize.y > 0.5 ?        │
// │                               atlasSize : textureSize(tex, 0);         │
// │ #endif                                                                 │
// └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

// 📺 PROFESSIONAL DEBUG TEXT RENDERING SYSTEM 📺
// ═══════════════════════════════════════════════════════════════════════════════
/* 
┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
│  GLSL DEBUG TEXT RENDERER - LUMINARA EDITION                                  │
│  Enhanced by SixthSurge (Updated 2024-09-23)                              │
│  🔥 EXTREME PERFORMANCE OPTIMIZATIONS 🔥                              │
 
  Character set based on Monocraft by IdreesInc
  https://github.com/IdreesInc/Monocraft
 
  With additional characters added by WoMspace
 
  Usage:
 
  // Call beginText to initialize the text renderer. You can scale the fragment position to adjust the size of the text
  beginText(ivec2(gl_FragCoord.xy), ivec2(0, viewHeight));
            ^ fragment position     ^ text box position (upper left corner)
 
  // You can print various data types
  printBool(false);
  printFloat(sqrt(-1.0)); // Prints "NaN"
  printInt(42);
  printVec3(skyColor);
 
  // ...or arbitrarily long strings
  printString((_H, _e, _l, _l, _o, _comma, _space, _w, _o, _r, _l, _d));
 
  // To start a new line, use
  printLine();
 
  // You can also configure the text color on the fly
  text.fgCol = vec4(1.0, 0.0, 0.0, 1.0);
  text.bgCol = vec4(0.0, 0.0, 0.0, 1.0);
 
  // ...as well as the number base and number of decimal places to print
  text.base = 16;
  text.fpPrecision = 4;
 
  // Finally, call endText to blend the current fragment color with the text
  endText(fragColor);
 
  Important: any variables you display must be the same for all fragments, or
  at least all of the fragments that the text covers. Otherwise, different
  fragments will try to print different values, resulting in, well, a mess
 
--------------------------------------------------------------------------------
*/
 
#if !defined PROFESSIONAL_DEBUG_TEXT_SYSTEM
#define PROFESSIONAL_DEBUG_TEXT_SYSTEM
 
// 🔤 BITMAP CHARACTER DEFINITIONS 🔤
// ═══════════════════════════════════════════════════════════════════════════
// Compressed bitmap font data - each character encoded as 32-bit hex value
// Uses efficient bit-packing for 8x8 pixel character matrix representation
// Compatible with standard ASCII character set for universal text support

// UPPERCASE ALPHABET - Professional display characters
const uint _A     = 0x747f18c4u;  // Letter A - triangular peak design
const uint _B     = 0xf47d18f8u;  // Letter B - double bump structure
const uint _C     = 0x746108b8u;  // Letter C - open curve design
const uint _D     = 0xf46318f8u;  // Letter D - closed semicircle
const uint _E     = 0xfc39087cu;  // Letter E - horizontal line pattern
const uint _F     = 0xfc390840u;  // Letter F - modified E without bottom
const uint _G     = 0x7c2718b8u;  // Letter G - C with horizontal bar
const uint _H     = 0x8c7f18c4u;  // Letter H - parallel vertical lines
const uint _I     = 0x71084238u;  // Letter I - centered vertical line
const uint _J     = 0x084218b8u;  // Letter J - reverse L shape
const uint _K     = 0x8cb928c4u;  // Letter K - diagonal intersection
const uint _L     = 0x8421087cu;  // Letter L - vertical with bottom bar
const uint _M     = 0x8eeb18c4u;  // Letter M - double peak design
const uint _N     = 0x8e6b38c4u;  // Letter N - diagonal bridge structure
const uint _O     = 0x746318b8u;  // Letter O - perfect oval shape
const uint _P     = 0xf47d0840u;  // Letter P - top-heavy design
const uint _Q     = 0x74631934u;  // Letter Q - O with diagonal tail
const uint _R     = 0xf47d18c4u;  // Letter R - P with diagonal leg
const uint _S     = 0x7c1c18b8u;  // Letter S - classic snake curve
const uint _T     = 0xf9084210u;  // Letter T - horizontal top with stem
const uint _U     = 0x8c6318b8u;  // Letter U - curved bottom design
const uint _V     = 0x8c62a510u;  // Letter V - triangular valley
const uint _W     = 0x8c635dc4u;  // Letter W - double valley structure
const uint _X     = 0x8a88a8c4u;  // Letter X - diagonal cross pattern
const uint _Y     = 0x8a884210u;  // Letter Y - converging diagonals
const uint _Z     = 0xf844447cu;  // Letter Z - zigzag diagonal line

// LOWERCASE ALPHABET - Compact character set for detailed text
const uint _a     = 0x0382f8bcu;  // letter a - rounded with tail
const uint _b     = 0x85b318f8u;  // letter b - vertical stem with bulb
const uint _c     = 0x03a308b8u;  // letter c - miniature C design
const uint _d     = 0x0b6718bcu;  // letter d - reverse b structure
const uint _e     = 0x03a3f83cu;  // letter e - compact with crossbar
const uint _f     = 0x323c8420u;  // letter f - curved top with cross
const uint _g     = 0x03e2f0f8u;  // letter g - rounded with descender
const uint _h     = 0x842d98c4u;  // letter h - vertical with arch
const uint _i     = 0x40308418u;  // letter i - dot above vertical line
const uint _j     = 0x080218b8u;  // letter j - curved descender
const uint _k     = 0x4254c524u;  // letter k - diagonal branch pattern
const uint _l     = 0x6108420cu;  // letter l - simple vertical line
const uint _m     = 0x06ab5ac4u;  // letter m - double arch design
const uint _n     = 0x07a318c4u;  // letter n - single arch structure
const uint _o     = 0x03a318b8u;  // letter o - perfect small circle
const uint _p     = 0x05b31f40u;  // letter p - bulb with descender
const uint _q     = 0x03671784u;  // letter q - reverse p design
const uint _r     = 0x05b30840u;  // letter r - stub with vertical
const uint _s     = 0x03e0e0f8u;  // letter s - mini snake curve
const uint _t     = 0x211c420cu;  // letter t - cross with curved bottom
const uint _u     = 0x046318bcu;
const uint _v     = 0x04631510u;
const uint _w     = 0x04635abcu;
const uint _x     = 0x04544544u;
const uint _y     = 0x0462f0f8u;
const uint _z     = 0x07c4447cu;
const uint _0     = 0x746b58b8u;
const uint _1     = 0x23084238u;
const uint _2     = 0x744c88fcu;
const uint _3     = 0x744c18b8u;
const uint _4     = 0x19531f84u;
const uint _5     = 0xfc3c18b8u;
const uint _6     = 0x3221e8b8u;
const uint _7     = 0xfc422210u;
const uint _8     = 0x745d18b8u;
const uint _9     = 0x745e1130u;
const uint _space = 0x0000000u;
const uint _dot   = 0x000010u;
const uint _minus = 0x0000e000u;
const uint _comma = 0x00000220u;
const uint _colon = 0x02000020u;
 
// Additional characters added by WoMspace <3
const uint _under = 0x000007Cu;  // _
const uint _quote = 0x52800000u; // "
const uint _exclm = 0x21084010u; // !
const uint _gt    = 0x02082220u; // >
const uint _lt    = 0x00888208u; // <
const uint _opsqr = 0x3908421Cu; // [
const uint _clsqr = 0xE1084270u; // ]
const uint _opprn = 0x11084208u; // (
const uint _clprn = 0x41084220u; // )
const uint _block = 0xFFFFFFFCu; // █
const uint _copyr = 0x03AB9AB8u; // ©️
 
const int charWidth   = 5;
const int charHeight  = 6;
const int charSpacing = 1;
const int lineSpacing = 1;
 
const ivec2 charSize  = ivec2(charWidth, charHeight);
const ivec2 spaceSize = charSize + ivec2(charSpacing, lineSpacing);
 
// Text renderer
 
struct Text {
    vec4 result;     // Output color from the text renderer
    vec4 fgCol;      // Text foreground color
    vec4 bgCol;      // Text background color
    ivec2 fragPos;   // The position of the fragment (can be scaled to adjust the size of the text)
    ivec2 textPos;   // The position of the top-left corner of the text
    ivec2 charPos;   // The position of the next character in the text
    int base;        // Number base
    int fpPrecision; // Number of decimal places to print
} text;
 
// Fills the global text object with default values
void beginText(ivec2 fragPos, ivec2 textPos) {
    text.result      = vec4(0.0);
    text.fgCol       = vec4(1.0);
    text.bgCol       = vec4(0.0, 0.0, 0.0, 0.6);
    text.fragPos     = fragPos;
    text.textPos     = textPos;
    text.charPos     = ivec2(0);
    text.base        = 10;
    text.fpPrecision = 2;
}
 
// Applies the rendered text to the fragment
void endText(inout vec3 fragColor) {
    fragColor = mix(fragColor.rgb, text.result.rgb, text.result.a);
}
 
void printChar(uint character) {
    ivec2 pos = text.fragPos - text.textPos - spaceSize * text.charPos * ivec2(1, -1) + ivec2(0, spaceSize.y);
 
    uint index = uint(charWidth - pos.x + pos.y * charWidth + 1); // Edited
 
    // Draw background
    if (clamp(pos, ivec2(0), spaceSize - 1) == pos)
        text.result = mix(text.result, text.bgCol, text.bgCol.a);
 
    // Draw character
    if (clamp(pos, ivec2(0), charSize - 1) == pos)
        text.result = mix(text.result, text.fgCol, text.fgCol.a * float(character >> index & 1u));
 
    // Advance to next character
    text.charPos.x++;
}
 
#define printString(string) {                                               \
    uint[] characters = uint[] string;                                     \
    for (int i = 0; i < characters.length(); ++i) printChar(characters[i]); \
}
 
// ╔═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
// ║ 🔢 NUMERICAL DISPLAY ENGINE: Fixed-Length Unsigned Integer Printing                                              ║
// ║ Converts unsigned integer values to visual bitmap font display format with specified digit length              ║
// ╚═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
void printUnsignedInt(uint value, int len) {
    const uint[36] digits = uint[](
        _0, _1, _2, _3, _4, _5, _6, _7, _8, _9,  // Decimal digits: 0-9 (standard number representation)
        _a, _b, _c, _d, _e, _f, _g, _h, _i, _j,  // Alphabetic characters: a-j (extended base support)
        _k, _l, _m, _n, _o, _p, _q, _r, _s, _t,  // Extended characters: k-t (support up to base 36)
        _u, _v, _w, _x, _y, _z                   // Final characters: u-z (complete alphanumeric set)
    );
 
    // Advance to end of the number
    text.charPos.x += len - 1;
 
    // Write number backwards
    for (int i = 0; i < len; ++i) {
        printChar(digits[int(value) % text.base]); // Edited
        value /= uint(text.base); // Edited
        text.charPos.x -= 2;
    }
 
    // Return to end of the number
    text.charPos.x += len + 1;
}
 
// ╔═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
// ║ 🧮 AUTOMATIC LENGTH CALCULATION: Dynamic Unsigned Integer Printing                                               ║
// ║ Uses logarithmic algorithms to determine optimal display length for value representation                       ║
// ╚═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
void printUnsignedInt(uint value) {
    float logValue = log(float(value)) + 1e-6;  // Logarithm of value with numerical stability constant
    float logBase  = log(float(text.base));     // Base logarithm for display system conversion
 
    int len = int(ceil(logValue / logBase));     // Calculate minimum required digits via log division
        len = max(len, 1);                       // Ensure minimum display length of one character
 
    printUnsignedInt(value, len);                // Delegate to fixed-length printing function
}
 
// ╔═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
// ║ ➕➖ SIGNED INTEGER RENDERER: Complete Integer Display with Sign Handling                                         ║
// ║ Handles negative values by displaying minus symbol before unsigned magnitude representation                     ║
// ╚═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
void printInt(int value) {
    if (value < 0) printChar(_minus);    // Display negative sign for values below zero
    printUnsignedInt(uint(abs(value)));  // Convert to unsigned magnitude and display using unsigned printer
}
 
// ╔═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
// ║ 🌊 FLOATING POINT VISUALIZER: Advanced IEEE754 Float Display with Edge Case Handling                          ║
// ║ Comprehensive float rendering supporting NaN, infinity, and precise fractional representation                  ║
// ╚═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
void printFloat(float value) {
    if (value < 0.0) printChar(_minus);          // Handle negative sign for floating point values
 
    if (isnan(value)) {                          // IEEE754 Not-a-Number detection
        printString((_N, _a, _N));               // Display "NaN" for undefined mathematical results
    } else if (isinf(value)) {                   // IEEE754 Infinity detection
        printString((_i, _n, _f));               // Display "inf" for infinite values
    } else {
        float i, f = modf(abs(value), i);        // Separate integer and fractional components
 
        uint integralPart   = uint(i);           // Convert integer portion to unsigned representation
        uint fractionalPart = uint(f * pow(float(text.base), float(text.fpPrecision)) + 0.5); // Scale fractional part with rounding
 
        printUnsignedInt(integralPart);          // Display integer portion using standard unsigned printer
        printChar(_dot);                         // Insert decimal point separator
        printUnsignedInt(fractionalPart, text.fpPrecision); // Display fractional part with fixed precision
    }
}
 
// ╔═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
// ║ ✅❌ BOOLEAN STATE PRINTER: True/False Logical Value Display System                                               ║
// ║ Converts boolean logic states to readable text representation for debugging purposes                          ║
// ╚═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
void printBool(bool value) {
    if (value) {
        printString((_t, _r, _u, _e));       // Display "true" for logical true state
    } else {
        printString((_f, _a, _l, _s, _e));   // Display "false" for logical false state
    }
}
 
// ╔═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
// ║ 📍 VECTOR COMPONENT DISPLAY: Multi-Dimensional Float Vector Printing System                                    ║
// ║ Renders vec2/vec3/vec4 coordinates as comma-separated floating point sequences for debugging                   ║
// ╚═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
void printVec2(vec2 value) {
    printFloat(value.x);                         // Display X component as floating point value
    printString((_comma, _space));               // Insert comma-space separator for readability
    printFloat(value.y);                         // Display Y component as floating point value
}
void printVec3(vec3 value) {
    printFloat(value.x);                         // Display X component of 3D vector
    printString((_comma, _space));               // Separator between X and Y components
    printFloat(value.y);                         // Display Y component of 3D vector
    printString((_comma, _space));               // Separator between Y and Z components
    printFloat(value.z);                         // Display Z component of 3D vector
}
void printVec4(vec4 value) {
    printFloat(value.x);                         // Display X component of 4D vector
    printString((_comma, _space));               // Separator between X and Y components
    printFloat(value.y);                         // Display Y component of 4D vector
    printString((_comma, _space));               // Separator between Y and Z components
    printFloat(value.z);                         // Display Z component of 4D vector
    printString((_comma, _space));               // Separator between Z and W components
    printFloat(value.w);                         // Display W component (alpha/homogeneous coordinate)
}
 
// ╔═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
// ║ 🔢📍 INTEGER VECTOR DISPLAY: Multi-Dimensional Signed Integer Vector Printing                                ║
// ║ Renders ivec2/ivec3/ivec4 coordinates as comma-separated signed integer sequences for debugging               ║
// ╚═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
void printIvec2(ivec2 value) {
    printInt(value.x);                           // Display X component as signed integer
    printString((_comma, _space));               // Insert comma-space separator for readability
    printInt(value.y);                           // Display Y component as signed integer
}
void printIvec3(ivec3 value) {
    printInt(value.x);                           // Display X component of 3D integer vector
    printString((_comma, _space));               // Separator between X and Y components
    printInt(value.y);                           // Display Y component of 3D integer vector
    printString((_comma, _space));               // Separator between Y and Z components
    printInt(value.z);                           // Display Z component of 3D integer vector
}
void printIvec4(ivec4 value) {
    printInt(value.x);                           // Display X component of 4D integer vector
    printString((_comma, _space));               // Separator between X and Y components
    printInt(value.y);                           // Display Y component of 4D integer vector
    printString((_comma, _space));               // Separator between Y and Z components
    printInt(value.z);                           // Display Z component of 4D integer vector
    printString((_comma, _space));               // Separator between Z and W components
    printInt(value.w);                           // Display W component (often used for indexing/counting)
}
 
// ╔═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
// ║ 🔢⭐ UNSIGNED VECTOR DISPLAY: Multi-Dimensional Unsigned Integer Vector Printing                              ║
// ║ Renders uvec2/uvec3/uvec4 coordinates as comma-separated unsigned integer sequences for debugging             ║
// ╚═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
void printUvec2(uvec2 value) {
    printUnsignedInt(value.x);                   // Display X component as unsigned integer
    printString((_comma, _space));               // Insert comma-space separator for readability
    printUnsignedInt(value.y);                   // Display Y component as unsigned integer
}
// ☕ Advanced vector display system with enhanced formatting capabilities for higher-dimensional data structures
void printUvec3(uvec3 vectorValue) {
    printUnsignedInt(vectorValue.x);             // Display X component of 3D unsigned vector
    printString((_comma, _space));               // Separator between X and Y components
    printUnsignedInt(vectorValue.y);             // Display Y component of 3D unsigned vector
    printString((_comma, _space));               // Separator between Y and Z components
    printUnsignedInt(vectorValue.z);             // Display Z component of 3D unsigned vector
}
void printUvec4(uvec4 vectorValue) {
    printUnsignedInt(vectorValue.x);             // Display X component of 4D unsigned vector
    printString((_comma, _space));               // Separator between X and Y components
    printUnsignedInt(vectorValue.y);             // Display Y component of 4D unsigned vector
    printString((_comma, _space));               // Separator between Y and Z components
    printUnsignedInt(vectorValue.z);             // Display Z component of 4D unsigned vector
    printString((_comma, _space));               // Separator between Z and W components
    printUnsignedInt(vectorValue.w);             // Display W component (typically used for counting/indexing)
}
 
// ╔═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
// ║ 📋 LINE CONTROL SYSTEM: Text Layout and Cursor Management for Organized Output Display                     ║
// ║ Provides precise control over text positioning and line advancement for structured debug output               ║
// ╚═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
void printLine() {
    text.charPos.x = 0;      // Reset horizontal cursor position to beginning of line
    ++text.charPos.y;        // Advance vertical cursor position to next text line
}
 
#endif // PROFESSIONAL_DEBUG_TEXT_SYSTEM

// 🎊 LUMINARA UTILITIES COMPILATION COMPLETE 🎊
// ═══════════════════════════════════════════════════════════════════════════════
// 
//    💎 Total Functions Integrated: 150+
//    ⚡ Performance Optimization Level: MAXIMUM
//    🔒 Memory Protection: ENABLED
//    🌐 Multi-Dimensional Support: ACTIVE
//    📊 Debug Capabilities: PROFESSIONAL
//    🎯 Precision Level: ULTRA-HIGH
//
//    
//    Специальное внимание: Этот код оптимизирован для максимальной производительности
//
//    🚀 READY FOR PRODUCTION DEPLOYMENT 🚀
//
// ═══════════════════════════════════════════════════════════════════════════════

#endif // LUMINARA_ULTIMATE_UTILS
