/*
═══════════════════════════════════════════════════════════════════════════════
    🌟 luminara_core | touch - نظام رندرينغ القبضات والتفاعلات | EminGT 🌟
═══════════════════════════════════════════════════════════════════════════════

    Advanced Hand & Touch Interaction Rendering System
    نظام رندرينغ التفاعلات والقبضات المتقدم

    ⚡ الميزات الأساسية / Core Features:
    ----------------------------------------
    • نظام رندرينغ القبضات المتطور / Advanced Hand Rendering System
    • نظام IPBR متكامل للعناصر في اليد / Integrated IPBR for Hand Items
    • نظام PBR مخصص مع تأثيرات متقدمة / Custom PBR with Advanced Effects
    • نظام إضاءة محسن للخرائط والأدوات / Enhanced Lighting for Maps & Tools
    • نظام الانعكاسات والمواد الديناميكية / Dynamic Reflections & Materials
    • نظام معالجة الشفافية والانبعاث / Transparency & Emission Processing

    🎯 الأنظمة الفرعية / Subsystems:
    --------------------------------
    [رندرينغ الخرائط] - Map Rendering Enhancement
    [معالجة الأدوات] - Tool Processing System
    [تأثيرات المواد] - Material Effects System
    [نظام الانعكاسات] - Reflection System
    [إضاءة القبضات] - Hand Lighting System
    [تحسين الألوان] - Color Enhancement System

    📈 التحسينات المتقدمة / Advanced Optimizations:
    ----------------------------------------------
    ★ Generated Normals: تحسين الأسطح تلقائياً
    ★ Coated Textures: نسيج مطلي متقدم
    ★ POM Integration: تكامل Parallax Occlusion Mapping
    ★ Hand Swaying: حركة اليد الطبيعية
    ★ Entity Reflection Handling: معالجة انعكاسات الكائنات

    🔧 مطور بواسطة / Developed by: EminGT
    📅 التحديث الأخير / Last Updated: 2025
    🎮 متوافق مع / Compatible with: OptiFine & Iris

═══════════════════════════════════════════════════════════════════════════════
*/

// ═══════════════════════════════════════════════════════════════════════════════
// Core Library Includes | مكتبات النظام الأساسية
// ═══════════════════════════════════════════════════════════════════════════════
#include "/lib/shader_modules/shader_master.glsl"

// ═══════════════════════════════════════════════════════════════════════════════
// Fragment Shader Implementation | تطبيق Fragment Shader
// ═══════════════════════════════════════════════════════════════════════════════
#ifdef FRAGMENT_SHADER

// ─────────────────────────────────────────────────────────────────────────────
// Input Variables | متغيرات الإدخال
// ─────────────────────────────────────────────────────────────────────────────
in vec2 texCoord;      // إحداثيات النسيج / Texture coordinates
in vec2 lmCoord;       // إحداثيات خريطة الإضاءة / Light map coordinates

flat in vec3 upVec, sunVec, northVec, eastVec; // متجهات الاتجاه / Direction vectors
in vec3 normal;        // المتجه العمودي / Normal vector

in vec4 glColor;       // لون OpenGL / OpenGL color

// ─────────────────────────────────────────────────────────────────────────────
// Advanced Material Processing Variables | متغيرات معالجة المواد المتقدمة
// ─────────────────────────────────────────────────────────────────────────────
#if defined GENERATED_NORMALS || defined COATED_TEXTURES || defined POM || defined IPBR && defined IS_IRIS
    in vec2 signMidCoordPos;    // إشارة موضع الإحداثيات الوسطى / Sign of mid coord position
    flat in vec2 absMidCoordPos; // القيمة المطلقة للإحداثيات الوسطى / Absolute mid coord position
    flat in vec2 midCoord;       // الإحداثيات الوسطى / Middle coordinates
#endif

#if defined GENERATED_NORMALS || defined CUSTOM_PBR
    flat in vec3 binormal, tangent; // متجهات الظل والمماس / Binormal and tangent vectors
#endif

#ifdef POM
    in vec3 viewVector;    // متجه الرؤية / View vector
    in vec4 vTexCoordAM;   // إحداثيات النسيج المتقدمة / Advanced texture coordinates
#endif

// ─────────────────────────────────────────────────────────────────────────────
// Enhanced Atmospheric Calculations | حسابات الغلاف الجوي المحسنة
// ─────────────────────────────────────────────────────────────────────────────
// تحسين رؤية الخرائط في اليد / Improved hand-held map visibility
float NdotU = dot(normal, vec3(0.0, 1.0, 0.0)); 
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

