/*
═══════════════════════════════════════════════════════════════════════════════
    🌟 luminara_programs | distant_terrain - نظام رندرينغ التضاريس البعيدة | EminGT 🌟
═══════════════════════════════════════════════════════════════════════════════

    Advanced Distant Terrain Rendering & Level-of-Detail System
    نظام رندرينغ التضاريس البعيدة ومستوى التفاصيل المتقدم

    ⚡ الميزات الأساسية / Core Features:
    ----------------------------------------
    • نظام رندرينغ التضاريس البعيدة المتقدم / Advanced Distant Terrain Rendering
    • تقنيات تحسين مستوى التفاصيل / Level-of-Detail Optimization Techniques
    • نظام الضوضاء ثلاثي الأبعاد المحسن / Enhanced 3D Noise System
    • معالجة مواد متخصصة للمسافات البعيدة / Specialized Material Processing for Distance
    • تكامل مع نظام Distant Horizons / Distant Horizons Integration
    • تحسينات الأداء للرندرينغ البعيد / Performance Optimizations for Distant Rendering

    🎯 الأنظمة الفرعية / Subsystems:
    --------------------------------
    [رندرينغ التضاريس البعيدة] - Distant Terrain Rendering with DH Integration
    [نظام الضوضاء المتقدم] - Advanced 3D Noise Generation System
    [معالجة المواد المتخصصة] - Specialized Material Processing (Leaves, Grass, etc.)
    [تحسين الأداء] - Distance-based Performance Culling
    [تكامل الإضاءة] - Advanced Lighting Integration for Distance

    📈 التحسينات المتقدمة / Advanced Optimizations:
    ----------------------------------------------
    ★ DH Matrix Aliasing: تسمية مصفوفات Distant Horizons
    ★ TAA Integration: تكامل التنعيم الزمني
    ★ Distance Culling: إخفاء بناءً على المسافة
    ★ 3D Noise Enhancement: تحسين الضوضاء ثلاثية الأبعاد
    ★ Material Specialization: تخصص المواد للمسافات البعيدة


═══════════════════════════════════════════════════════════════════════════════
*/

/////////////////////////////////////
// Luminara Shader - Enhanced by EminGT //
/////////////////////////////////////

// ═══════════════════════════════════════════════════════════════════════════════
// Core Library Includes | مكتبات النظام الأساسية
// ═══════════════════════════════════════════════════════════════════════════════
#include "/lib/shader_modules/shader_master.glsl"

// ═══════════════════════════════════════════════════════════════════════════════
// Fragment Shader Implementation | تطبيق Fragment Shader
// ═══════════════════════════════════════════════════════════════════════════════
#ifdef FRAGMENT_SHADER

flat in int mat;

in vec2 lmCoord;

flat in vec3 upVec, sunVec, northVec, eastVec;
in vec3 normal;
in vec3 playerPos;

in vec4 glColor;

// ─────────────────────────────────────────────────────────────────────────────
// Enhanced Atmospheric Calculations | حسابات الغلاف الجوي المحسنة
// ─────────────────────────────────────────────────────────────────────────────
float NdotU = dot(normal, upVec);
float NdotUmax0 = max(NdotU, 0.0);
float SdotU = dot(sunVec, upVec);

// نظام عوامل الشمس المتقدم / Advanced Sun Factor System
float sunFactor = SdotU < 0.0 ? 
    clamp(SdotU + 0.375, 0.0, 0.75) / 0.75 : 
    clamp(SdotU + 0.03125, 0.0, 0.0625) / 0.0625;

float sunVisibility = clamp(SdotU + 0.0625, 0.0, 0.125) / 0.125;
float sunVisibility2 = sunVisibility * sunVisibility;
float shadowTimeVar1 = abs(sunVisibility - 0.5) * 2.0;
float shadowTimeVar2 = shadowTimeVar1 * shadowTimeVar1;
float shadowTime = shadowTimeVar2 * shadowTimeVar2;

vec2 lmCoordM = lmCoord;

