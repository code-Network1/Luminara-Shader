

#ifndef EminGT_UNIFIED_RENDERING_CORE_INCLUDED
#define EminGT_UNIFIED_RENDERING_CORE_INCLUDED


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


const bool colortex0Clear = true;
const bool colortex7Clear = false;
const bool colortex3Clear = true;
const bool colortex1Clear = false;
const bool colortex6Clear = true;
const bool colortex2Clear = false;
const bool colortex4Clear = false;
const bool colortex5Clear = false;


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


const int noiseTextureResolution = 128;


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


const float drynessHalflife = 300.0;
const float wetnessHalflife = 300.0;


uniform ivec2 atlasSize;
uniform ivec2 eyeBrightness;

uniform vec3 relativeEyePosition;
uniform vec3 cameraPosition;
uniform vec3 skyColor;
uniform vec3 fogColor;
uniform vec3 previousCameraPosition;

uniform vec4 entityColor;
uniform vec4 lightningBoltPosition;


const bool shadowHardwareFiltering = true;
const float shadowDistanceRenderMul = 1.0;
const float entityShadowDistanceMul = 0.125; // Iris feature


const float ambientOcclusionLevel = 1.0;


uniform mat4 gbufferModelView;
uniform mat4 shadowModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowProjectionInverse;
uniform mat4 gbufferPreviousModelView;
uniform mat4 shadowModelViewInverse;
uniform mat4 gbufferPreviousProjection;
uniform mat4 shadowProjection;


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


uniform ivec3 cameraPositionInt;
uniform ivec3 previousCameraPositionInt;
uniform vec3 cameraPositionFract;
uniform vec3 previousCameraPositionFract;


#ifdef IS_IRIS
    uniform int renderStage;
#endif


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


#if !defined DH_TERRAIN && !defined DH_WATER
    uniform mat4 gbufferProjection;
    uniform mat4 gbufferProjectionInverse;
#endif


#ifdef DISTANT_HORIZONS
    uniform int dhRenderDistance;

    uniform mat4 dhProjection;
    uniform mat4 dhProjectionInverse;
    
    uniform sampler2D dhDepthTex;
    uniform sampler2D dhDepthTex1;
#endif


#if COLORED_LIGHTING_INTERNAL > 0
    uniform usampler3D voxel_sampler;
    uniform sampler3D floodfill_sampler;
    uniform sampler3D floodfill_sampler_copy;
#endif


#ifdef PUDDLE_VOXELIZATION
    uniform usampler2D puddle_sampler;
#endif



#endif // EminGT_UNIFIED_RENDERING_CORE_INCLUDED
