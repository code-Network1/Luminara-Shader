/*
═══════════════════════════════════════════════════════════════════════════════
    🌟 luminara_core | surface - نظام رندرينغ الجسيمات والتأثيرات السطحية | EminGT 🌟
═══════════════════════════════════════════════════════════════════════════════

    Surface Particle & Atmospheric Effects Rendering System
    نظام رندرينغ الجسيمات والتأثيرات الجوية

    ⚡ الميزات الأساسية / Core Features:
    ----------------------------------------
    • نظام تحسين جسيمات البوابات الذهبية / Golden Portal Particle Enhancement
    • نظام تأثيرات المطر والثلج المتطور / Advanced Rain & Snow Effects
    • نظام تحسين جسيمات الماء والدخان / Water & Smoke Particle Enhancement
    • نظام الإضاءة الجوية للجسيمات / Atmospheric Lighting for Particles
    • نظام التحكم في الشفافية والمواد / Transparency & Material Control
    • نظام كشف جسيمات النهاية السحرية / Magical End Particles Detection

    🎯 الأنظمة الفرعية / Subsystems:
    --------------------------------
    [حركة الجسيمات] - Particle Movement Systems
    [تأثيرات النار والحمم] - Fire & Lava Effects
    [تأثيرات البوابات السحرية] - Portal Magic Effects
    [تحسين الألوان الذهبية] - Golden Color Enhancement
    [كشف جسيمات الطقس] - Weather Particle Detection
    [تأثيرات الأبعاد المختلفة] - Multi-Dimensional Effects

    📈 التحسينات المتقدمة / Advanced Optimizations:
    ----------------------------------------------
    ★ TAA Support: دعم التنعيم الزمني
    ★ Cloud Culling: قطع السحب الذكي
    ★ Distance-Based Effects: تأثيرات قائمة على المسافة
    ★ Atmospheric Color Integration: تكامل ألوان جوية
    ★ Multi-Atlas Support: دعم أطلس متعدد

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

flat in vec3 upVec, sunVec; // متجهات الاتجاه / Direction vectors
in vec3 normal;        // المتجه العمودي / Normal vector

flat in vec4 glColor;  // لون OpenGL / OpenGL color

#ifdef CLOUD_SHADOWS
    flat in vec3 eastVec; // متجه الشرق / East vector

    #if SUN_ANGLE != 0
        flat in vec3 northVec; // متجه الشمال / North vector
    #endif
#endif

// ─────────────────────────────────────────────────────────────────────────────
// Atmospheric Calculations | حسابات الغلاف الجوي
// ─────────────────────────────────────────────────────────────────────────────
float NdotU = dot(normal, upVec);
float NdotUmax0 = max(NdotU, 0.0);
float SdotU = dot(sunVec, upVec);

// نظام تحديد وقت الشمس المتقدم / Advanced Sun Time Detection System
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
// Essential Library Includes | المكتبات الأساسية المطلوبة
// ─────────────────────────────────────────────────────────────────────────────
#include "/lib/atmospherics/luminara_atmospheric_core.glsl"
#include "/lib/illumination_systems/core_illumination_system.glsl"

#if MC_VERSION >= 11500
    #include "/lib/atmospherics/particles/mainParticles.glsl"
#endif

#ifdef ATM_COLOR_MULTS
    #include "/lib/color_schemes/color_effects_system.glsl"
#endif

#ifdef COLOR_CODED_PROGRAMS
    #include "/lib/effects/effects_unified.glsl"
#endif

// ═══════════════════════════════════════════════════════════════════════════════
// Main Surface Rendering Function | الدالة الرئيسية لرندرينغ السطح
// ═══════════════════════════════════════════════════════════════════════════════
void main() {
    // ─────────────────────────────────────────────────────────────────────────
    // Initial Color Setup | إعداد الألوان الأولي
    // ─────────────────────────────────────────────────────────────────────────
    vec4 color = texture2D(tex, texCoord);
    vec4 colorP = color; // احتفظ بالألوان الأصلية / Preserve original colors
    color *= glColor;

    // ─────────────────────────────────────────────────────────────────────────
    // Spatial Coordinate System | نظام الإحداثيات المكانية
    // ─────────────────────────────────────────────────────────────────────────
    vec3 screenPos = vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z);
    vec3 viewPos = ScreenToView(screenPos);
    float lViewPos = length(viewPos);
    vec3 playerPos = ViewToPlayer(viewPos);

    // ─────────────────────────────────────────────────────────────────────────
    // Advanced Dithering System | نظام التشويش المتقدم
    // ─────────────────────────────────────────────────────────────────────────
    float dither = texture2D(noisetex, gl_FragCoord.xy / 128.0).b;
    #ifdef TAA
        dither = fract(dither + goldenRatio * mod(float(frameCounter), 3600.0));
    #endif

    // ─────────────────────────────────────────────────────────────────────────
    // Atmospheric Color Enhancement | تحسين الألوان الجوية
    // ─────────────────────────────────────────────────────────────────────────
    #ifdef ATM_COLOR_MULTS
        atmColorMult = GetAtmColorMult();
    #endif

    // ─────────────────────────────────────────────────────────────────────────
    // Cloud Depth Culling System | نظام قطع عمق السحب
    // ─────────────────────────────────────────────────────────────────────────
    #ifdef VL_CLOUDS_ACTIVE
        float cloudLinearDepth = texelFetch(gaux1, texelCoord, 0).r;

        if (cloudLinearDepth > 0.0) // Iris pipeline position adjustment
        if (pow2(cloudLinearDepth + OSIEBCA * dither) * renderDistance < min(lViewPos, renderDistance)) 
            discard;
    #endif

    // ─────────────────────────────────────────────────────────────────────────
    // Material Properties Setup | إعداد خصائص المواد
    // ─────────────────────────────────────────────────────────────────────────
    float emission = 0.0;
    float materialMask = OSIEBCA * 254.0; // تعطيل SSAO و TAA / Disable SSAO & TAA
    vec2 lmCoordM = lmCoord;
    vec3 normalM = normal, geoNormal = normal, shadowMult = vec3(1.0);
    vec3 worldGeoNormal = normalize(ViewToPlayer(geoNormal * 10000.0));

    // ═══════════════════════════════════════════════════════════════════════════
    // Advanced Particle Enhancement System | نظام تحسين الجسيمات المتقدم
    // ═══════════════════════════════════════════════════════════════════════════
    #if defined IPBR && defined IPBR_PARTICLE_FEATURES
        // تحديد حجم الأطلس للكشف عن الجسيمات / Atlas size detection for particles
        #if MC_VERSION >= 12000
            float atlasCheck = 1200.0; // أطلس أكبر في الإصدارات الجديدة / Larger atlas in newer versions
        #else
            float atlasCheck = 950.0;
        #endif

        if (atlasSize.x < atlasCheck) {
            // ─────────────────────────────────────────────────────────────────
            // Golden Water Particle Enhancement | تحسين جسيمات الماء الذهبية
            // ─────────────────────────────────────────────────────────────────
            if (color.b > 1.15 * (color.r + color.g) && color.g > color.r * 1.25 && 
                color.g < 0.425 && color.b > 0.75) {
                if (color.a < 0.1) discard;
                
                // جسيمات ماء ذهبية مكثفة / Intensified Golden Water Particles
                color.rgb = vec3(1.2, 0.85, 0.25) * 1.5;
                emission = 4.0;
                materialMask = 0.0;
                
            // ─────────────────────────────────────────────────────────────────
            // Weather Effects Enhancement | تحسين تأثيرات الطقس
            // ─────────────────────────────────────────────────────────────────
            #ifdef OVERWORLD
            } else if (color.b > 0.7 && color.r < 0.28 && color.g < 0.425 && 
                      color.g > color.r * 1.4) { // تحسين مطر فيزياء / Physics rain enhancement
                if (color.a < 0.1 || isEyeInWater == 3) discard;
                
                color.a *= rainTexOpacity;
                // لون مطر ذهبي معزز / Enhanced golden rain color
                vec3 rainGolden = vec3(1.3, 1.1, 0.75);
                color.rgb = sqrt2(color.rgb) * rainGolden * 
                           (blocklightCol * 2.5 * lmCoord.x + 
                            ambientColor * lmCoord.y * (0.8 + 0.4 * sunFactor));
                emission = 2.5; // توهج ذهبي للمطر / Golden glow for rain
                
            } else if (color.rgb == vec3(1.0) && color.a < 0.765 && color.a > 0.605) {
                // تحسين الثلج / Snow enhancement
                if (color.a < 0.1 || isEyeInWater == 3) discard;
                
                color.a *= snowTexOpacity;
                // ثلج ذهبي ناعم / Soft golden snow
                vec3 snowGolden = vec3(1.1, 1.05, 0.9);
                color.rgb = sqrt2(color.rgb) * snowGolden * 
                           (blocklightCol * 2.2 * lmCoord.x + 
                            lmCoord.y * (0.75 + 0.4 * sunFactor) + 
                            ambientColor * 0.25);
                emission = 1.0; // توهج خفيف للثلج / Soft glow for snow
            #endif
                
            // ─────────────────────────────────────────────────────────────────
            // Underwater Particle Enhancement | تحسين الجسيمات تحت الماء
            // ─────────────────────────────────────────────────────────────────
            } else if (color.r == color.g && color.r - 0.5 * color.b < 0.06) {
                // جسيمات ماء تحت الماء ذهبية / Golden underwater particles
                color.rgb = vec3(1.2, 0.8, 0.15) * 1.8;
                emission = 5.0; // توهج قوي / Strong glow
                materialMask = 0.0;
                
            // ─────────────────────────────────────────────────────────────────
            // Smoke Particle Enhancement | تحسين جسيمات الدخان
            // ─────────────────────────────────────────────────────────────────
            } else if (color.a < 0.99 && dot(color.rgb, color.rgb) < 1.0) {
                color.a *= 0.5;
                // دخان ذهبي دافئ / Warm golden smoke
                vec3 smokeGolden = vec3(1.2, 1.1, 0.9);
                color.rgb *= smokeGolden;
                emission = 2.0; // توهج خفيف / Subtle glow
                materialMask = 0.0;
                
            // ─────────────────────────────────────────────────────────────────
            // Grayscale Particle Enhancement | تحسين الجسيمات الرمادية
            // ─────────────────────────────────────────────────────────────────
            } else if (max(abs(colorP.r - colorP.b), abs(colorP.b - colorP.g)) < 0.001) {
                float dotColor = dot(color.rgb, color.rgb);
                
                if (dotColor > 0.25 && color.g < 0.5 && 
                   (color.b > color.r * 1.1 && color.r > 0.3 || 
                    color.r > (color.g + color.b) * 3.0)) {
                    // جسيمات البوابة الذهبية / Golden Portal Particles
                    emission = clamp(color.r * 12.0, 3.0, 8.0);
                    
                    vec3 goldenPortalColor = vec3(2.8, 2.3, 0.7);
                    color.rgb = goldenPortalColor * 
                               pow(dot(color.rgb, vec3(0.299, 0.587, 0.114)), 0.7);
                    color.rgb = pow1_5(color.rgb);
                    lmCoordM = vec2(0.0);
                    
                } else if (color.r > 0.83 && color.g > 0.23 && color.b < 0.4) {
                    // جسيمات الحمم المحسنة / Enhanced Lava Particles
                    emission = 3.0;
                    color.b *= 0.4;
                    color.r *= 1.3;
                    color.g *= 1.1;
                }
            }
            
            // ─────────────────────────────────────────────────────────────────
            // Purple/Magenta to Golden Conversion | تحويل البنفسجي إلى ذهبي
            // ─────────────────────────────────────────────────────────────────
            if (color.b > color.r * 1.2 && color.b > color.g * 1.3 && color.b > 0.4) {
                vec3 goldenPortalColor = vec3(2.5, 2.0, 0.6);
                float intensity = dot(color.rgb, vec3(0.333));
                color.rgb = goldenPortalColor * intensity * 1.8;
                emission = clamp(intensity * 10.0, 2.0, 6.0);
                lmCoordM = vec2(0.0);
            }
            
            // ─────────────────────────────────────────────────────────────────
            // End Dimension Magical Effects | تأثيرات النهاية السحرية
            // ─────────────────────────────────────────────────────────────────
            #ifdef END
                if (color.b > 0.6 || (color.r + color.b > 1.0 && color.g < 0.8)) {
                    // ألوان سحرية متحركة / Animated magical colors
                    vec3 endMagicalColor = mix(
                        vec3(2.0, 1.4, 2.8),  // بنفسجي ذهبي / Purple-gold
                        vec3(2.3, 2.0, 0.9),  // ذهبي خالص / Pure gold
                        sin(frameTimeCounter * 4.0 + dot(gl_FragCoord.xy, vec2(0.1))) * 0.5 + 0.5
                    );
                    
                    float magicalIntensity = dot(color.rgb, vec3(0.299, 0.587, 0.114));
                    color.rgb = endMagicalColor * magicalIntensity * 2.0;
                    emission = clamp(magicalIntensity * 15.0, 3.0, 10.0);
                    lmCoordM = vec2(0.0);
                }
            #endif
            
            // ─────────────────────────────────────────────────────────────────
            // Nether Dimensional Effects | تأثيرات بُعد الجحيم
            // ─────────────────────────────────────────────────────────────────
            #ifdef NETHER
                if (color.r > 0.7 && color.g < 0.5) {
                    // تحسين جسيمات الجحيم / Nether particle enhancement
                    color.r *= 1.2;
                    color.g *= 1.1;
                    color.b *= 0.8;
                    emission += 1.5;
                }
            #endif
        }
        
        bool noSmoothLighting = false;
    #else
        bool noSmoothLighting = true;
    #endif

    // ─────────────────────────────────────────────────────────────────────────
    // Distance-Based Particle Culling | قطع الجسيمات حسب المسافة
    // ─────────────────────────────────────────────────────────────────────────
    #ifdef REDUCE_CLOSE_PARTICLES
        if (lViewPos - 1.0 < dither) discard;
    #endif

    // ─────────────────────────────────────────────────────────────────────────
    // Glowing Colored Particles System | نظام الجسيمات الملونة المتوهجة
    // ─────────────────────────────────────────────────────────────────────────
    #ifdef GLOWING_COLORED_PARTICLES
        if (atlasSize.x < 950.0) {
            if (dot(glColor.rgb, vec3(1.0)) < 2.99) {
                emission = 6.0; // توهج معزز / Enhanced glow
            }
        }
    #endif

    // ═══════════════════════════════════════════════════════════════════════════
    // Advanced Lighting Integration | تكامل الإضاءة المتقدم
    // ═══════════════════════════════════════════════════════════════════════════
    DoLighting(color, shadowMult, playerPos, viewPos, lViewPos, geoNormal, normalM, dither,
               worldGeoNormal, lmCoordM, noSmoothLighting, false, true,
               false, 0, 0.0, 1.0, emission);

    // ─────────────────────────────────────────────────────────────────────────
    // Atmospheric Fog Integration | تكامل الضباب الجوي
    // ─────────────────────────────────────────────────────────────────────────
    #if MC_VERSION >= 11500
        vec3 nViewPos = normalize(viewPos);

        float VdotU = dot(nViewPos, upVec);
        float VdotS = dot(nViewPos, sunVec);
        float sky = 0.0;

        DoFog(color.rgb, sky, lViewPos, playerPos, VdotU, VdotS, dither);
    #endif

    // ─────────────────────────────────────────────────────────────────────────
    // Translucency Multiplier System | نظام ضارب الشفافية
    // ─────────────────────────────────────────────────────────────────────────
    vec3 translucentMult = mix(vec3(0.666), 
                              color.rgb * (1.0 - pow2(pow2(color.a))), 
                              color.a);

    // ─────────────────────────────────────────────────────────────────────────
    // Color Coding Debug System | نظام ترميز الألوان للتطوير
    // ─────────────────────────────────────────────────────────────────────────
    #ifdef COLOR_CODED_PROGRAMS
        ColorCodeProgram(color, -1);
    #endif

    // ═══════════════════════════════════════════════════════════════════════════
    // Final Output Buffers | مخازن الإخراج النهائية
    // ═══════════════════════════════════════════════════════════════════════════
    /* DRAWBUFFERS:063 */
    gl_FragData[0] = color;                                    // اللون النهائي / Final color
    gl_FragData[1] = vec4(0.0, materialMask, 0.0, 1.0);      // قناع المواد / Material mask
    gl_FragData[2] = vec4(1.0 - translucentMult, 1.0);       // معلومات الشفافية / Translucency info
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

