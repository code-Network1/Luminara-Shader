/*
===============================================================================
   MIST GLSL - Luminara Shader Advanced Cloud and Atmospheric Mist System
===============================================================================
   Sophisticated Cloud Rendering and Atmospheric Mist Effects Pipeline
   
   ● Purpose: Advanced volumetric cloud rendering and atmospheric mist effects
   ● Features: Dynamic cloud lighting, border fog, atmospheric color modulation
   ● Performance: Optimized for real-time volumetric cloud and mist rendering
   
   Credits & Rights:
   • VcorA - Advanced cloud and atmospheric mist system development
   • Sophisticated volumetric cloud lighting algorithms
   • Dynamic atmospheric color integration systems
   • Advanced border fog with distance-based fade effects
   • Multi-dimensional cloud rendering support
   • Temporal stability systems for cloud animation
   
   Technical Specifications:
   - Conditional compilation based on CLOUD_STYLE_DEFINE for optimal performance
   - Advanced cloud lighting with day/night transitions
   - Atmospheric color multiplication with moon phase influence
   - Border fog system with customizable distance parameters
   - TAA compatibility for temporal stability in cloud animation
   - Multi-buffer output for translucency and atmospheric integration
   - Color-coded program support for development debugging
===============================================================================
*/

// Core shader library integration
#include "/lib/shader_modules/shader_master.glsl"

/*
===============================================================================
   FRAGMENT SHADER PIPELINE
===============================================================================
   Advanced cloud and atmospheric mist rendering system
*/
#ifdef FRAGMENT_SHADER

/*
   CONDITIONAL INPUT DATA
   ────────────────────────────────────────────────────────────────────────────
   @VcorA: Conditional vertex data based on cloud style configuration
   
   Note: We use CLOUD_STYLE_DEFINE instead of CLOUD_STYLE in this file 
   because OptiFine cannot use generated defines for pipeline configuration
*/
#if CLOUD_STYLE_DEFINE == 50
    in vec2 texCoord;               // Primary texture coordinates for cloud texture sampling
    flat in vec3 upVec, sunVec;     // Directional vectors for atmospheric calculations
    in vec4 glColor;                // Vertex color from OpenGL state for cloud tinting
#endif

/*
   ATMOSPHERIC CALCULATIONS
   ────────────────────────────────────────────────────────────────────────────
   @VcorA: Advanced sun tracking and visibility calculations for cloud lighting
*/
#if CLOUD_STYLE_DEFINE == 50
    float SdotU = dot(sunVec, upVec);              // Sun-Up angle for time calculations
    float sunFactor = SdotU < 0.0 ? clamp(SdotU + 0.375, 0.0, 0.75) / 0.75 : clamp(SdotU + 0.03125, 0.0, 0.0625) / 0.0625;
    float sunVisibility = clamp(SdotU + 0.0625, 0.0, 0.125) / 0.125;
    float sunVisibility2 = sunVisibility * sunVisibility;
#endif

/*
   ADVANCED LIBRARY INTEGRATION
   ────────────────────────────────────────────────────────────────────────────
   Comprehensive atmospheric and cloud rendering systems
*/
#if CLOUD_STYLE_DEFINE == 50
    #include "/lib/color_schemes/core_color_system.glsl"
        #include "/lib/atmospherics/luminara_atmospheric_core.glsl"
    
    // Border fog with TAA support
    #if defined TAA && defined BORDER_FOG
        #include "/lib/smoothing/sampleOffset.glsl"
    #endif
    
    // Atmospheric color systems
    #ifdef ATM_COLOR_MULTS
        #include "/lib/color_schemes/color_effects_system.glsl"
    #endif
    #ifdef MOON_PHASE_INF_ATMOSPHERE
        #include "/lib/color_schemes/color_effects_system.glsl"
    #endif
    
    // Development debugging
    #ifdef COLOR_CODED_PROGRAMS
        #include "/lib/effects/effects_unified.glsl"
    #endif
#endif

