
// Celestial body visibility during precipitation | رؤية الأجرام السماوية أثناء الهطول
#define SUN_MOON_DURING_RAIN
// Horizon-enhanced celestial rendering | تصيير سماوي محسن للأفق
#define SUN_MOON_HORIZON
// Professional celestial object style | نمط أجرام سماوية احترافي
#define SUN_MOON_STYLE_DEFINE -1 //[-1 1 2 3]


// Enhanced stellar density control | تحكم كثافة نجمية محسن
#define NIGHT_STAR_AMOUNT 3 //[2 3]
// Nebula intensity modulator | مُعدِّل شدة السديم
#define NIGHT_NEBULA_I 120 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300]


// Weather texture opacity controller | متحكم شفافية نسيج الطقس
#define WEATHER_TEX_OPACITY 100 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300 325 350 375 400 425 450 475 500 550 600 650 700 750 800 850 900]
// Precipitation rendering mode | وضع تصيير الهطول
#define RAIN_STYLE 1 //[1 2]
// Optical atmospheric effects | تأثيرات جوية بصرية
#define RAINBOWS 1 //[0 1 3]


// Dynamic cloud shadow casting | إلقاء ظلال السحب الديناميكي
#define CLOUD_SHADOWS
// Advanced cloud area detection | كشف منطقة السحب المتقدم
#define CLOUD_CLOSED_AREA_CHECK
// Cloud blue channel vibrancy | حيوية القناة الزرقاء للسحب
#define CLOUD_B 115 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300]


// Cloud scale enhancement multiplier | مضاعف تحسين مقياس السحب
#define CLOUD_UNBOUND_SIZE_MULT 140 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300]
// Weather-responsive cloud density | كثافة سحب مستجيبة للطقس
#define CLOUD_UNBOUND_RAIN_ADD 0.75 //[0.00 0.05 0.06 0.07 0.08 0.09 0.10 0.12 0.14 0.16 0.18 0.22 0.26 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50]


// Cloud green channel saturation | تشبع القناة الخضراء للسحب  
#define CLOUD_G 110 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300]
// Atmospheric movement velocity | سرعة الحركة الجوية
#define CLOUD_SPEED_MULT 85 //[0 5 7 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300 325 350 375 400 425 450 475 500 550 600 650 700 750 800 850 900]
// Professional cloud style selector | محدد نمط السحب الاحترافي
#define CLOUD_STYLE_DEFINE 3 //[-1 0 1 3 50]


// Aurora visibility conditions | شروط رؤية الشفق القطبي
#define AURORA_CONDITION 3 //[0 1 2 3 4]
// Aurora rendering style control | تحكم نمط تصيير الشفق القطبي
#define AURORA_STYLE_DEFINE -1 //[-1 0 1 2]


// Enhanced atmospheric depth fog | ضباب عمق جوي محسن
#define ATMOSPHERIC_FOG
// Conditional bloom fog system | نظام ضباب الإزهار المشروط
#define BLOOM_FOG
    // Advanced Nether environment optimization | تحسين بيئة العالم السفلي المتقدم
    #ifdef NETHER
        #undef BLOOM_FOG
    #endif


// Volumetric cloud density control | تحكم كثافة السحب الحجمية
#define CLOUD_UNBOUND_AMOUNT 1.3 //[0.70 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.80 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.90 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.00 1.02 1.04 1.06 1.08 1.10 1.12 1.14 1.16 1.18 1.20 1.22 1.24 1.26 1.28 1.30 1.32 1.34 1.36 1.38 1.40 1.42 1.44 1.46 1.48 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00 2.10 2.20 2.30 2.40 2.50 2.60 2.70 2.80 2.90 3.00]
// Cloud red channel warmth | دفء القناة الحمراء للسحب
#define CLOUD_R 105 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300]