flat out vec3 upVec, sunVec; // متجهات الاتجاه / Direction vectors
out vec3 normal;        // المتجه العمودي / Normal vector

flat out vec4 glColor;  // لون OpenGL / OpenGL color

#ifdef CLOUD_SHADOWS
    flat out vec3 eastVec; // متجه الشرق / East vector

    #if SUN_ANGLE != 0
        flat out vec3 northVec; // متجه الشمال / North vector
    #endif
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
    // Texture Coordinate Processing | معالجة إحداثيات النسيج
    // ─────────────────────────────────────────────────────────────────────────
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmCoord  = GetLightMapCoordinates();

    // ─────────────────────────────────────────────────────────────────────────
    // Color Information Transfer | نقل معلومات الألوان
    // ─────────────────────────────────────────────────────────────────────────
    glColor = gl_Color;

    // ─────────────────────────────────────────────────────────────────────────
    // Normal and Direction Vector Setup | إعداد المتجهات والاتجاهات
    // ─────────────────────────────────────────────────────────────────────────
    normal = normalize(gl_NormalMatrix * gl_Normal);
    upVec = normalize(gbufferModelView[1].xyz);
    sunVec = GetSunVector();

    // ─────────────────────────────────────────────────────────────────────────
    // Flickering Fix System | نظام إصلاح الوميض
    // ─────────────────────────────────────────────────────────────────────────
    #ifdef FLICKERING_FIX
        gl_Position.z -= 0.000002; // تصحيح عمق صغير / Minor depth correction
    #endif

    // ─────────────────────────────────────────────────────────────────────────
    // Cloud Shadow Vector Setup | إعداد متجهات ظلال السحب
    // ─────────────────────────────────────────────────────────────────────────
    #ifdef CLOUD_SHADOWS
        eastVec = normalize(gbufferModelView[0].xyz);

        #if SUN_ANGLE != 0
            northVec = normalize(gbufferModelView[2].xyz);
        #endif
    #endif
}

#endif

/*
═══════════════════════════════════════════════════════════════════════════════
    تم التطوير بواسطة EminGT - نظام رندرينغ الجسيمات والتأثيرات السطحية
    Developed by EminGT - Surface Particle & Atmospheric Effects System
═══════════════════════════════════════════════════════════════════════════════
*/
