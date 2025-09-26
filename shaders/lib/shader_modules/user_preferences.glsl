/*=====================================================================
        VcorA User Preference Engine v2.8
        Advanced User Configuration & Quality Control System
        
        
        
        ⚠️  PROPRIETARY SOFTWARE - Unauthorized redistribution prohibited
        ⚠️  برمجية خاصة - يُمنع إعادة التوزيع بدون تصريح
=====================================================================*/

/*---------------------------------------------------------------------
    🎯 VcorA QUALITY CONTROL MATRIX - مصفوفة التحكم في الجودة VcorA
    Professional performance optimization and visual quality balance
    تحسين الأداء الاحترافي وتوازن الجودة البصرية
---------------------------------------------------------------------*/
// Advanced shadow rendering quality | جودة تصيير الظلال المتقدمة
#define SHADOW_QUALITY 2 //[-1 0 1 2 3 4 5]
// Shadow distance optimization | تحسين مسافة الظلال
const float shadowDistance = 192.0; //[64.0 80.0 96.0 112.0 128.0 160.0 192.0 224.0 256.0 320.0 384.0 512.0 768.0 1024.0]
// Professional cloud rendering quality | جودة تصيير السحب الاحترافية
#define CLOUD_QUALITY 3 //[0 1 2 3]
// Block reflection quality control | تحكم جودة انعكاس الكتل
#define BLOCK_REFLECT_QUALITY 3 //[0 1 2 3]

/*---------------------------------------------------------------------
    🌟 VcorA SHADER STYLE ENGINE - محرك أنماط الشيدر VcorA
    Core rendering style and rendering pipeline selection
    اختيار نمط التصيير الأساسي وخط أنابيب التصيير
---------------------------------------------------------------------*/
// Master shader style selector | محدد نمط الشيدر الرئيسي
#define SHADER_STYLE 1 //[1 4]
// Rendering pipeline mode | وضع خط أنابيب التصيير
#define RP_MODE 1 //[1 0 3 2]
// Detail quality enhancement | تحسين جودة التفاصيل
#define DETAIL_QUALITY 2 //[0 2 3]

/*---------------------------------------------------------------------
    🎨 VcorA LIGHTING DYNAMICS - ديناميكيات الإضاءة VcorA
    Advanced lighting control and color management
    تحكم إضاءة متقدم وإدارة الألوان
---------------------------------------------------------------------*/
// Colored lighting system control | تحكم نظام الإضاءة الملونة
#define COLORED_LIGHTING 0 //[128 192 256 384 512 768 1024]
#if defined IRIS_FEATURE_CUSTOM_IMAGES && SHADOW_QUALITY > -1 && !defined MC_OS_MAC && !(defined DH_TERRAIN || defined DH_WATER)
    #define COLORED_LIGHTING_INTERNAL COLORED_LIGHTING
    #if COLORED_LIGHTING_INTERNAL > 0
        // Color saturation enhancement | تحسين تشبع الألوان
        #define COLORED_LIGHT_SATURATION 100 //[50 55 60 65 70 75 80 85 90 95 100 105 110 115 120 125]
        // Advanced fog lighting effects | تأثيرات إضاءة الضباب المتقدمة
        #define COLORED_LIGHT_FOG
        // Fog lighting intensity | شدة إضاءة الضباب
        #define COLORED_LIGHT_FOG_I 0.65 //[0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50]
        // Dimensional portal edge effects | تأثيرات حافة البوابة البعدية
        #define PORTAL_EDGE_EFFECT
        #ifndef IRIS_HAS_CONNECTED_TEXTURES
            // Connected glass visual effects | تأثيرات بصرية للزجاج المتصل
            #define CONNECTED_GLASS_EFFECT
        #endif
    #endif
#else
    #define COLORED_LIGHTING_INTERNAL 0
#endif