// ─────────────────────────────────────────────────────────────────────────────
// Enhanced DH Matrix Aliasing System | نظام تسمية مصفوفات DH المحسن
// ─────────────────────────────────────────────────────────────────────────────
// تجنب التعارض في التصريحات: ربط مصفوفات DH بالأسماء القياسية
// Avoid conflicting redeclarations: alias DH matrices to standard names
#undef gbufferProjection
#undef gbufferProjectionInverse
#define gbufferProjection dhProjection
#define gbufferProjectionInverse dhProjectionInverse

// ─────────────────────────────────────────────────────────────────────────────
// Advanced Light Direction System | نظام اتجاه الضوء المتقدم
// ─────────────────────────────────────────────────────────────────────────────
#ifdef OVERWORLD
    vec3 lightVec = sunVec * ((timeAngle < 0.5325 || timeAngle > 0.9675) ? 1.0 : -1.0);
#else
    vec3 lightVec = sunVec;
#endif

// ═══════════════════════════════════════════════════════════════════════════════
// Enhanced 3D Noise Generation System | نظام توليد الضوضاء ثلاثي الأبعاد المحسن
// ═══════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────────────────
// Advanced 3D Noise Function | دالة الضوضاء ثلاثية الأبعاد المتقدمة
// ─────────────────────────────────────────────────────────────────────────────
float Noise3D(vec3 p) {
    // تحسين إحداثي Z للحصول على ضوضاء أفضل / Enhance Z coordinate for better noise
    p.z = fract(p.z) * 128.0;
    float iz = floor(p.z);
    float fz = fract(p.z);
    
    // حساب الإزاحات المحسنة / Calculate enhanced offsets
    vec2 a_off = vec2(23.0, 29.0) * (iz) / 128.0;
    vec2 b_off = vec2(23.0, 29.0) * (iz + 1.0) / 128.0;
    
    // أخذ عينات الضوضاء / Sample noise
    float a = texture2D(noisetex, p.xy + a_off).r;
    float b = texture2D(noisetex, p.xy + b_off).r;
    
    // مزج ناعم بين المستويات / Smooth blending between levels
    return mix(a, b, fz);
}

// ─────────────────────────────────────────────────────────────────────────────
// Essential Library Includes | المكتبات الأساسية المطلوبة
// ─────────────────────────────────────────────────────────────────────────────
#include "/lib/atmospherics/luminara_atmospheric_core.glsl"

#ifdef ATM_COLOR_MULTS
    #include "/lib/color_schemes/color_effects_system.glsl"
#endif

#ifdef TAA
    #include "/lib/smoothing/sampleOffset.glsl"
#endif

// تعريف خاص للتضاريس / Special terrain definition
#define GBUFFERS_TERRAIN
    #include "/lib/illumination_systems/core_illumination_system.glsl"
#undef GBUFFERS_TERRAIN

#ifdef SNOWY_WORLD
    #include "/lib/materialMethods/snowyWorld.glsl"
#endif

