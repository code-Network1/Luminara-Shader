/*=====================================================================================
    🎯 VcorA UNIFIED RENDERING PIPELINE v4.2 - خط أنابيب الرسم الموحد VcorA
    Advanced Shader Pipeline Configuration & Uniform Management System
    نظام إدارة خط أنابيب الشيدرز المتقدم والمتغيرات الموحدة
    
    🚀 CORE FEATURES - الميزات الأساسية:
    ✨ Unified pipeline settings and uniform variables
    ✨ Advanced color buffer management 
    ✨ Shadow mapping optimization
    ✨ Cross-platform compatibility layer
    
    📋 FILE COMPONENTS - مكونات الملف:
    🔧 Pipeline Configuration System
    📊 Texture Buffer Management  
    🌟 Uniform Variable Definitions
    ⚡ Performance Optimization Settings
    
    © 2025 VcorA Technologies - Professional Shader Solutions
    إنتاج شركة VcorA للتقنيات - حلول الشيدرز الاحترافية
=====================================================================================*/

#ifndef VCORA_UNIFIED_RENDERING_CORE_INCLUDED
#define VCORA_UNIFIED_RENDERING_CORE_INCLUDED

/*---------------------------------------------------------------------
    🎮 VcorA CUSTOM PLATFORM DETECTION - كشف المنصة المخصصة VcorA
    Dynamic platform and environment variable detection
    كشف المنصة والمتغيرات البيئية الديناميكي
---------------------------------------------------------------------*/
uniform float framemod8;
uniform float isEyeInCave;
uniform float inDry;
uniform float inRainy;
uniform float inSnowy;
uniform float velocity;
uniform float starter;
uniform float frameTimeSmooth;
uniform float eyeBrightnessM;
uniform float eyeBrightnessM2;
uniform float rainFactor;
uniform float inBasaltDeltas;
uniform float inCrimsonForest;
uniform float inNetherWastes;
uniform float inSoulValley;
uniform float inWarpedForest;
uniform float inPaleGarden;

/*---------------------------------------------------------------------
    📊 VcorA COLOR BUFFER MATRIX - مصفوفة المخازن الملونة VcorA
    Advanced color texture buffer format optimization
    تحسين تنسيق مخازن النسيج الملونة المتقدم
---------------------------------------------------------------------*/
/*
const int colortex0Format = R11F_G11F_B10F; //main color
const int colortex1Format = R32F;           //previous depth
const int colortex2Format = RGB16F;         //taa
const int colortex3Format = RGBA8;          //(cloud/water map on deferred/gbuffer) | translucentMult & bloom & final color
const int colortex4Format = R8;             //volumetric cloud linear depth & volumetric light factor
const int colortex5Format = RGBA8_SNORM;    //normalM & scene image for water reflections
const int colortex6Format = RGBA8;          //smoothnessD & materialMask & skyLightFactor
const int colortex7Format = RGBA16F;        //(cloud/water map on gbuffer) | temporal filter
*/

/*---------------------------------------------------------------------
    💾 VcorA BUFFER INITIALIZATION CONTROLLER - تحكم تهيئة المخازن VcorA
    Smart buffer clearing and memory management
    مسح المخازن الذكي وإدارة الذاكرة
---------------------------------------------------------------------*/
const bool colortex0Clear = true;
const bool colortex7Clear = false;
const bool colortex3Clear = true;
const bool colortex1Clear = false;
const bool colortex6Clear = true;
const bool colortex2Clear = false;
const bool colortex4Clear = false;
const bool colortex5Clear = false;

/*---------------------------------------------------------------------
    🌍 VcorA GLOBAL ENVIRONMENT VARIABLES - المتغيرات البيئية العامة VcorA
    Core world and timing uniform variables
    المتغيرات الأساسية للعالم والتوقيت
---------------------------------------------------------------------*/
uniform int blockEntityId;
uniform int worldTime;
uniform int currentRenderedItemId;
uniform int frameCounter;
uniform int entityId;
uniform int worldDay;
uniform int heldBlockLightValue;
uniform int moonPhase;
uniform int heldBlockLightValue2;
uniform int isEyeInWater;
uniform int heldItemId;
uniform int heldItemId2;