/*---------------------------------------------------------------------
    🌍 VcorA ENVIRONMENTAL SYSTEMS - الأنظمة البيئية VcorA
    Advanced environmental rendering and atmospheric effects
    تصيير بيئي متقدم وتأثيرات جوية
---------------------------------------------------------------------*/
// Nether dimension view distance | مسافة الرؤية في بعد العالم السفلي
#define NETHER_VIEW_LIMIT 99999.0 //[96.0 112.0 128.0 160.0 192.0 224.0 256.0 320.0 384.0 512.0 768.0 1024.0 99999.0]
// Advanced Nether storm system | نظام عاصفة العالم السفلي المتقدم
#define NETHER_STORM
// Storm altitude control | تحكم ارتفاع العاصفة
#define NETHER_STORM_LOWER_ALT 28 //[-296 -292 -288 -284 -280 -276 -272 -268 -264 -260 -256 -252 -248 -244 -240 -236 -232 -228 -224 -220 -216 -212 -208 -204 -200 -196 -192 -188 -184 -180 -176 -172 -168 -164 -160 -156 -152 -148 -144 -140 -136 -132 -128 -124 -120 -116 -112 -108 -104 -100 -96 -92 -88 -84 -80 -76 -72 -68 -64 -60 -56 -52 -48 -44 -40 -36 -32 -28 -24 -20 -16 -12 -8 -4 0 4 8 12 16 20 22 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 104 108 112 116 120 124 128 132 136 140 144 148 152 156 160 164 168 172 176 180 184 188 192 196 200 204 208 212 216 220 224 228 232 236 240 244 248 252 256 260 264 268 272 276 280 284 288 292 296 300]
// Storm intensity modulator | مُعدِّل شدة العاصفة
#define NETHER_STORM_I 0.40 //[0.05 0.06 0.07 0.08 0.09 0.10 0.12 0.14 0.16 0.18 0.22 0.26 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50]

/*---------------------------------------------------------------------
    💫 VcorA CELESTIAL RENDERING - التصيير السماوي VcorA
    Advanced sky and celestial object visualization
    تصور السماء والأجرام السماوية المتقدم
---------------------------------------------------------------------*/
// Aurora visibility system | نظام رؤية الشفق القطبي
#define AURORA_STYLE_DEFINE -1 //[-1 0 1 2]
// Aurora environmental conditions | الظروف البيئية للشفق القطبي
#define AURORA_CONDITION 3 //[0 1 2 3 4]
// Enhanced stellar density | كثافة نجمية محسنة
#define NIGHT_STAR_AMOUNT 3 //[2 3]
// Atmospheric rainbow effects | تأثيرات قوس قزح الجوية
#define RAINBOWS 1 //[0 1 3]

/*---------------------------------------------------------------------
    ⚡ VcorA ANTI-ALIASING ENGINE - محرك مكافحة التعرج VcorA
    Advanced edge smoothing and image quality enhancement
    تنعيم الحواف المتقدم وتحسين جودة الصورة
---------------------------------------------------------------------*/
// Fast approximate anti-aliasing | مكافحة التعرج التقريبية السريعة
#define FXAA_DEFINE 1 //[-1 1]
// Shadow smoothing quality | جودة تنعيم الظلال
#define SHADOW_SMOOTHING 4 //[1 2 3 4]
// Entity shadow rendering | تصيير ظلال الكيان
#define ENTITY_SHADOWS_DEFINE -1 //[-1 1]

/*---------------------------------------------------------------------
    🎯 VcorA SELECTION OUTLINE SYSTEM - نظام محيط التحديد VcorA
    Advanced block selection and highlighting system
    نظام تحديد وإبراز الكتل المتقدم
---------------------------------------------------------------------*/
// Selection outline mode | وضع محيط التحديد
#define SELECT_OUTLINE 1 //[0 1 3 4 2]
// Outline intensity control | تحكم شدة المحيط
#define SELECT_OUTLINE_I 1.00 //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00 2.20 2.40 2.60 2.80 3.00 3.25 3.50 3.75 4.00 4.50 5.00]
// RGB color channel control | تحكم قنوات الألوان RGB
#define SELECT_OUTLINE_R 1.35 //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]
#define SELECT_OUTLINE_G 0.35 //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]
#define SELECT_OUTLINE_B 1.75 //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]

/*---------------------------------------------------------------------
    🌙 VcorA LUNAR PHASE SYSTEM - نظام أطوار القمر VcorA
    Dynamic moon phase effects and lighting influence
    تأثيرات أطوار القمر الديناميكية والتأثير على الإضاءة
---------------------------------------------------------------------*/
// Moon phase reflection influence | تأثير أطوار القمر على الانعكاس
#define MOON_PHASE_INF_REFLECTION
// Full moon lighting intensity | شدة إضاءة البدر
#define MOON_PHASE_FULL 1.00 //[0.01 0.03 0.05 0.07 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
// Partial moon phase intensity | شدة الطور الجزئي للقمر
#define MOON_PHASE_PARTIAL 0.85 //[0.01 0.03 0.05 0.07 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]