// ═══════════════════════════════════════════════════════════════════════════════
// Main Distant Terrain Rendering Function | الدالة الرئيسية لرندرينغ التضاريس البعيدة
// ═══════════════════════════════════════════════════════════════════════════════
void main() {
    // ─────────────────────────────────────────────────────────────────────────
    // Enhanced Color Initialization | تهيئة الألوان المحسنة
    // ─────────────────────────────────────────────────────────────────────────
    vec4 color = vec4(glColor.rgb, 1.0);

    // ─────────────────────────────────────────────────────────────────────────
    // Advanced View Position Calculation | حساب موضع الرؤية المتقدم
    // ─────────────────────────────────────────────────────────────────────────
    vec3 screenPos = vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z);
    #ifdef TAA
        vec3 viewPos = ScreenToView(vec3(TAAJitter(screenPos.xy, -0.5), screenPos.z));
    #else
        vec3 viewPos = ScreenToView(screenPos);
    #endif
    float lViewPos = length(playerPos);
    vec3 nViewPos = normalize(viewPos);
    float VdotU = dot(nViewPos, upVec);
    float VdotS = dot(nViewPos, sunVec);

    // ─────────────────────────────────────────────────────────────────────────
    // Enhanced Dithering System | نظام التشويش المحسن
    // ─────────────────────────────────────────────────────────────────────────
    float dither = Bayer64(gl_FragCoord.xy);
    #ifdef TAA
        dither = fract(dither + goldenRatio * mod(float(frameCounter), 3600.0));
    #endif

    // ─────────────────────────────────────────────────────────────────────────
    // Advanced Atmospheric Color Processing | معالجة ألوان الغلاف الجوي المتقدمة
    // ─────────────────────────────────────────────────────────────────────────
    #ifdef ATM_COLOR_MULTS
        atmColorMult = GetAtmColorMult();
    #endif

    // ─────────────────────────────────────────────────────────────────────────
    // Enhanced Material Properties Initialization | تهيئة خصائص المواد المحسنة
    // ─────────────────────────────────────────────────────────────────────────
    bool noSmoothLighting = false, noDirectionalShading = false, noVanillaAO = false, centerShadowBias = false;
    int subsurfaceMode = 0;
    float smoothnessG = 0.0, smoothnessD = 0.0, highlightMult = 1.0, emission = 0.0;
    float snowFactor = 1.0, snowMinNdotU = 0.0;
    vec3 normalM = normal, geoNormal = normal, shadowMult = vec3(1.0);    
    vec3 worldGeoNormal = normalize(ViewToPlayer(geoNormal * 10000.0));
    
    // ═══════════════════════════════════════════════════════════════════════════
    // Advanced Material-Specific Processing | معالجة خاصة بالمواد المتقدمة
    // ═══════════════════════════════════════════════════════════════════════════
    if (mat == DH_BLOCK_LEAVES) {
        // معالجة الأوراق المتخصصة للمسافات البعيدة / Specialized leaf processing for distance
        #include "/lib/specificMaterials/terrain/leaves.glsl"
    } else if (mat == DH_BLOCK_GRASS) {
        // معالجة العشب المحسنة / Enhanced grass processing
        smoothnessG = pow2(color.g) * 0.85;
    } else if (mat == DH_BLOCK_ILLUMINATED) {
        // معالجة الكتل المضيئة / Illuminated block processing
        emission = 2.5;
    } else if (mat == DH_BLOCK_LAVA) {
        // معالجة الحمم البركانية / Lava processing
        emission = 1.5;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Enhanced Snowy World Effects | تأثيرات العالم الثلجي المحسنة
    // ─────────────────────────────────────────────────────────────────────────
    #ifdef SNOWY_WORLD
        DoSnowyWorld(color, smoothnessG, highlightMult, smoothnessD, emission,
                     playerPos, lmCoord, snowFactor, snowMinNdotU, NdotU, subsurfaceMode);
    #endif

    // ─────────────────────────────────────────────────────────────────────────
    // Advanced Distance-Based Optimization | التحسين القائم على المسافة المتقدم
    // ─────────────────────────────────────────────────────────────────────────
    vec3 playerPosAlt = ViewToPlayer(viewPos); // AMD لديها مشاكل مع vertex playerPos و DH / AMD has problems with vertex playerPos and DH
    float lengthCylinder = max(length(playerPosAlt.xz), abs(playerPosAlt.y));
    
    // تحسين قوة الإضاءة حسب المسافة / Optimize lighting strength based on distance
    highlightMult *= 0.5 + 0.5 * pow2(1.0 - smoothstep(far, far * 1.5, lengthCylinder));
    
    // تطبيق شفافية تدريجية للمسافات البعيدة / Apply gradual transparency for distant areas
    color.a *= smoothstep(far * 0.5, far * 0.7, lengthCylinder);
    if (color.a < min(dither, 1.0)) discard; // قطع البكسل إذا كان شفافاً جداً / Discard if too transparent

    // ═══════════════════════════════════════════════════════════════════════════
    // Enhanced 3D Noise Application | تطبيق الضوضاء ثلاثية الأبعاد المحسن
    // ═══════════════════════════════════════════════════════════════════════════
    // حساب موضع الضوضاء المحسن / Calculate enhanced noise position
    vec3 noisePos = floor((playerPos + cameraPosition) * 4.0 + 0.001) / 32.0;
    float noiseTexture = Noise3D(noisePos) + 0.5;
    
    // تطبيق عامل الضوضاء التكيفي / Apply adaptive noise factor
    float noiseFactor = max0(1.0 - 0.3 * dot(color.rgb, color.rgb));
    color.rgb *= pow(noiseTexture, 0.6 * noiseFactor);

    // ─────────────────────────────────────────────────────────────────────────
    // Advanced Lighting Integration | تكامل الإضاءة المتقدم
    // ─────────────────────────────────────────────────────────────────────────
    DoLighting(color, shadowMult, playerPos, viewPos, lViewPos, geoNormal, normalM, 0.5,
               worldGeoNormal, lmCoordM, noSmoothLighting, noDirectionalShading, noVanillaAO,
               centerShadowBias, subsurfaceMode, smoothnessG, highlightMult, emission);
    
    // ─────────────────────────────────────────────────────────────────────────
    // Final Output Buffer | المخزن النهائي للإخراج
    // ─────────────────────────────────────────────────────────────────────────
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = color;
}