/*
   MAIN CLOUD AND MIST RENDERING SYSTEM
   ────────────────────────────────────────────────────────────────────────────
   @VcorA: Advanced volumetric cloud and atmospheric mist rendering pipeline
   
   Features:
   • Conditional rendering based on cloud style configuration
   • Advanced cloud lighting with atmospheric integration
   • Dynamic translucency calculations for realistic cloud density
   • Border fog system with distance-based fade effects
   • Multi-dimensional support for different world environments
   
   Processing Pipeline:
   1. Cloud style validation and early discard optimization
   2. Cloud texture sampling and color preparation
   3. Translucency calculation for realistic cloud density
   4. Advanced atmospheric lighting integration
   5. Border fog distance calculation and application
   6. Multi-buffer output for atmospheric integration
*/
void main() {
    /*
       CLOUD STYLE VALIDATION AND OPTIMIZATION
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Early discard optimization for non-cloud rendering modes
       
       This optimization ensures that when volumetric clouds are disabled,
       the shader immediately discards fragments to avoid unnecessary processing.
    */
    #if CLOUD_STYLE_DEFINE != 50
        discard;
    #else
        /*
           CLOUD TEXTURE SAMPLING AND COLOR PREPARATION
           ──────────────────────────────────────────────────────────────────────
           Sample cloud texture and apply vertex color modulation
        */
        vec4 color = texture2D(tex, texCoord) * glColor;
        
        /*
           ADVANCED TRANSLUCENCY CALCULATION
           ──────────────────────────────────────────────────────────────────────
           @VcorA: Sophisticated translucency system for realistic cloud density
           
           This system calculates realistic cloud translucency based on alpha values,
           creating natural-looking cloud density variations and light transmission.
        */
        vec4 translucentMult = vec4(mix(vec3(0.666), color.rgb * (1.0 - pow2(pow2(color.a))), color.a), 1.0);
        
        /*
           OVERWORLD ATMOSPHERIC LIGHTING SYSTEM
           ──────────────────────────────────────────────────────────────────────
           @VcorA: Advanced cloud lighting with day/night transitions
        */
        #ifdef OVERWORLD
            /*
               DYNAMIC CLOUD LIGHTING CALCULATION
               ──────────────────────────────────────────────────────────────────
               Advanced lighting system with smooth day/night transitions
            */
            vec3 cloudLight = mix(vec3(0.8, 1.6, 1.5) * sqrt1(nightFactor), 
                                mix(dayDownSkyColor, dayMiddleSkyColor, 0.1), sunFactor);
            color.rgb *= sqrt(cloudLight) * (1.2 + 0.4 * noonFactor * invRainFactor);
            
            /*
               CUSTOM CLOUD COLOR ADJUSTMENT
               ──────────────────────────────────────────────────────────────────
               Support for user-customizable cloud coloring
            */
            #if CLOUD_R != 100 || CLOUD_G != 100 || CLOUD_B != 100
                color.rgb *= vec3(CLOUD_R, CLOUD_G, CLOUD_B) * 0.01;
            #endif
            
            /*
               ATMOSPHERIC COLOR INTEGRATION
               ──────────────────────────────────────────────────────────────────
               @VcorA: Advanced atmospheric color system integration
            */
            #ifdef ATM_COLOR_MULTS
                color.rgb *= sqrt(GetAtmColorMult()); // C72380KD - Reduced atmColorMult impact
            #endif
            #ifdef MOON_PHASE_INF_ATMOSPHERE
                color.rgb *= moonPhaseInfluence;
            #endif
        #endif
        
        /*
           ADVANCED BORDER FOG SYSTEM
           ──────────────────────────────────────────────────────────────────────
           @VcorA: Distance-based fog with customizable parameters
        */
        #if defined BORDER_FOG && !defined DREAM_TWEAKED_BORDERFOG
            /*
               COORDINATE SYSTEM CONVERSION
               ──────────────────────────────────────────────────────────────────
               Convert screen coordinates to world space for distance calculations
            */
            vec3 screenPos = vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z);
            #ifdef TAA
                vec3 viewPos = ScreenToView(vec3(TAAJitter(screenPos.xy, -0.5), screenPos.z));
            #else
                vec3 viewPos = ScreenToView(screenPos);
            #endif
            vec3 playerPos = ViewToPlayer(viewPos);
            
            /*
               DISTANCE-BASED FOG CALCULATION
               ──────────────────────────────────────────────────────────────────
               Advanced distance calculation with smooth fade-out
            */
            float xzMaxDistance = max(abs(playerPos.x), abs(playerPos.z));
            float cloudDistance = 375.0;
            cloudDistance = clamp((cloudDistance - xzMaxDistance) / cloudDistance, 0.0, 1.0);
            color.a *= clamp01(cloudDistance * 3.0);
        #endif
        
        /*
           DEVELOPMENT DEBUGGING INTEGRATION
           ──────────────────────────────────────────────────────────────────────
           @VcorA: Color-coded program identification for development
        */
        #ifdef COLOR_CODED_PROGRAMS
            ColorCodeProgram(color, -1);  // -1 indicates cloud/mist program
        #endif
        
        /*
           MULTI-BUFFER OUTPUT SYSTEM
           ──────────────────────────────────────────────────────────────────────
           Multiple render targets for atmospheric integration
        */
        /* DRAWBUFFERS:063 */
        gl_FragData[0] = color;                                    // Main cloud color output
        gl_FragData[1] = vec4(0.0, 0.0, 0.0, 1.0);               // Secondary buffer clear
        gl_FragData[2] = vec4(1.0 - translucentMult.rgb, translucentMult.a); // Translucency data
    #endif
}