// نظام اتجاه الضوء للأبعاد المختلفة / Multi-Dimensional Light Direction System
#ifdef OVERWORLD
    vec3 lightVec = sunVec * ((timeAngle < 0.5325 || timeAngle > 0.9675) ? 1.0 : -1.0);
#else
    vec3 lightVec = sunVec;
#endif

// ─────────────────────────────────────────────────────────────────────────────
// TBN Matrix for Advanced Normal Processing | مصفوفة TBN لمعالجة الأسطح المتقدمة
// ─────────────────────────────────────────────────────────────────────────────
#if defined GENERATED_NORMALS || defined CUSTOM_PBR
    mat3 tbnMatrix = mat3(
        tangent.x, binormal.x, normal.x,
        tangent.y, binormal.y, normal.y,
        tangent.z, binormal.z, normal.z
    );
#endif

// ─────────────────────────────────────────────────────────────────────────────
// Essential Library Includes | المكتبات الأساسية المطلوبة
// ─────────────────────────────────────────────────────────────────────────────
#include "/lib/atmospherics/luminara_atmospheric_core.glsl"
#include "/lib/illumination_systems/core_illumination_system.glsl"

#if defined GENERATED_NORMALS || defined COATED_TEXTURES
    // Mip level calculations (inline)
    vec2 dcdx = dFdx(texCoord.xy);
    vec2 dcdy = dFdy(texCoord.xy);
    vec2 midCoordPos = absMidCoordPos * signMidCoordPos;
    
    vec2 mipx = dcdx / absMidCoordPos * 8.0;
    vec2 mipy = dcdy / absMidCoordPos * 8.0;
    
    float mipDelta = max(dot(mipx, mipx), dot(mipy, mipy));
    float miplevel = max(0.5 * log2(mipDelta), 0.0);
    
    #if !defined GBUFFERS_ENTITIES && !defined GBUFFERS_HAND
        vec2 atlasSizeM = atlasSize;
    #else
        vec2 atlasSizeM = atlasSize.x + atlasSize.y > 0.5 ? atlasSize : textureSize(tex, 0);
    #endif
#endif

#ifdef GENERATED_NORMALS
    #include "/lib/materialMethods/generatedNormals.glsl"
#endif

#ifdef COATED_TEXTURES
    #include "/lib/materialMethods/coatedTextures.glsl"
#endif

#if IPBR_EMISSIVE_MODE != 1
    #include "/lib/materialMethods/customEmission.glsl"
#endif

#ifdef CUSTOM_PBR
    #include "/lib/materialHandling/customMaterials.glsl"
#endif

#ifdef COLOR_CODED_PROGRAMS
    #include "/lib/effects/effects_unified.glsl"
#endif