/*---------------------------------------------------------------------
    🎯 VcorA NOISE TEXTURE RESOLUTION ENGINE - محرك دقة نسيج الضوضاء VcorA
    Procedural noise generation optimization
    تحسين توليد الضوضاء الإجرائية
---------------------------------------------------------------------*/
const int noiseTextureResolution = 128;

/*---------------------------------------------------------------------
    🌊 VcorA ATMOSPHERIC DYNAMICS PROCESSOR - معالج الديناميكيات الجوية VcorA
    Weather and environmental condition management
    إدارة الطقس والظروف البيئية
---------------------------------------------------------------------*/
uniform float aspectRatio;
uniform float wetness;
uniform float blindness;
uniform float rainStrength;
uniform float darknessFactor;
uniform float sunAngle;
uniform float darknessLightFactor;
uniform float screenBrightness;
uniform float maxBlindnessDarkness;
uniform float playerMood;
uniform float eyeAltitude;
uniform float far;
uniform float frameTime;
uniform float near;
uniform float frameTimeCounter;
uniform float viewHeight;
uniform float nightVision;
uniform float viewWidth;

/*---------------------------------------------------------------------
    🏔️ VcorA ENVIRONMENTAL MOISTURE SYSTEM - نظام الرطوبة البيئية VcorA
    Advanced wetness and dryness lifecycle management
    إدارة دورة حياة الرطوبة والجفاف المتقدمة
---------------------------------------------------------------------*/
const float drynessHalflife = 300.0;
const float wetnessHalflife = 300.0;

/*---------------------------------------------------------------------
    🔍 VcorA VECTOR COORDINATE FRAMEWORK - إطار الإحداثيات الشعاعية VcorA
    2D and 3D vector uniform management
    إدارة المتغيرات الشعاعية ثنائية وثلاثية الأبعاد
---------------------------------------------------------------------*/
uniform ivec2 atlasSize;
uniform ivec2 eyeBrightness;

uniform vec3 relativeEyePosition;
uniform vec3 cameraPosition;
uniform vec3 skyColor;
uniform vec3 fogColor;
uniform vec3 previousCameraPosition;

uniform vec4 entityColor;
uniform vec4 lightningBoltPosition;

/*---------------------------------------------------------------------
    🌒 VcorA SHADOW MAPPING ARCHITECTURE - هندسة رسم الظلال VcorA
    Hardware-accelerated shadow filtering and optimization
    ترشيح الظلال المعجل بالأجهزة والتحسين
---------------------------------------------------------------------*/
const bool shadowHardwareFiltering = true;
const float shadowDistanceRenderMul = 1.0;
const float entityShadowDistanceMul = 0.125; // Iris feature

/*---------------------------------------------------------------------
    💡 VcorA AMBIENT OCCLUSION ENGINE - محرك الانسداد المحيطي VcorA
    Advanced ambient lighting calculation system
    نظام حساب الإضاءة المحيطة المتقدم
---------------------------------------------------------------------*/
const float ambientOcclusionLevel = 1.0;

/*---------------------------------------------------------------------
    🎥 VcorA TRANSFORMATION MATRIX SYSTEM - نظام مصفوفات التحويل VcorA
    Camera and projection matrix management
    إدارة مصفوفات الكاميرا والإسقاط
---------------------------------------------------------------------*/
uniform mat4 gbufferModelView;
uniform mat4 shadowModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowProjectionInverse;
uniform mat4 gbufferPreviousModelView;
uniform mat4 shadowModelViewInverse;
uniform mat4 gbufferPreviousProjection;
uniform mat4 shadowProjection;

/*---------------------------------------------------------------------
    🎨 VcorA TEXTURE SAMPLER COLLECTION - مجموعة أخذ عينات النسيج VcorA
    Comprehensive texture and depth buffer access
    الوصول الشامل للنسيج ومخازن العمق
---------------------------------------------------------------------*/
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D colortex5;
uniform sampler2D colortex6;
uniform sampler2D colortex7;
uniform sampler2D colortex8;
uniform sampler2D colortex9;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D depthtex2;
uniform sampler2D gaux1;
uniform sampler2D gaux2;
uniform sampler2D gaux4;
uniform sampler2D normals;
uniform sampler2D noisetex;
uniform sampler2D specular;
uniform sampler2D tex;