/*---------------------------------------------------------------------
    💨 VcorA ATMOSPHERIC FOG ENGINE - محرك الضباب الجوي VcorA
    Advanced fog rendering and atmospheric depth control
    تصيير ضباب متقدم وتحكم العمق الجوي
---------------------------------------------------------------------*/
// Dynamic border fog system | نظام الضباب الحدودي الديناميكي
#define BORDER_FOG
    // Nether environment fog optimization | تحسين ضباب بيئة العالم السفلي
    #ifdef NETHER
        #undef BORDER_FOG
    #endif
// Atmospheric fog multiplier | مضاعف الضباب الجوي
#define ATM_FOG_MULT 0.65 //[0.50 0.65 0.80 0.95]
// Fog distance control | تحكم مسافة الضباب
#define ATM_FOG_DISTANCE 130 //[10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300]
// Cave atmospheric fog | ضباب جوي للكهوف
#define CAVE_FOG

/*---------------------------------------------------------------------
    ⚙️ VcorA ADVANCED OPTIMIZATION - التحسينات المتقدمة VcorA
    Performance enhancement and rendering optimization
    تحسين الأداء وتحسين التصيير
---------------------------------------------------------------------*/
// Particle density reduction | تقليل كثافة الجسيمات
#define REDUCE_CLOSE_PARTICLES
// Lava fog intensity reduction | تقليل شدة ضباب الحمم
#define LESS_LAVA_FOG
// Anisotropic filtering quality | جودة التصفية متباينة الخواص
#define ANISOTROPIC_FILTER 0 //[0 4 8 16]

/*---------------------------------------------------------------------
    🎮 VcorA USER INTERACTION SYSTEM - نظام التفاعل مع المستخدم VcorA
    Enhanced user interface and interaction controls
    واجهة مستخدم محسنة وضوابط التفاعل
---------------------------------------------------------------------*/
// Hand movement animation | رسوم متحركة لحركة اليد
#define HAND_SWAYING 0 //[0 1 2 3]
// Light level visualization | تصور مستوى الضوء
#define SHOW_LIGHT_LEVEL 0 //[0 1 2 3]
// Solar positioning control | تحكم موضع الشمس
#define SUN_ANGLE -1 //[-1 0 -20 -30 -40 -50 -60 60 50 40 30 20]

/*---------------------------------------------------------------------
    🌊 VcorA REFLECTION ENGINE - محرك الانعكاسات VcorA
    Advanced water and surface reflection system
    نظام انعكاسات الماء والأسطح المتقدم
---------------------------------------------------------------------*/
// Water reflection quality | جودة انعكاس الماء
#define WATER_REFLECT_QUALITY 2 //[-1 0 1 2]
// Rain puddle rendering | تصيير برك المطر
#define RAIN_PUDDLES 0 //[0 1 2 3 4]

/*---------------------------------------------------------------------
    🌟 VcorA AMBIENT OCCLUSION SYSTEM - نظام الانسداد المحيطي VcorA
    Screen space ambient occlusion and depth enhancement
    انسداد محيطي لمساحة الشاشة وتحسين العمق
---------------------------------------------------------------------*/
// SSAO quality control | تحكم جودة SSAO
#define SSAO_QUALI_DEFINE 2 //[0 2 3]
// SSAO intensity | شدة SSAO
#define SSAO_I 100 //[0 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300]
// Vanilla AO intensity | شدة AO الفانيليا
#define VANILLAAO_I 100 //[0 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300]

/*---------------------------------------------------------------------
    💡 VcorA LIGHT SHAFT ENGINE - محرك أعمدة الضوء VcorA
    Volumetric light ray rendering and atmospheric lighting
    تصيير أشعة الضوء الحجمية والإضاءة الجوية
---------------------------------------------------------------------*/
// Light shaft behavior mode | وضع سلوك عمود الضوء
#define LIGHTSHAFT_BEHAVIOUR 1 //[0 1 2 3]
// Light shaft quality definition | تعريف جودة عمود الضوء
#define LIGHTSHAFT_QUALI_DEFINE 0 //[0 1 2 3 4]
// Day light shaft intensity | شدة عمود الضوء النهاري
#define LIGHTSHAFT_DAY_I 100 //[1 3 5 7 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200]
// Night light shaft enhancement | تحسين عمود الضوء الليلي
#define LIGHTSHAFT_NIGHT_I 100 //[1 3 5 7 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200]