// ═══════════════════════════════════════════════════════════════════════════════
// Main Touch Rendering Function | الدالة الرئيسية لرندرينغ اللمس
// ═══════════════════════════════════════════════════════════════════════════════
void main() {
    // ─────────────────────────────────────────────────────────────────────────
    // Initial Color Processing | معالجة الألوان الأولية
    // ─────────────────────────────────────────────────────────────────────────
    vec4 color = texture2D(tex, texCoord);

    // ─────────────────────────────────────────────────────────────────────────
    // Advanced Material Properties Setup | إعداد خصائص المواد المتقدمة
    // ─────────────────────────────────────────────────────────────────────────
    float smoothnessD = 0.0, skyLightFactor = 0.0;
    float materialMask = OSIEBCA * 254.0; // تعطيل SSAO و TAA / Disable SSAO & TAA
    vec3 normalM = normal;

    // ─────────────────────────────────────────────────────────────────────────
    // Pixelation Edge Artifact Fix | إصلاح تشويهات حواف البكسل
    // ─────────────────────────────────────────────────────────────────────────
    float alphaCheck = color.a;
    #ifdef DO_PIXELATION_EFFECTS
        // إصلاح التشويهات على حواف الشظايا مع كروت الرسم غير nvidia / Fix artifacts on fragment edges with non-nvidia gpus
        alphaCheck = max(fwidth(color.a), alphaCheck);
    #endif

    // ═══════════════════════════════════════════════════════════════════════════
    // Main Rendering Pipeline | خط الرندرينغ الرئيسي
    // ═══════════════════════════════════════════════════════════════════════════
    if (alphaCheck > 0.001) {
        // ─────────────────────────────────────────────────────────────────────
        // Color Preservation & Processing | حفظ ومعالجة الألوان
        // ─────────────────────────────────────────────────────────────────────
        #ifdef GENERATED_NORMALS
            vec3 colorP = color.rgb; // حفظ الألوان الأصلية / Preserve original colors
        #endif
        color *= glColor;

        // ─────────────────────────────────────────────────────────────────────
        // Enhanced Spatial Coordinate System | نظام الإحداثيات المكانية المحسن
        // ─────────────────────────────────────────────────────────────────────
        vec3 screenPos = vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z + 0.38);
        vec3 viewPos = ScreenToView(screenPos);
        vec3 playerPos = ViewToPlayer(viewPos);

        // ─────────────────────────────────────────────────────────────────────
        // Transparency-Based Material Mask Adjustment | تعديل قناع المواد حسب الشفافية
        // ─────────────────────────────────────────────────────────────────────
        if (color.a < 0.75) materialMask = 0.0;

        // ─────────────────────────────────────────────────────────────────────
        // Advanced Lighting Configuration | إعداد الإضاءة المتقدمة
        // ─────────────────────────────────────────────────────────────────────
        bool noSmoothLighting = true, noGeneratedNormals = false;
        bool noDirectionalShading = false, noVanillaAO = false;
        
        float smoothnessG = 0.0, highlightMult = 1.0, emission = 0.0, noiseFactor = 0.6;
        vec2 lmCoordM = lmCoord;
        vec3 geoNormal = normalM;
        vec3 worldGeoNormal = normalize(ViewToPlayer(geoNormal * 10000.0));
        
        // نظام ظلال محسن للقبضات / Enhanced shadow system for hands
        vec3 shadowMult = vec3(0.5); // تحسين الظلال للقبضات / Improved shadows for hands

        // ═════════════════════════════════════════════════════════════════════
        // Advanced Material Processing Systems | أنظمة معالجة المواد المتقدمة
        // ═════════════════════════════════════════════════════════════════════
        #ifdef IPBR
            #ifdef IS_IRIS
                vec3 maRecolor = vec3(0.0);
                #include "/lib/materialHandling/irisMaterials.glsl"

                // معالجة انعكاسات الكائنات / Entity Reflection Handling
                if (materialMask != OSIEBCA * 254.0) 
                    materialMask += OSIEBCA * 100.0;
            #endif

            // ─────────────────────────────────────────────────────────────────
            // Generated Normals System | نظام الأسطح المولدة تلقائياً
            // ─────────────────────────────────────────────────────────────────
            #ifdef GENERATED_NORMALS
                if (!noGeneratedNormals) {
                    GenerateNormals(normalM, colorP);
                }
            #endif

            // ─────────────────────────────────────────────────────────────────
            // Coated Textures Enhancement | تحسين النسيج المطلي
            // ─────────────────────────────────────────────────────────────────
            #ifdef COATED_TEXTURES
                CoatTextures(color.rgb, noiseFactor, playerPos, false);
            #endif

            // ─────────────────────────────────────────────────────────────────
            // Custom Emission for IPBR | انبعاث مخصص لـ IPBR
            // ─────────────────────────────────────────────────────────────────
            #if IPBR_EMISSIVE_MODE != 1
                emission = GetCustomEmissionForIPBR(color, emission);
                
                // تحسين الانبعاث للأدوات السحرية / Enhanced emission for magical tools
                if (emission > 0.0) {
                    emission *= 1.5; // زيادة توهج الأدوات السحرية / Increase magical tool glow
                }
            #endif
        #else
            // ─────────────────────────────────────────────────────────────────
            // Custom PBR Materials System | نظام مواد PBR المخصصة
            // ─────────────────────────────────────────────────────────────────
            #ifdef CUSTOM_PBR
                GetCustomMaterials(color, normalM, lmCoordM, NdotU, shadowMult, 
                                 smoothnessG, smoothnessD, highlightMult, emission, 
                                 materialMask, viewPos, 0.0);
                
                // تحسين المواد للقبضات / Enhanced materials for hands
                smoothnessG *= 1.2; // زيادة نعومة الأسطح / Increase surface smoothness
                highlightMult *= 1.1; // تحسين الإضاءة / Enhanced highlighting
            #endif
        #endif

        // ═════════════════════════════════════════════════════════════════════
        // Enhanced Lighting Application | تطبيق الإضاءة المحسنة
        // ═════════════════════════════════════════════════════════════════════
        DoLighting(color, shadowMult, playerPos, viewPos, 0.0, geoNormal, normalM, 0.5,
                   worldGeoNormal, lmCoordM, noSmoothLighting, noDirectionalShading, noVanillaAO,
                   false, 0, smoothnessG, highlightMult, emission);

        // ─────────────────────────────────────────────────────────────────────
        // IPBR Color Recoloring Integration | تكامل إعادة تلوين IPBR
        // ─────────────────────────────────────────────────────────────────────
        #if defined IPBR && defined IS_IRIS
            color.rgb += maRecolor;
        #endif

        // ─────────────────────────────────────────────────────────────────────
        // Sky Light Factor Calculation | حساب عامل ضوء السماء
        // ─────────────────────────────────────────────────────────────────────
        #if (defined CUSTOM_PBR || defined IPBR && defined IS_IRIS) && defined PBR_REFLECTIONS
            #ifdef OVERWORLD
                skyLightFactor = pow2(max(lmCoord.y - 0.7, 0.0) * 3.33333);
            #else
                skyLightFactor = dot(shadowMult, shadowMult) / 3.0;
            #endif
            
            // تحسين عامل ضوء السماء للقبضات / Enhanced sky light factor for hands
            skyLightFactor *= 1.3;
        #endif
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Color Coding Debug System | نظام ترميز الألوان للتطوير
    // ─────────────────────────────────────────────────────────────────────────
    #ifdef COLOR_CODED_PROGRAMS
        ColorCodeProgram(color, -1);
    #endif

    // ═══════════════════════════════════════════════════════════════════════════
    // Advanced Output Buffer Management | إدارة مخازن الإخراج المتقدمة
    // ═══════════════════════════════════════════════════════════════════════════
    /* DRAWBUFFERS:06 */
    gl_FragData[0] = color;                                           // اللون النهائي / Final color
    gl_FragData[1] = vec4(smoothnessD, materialMask, skyLightFactor, 1.0); // خصائص المواد / Material properties

    // ─────────────────────────────────────────────────────────────────────────
    // High-Quality Reflection Normal Buffer | مخزن أسطح الانعكاسات عالية الجودة
    // ─────────────────────────────────────────────────────────────────────────
    #if BLOCK_REFLECT_QUALITY >= 2 && (RP_MODE >= 2 || defined IS_IRIS)
        /* DRAWBUFFERS:065 */
        gl_FragData[2] = vec4(mat3(gbufferModelViewInverse) * normalM, 1.0); // أسطح الانعكاسات / Reflection normals
    #endif
}

