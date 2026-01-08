/*
═══════════════════════════════════════════════════════════════════════════════
    🌟 luminara_programs | distant_water - نظام رندرينغ المياه البعيدة | EminGT 🌟
═══════════════════════════════════════════════════════════════════════════════

    Advanced Distant Water Rendering & Effects System
    نظام رندرينغ وتأثيرات المياه البعيدة المتقدم

    ⚡ الميزات الأساسية / Core Features:
    ----------------------------------------
    • نظام رندرينغ المياه البعيدة المتقدم / Advanced Distant Water Rendering
    • تقنيات الانعكاس عالية الجودة / High-Quality Reflection Techniques
    • نظام تأثيرات الغلاف الجوي للمياه / Atmospheric Water Effects System
    • معالجة الضباب والجسيمات المتقدمة / Advanced Fog & Particle Processing
    • تكامل مع نظام Distant Horizons / Distant Horizons Integration
    • تحسينات الأداء للمسافات البعيدة / Performance Optimizations for Distance

    🎯 الأنظمة الفرعية / Subsystems:
    --------------------------------
    [رندرينغ المياه البعيدة] - Distant Water Rendering with DH Integration
    [نظام الانعكاسات] - Advanced Reflection System with Sky Effects
    [التأثيرات الجوية] - Atmospheric Effects Integration
    [معالجة الضباب] - Enhanced Fog Processing
    [تحسين الأداء] - Distance-based Performance Optimization

    📈 التحسينات المتقدمة / Advanced Optimizations:
    ----------------------------------------------
    ★ DH Matrix Aliasing: تسمية مصفوفات Distant Horizons
    ★ TAA Integration: تكامل التنعيم الزمني
    ★ Cloud Integration: تكامل مع نظام السحب
    ★ Performance Culling: إخفاء تحسين الأداء
    ★ Atmospheric Integration: تكامل الغلاف الجوي


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
in vec3 viewVector;

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

// ─────────────────────────────────────────────────────────────────────────────
// Enhanced TBN Matrix for Advanced Material Processing | مصفوفة TBN المحسنة لمعالجة المواد المتقدمة
// ─────────────────────────────────────────────────────────────────────────────
#if WATER_STYLE >= 2 || RAIN_PUDDLES >= 1 && WATER_STYLE == 1 && WATER_MAT_QUALITY >= 2 || defined GENERATED_NORMALS || defined CUSTOM_PBR
    mat3 tbnMatrix = mat3(
        eastVec.x, northVec.x, normal.x,
        eastVec.y, northVec.y, normal.y,
        eastVec.z, northVec.z, normal.z
    );
#endif

// ─────────────────────────────────────────────────────────────────────────────
// Essential Library Includes | المكتبات الأساسية المطلوبة
// ─────────────────────────────────────────────────────────────────────────────
#include "/lib/atmospherics/luminara_atmospheric_core.glsl"
#include "/lib/illumination_systems/core_illumination_system.glsl"
#include "/lib/atmospherics/particles/mainParticles.glsl"

#ifdef TAA
    #include "/lib/smoothing/sampleOffset.glsl"
#endif

#ifdef OVERWORLD
    #include "/lib/atmospherics/atmosphericVolumetricSystem.glsl"
#endif

// ─────────────────────────────────────────────────────────────────────────────
// Advanced Reflection System Includes | مكتبات نظام الانعكاسات المتقدم
// ─────────────────────────────────────────────────────────────────────────────
#if WATER_REFLECT_QUALITY >= 0
    #if defined SKY_EFFECT_REFLECTION && defined OVERWORLD
        #include "/lib/atmospherics/atmosphericVolumetricSystem.glsl"

        #ifdef VL_CLOUDS_ACTIVE 
            #include "/lib/atmospherics/atmosphere/mainAtmosphere.glsl"
        #endif
    #endif

    #include "/lib/materialMethods/reflections.glsl"
#endif

// ─────────────────────────────────────────────────────────────────────────────
// Advanced Color Enhancement Includes | مكتبات تحسين الألوان المتقدمة
// ─────────────────────────────────────────────────────────────────────────────
#ifdef ATM_COLOR_MULTS
    #include "/lib/color_schemes/color_effects_system.glsl"
#endif
#ifdef MOON_PHASE_INF_ATMOSPHERE
    #include "/lib/color_schemes/color_effects_system.glsl"
#endif

// ═══════════════════════════════════════════════════════════════════════════════
// Main Distant Water Rendering Function | الدالة الرئيسية لرندرينغ المياه البعيدة
// ═══════════════════════════════════════════════════════════════════════════════
void main() {
    // ─────────────────────────────────────────────────────────────────────────
    // Enhanced Water Color Initialization | تهيئة ألوان المياه المحسنة
    // ─────────────────────────────────────────────────────────────────────────
    vec4 colorP = vec4(vec3(0.85), glColor.a);  // لون المياه الأساسي / Base water color
    vec4 color = glColor;

    // ─────────────────────────────────────────────────────────────────────────
    // Advanced Depth Testing | اختبار العمق المتقدم
    // ─────────────────────────────────────────────────────────────────────────
    vec3 screenPos = vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z);
    if (texture2D(depthtex1, screenPos.xy).r < 1.0) discard; // قطع البكسل إذا كان هناك هندسة أمامه / Discard pixel if there's geometry in front
    float lViewPos = length(playerPos);

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
        sqrtAtmColorMult = sqrt(atmColorMult);
    #endif

    // ─────────────────────────────────────────────────────────────────────────
    // Enhanced Cloud Integration System | نظام تكامل السحب المحسن
    // ─────────────────────────────────────────────────────────────────────────
    #ifdef VL_CLOUDS_ACTIVE
        float cloudLinearDepth = texelFetch(gaux1, texelCoord, 0).r;

        // قطع البكسل إذا كانت السحب أقرب / Discard pixel if clouds are closer
        if (pow2(cloudLinearDepth + OSIEBCA * dither) * renderDistance < min(lViewPos, renderDistance)) discard;
    #endif

    // ─────────────────────────────────────────────────────────────────────────
    // Advanced View Position Calculation | حساب موضع الرؤية المتقدم
    // ─────────────────────────────────────────────────────────────────────────
    #ifdef TAA
        vec3 viewPos = ScreenToView(vec3(TAAJitter(screenPos.xy, -0.5), screenPos.z));
    #else
        vec3 viewPos = ScreenToView(screenPos);
    #endif
    vec3 nViewPos = normalize(viewPos);
    float VdotU = dot(nViewPos, upVec);
    float VdotS = dot(nViewPos, sunVec);

    // ─────────────────────────────────────────────────────────────────────────
    // Enhanced Material Properties Initialization | تهيئة خصائص المواد المحسنة
    // ─────────────────────────────────────────────────────────────────────────
    bool noSmoothLighting = false, noDirectionalShading = false, noVanillaAO = false, centerShadowBias = false;
    int subsurfaceMode = 0;
    float smoothnessG = 0.0, highlightMult = 0.0, emission = 0.0, materialMask = 0.0, reflectMult = 0.0;
    vec3 normalM = normal, geoNormal = normal, shadowMult = vec3(1.0);
    vec3 worldGeoNormal = normalize(ViewToPlayer(geoNormal * 10000.0));
    float fresnel = clamp(1.0 + dot(normalM, nViewPos), 0.0, 1.0);

    // ═══════════════════════════════════════════════════════════════════════════
    // Advanced Water Material Processing | معالجة مواد المياه المتقدمة
    // ═══════════════════════════════════════════════════════════════════════════
    if (mat == DH_BLOCK_WATER) {
        #include "/lib/specificMaterials/translucents/water.glsl"
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Enhanced Distance-Based Alpha Processing | معالجة الشفافية القائمة على المسافة المحسنة
    // ─────────────────────────────────────────────────────────────────────────
    float lengthCylinder = max(length(playerPos.xz), abs(playerPos.y) * 2.0);
    color.a *= smoothstep(far * 0.5, far * 0.7, lengthCylinder);

    // ─────────────────────────────────────────────────────────────────────────
    // Advanced Lighting Integration | تكامل الإضاءة المتقدم
    // ─────────────────────────────────────────────────────────────────────────
    DoLighting(color, shadowMult, playerPos, viewPos, lViewPos, geoNormal, normalM, 0.5,
               worldGeoNormal, lmCoordM, noSmoothLighting, noDirectionalShading, noVanillaAO,
               centerShadowBias, subsurfaceMode, smoothnessG, highlightMult, emission);

    // ═══════════════════════════════════════════════════════════════════════════
    // Advanced Water Reflection System | نظام انعكاسات المياه المتقدم
    // ═══════════════════════════════════════════════════════════════════════════
    #if WATER_REFLECT_QUALITY >= 0
        // ─────────────────────────────────────────────────────────────────────
        // Enhanced Light Color Processing | معالجة ألوان الضوء المحسنة
        // ─────────────────────────────────────────────────────────────────────
        #ifdef LIGHT_COLOR_MULTS
            highlightColor *= lightColorMult;
        #endif
        #ifdef MOON_PHASE_INF_REFLECTION
            highlightColor *= pow2(moonPhaseInfluence);
        #endif

        // ─────────────────────────────────────────────────────────────────────
        // Advanced Fresnel Calculation | حساب فريسنل المتقدم
        // ─────────────────────────────────────────────────────────────────────
        float fresnelM = (pow3(fresnel) * 0.85 + 0.15) * reflectMult;

        // ─────────────────────────────────────────────────────────────────────
        // Enhanced Sky Light Factor | عامل ضوء السماء المحسن
        // ─────────────────────────────────────────────────────────────────────
        float skyLightFactor = pow2(max(lmCoordM.y - 0.7, 0.0) * 3.33333);
        #if SHADOW_QUALITY > -1 && WATER_REFLECT_QUALITY >= 2 && WATER_MAT_QUALITY >= 2
            skyLightFactor = max(skyLightFactor, min1(dot(shadowMult, shadowMult)));
        #endif

        // ─────────────────────────────────────────────────────────────────────
        // Advanced Reflection Calculation | حساب الانعكاسات المتقدم
        // ─────────────────────────────────────────────────────────────────────
        vec4 reflection = GetReflection(normalM, viewPos.xyz, nViewPos, playerPos, lViewPos, -1.0,
                                        depthtex1, dither, skyLightFactor, fresnel,
                                        smoothnessG, geoNormal, color.rgb, shadowMult, highlightMult);

        // مزج الانعكاسات مع اللون الأساسي / Blend reflections with base color
        color.rgb = mix(color.rgb, reflection.rgb, fresnelM);
    #endif

    // ─────────────────────────────────────────────────────────────────────────
    // Enhanced Fog Processing | معالجة الضباب المحسنة
    // ─────────────────────────────────────────────────────────────────────────
    float sky = 0.0;
    DoFog(color.rgb, sky, lViewPos, playerPos, VdotU, VdotS, dither);
    color.a *= 1.0 - sky;

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
out vec3 viewVector;

out vec4 glColor;

// ─────────────────────────────────────────────────────────────────────────────
// Input Attributes | خصائص الإدخال
// ─────────────────────────────────────────────────────────────────────────────
attribute vec4 at_tangent;

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
    // Advanced TBN Matrix Setup | إعداد مصفوفة TBN المتقدم
    // ─────────────────────────────────────────────────────────────────────────
    mat3 tbnMatrix = mat3(
        eastVec.x, northVec.x, normal.x,
        eastVec.y, northVec.y, normal.y,
        eastVec.z, northVec.z, normal.z
    );

    // ─────────────────────────────────────────────────────────────────────────
    // Enhanced View Vector Calculation | حساب متجه الرؤية المحسن
    // ─────────────────────────────────────────────────────────────────────────
    viewVector = tbnMatrix * (gl_ModelViewMatrix * gl_Vertex).xyz;

    // ─────────────────────────────────────────────────────────────────────────
    // Color Processing | معالجة الألوان
    // ─────────────────────────────────────────────────────────────────────────
    glColor = gl_Color;
}

#endif

/*
═══════════════════════════════════════════════════════════════════════════════
    ✨ تم إنجاز distant_water.glsl بنجاح - EminGT ✨
    🌟 Distant_water.glsl completed successfully - EminGT 🌟
    
    🎯 نظام رندرينغ المياه البعيدة وتأثيرات Distant Horizons مكتمل
    🎯 Distant Water Rendering & Distant Horizons Effects System Complete
    
    💎 تم بناؤه بفخر من قبل EminGT
    💎 Proudly built by EminGT
═══════════════════════════════════════════════════════════════════════════════
*/
