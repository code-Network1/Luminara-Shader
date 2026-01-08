/*
═══════════════════════════════════════════════════════════════════════════════
    🌟 luminara_core | void - نظام رندرينغ الفراغ والسماء | EminGT 🌟
═══════════════════════════════════════════════════════════════════════════════

    Advanced Void & Sky Rendering System
    نظام رندرينغ الفراغ والسماء المتقدم

    ⚡ الميزات الأساسية / Core Features:
    ----------------------------------------
    • نظام السماء الجوية المتقدم / Advanced Atmospheric Sky System
    • نظام النجوم والقمر المحسن / Enhanced Stars & Moon System
    • نظام أطوار القمر الديناميكية / Dynamic Moon Phases System
    • نظام الألوان الجوية التفاعلية / Interactive Atmospheric Colors
    • نظام تأثيرات الطقس على السماء / Weather Effects on Sky
    • نظام الشمس والقمر القابل للتخصيص / Customizable Sun & Moon System

    🎯 الأنظمة الفرعية / Subsystems:
    --------------------------------
    [رندرينغ السماء] - Sky Rendering System
    [نظام النجوم] - Star System with Enhanced Brightness
    [أطوار القمر] - Moon Phase Calculation System
    [تأثيرات الغروب] - Sunset & Sunrise Effects
    [الألوان الجوية] - Atmospheric Color Dynamics
    [تأثيرات الكهوف] - Cave Atmosphere Effects

    📈 التحسينات المتقدمة / Advanced Optimizations:
    ----------------------------------------------
    ★ Dynamic Sky Colors: ألوان سماء ديناميكية
    ★ Enhanced Moon Rendering: رندرينغ قمر محسن
    ★ Atmospheric Volume System: نظام الحجم الجوي
    ★ Weather Integration: تكامل تأثيرات الطقس
    ★ Multi-Dimensional Support: دعم الأبعاد المتعددة

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
flat in vec3 upVec, sunVec;    // متجهات الاتجاه / Direction vectors
flat in vec4 glColor;          // لون OpenGL / OpenGL color

#ifdef OVERWORLD
    flat in float vanillaStars; // كشف النجوم الأصلية / Vanilla stars detection
#endif

// ─────────────────────────────────────────────────────────────────────────────
// Enhanced Atmospheric Calculations | حسابات الغلاف الجوي المحسنة
// ─────────────────────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────────────────────
// Essential Library Includes | المكتبات الأساسية المطلوبة
// ─────────────────────────────────────────────────────────────────────────────
#include "/lib/atmospherics/luminara_atmospheric_core.glsl"

#ifdef OVERWORLD
    #include "/lib/atmospherics/atmosphericVolumetricSystem.glsl"
#endif

#ifdef CAVE_FOG
    #include "/lib/atmospherics/particles/depthFactor.glsl"
#endif

#ifdef ATM_COLOR_MULTS
    #include "/lib/color_schemes/color_effects_system.glsl"
#endif

#ifdef MOON_PHASE_INF_ATMOSPHERE
    #include "/lib/color_schemes/color_effects_system.glsl"
#endif

#ifdef COLOR_CODED_PROGRAMS
    #include "/lib/effects/effects_unified.glsl"
#endif

#if SUN_MOON_STYLE >= 2
    #include "/lib/atmospherics/luminara_atmospheric_core.glsl"
#endif

// ═══════════════════════════════════════════════════════════════════════════════
// Main Void Rendering Function | الدالة الرئيسية لرندرينغ الفراغ
// ═══════════════════════════════════════════════════════════════════════════════
void main() {
    // ─────────────────────────────────────────────────────────────────────────
    // Initial Color Processing | معالجة الألوان الأولية
    // ─────────────────────────────────────────────────────────────────────────
    vec4 color = vec4(glColor.rgb, 1.0);

    #ifdef OVERWORLD
        // ─────────────────────────────────────────────────────────────────────
        // Vanilla Stars Culling | قطع النجوم الأصلية
        // ─────────────────────────────────────────────────────────────────────
        if (vanillaStars > 0.5) {
            discard; // إزالة النجوم الأصلية / Remove vanilla stars
        }

        // ─────────────────────────────────────────────────────────────────────
        // Iris Compatibility Fix | إصلاح التوافق مع Iris
        // ─────────────────────────────────────────────────────────────────────
        #if IRIS_VERSION >= 10800 && IRIS_VERSION < 10805
            if (renderStage == MC_RENDER_STAGE_MOON) {
                discard; // إصلاح اختفاء الشمس / Fixes sun disappearing issue
            }
        #endif

        // ─────────────────────────────────────────────────────────────────────
        // Enhanced Spatial Coordinate System | نظام الإحداثيات المكانية المحسن
        // ─────────────────────────────────────────────────────────────────────
        vec4 screenPos = vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z, 1.0);
        vec4 viewPos = gbufferProjectionInverse * (screenPos * 2.0 - 1.0);
        viewPos /= viewPos.w;
        vec3 nViewPos = normalize(viewPos.xyz);

        // ─────────────────────────────────────────────────────────────────────
        // Advanced View Direction Calculations | حسابات اتجاه الرؤية المتقدمة
        // ─────────────────────────────────────────────────────────────────────
        float VdotU = dot(nViewPos, upVec);
        float VdotS = dot(nViewPos, sunVec);
        float dither = Bayer8(gl_FragCoord.xy);

        // ═════════════════════════════════════════════════════════════════════
        // Enhanced Sky Rendering System | نظام رندرينغ السماء المحسن
        // ═════════════════════════════════════════════════════════════════════
        color.rgb = GetSky(VdotU, VdotS, dither, true, false);

        // ─────────────────────────────────────────────────────────────────────
        // Atmospheric Color Enhancement | تحسين الألوان الجوية
        // ─────────────────────────────────────────────────────────────────────
        #ifdef ATM_COLOR_MULTS
            color.rgb *= GetAtmColorMult();
        #endif

        #ifdef MOON_PHASE_INF_ATMOSPHERE
            color.rgb *= moonPhaseInfluence; // تأثير أطوار القمر / Moon phase influence
        #endif

        // ─────────────────────────────────────────────────────────────────────
        // Enhanced Star System | نظام النجوم المحسن
        // ─────────────────────────────────────────────────────────────────────
        vec2 starCoord = GetStarCoord(viewPos.xyz, 0.5);
        vec3 starLight = GetStars(starCoord, VdotU, VdotS);
        
        // تحسين إضاءة النجوم / Enhanced star brightness
        starLight *= 1.3; // زيادة سطوع النجوم / Increase star brightness
        color.rgb += starLight;

        // ═════════════════════════════════════════════════════════════════════
        // Advanced Sun & Moon Rendering System | نظام رندرينغ الشمس والقمر المتقدم
        // ═════════════════════════════════════════════════════════════════════
        #if SUN_MOON_STYLE >= 2 && !defined(DISABLE_UNBOUND_SUN_MOON)
        #ifndef DISABLE_UNBOUND_SUN_MOON
            float absVdotS = abs(VdotS);
            
            // ─────────────────────────────────────────────────────────────────
            // Dynamic Sun/Moon Size Configuration | إعداد حجم الشمس/القمر الديناميكي
            // ─────────────────────────────────────────────────────────────────
            #if SUN_MOON_STYLE == 2
                float sunSizeFactor1 = 0.9975;
                float sunSizeFactor2 = 400.0;
                float moonCrescentOffset = 0.0055;
                float moonPhaseFactor1 = 2.45;
                float moonPhaseFactor2 = 750.0;
            #else
                float sunSizeFactor1 = 0.9983;
                float sunSizeFactor2 = 588.235;
                float moonCrescentOffset = 0.0042;
                float moonPhaseFactor1 = 2.2;
                float moonPhaseFactor2 = 1000.0;
            #endif
            
            if (absVdotS > sunSizeFactor1) {
                float sunMoonMixer = sqrt1(sunSizeFactor2 * (absVdotS - sunSizeFactor1));

                // ─────────────────────────────────────────────────────────────
                // Weather Integration System | نظام تكامل الطقس
                // ─────────────────────────────────────────────────────────────
                #ifdef SUN_MOON_DURING_RAIN
                    sunMoonMixer *= 1.0 - 0.4 * rainFactor2; // تأثير خفيف للمطر / Light rain effect
                #else
                    sunMoonMixer *= 1.0 - rainFactor2; // تأثير كامل للمطر / Full rain effect
                #endif

                // ─────────────────────────────────────────────────────────────
                // Enhanced Sun Rendering | رندرينغ الشمس المحسن
                // ─────────────────────────────────────────────────────────────
                if (VdotS > 0.0) {
                    sunMoonMixer = pow2(sunMoonMixer) * GetHorizonFactor(SdotU);

                    #ifdef CAVE_FOG
                        sunMoonMixer *= 1.0 - 0.65 * GetCaveFactor(); // تأثير الكهوف / Cave effect
                    #endif

                    // ألوان شمس ذهبية محسنة / Enhanced golden sun colors
                    vec3 sunColor = vec3(1.2, 0.7, 0.4) * 12.0; // ألوان أكثر دفئاً / Warmer colors
                    color.rgb = mix(color.rgb, sunColor, sunMoonMixer);
                    
                } else {
                    // ─────────────────────────────────────────────────────────
                    // Advanced Moon Rendering System | نظام رندرينغ القمر المتقدم
                    // ─────────────────────────────────────────────────────────
                    float horizonFactor = GetHorizonFactor(-SdotU);
                    sunMoonMixer = max0(sunMoonMixer - 0.25) * 1.33333 * horizonFactor;

                    // إحداثيات نسيج القمر المحسنة / Enhanced moon texture coordinates
                    starCoord = GetStarCoord(viewPos.xyz, 1.0) * 0.5 + 0.617;
                    
                    // نظام نسيج القمر متعدد الطبقات / Multi-layer moon texture system
                    float moonNoise = texture2D(noisetex, starCoord).g
                                    + texture2D(noisetex, starCoord * 2.5).g * 0.7
                                    + texture2D(noisetex, starCoord * 5.0).g * 0.5;
                    moonNoise = max0(moonNoise - 0.75) * 1.7;
                    
                    // ألوان قمر محسنة / Enhanced moon colors
                    vec3 moonColor = vec3(0.45, 0.48, 0.6) * 
                                   (1.3 - (0.25 + 0.25 * sqrt1(nightFactor)) * moonNoise);

                    // ═════════════════════════════════════════════════════════
                    // Dynamic Moon Phase System | نظام أطوار القمر الديناميكي
                    // ═════════════════════════════════════════════════════════
                    if (moonPhase >= 1) {
                        float moonPhaseOffset = 0.0;
                        
                        if (moonPhase != 4) {
                            moonPhaseOffset = moonCrescentOffset;
                            moonColor *= 9.5; // سطوع أكبر للهلال / Brighter crescent
                        } else {
                            moonColor *= 11.0; // سطوع أكبر للبدر / Brighter full moon
                        }
                        
                        if (moonPhase > 4) {
                            moonPhaseOffset = -moonPhaseOffset;
                        }

                        // حسابات زاوية القمر المتقدمة / Advanced moon angle calculations
                        float ang = fract(timeAngle - (0.25 + moonPhaseOffset));
                        ang = (ang + (cos(ang * 3.14159265358979) * -0.5 + 0.5 - ang) / 3.0) * 6.28318530717959;
                        
                        // بيانات دوران الشمس المحسنة / Enhanced sun rotation data
                        vec2 sunRotationData2 = vec2(cos(sunPathRotation * 0.01745329251994), 
                                                   -sin(sunPathRotation * 0.01745329251994));
                        vec3 rawSunVec2 = (gbufferModelView * 
                                         vec4(vec3(-sin(ang), cos(ang) * sunRotationData2) * 2000.0, 1.0)).xyz;

                        float moonPhaseVdotS = dot(nViewPos, normalize(rawSunVec2.xyz));

                        // تطبيق تأثير أطوار القمر / Apply moon phase effect
                        sunMoonMixer *= pow2(1.0 - min1(pow(abs(moonPhaseVdotS), moonPhaseFactor2) * moonPhaseFactor1));
                    } else {
                        moonColor *= 5.0; // قمر جديد خافت / Dim new moon
                    }

                    #ifdef CAVE_FOG
                        sunMoonMixer *= 1.0 - 0.5 * GetCaveFactor(); // تأثير الكهوف على القمر / Cave effect on moon
                    #endif

                    color.rgb = mix(color.rgb, moonColor, sunMoonMixer);
                }
            }
        #endif
        #endif // DISABLE_UNBOUND_SUN_MOON
    #endif

    // ─────────────────────────────────────────────────────────────────────────
    // Blindness Effect Integration | تكامل تأثير العمى
    // ─────────────────────────────────────────────────────────────────────────
    color.rgb *= 1.0 - maxBlindnessDarkness;

    // ─────────────────────────────────────────────────────────────────────────
    // Color Coding Debug System | نظام ترميز الألوان للتطوير
    // ─────────────────────────────────────────────────────────────────────────
    #ifdef COLOR_CODED_PROGRAMS
        ColorCodeProgram(color, -1);
    #endif

    // ═══════════════════════════════════════════════════════════════════════════
    // Final Output Buffer | مخزن الإخراج النهائي
    // ═══════════════════════════════════════════════════════════════════════════
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = color; // اللون النهائي للسماء / Final sky color
}

#endif

// ═══════════════════════════════════════════════════════════════════════════════
// Vertex Shader Implementation | تطبيق Vertex Shader
// ═══════════════════════════════════════════════════════════════════════════════
#ifdef VERTEX_SHADER

// ─────────────────────────────────────────────────────────────────────────────
// Output Variables | متغيرات الإخراج
// ─────────────────────────────────────────────────────────────────────────────
flat out vec3 upVec, sunVec;    // متجهات الاتجاه / Direction vectors
flat out vec4 glColor;          // لون OpenGL / OpenGL color

#ifdef OVERWORLD
    flat out float vanillaStars; // كشف النجوم الأصلية / Vanilla stars detection
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
    // Color Information Transfer | نقل معلومات الألوان
    // ─────────────────────────────────────────────────────────────────────────
    glColor = gl_Color;

    // ─────────────────────────────────────────────────────────────────────────
    // Direction Vector Setup | إعداد متجهات الاتجاه
    // ─────────────────────────────────────────────────────────────────────────
    upVec = normalize(gbufferModelView[1].xyz);
    sunVec = GetSunVector();

    #ifdef OVERWORLD
        // ─────────────────────────────────────────────────────────────────────
        // Enhanced Vanilla Star Detection | كشف النجوم الأصلية المحسن
        // ─────────────────────────────────────────────────────────────────────
        // نظام كشف النجوم الأصلية بواسطة Builderb0y محسن / Enhanced Vanilla Star Detection by Builderb0y
        vanillaStars = float(glColor.r == glColor.g && 
                           glColor.g == glColor.b && 
                           glColor.r > 0.0 && 
                           glColor.r < 0.51);
    #endif
}

#endif

/*
═══════════════════════════════════════════════════════════════════════════════
    تم التطوير بواسطة EminGT - نظام رندرينغ الفراغ والسماء المتقدم
    Developed by EminGT - Advanced Void & Sky Rendering System
═══════════════════════════════════════════════════════════════════════════════
*/