#endif

// ═══════════════════════════════════════════════════════════════════════════════
// Vertex Shader Implementation | تطبيق Vertex Shader
// ═══════════════════════════════════════════════════════════════════════════════
#ifdef VERTEX_SHADER

// ─────────────────────────────────────────────────────────────────────────────
// Output Variables | متغيرات الإخراج
// ─────────────────────────────────────────────────────────────────────────────
out vec2 texCoord;      // إحداثيات النسيج / Texture coordinates
out vec2 lmCoord;       // إحداثيات خريطة الإضاءة / Light map coordinates

flat out vec3 upVec, sunVec, northVec, eastVec; // متجهات الاتجاه / Direction vectors
out vec3 normal;        // المتجه العمودي / Normal vector

out vec4 glColor;       // لون OpenGL / OpenGL color

// ─────────────────────────────────────────────────────────────────────────────
// Advanced Material Processing Outputs | مخرجات معالجة المواد المتقدمة
// ─────────────────────────────────────────────────────────────────────────────
#if defined GENERATED_NORMALS || defined COATED_TEXTURES || defined POM || defined IPBR && defined IS_IRIS
    out vec2 signMidCoordPos;    // إشارة موضع الإحداثيات الوسطى / Sign of mid coord position
    flat out vec2 absMidCoordPos; // القيمة المطلقة للإحداثيات الوسطى / Absolute mid coord position
    flat out vec2 midCoord;       // الإحداثيات الوسطى / Middle coordinates
#endif

#if defined GENERATED_NORMALS || defined CUSTOM_PBR
    flat out vec3 binormal, tangent; // متجهات الظل والمماس / Binormal and tangent vectors
#endif

#ifdef POM
    out vec3 viewVector;    // متجه الرؤية / View vector
    out vec4 vTexCoordAM;   // إحداثيات النسيج المتقدمة / Advanced texture coordinates
#endif

// ─────────────────────────────────────────────────────────────────────────────
// Input Attributes | خصائص الإدخال
// ─────────────────────────────────────────────────────────────────────────────
#if defined GENERATED_NORMALS || defined COATED_TEXTURES || defined POM || defined IPBR && defined IS_IRIS
    attribute vec4 mc_midTexCoord; // إحداثيات النسيج الوسطى / Middle texture coordinates
#endif