#endif

// ═══════════════════════════════════════════════════════════════════════════════
// Vertex Shader Implementation | تطبيق Vertex Shader
// ═══════════════════════════════════════════════════════════════════════════════
#ifdef VERTEX_SHADER

flat out int mat;

out vec2 lmCoord;

flat out vec3 upVec, sunVec, northVec, eastVec;
out vec3 normal;
out vec3 playerPos;

out vec4 glColor;

// ─────────────────────────────────────────────────────────────────────────────
// Essential Library Includes | المكتبات الأساسية المطلوبة
// ─────────────────────────────────────────────────────────────────────────────
#ifdef TAA
    #include "/lib/smoothing/sampleOffset.glsl"
#endif

// ═══════════════════════════════════════════════════════════════════════════════
// Vertex Processing Main Function | الدالة الرئيسية لمعالجة Vertex
// ═══════════════════════════════════════════════════════════════════════════════
void main() {
    // ─────────────────────────────────────────────────────────────────────────
    // Enhanced Position Transformation | تحويل الموضع المحسن
    // ─────────────────────────────────────────────────────────────────────────
    gl_Position = ftransform();
    #ifdef TAA
        gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
    #endif

    // ─────────────────────────────────────────────────────────────────────────
    // Enhanced Material and Coordinate Processing | معالجة المواد والإحداثيات المحسنة
    // ─────────────────────────────────────────────────────────────────────────
    mat = dhMaterialId;

    lmCoord  = GetLightMapCoordinates();
    
    // ─────────────────────────────────────────────────────────────────────────
    // Advanced Direction Vector Setup | إعداد متجهات الاتجاه المتقدم
    // ─────────────────────────────────────────────────────────────────────────
    normal = normalize(gl_NormalMatrix * gl_Normal);
    upVec = normalize(gbufferModelView[1].xyz);
    eastVec = normalize(gbufferModelView[0].xyz);
    northVec = normalize(gbufferModelView[2].xyz);
    sunVec = GetSunVector();

    // ─────────────────────────────────────────────────────────────────────────
    // Enhanced Player Position Calculation | حساب موضع اللاعب المحسن
    // ─────────────────────────────────────────────────────────────────────────
    playerPos = (gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex).xyz;

    // ─────────────────────────────────────────────────────────────────────────
    // Color Processing | معالجة الألوان
    // ─────────────────────────────────────────────────────────────────────────
    glColor = gl_Color;
}

#endif

/*
═══════════════════════════════════════════════════════════════════════════════
    ✨ تم إنجاز distant_terrain.glsl بنجاح - EminGT ✨
    🌟 Distant_terrain.glsl completed successfully - EminGT 🌟
    
    🎯 نظام رندرينغ التضاريس البعيدة ومستوى التفاصيل مكتمل
    🎯 Distant Terrain Rendering & Level-of-Detail System Complete
    
    💎 تم بناؤه بفخر من قبل EminGT
    💎 Proudly built by EminGT
═══════════════════════════════════════════════════════════════════════════════
*/