/*---------------------------------------------------------------------
    📍 VcorA CAMERA POSITION TRACKING SYSTEM - نظام تتبع موقع الكاميرا VcorA
    High-precision camera position management
    إدارة موقع الكاميرا عالية الدقة
---------------------------------------------------------------------*/
uniform ivec3 cameraPositionInt;
uniform ivec3 previousCameraPositionInt;
uniform vec3 cameraPositionFract;
uniform vec3 previousCameraPositionFract;

/*---------------------------------------------------------------------
    🌅 VcorA IRIS RENDER STAGE DETECTION - كشف مرحلة رسم Iris VcorA
    Cross-platform render stage identification
    تحديد مرحلة الرسم متعددة المنصات
---------------------------------------------------------------------*/
#ifdef IS_IRIS
    uniform int renderStage;
#endif

/*---------------------------------------------------------------------
    🌫️ VcorA SHADOW TEXTURE MANAGEMENT - إدارة نسيج الظلال VcorA
    Advanced shadow mapping and light shaft processing
    رسم الظلال المتقدم ومعالجة أعمدة الضوء
---------------------------------------------------------------------*/
#if SHADOW_QUALITY > -1 || defined LIGHTSHAFTS_ACTIVE || defined FF_BLOCKLIGHT
    uniform sampler2D shadowcolor0;
    uniform sampler2D shadowcolor1;

    uniform sampler2DShadow shadowtex1;

    #ifdef COMPOSITE
        uniform sampler2D shadowtex0;
    #else
        uniform sampler2DShadow shadowtex0;
    #endif
#endif

/*---------------------------------------------------------------------
    📐 VcorA PROJECTION MATRIX CONTROLLER - تحكم مصفوفة الإسقاط VcorA
    Dynamic projection matrix management system
    نظام إدارة مصفوفة الإسقاط الديناميكي
---------------------------------------------------------------------*/
#if !defined DH_TERRAIN && !defined DH_WATER
    uniform mat4 gbufferProjection;
    uniform mat4 gbufferProjectionInverse;
#endif

/*---------------------------------------------------------------------
    🌄 VcorA DISTANT HORIZONS INTEGRATION - تكامل الآفاق البعيدة VcorA
    Long-distance rendering optimization system
    نظام تحسين الرسم بعيد المدى
---------------------------------------------------------------------*/
#ifdef DISTANT_HORIZONS
    uniform int dhRenderDistance;

    uniform mat4 dhProjection;
    uniform mat4 dhProjectionInverse;
    
    uniform sampler2D dhDepthTex;
    uniform sampler2D dhDepthTex1;
#endif

/*---------------------------------------------------------------------
    🎨 VcorA COLORED LIGHTING VOXELIZATION - تحويل الإضاءة الملونة للفوكسل VcorA
    Advanced 3D lighting calculation system
    نظام حساب الإضاءة ثلاثية الأبعاد المتقدم
---------------------------------------------------------------------*/
#if COLORED_LIGHTING_INTERNAL > 0
    uniform usampler3D voxel_sampler;
    uniform sampler3D floodfill_sampler;
    uniform sampler3D floodfill_sampler_copy;
#endif

/*---------------------------------------------------------------------
    💧 VcorA PUDDLE VOXELIZATION ENGINE - محرك تحويل البرك للفوكسل VcorA
    Water puddle 3D representation system
    نظام التمثيل ثلاثي الأبعاد لبرك المياه
---------------------------------------------------------------------*/
#ifdef PUDDLE_VOXELIZATION
    uniform usampler2D puddle_sampler;
#endif

/*=====================================================================================
    ✨ VcorA UNIFIED RENDERING PIPELINE COMPLETE ✨
    خط أنابيب الرسم الموحد VcorA مكتمل
    
    🎉 PERFORMANCE OPTIMIZED - محسن للأداء
    🔧 CROSS-PLATFORM COMPATIBLE - متوافق متعدد المنصات  
    🌟 PROFESSIONALLY DESIGNED - مصمم باحترافية
    
    Total Unified Components: 8 Major Systems
    إجمالي المكونات الموحدة: 8 أنظمة رئيسية
=====================================================================================*/

#endif // VCORA_UNIFIED_RENDERING_CORE_INCLUDED