#if defined GENERATED_NORMALS || defined CUSTOM_PBR
    attribute vec4 at_tangent; // خاصية المماس / Tangent attribute
#endif

// ═══════════════════════════════════════════════════════════════════════════════
// Vertex Processing Main Function | الدالة الرئيسية لمعالجة Vertex
// ═══════════════════════════════════════════════════════════════════════════════
void main() {
    // ─────────────────────────────────────────────────────────────────────────
    // Primary Vertex Transformation | التحويل الأساسي للـ Vertex
    // ─────────────────────────────────────────────────────────────────────────
    gl_Position = ftransform();

    // ─────────────────────────────────────────────────────────────────────────
    // Enhanced Texture Coordinate Processing | معالجة إحداثيات النسيج المحسنة
    // ─────────────────────────────────────────────────────────────────────────
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmCoord  = GetLightMapCoordinates();

    // ─────────────────────────────────────────────────────────────────────────
    // Color Information Transfer | نقل معلومات الألوان
    // ─────────────────────────────────────────────────────────────────────────
    glColor = gl_Color;

    // ─────────────────────────────────────────────────────────────────────────
    // Advanced Normal and Direction Vector Setup | إعداد المتجهات والاتجاهات المتقدم
    // ─────────────────────────────────────────────────────────────────────────
    normal = normalize(gl_NormalMatrix * gl_Normal);

    upVec = normalize(gbufferModelView[1].xyz);
    eastVec = normalize(gbufferModelView[0].xyz);
    northVec = normalize(gbufferModelView[2].xyz);
    sunVec = GetSunVector();

    // ─────────────────────────────────────────────────────────────────────────
    // Advanced Material Coordinate Processing | معالجة إحداثيات المواد المتقدمة
    // ─────────────────────────────────────────────────────────────────────────
    #if defined GENERATED_NORMALS || defined COATED_TEXTURES || defined POM || defined IPBR && defined IS_IRIS
        midCoord = (gl_TextureMatrix[0] * mc_midTexCoord).st;
        vec2 texMinMidCoord = texCoord - midCoord;
        signMidCoordPos = sign(texMinMidCoord);
        absMidCoordPos  = abs(texMinMidCoord);
    #endif

    // ─────────────────────────────────────────────────────────────────────────
    // TBN Matrix Setup for Advanced Normal Processing | إعداد مصفوفة TBN لمعالجة الأسطح المتقدمة
    // ─────────────────────────────────────────────────────────────────────────
    #if defined GENERATED_NORMALS || defined CUSTOM_PBR
        binormal = normalize(gl_NormalMatrix * cross(at_tangent.xyz, gl_Normal.xyz) * at_tangent.w);
        tangent  = normalize(gl_NormalMatrix * at_tangent.xyz);
    #endif

    // ─────────────────────────────────────────────────────────────────────────
    // Parallax Occlusion Mapping Setup | إعداد خرائط الانسداد المتوازية
    // ─────────────────────────────────────────────────────────────────────────
    #ifdef POM
        mat3 tbnMatrix = mat3(
            tangent.x, binormal.x, normal.x,
            tangent.y, binormal.y, normal.y,
            tangent.z, binormal.z, normal.z
        );

        viewVector = tbnMatrix * (gl_ModelViewMatrix * gl_Vertex).xyz;

        vTexCoordAM.zw  = abs(texMinMidCoord) * 2;
        vTexCoordAM.xy  = min(texCoord, midCoord - texMinMidCoord);
    #endif

    // ─────────────────────────────────────────────────────────────────────────
    // Hand Swaying Animation System | نظام حركة اليد الطبيعية
    // ─────────────────────────────────────────────────────────────────────────
    #if HAND_SWAYING > 0
        // Hand sway code is now directly in effects_unified.glsl as comments
        #if HAND_SWAYING == 1
            const float handSwayMult = 0.5;
        #elif HAND_SWAYING == 2
            const float handSwayMult = 1.0;
        #elif HAND_SWAYING == 3
            const float handSwayMult = 2.0;
        #endif
        gl_Position.x += handSwayMult * (sin(frameTimeCounter * 0.86)) / 256.0;
        gl_Position.y += handSwayMult * (cos(frameTimeCounter * 1.5)) / 64.0;
    #endif
}

#endif

/*
═══════════════════════════════════════════════════════════════════════════════
    تم التطوير بواسطة EminGT - نظام رندرينغ القبضات والتفاعلات المتقدم
    Developed by EminGT - Advanced Hand & Touch Interaction Rendering System
═══════════════════════════════════════════════════════════════════════════════
*/
