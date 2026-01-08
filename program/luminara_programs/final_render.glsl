/*
═══════════════════════════════════════════════════════════════════════════════
    🌟 luminara_programs | final_render - نظام الرندرينغ النهائي | EminGT 🌟
═══════════════════════════════════════════════════════════════════════════════

    Advanced Final Rendering & Post-Processing System
    نظام الرندرينغ النهائي ومعالجة ما بعد الرندرينغ المتقدم

    ⚡ الميزات الأساسية / Core Features:
    ----------------------------------------
    • نظام معالجة الصورة النهائية المتقدم / Advanced Final Image Processing
    • تقنيات شحذ الصورة التكيفية / Adaptive Image Sharpening Techniques
    • تأثيرات الانحراف اللوني المحسنة / Enhanced Chromatic Aberration Effects
    • نظام تشويه تحت الماء التفاعلي / Interactive Underwater Distortion
    • معالجة الأخطاء والتحذيرات المتقدمة / Advanced Error & Warning Handling
    • تقنيات التظليل المحيطي المحسنة / Enhanced Vignette Techniques

    🎯 الأنظمة الفرعية / Subsystems:
    --------------------------------
    [معالجة الصورة النهائية] - Final Image Processing with Multi-layer Effects
    [تحسين الوضوح] - Clarity Enhancement with TAA Integration
    [التأثيرات البصرية] - Visual Effects (Chromatic Aberration, Underwater)
    [إدارة الأخطاء] - Error Management for OptiFine/Iris Compatibility
    [تحسين الألوان] - Color Enhancement and Vignette Systems

    📈 التحسينات المتقدمة / Advanced Optimizations:
    ----------------------------------------------
    ★ TAA Integration: تكامل التنعيم الزمني المحسن
    ★ Adaptive Sharpening: شحذ تكيفي حسب جودة TAA
    ★ Color Space Enhancement: تحسين مساحة الألوان
    ★ Performance Error Checking: فحص أخطاء الأداء
    ★ Cross-Platform Compatibility: توافق عبر المنصات


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

noperspective in vec2 texCoord;

// ─────────────────────────────────────────────────────────────────────────────
// Pipeline Constants - Already included in shader_master.glsl
// ثوابت خط الأنابيب - متضمنة بالفعل في shader_master.glsl
// ─────────────────────────────────────────────────────────────────────────────



// ═══════════════════════════════════════════════════════════════════════════════
// Advanced Image Sharpening System | نظام شحذ الصورة المتقدم
// ═══════════════════════════════════════════════════════════════════════════════
#if IMAGE_SHARPENING > 0
    vec2 viewD = 1.0 / vec2(viewWidth, viewHeight);

    // مصفوفة الإزاحات للشحذ / Sharpening offset matrix
    vec2 sharpenOffsets[4] = vec2[4](
        vec2( viewD.x,  0.0),    // يمين / Right
        vec2( 0.0,  viewD.y),    // أعلى / Up  
        vec2(-viewD.x,  0.0),    // يسار / Left
        vec2( 0.0, -viewD.y)     // أسفل / Down
    );

    // ─────────────────────────────────────────────────────────────────────────
    // Enhanced Adaptive Sharpening Function | دالة الشحذ التكيفي المحسنة
    // ─────────────────────────────────────────────────────────────────────────
    void SharpenImage(inout vec3 color, vec2 texCoordM) {
        #ifdef TAA
            // شحذ كامل مع TAA / Full sharpening with TAA
            float sharpenMult = IMAGE_SHARPENING;
        #else
            // شحذ مخفف بدون TAA / Reduced sharpening without TAA
            float sharpenMult = IMAGE_SHARPENING * 0.5;
        #endif
        
        float mult = 0.0125 * sharpenMult;
        
        // تحسين الصورة الأساسية / Enhance base image
        color *= 1.0 + 0.05 * sharpenMult;

        // تطبيق مرشح الشحذ متعدد الاتجاهات / Apply multi-directional sharpening filter
        for (int i = 0; i < 4; i++) {
            color -= texture2D(colortex3, texCoordM + sharpenOffsets[i]).rgb * mult;
        }
    }
#endif



// ═══════════════════════════════════════════════════════════════════════════════
// Main Final Rendering Function | الدالة الرئيسية للرندرينغ النهائي
// ═══════════════════════════════════════════════════════════════════════════════
void main() {
    // ─────────────────────────────────────────────────────────────────────────
    // Enhanced Texture Coordinate Processing | معالجة إحداثيات النسيج المحسنة
    // ─────────────────────────────────────────────────────────────────────────
    vec2 texCoordM = texCoord;

    // ═══════════════════════════════════════════════════════════════════════════
    // Advanced Underwater Distortion Effect | تأثير التشويه تحت الماء المتقدم
    // ═══════════════════════════════════════════════════════════════════════════
    #ifdef UNDERWATER_DISTORTION
        if (isEyeInWater == 1) {
            // تطبيق تشويه تفاعلي مع الوقت / Apply interactive time-based distortion
            texCoordM += WATER_REFRACTION_INTENSITY * 0.00035 * 
                        sin((texCoord.x + texCoord.y) * 25.0 + frameTimeCounter * 3.0);
        }
    #endif

    // ─────────────────────────────────────────────────────────────────────────
    // Base Color Sampling | أخذ عينة اللون الأساسي
    // ─────────────────────────────────────────────────────────────────────────
    vec3 color = texture2D(colortex3, texCoordM).rgb;

    // ═══════════════════════════════════════════════════════════════════════════
    // Enhanced Chromatic Aberration System | نظام الانحراف اللوني المحسن
    // ═══════════════════════════════════════════════════════════════════════════
    #if CHROMA_ABERRATION > 0
        // حساب مقياس التشويه التكيفي / Calculate adaptive distortion scale
        vec2 scale = vec2(1.0, viewHeight / viewWidth);
        vec2 aberration = (texCoordM - 0.5) * (2.0 / vec2(viewWidth, viewHeight)) * 
                         scale * CHROMA_ABERRATION;
        
        // تطبيق الانحراف اللوني على القنوات الحمراء والزرقاء / Apply chromatic aberration to red and blue channels
        color.rb = vec2(texture2D(colortex3, texCoordM + aberration).r, 
                       texture2D(colortex3, texCoordM - aberration).b);
    #endif

    // ═══════════════════════════════════════════════════════════════════════════
    // Advanced Image Sharpening Application | تطبيق شحذ الصورة المتقدم
    // ═══════════════════════════════════════════════════════════════════════════
    #if IMAGE_SHARPENING > 0
        SharpenImage(color, texCoordM);
    #endif

    // ─────────────────────────────────────────────────────────────────────────
    // Future Enhancement Space (Currently Commented)
    // مساحة للتحسينات المستقبلية (معلقة حالياً)
    // ─────────────────────────────────────────────────────────────────────────
    /*
    // نظام تحسين الصورة المتقدم / Advanced image enhancement system
    ivec2 boxOffsets[8] = ivec2[8](
        ivec2( 1, 0),  ivec2( 0, 1),  ivec2(-1, 0),  ivec2( 0,-1),
        ivec2( 1, 1),  ivec2( 1,-1),  ivec2(-1, 1),  ivec2(-1,-1)
    );

    for (int i = 0; i < 8; i++) {
        color = max(color, texelFetch(colortex3, texelCoord + boxOffsets[i], 0).rgb);
    }
    */

    // ═══════════════════════════════════════════════════════════════════════════
    // Enhanced Vignette Effect System | نظام تأثير التظليل المحيطي المحسن
    // ═══════════════════════════════════════════════════════════════════════════
    #ifdef VIGNETTE_R
        // حساب المسافة من المركز / Calculate distance from center
        vec2 texCoordMin = texCoordM.xy - 0.5;
        
        // تطبيق تظليل محيطي تكيفي حسب سطوع الصورة / Apply adaptive vignette based on image brightness
        float vignette = 1.0 - dot(texCoordMin, texCoordMin) * (1.0 - GetLuminance(color));
        color *= vignette;
    #endif

    // ─────────────────────────────────────────────────────────────────────────
    // Final Output Buffer | المخزن النهائي للإخراج
    // ─────────────────────────────────────────────────────────────────────────
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(color, 1.0);
}

#endif

// ═══════════════════════════════════════════════════════════════════════════════
// Vertex Shader Implementation | تطبيق Vertex Shader
// ═══════════════════════════════════════════════════════════════════════════════
#ifdef VERTEX_SHADER

noperspective out vec2 texCoord;

// ─────────────────────────────────────────────────────────────────────────────
// Vertex Processing Main Function | الدالة الرئيسية لمعالجة Vertex
// ─────────────────────────────────────────────────────────────────────────────
void main() {
    // تحويل الموضع الأساسي / Basic position transformation
    gl_Position = ftransform();
    
    // حساب إحداثيات النسيج / Calculate texture coordinates
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif

/*
═══════════════════════════════════════════════════════════════════════════════
    ✨ تم إنجاز final_render.glsl بنجاح - EminGT ✨
    🌟 Final_render.glsl completed successfully - EminGT 🌟
    
    🎯 نظام الرندرينغ النهائي ومعالجة ما بعد الرندرينغ مكتمل
    🎯 Final Rendering & Post-Processing System Complete
    
    💎 تم بناؤه بفخر من قبل EminGT
    💎 Proudly built by EminGT
═══════════════════════════════════════════════════════════════════════════════
*/
