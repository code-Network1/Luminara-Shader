
// Enhanced redstone block emission | انبعاث محسن لكتلة الريدستون
#define EMISSIVE_REDSTONE_BLOCK
// Advanced amethyst glow system | نظام توهج الجمشت المتقدم
#define GLOWING_AMETHYST 2 //[0 1 2]
// Custom emission intensity control | تحكم شدة الانبعاث المخصص
#define CUSTOM_EMISSION_INTENSITY 40 //[0 5 7 10 15 20 25 30 35 40 45 50 60 70 80 90 100 110 120 130 140 150 160 170 180 190 200 225 250]


// POM surface detail depth control | تحكم عمق تفاصيل سطح POM
#define POM_DEPTH 0.80 //[0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]
// Advanced lighting calculation mode | وضع حساب الإضاءة المتقدم
#define POM_LIGHTING_MODE 2 //[1 2]
// Distance-based quality optimization | تحسين الجودة القائم على المسافة
#define POM_DISTANCE 32 //[16 24 32 48 64 128 256 512 1024]


// Underground illumination enhancement | تحسين الإضاءة تحت الأرض
#define CAVE_LIGHTING 100 //[0 5 7 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300 325 350 375 400 425 450 475 500 550 600 650 700 750 800 850 900 950 1000 1100 1200 1300 1400 1500 1600]
// Dynamic light flicker simulation | محاكاة وميض الضوء الديناميكي
#define BLOCKLIGHT_FLICKERING 0 //[0 2 3 4 5 6 7 8 9 10]
// Held item illumination mode | وضع إضاءة العنصر المحمول
#define HELD_LIGHTING_MODE 2 //[0 1 2]


// Master ore glow controller | متحكم توهج الخامات الرئيسي
#define GLOWING_ORE_MASTER 2 //[0 1 2]
// Advanced lichen luminescence | توهج الأشنة المتقدم
#define GLOWING_LICHEN 2 //[0 1 2]
// Ore glow intensity multiplier | مضاعف شدة توهج الخامات
#define GLOWING_ORE_MULT_BASE 0.25 //[0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00]
// Dynamic ore glow with flickering effect | توهج خامات ديناميكي مع تأثير الوميض
#define GLOWING_ORE_MULT (GLOWING_ORE_MULT_BASE * getOreFlickerMultiplier(playerPos + cameraPosition, frameTimeCounter))

#if GLOWING_ORE_MASTER == 2 || SHADER_STYLE == 4 && GLOWING_ORE_MASTER == 1
    // Precious metal ore illumination | إضاءة خامات المعادن الثمينة
    #define GLOWING_ORE_GOLD
    #define GLOWING_ORE_DIAMOND
    #define GLOWING_ORE_EMERALD
    // Base metal ore enhancement | تحسين خامات المعادن الأساسية  
    #define GLOWING_ORE_IRON
    #define GLOWING_ORE_COPPER
    // Functional ore highlighting | إبراز الخامات الوظيفية
    #define GLOWING_ORE_REDSTONE
    #define GLOWING_ORE_LAPIS
    // Nether realm ore control | تحكم خامات عالم الجحيم
    #define GLOWING_ORE_GILDEDBLACKSTONE
    // Modded content compatibility | توافق المحتوى المعدل
    #define GLOWING_ORE_MODDED
#endif


// Generated normal map intensity | شدة خريطة العادي المولدة
#define GENERATED_NORMAL_MULT 100 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 250 300 400]
// Normal mapping strength control | تحكم قوة خرائط العادي
#define NORMAL_MAP_STRENGTH 100 //[0 10 15 20 30 40 60 80 100 120 140 160 180 200]
// Entity normal generation system | نظام توليد عادي الكيان
#define ENTITY_GN_AND_CT


// Advanced portal visual effects | تأثيرات بصرية متقدمة للبوابات
#define SPECIAL_PORTAL_EFFECTS


// Coated texture enhancement multiplier | مضاعف تحسين النسيج المطلي
#define COATED_TEXTURE_MULT 100 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200]
// Lapis lazuli block emission | انبعاث كتلة اللازورد
#define EMISSIVE_LAPIS_BLOCK
// Glass transparency control | تحكم شفافية الزجاج
#define GLASS_OPACITY 0.25


// Shadow frustum fitting algorithm | خوارزمية ملائمة مخروط الظل
#define SHADOW_FRUSTUM_FIT
// Entity glow stability fix | إصلاح استقرار توهج الكيان
#define GLOWING_ENTITY_FIX
// Light flickering correction | تصحيح وميض الضوء
#define FLICKERING_FIX


// High-quality shadow filtering | تصفية ظلال عالية الجودة
#define SHADOW_FILTERING
// Advanced directional shading | تظليل اتجاهي متقدم
#define DIRECTIONAL_SHADING
// Environmental side shadowing | تظليل جانبي بيئي
#define SIDE_SHADOWING
// Player shadow casting mode | وضع إلقاء ظل اللاعب
#define PLAYER_SHADOW 1 //[-1 1]


// Ambient illumination multiplier | مضاعف الإضاءة المحيطة
#define AMBIENT_MULT 100 //[50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200]
// PBR emission processing mode | وضع معالجة انبعاث PBR
#define IPBR_EMISSIVE_MODE 1 //[1 3 2]
// Directional block light control | تحكم الضوء الكتلي الاتجاهي
#define DIRECTIONAL_BLOCKLIGHT 0 //[0 3 7 11]


// Advanced Nether emission reduction | تقليل انبعاث العالم السفلي المتقدم
#ifdef NETHER
    #define NETHER_EMISSION_REDUCTION 0.3
#else
    #define NETHER_EMISSION_REDUCTION 1.0
#endif


// POM rendering quality level | مستوى جودة تصيير POM
#define POM_QUALITY 128 //[16 32 64 128 256 512]


// Ore flickering animation speed | سرعة رسوم وميض الخامات
#define ORE_FLICKER_SPEED 2.5

// Generate flickering multiplier for ore glow | توليد مضاعف الوميض لتوهج الخامات
float getOreFlickerMultiplier(vec3 worldPos, float time) {
    // Create unique seed based on world position | إنشاء بذرة فريدة بناء على موقع العالم
    float seed = dot(floor(worldPos * 0.1), vec3(12.9898, 78.233, 45.164));
    
    // Generate smooth flickering pattern | توليد نمط وميض ناعم
    float flicker1 = sin(time * ORE_FLICKER_SPEED + seed) * 0.5 + 0.5;
    float flicker2 = sin(time * ORE_FLICKER_SPEED * 1.7 + seed * 1.3) * 0.3 + 0.7;
    
    // Combine flickering patterns for natural effect | دمج أنماط الوميض للحصول على تأثير طبيعي
    float combinedFlicker = flicker1 * flicker2;
    
    // Apply smooth transitions | تطبيق انتقالات ناعمة
    return mix(0.3, 1.0, combinedFlicker);
}
