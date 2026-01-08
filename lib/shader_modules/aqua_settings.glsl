// Volumetric caustic lighting system | نظام إضاءة كاستيك حجمي
#define WATER_CAUSTIC_STYLE_DEFINE 3 //[-1 1 3]
// Advanced underwater view distortion | تشويه رؤية واقعي تحت الماء
#define UNDERWATER_DISTORTION


// Underwater red channel intensity | شدة القناة الحمراء تحت الماء
#define UNDERWATERCOLOR_R 80 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150]
// Advanced water color mode selection | اختيار وضع لون مياه متقدم
#define WATERCOLOR_MODE 3 //[3 2 0]
// Underwater blue channel saturation | تشبع القناة الزرقاء تحت الماء  
#define UNDERWATERCOLOR_B 130 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150]


// Wave velocity multiplier control | تحكم مضاعف سرعة الأمواج
#define WATER_SPEED_MULT 1.30 //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00 2.20 2.40 2.60 2.80 3.00 3.25 3.50 3.75 4.00 4.50 5.00]
// Large scale wave displacement | إزاحة موجية واسعة النطاق
#define WATER_BUMP_BIG 2.40 //[0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00 2.20 2.40 2.60 2.80 3.00 3.25 3.50 3.75 4.00 4.50 5.00]


// Premium water surface rendering mode | وضع تصيير سطح مائي متميز
#define WATER_STYLE_DEFINE 3 //[-1 1 2 3]
// Water foam intensity control | تحكم شدة رغوة الماء
#define WATER_FOAM_I 120 //[0 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150]


// Rain-enhanced waving multiplier | مضاعف تمايل محسن بالمطر
#define WAVING_I_RAIN_MULT 100 //[25 50 75 100 125 150 175 200]
// Botanical leaf dynamics | ديناميكيات الأوراق النباتية
#define WAVING_LEAVES
// Aquatic vegetation animation | رسوم متحركة للنباتات المائية
#define WAVING_LILY_PAD
// Advanced lava flow simulation | محاكاة تدفق حمم متقدمة
#define WAVING_LAVA
// Motion intensity controller | متحكم شدة الحركة
#define WAVING_I 1.00 //[0.25 0.50 0.75 1.00 1.25 1.50 1.75 2.00 50.0]


// Surface roughness master control | تحكم رئيسي في خشونة السطح
#define WATER_BUMPINESS 1.50 //[0.05 0.10 0.15 0.20 0.25 0.30 0.40 0.50 0.65 0.80 1.00 1.25 1.50 2.00 2.50]
// Water red channel intensity | شدة القناة الحمراء للماء
#define WATERCOLOR_R 85 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300]
// Environmental animation speed | سرعة الرسوم المتحركة البيئية
#define WAVING_SPEED 1.00 //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00 2.20 2.40 2.60 2.80 3.00 3.25 3.50 3.75 4.00 4.50 5.00]


// Water green channel saturation | تشبع القناة الخضراء للماء
#define WATERCOLOR_G 120 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300]
// Underwater green channel intensity | شدة القناة الخضراء تحت الماء
#define UNDERWATERCOLOR_G 110 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150]
// Water blue channel vibrancy | حيوية القناة الزرقاء للماء
#define WATERCOLOR_B 140 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300]


// Precipitation response system | نظام استجابة للهطول
#define WAVING_RAIN
// Indoor motion suppression | قمع الحركة الداخلية
#define NO_WAVING_INDOORS
// Enhanced cave water lighting | إضاءة محسنة لمياه الكهوف
#define BRIGHT_CAVE_WATER
// Vegetation dynamics system | نظام ديناميكيات النباتات
#define WAVING_FOLIAGE


// Transparency modulation factor | عامل تعديل الشفافية
#define WATER_ALPHA_MULT 85 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300 325 350 375 400 425 450 475 500 550 600 650 700 750 800 850 900]
// Medium wave pattern control | تحكم نمط الأمواج المتوسطة
#define WATER_BUMP_MED 2.00 //[0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00 2.20 2.40 2.60 2.80 3.00 3.25 3.50 3.75 4.00 4.50 5.00]
// Vertex-level water animation | رسوم متحركة للماء على مستوى الرؤوس
#define WAVING_WATER_VERTEX
// Refractive index controller | متحكم معامل الانكسار
#define WATER_REFRACTION_INTENSITY 2.4 //[0.0 0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0]

// Atmospheric fog density multiplier | مضاعف كثافة الضباب الجوي
#define WATER_FOG_MULT 95 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300 325 350 375 400 425 450 475 500 550 600 650 700 750 800 850 900]
// Wave scale enhancement factor | عامل تحسين مقياس الأمواج
#define WATER_SIZE_MULT 100 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300]
// Fine detail wave control | تحكم تفاصيل الأمواج الدقيقة
#define WATER_BUMP_SMALL 1.00 //[0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00 2.20 2.40 2.60 2.80 3.00 3.25 3.50 3.75 4.00 4.50 5.00]