/*---------------------------------------------------------------------
    🌈 VcorA WEATHER SYSTEM - نظام الطقس VcorA
    Advanced weather effects and precipitation rendering
    تأثيرات طقسية متقدمة وتصيير الهطول
---------------------------------------------------------------------*/
// Weather texture opacity | شفافية نسيج الطقس
#define WEATHER_TEX_OPACITY 100 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300 325 350 375 400 425 450 475 500 550 600 650 700 750 800 850 900]
// Rain rendering style | نمط تصيير المطر
#define RAIN_STYLE 1 //[1 2]
// Rain light shaft intensity | شدة عمود الضوء المطري
#define LIGHTSHAFT_RAIN_I 100 //[1 3 5 7 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200]

/*---------------------------------------------------------------------
    🎨 VcorA OUTLINE ENHANCEMENT - تحسين المحيطات VcorA
    Advanced world and entity outline rendering
    تصيير محيطات العالم والكيانات المتقدم
---------------------------------------------------------------------*/
// World outline thickness control | تحكم سمك محيط العالم
#define WORLD_OUTLINE_THICKNESS 1 //[1 2 3 4]
// World outline intensity | شدة محيط العالم
#define WORLD_OUTLINE_I 1.50 //[0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00 2.20 2.40 2.60 2.80 3.00 3.25 3.50 3.75 4.00]
// Entity outline rendering | تصيير محيط الكيان
#define WORLD_OUTLINE_ON_ENTITIES
// Dark outline enhancement | تحسين المحيط المظلم
#define DARK_OUTLINE_THICKNESS 1 //[1 2]

/*---------------------------------------------------------------------
    🌌 VcorA CELESTIAL OBJECTS - الأجرام السماوية VcorA
    Advanced sun and moon rendering system
    نظام تصيير الشمس والقمر المتقدم
---------------------------------------------------------------------*/
// Celestial object style | نمط الأجرام السماوية
#define SUN_MOON_STYLE_DEFINE -1 //[-1 1 2 3]
// Horizon celestial visibility | رؤية الأجرام السماوية في الأفق
#define SUN_MOON_HORIZON
// Celestial visibility during rain | رؤية الأجرام السماوية أثناء المطر
#define SUN_MOON_DURING_RAIN

/*---------------------------------------------------------------------
    🔥 VcorA NETHER OPTIMIZATION - تحسين العالم السفلي VcorA
    Specialized Nether dimension enhancements
    تحسينات متخصصة لبعد العالم السفلي
---------------------------------------------------------------------*/
// Nether color mode selection | اختيار وضع ألوان العالم السفلي
#define NETHER_COLOR_MODE 3 //[3 2 0]
// Nether storm height control | تحكم ارتفاع عاصفة العالم السفلي
#define NETHER_STORM_HEIGHT 200 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300 325 350 375 400 425 450 475 500 550 600 650 700 750 800 850 900]
// Atmospheric fog altitude | ارتفاع الضباب الجوي
#define ATM_FOG_ALTITUDE 70 //[0 5 10 15 20 25 30 35 40 45 50 52 54 56 58 60 61 62 63 64 65 66 67 68 69 70 72 74 76 78 80 85 90 95 100 105 110 115 120 125 130 135 140 145 150 155 160 165 170 175 180 185 190 195 200 210 220 230 240 250 260 270 280 290 300]

// Nether-specific light shaft optimization | تحسين عمود الضوء الخاص بالعالم السفلي
#ifdef NETHER
    #undef LIGHTSHAFT_DAY_I
    #undef LIGHTSHAFT_NIGHT_I
    #undef LIGHTSHAFT_RAIN_I
    #define LIGHTSHAFT_DAY_I 25
    #define LIGHTSHAFT_NIGHT_I 25
    #define LIGHTSHAFT_RAIN_I 25
#endif

/*---------------------------------------------------------------------
    🌑 VcorA DARKNESS PHASE CONTROL - تحكم طور الظلام VcorA
    Advanced dark moon phase lighting management
    إدارة إضاءة طور القمر المظلم المتقدمة
---------------------------------------------------------------------*/
// Dark moon phase intensity | شدة طور القمر المظلم
#define MOON_PHASE_DARK 0.60 //[0.01 0.03 0.05 0.07 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
// Nebula intensity control | تحكم شدة السديم
#define NIGHT_NEBULA_I 120 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300]

/*---------------------------------------------------------------------
    🎯 VcorA PIXEL CONTROL SYSTEM - نظام التحكم في البكسل VcorA
    Advanced pixel-level rendering control
    تحكم تصيير متقدم على مستوى البكسل
---------------------------------------------------------------------*/
// Pixel scale enhancement | تحسين مقياس البكسل
#define PIXEL_SCALE 1 //[-2 -1 1 2 3 4 5]