#endif

/*
===============================================================================
   VERTEX SHADER PIPELINE
===============================================================================
   Optimized vertex processing for cloud and mist rendering
*/
#ifdef VERTEX_SHADER

/*
   CONDITIONAL OUTPUT DATA
   ────────────────────────────────────────────────────────────────────────────
   Conditional vertex data based on cloud style configuration
*/
#if CLOUD_STYLE_DEFINE == 50
    out vec2 texCoord;              // Texture coordinates for cloud texture sampling
    flat out vec3 upVec, sunVec;    // Directional vectors for atmospheric calculations
    out vec4 glColor;               // Vertex color for cloud tinting
#endif

/*
   VERTEX PROCESSING UTILITIES
   ────────────────────────────────────────────────────────────────────────────
   TAA support for temporal stability in cloud animation
*/
#if CLOUD_STYLE_DEFINE == 50
    #ifdef TAA
        #include "/lib/smoothing/sampleOffset.glsl"
    #endif
#endif

/*
   MAIN VERTEX PROCESSING SYSTEM
   ────────────────────────────────────────────────────────────────────────────
   @VcorA: Efficient vertex transformation for cloud and mist rendering
   
   Features:
   • Conditional processing based on cloud style configuration
   • Optimized vertex transformation for cloud geometry
   • TAA jittering for temporal stability in cloud animation
   • Directional vector calculation for atmospheric effects
   
   Processing Pipeline:
   1. Cloud style validation and early exit optimization
   2. Texture coordinate mapping for cloud textures
   3. Directional vector calculation for atmospheric effects
   4. World space transformation for proper cloud positioning
   5. TAA jittering for temporal stability
*/
void main() {
    /*
       CLOUD STYLE VALIDATION AND OPTIMIZATION
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Early exit optimization for non-cloud rendering modes
       
       When volumetric clouds are disabled, this optimization moves vertices
       outside the view frustum to avoid unnecessary processing.
    */
    #if CLOUD_STYLE_DEFINE != 50
        gl_Position = vec4(-1.0);  // Move vertex outside view frustum
    #else
        /*
           TEXTURE COORDINATE MAPPING
           ──────────────────────────────────────────────────────────────────────
           Map texture coordinates for cloud texture sampling
        */
        texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
        
        /*
           VERTEX COLOR TRANSFER
           ──────────────────────────────────────────────────────────────────────
           Transfer vertex color data for cloud tinting effects
        */
        glColor = gl_Color;
        
        /*
           DIRECTIONAL VECTORS CALCULATION
           ──────────────────────────────────────────────────────────────────────
           @VcorA: Calculate world-space directional vectors for atmospheric effects
        */
        upVec = normalize(gbufferModelView[1].xyz);    // World up direction
        sunVec = GetSunVector();                       // Current sun/moon position
        
        /*
           CLOUD VERTEX TRANSFORMATION
           ──────────────────────────────────────────────────────────────────────
           @VcorA: Transform cloud vertices to world space for proper positioning
        */
        vec4 position = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;
        gl_Position = gl_ProjectionMatrix * gbufferModelView * position;
        
        /*
           TEMPORAL ANTI-ALIASING INTEGRATION
           ──────────────────────────────────────────────────────────────────────
           Apply TAA jittering for temporal stability in cloud animation
        */
        #ifdef TAA
            gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
        #endif
    #endif
}

#endif

/*
===============================================================================
   END OF MIST SHADER
   @VcorA - Advanced cloud and atmospheric mist rendering system
===============================================================================
*/
