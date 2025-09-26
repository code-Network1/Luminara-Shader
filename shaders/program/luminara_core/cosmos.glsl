/*
===============================================================================
   COSMOS GLSL - Luminara Shader Celestial System
===============================================================================
   Advanced Sky and Celestial Object Rendering
   
   ● Purpose: Comprehensive sky rendering with sun, moon, and planetary objects
   ● Features: Multi-dimensional support, Ad Astra compatibility, dynamic lighting
   ● Compatibility: Overworld, Nether, End dimensions with unique sky systems
   
   Credits & Rights:
   • VcorA - Advanced celestial rendering system development
   • Dynamic sun/moon lighting algorithms
   • Multi-dimensional sky color systems
   • Ad Astra planetary compatibility integration
   
   Technical Features:
   - Iris shader compatibility with render stage detection
   - Adaptive celestial object lighting based on world type
   - Advanced rain and weather effects on sky visibility
   - Underwater sky color adjustment
   - Cave fog integration for realistic underground lighting
   - Custom skybox support for modded dimensions
===============================================================================
*/

// Essential library integration for sky rendering
#include "/lib/shader_modules/shader_master.glsl"

/*
===============================================================================
   FRAGMENT SHADER PIPELINE
===============================================================================
   Advanced sky fragment processing with celestial object rendering
*/
#ifdef FRAGMENT_SHADER

/*
   INPUT VERTEX DATA
   ────────────────────────────────────────────────────────────────────────────
   Sky rendering vertex data from vertex shader
*/
in vec2 texCoord;        // Texture coordinates for sky objects
flat in vec4 glColor;    // Vertex color from OpenGL state

// Overworld-specific directional data for sun/moon calculations
#ifdef OVERWORLD
    flat in vec3 upVec, sunVec; // World up and sun direction vectors
#endif

/*
   OVERWORLD ATMOSPHERIC CALCULATIONS
   ────────────────────────────────────────────────────────────────────────────
   @VcorA: Advanced sun visibility and atmospheric transition system
*/
#ifdef OVERWORLD
    float SdotU = dot(sunVec, upVec);      // Sun-Up angle for time calculations
    
    // Dynamic sun visibility with smooth day/night transitions
    float sunFactor = SdotU < 0.0 ? clamp(SdotU + 0.375, 0.0, 0.75) / 0.75 : clamp(SdotU + 0.03125, 0.0, 0.0625) / 0.0625;
    float sunVisibility = clamp(SdotU + 0.0625, 0.0, 0.125) / 0.125;
    float sunVisibility2 = sunVisibility * sunVisibility; // Quadratic falloff for smooth transitions
#endif

/*
   SPECIALIZED RENDERING SYSTEMS
   ────────────────────────────────────────────────────────────────────────────
   Color schemes, cave fog, and debugging utilities
*/
#include "/lib/color_schemes/core_color_system.glsl"

// Underground atmosphere effects
#ifdef CAVE_FOG
    #include "/lib/atmospherics/particles/depthFactor.glsl"
#endif

// Development debugging system
#ifdef COLOR_CODED_PROGRAMS
    #include "/lib/effects/effects_unified.glsl"
#endif

/*
   MAIN FRAGMENT PROCESSING
   ────────────────────────────────────────────────────────────────────────────
   @VcorA: Universal sky rendering with multi-dimensional support
   
   Sky System Features:
   • Overworld: Dynamic sun/moon with atmospheric effects
   • Nether: Transparent sky for void rendering
   • End: Custom End sky color system
*/
void main() {
    /*
       OVERWORLD SKY SYSTEM
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Advanced celestial object rendering with atmospheric integration
    */
    #ifdef OVERWORLD
        vec2 tSize = textureSize(tex, 0);              // Texture size for object identification
        vec4 color = texture2D(tex, texCoord);         // Sample sky texture
        color.rgb *= glColor.rgb;                      // Apply vertex coloring
        
        /*
           CELESTIAL OBJECT LIGHTING SYSTEM
           ──────────────────────────────────────────────────────────────────────
           Skip lighting calculations for unlit sky objects mode
        */
        #ifndef UNLIT_SKY_OBJECTS
        
        /*
           COORDINATE SYSTEM SETUP
           ──────────────────────────────────────────────────────────────────────
           Convert screen coordinates to view space for directional calculations
        */
        vec4 screenPos = vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z, 1.0);
        vec4 viewPos = gbufferProjectionInverse * (screenPos * 2.0 - 1.0);
        viewPos /= viewPos.w;
        vec3 nViewPos = normalize(viewPos.xyz);
        
        // Calculate viewing angles for atmospheric effects
        float VdotS = dot(nViewPos, sunVec);  // View-Sun angle for brightness
        float VdotU = dot(nViewPos, upVec);   // View-Up angle for horizon effects
        
        /*
           CELESTIAL OBJECT IDENTIFICATION
           ──────────────────────────────────────────────────────────────────────
           @VcorA: Robust sun/moon detection system with Iris compatibility
           
           Detection Methods:
           • Iris: Use render stage detection for precise identification
           • OptiFine: Use texture size and viewing angle analysis
        */
        #ifdef IS_IRIS
            bool isSun = renderStage == MC_RENDER_STAGE_SUN;
            bool isMoon = renderStage == MC_RENDER_STAGE_MOON;
        #else
            bool tSizeCheck = abs(tSize.y - 264.0) < 248.5;    // Texture size range: 16-512
            bool sunSideCheck = VdotS > 0.0;                   // Sun-facing check
            bool isSun = tSizeCheck && sunSideCheck;           // Sun identification
            bool isMoon = tSizeCheck && !sunSideCheck;         // Moon identification
        #endif
        
        /*
           SUN AND MOON RENDERING
           ──────────────────────────────────────────────────────────────────────
           @VcorA: Advanced celestial lighting with world-specific adaptations
        */
        if (isSun || isMoon) {
            // Preserve vanilla sun/moon appearance for consistency
            // Future customization options commented for reference:
            // #if SUN_MOON_STYLE >= 2
            //     discard;
            // #endif
            
            /*
               SUN LIGHTING SYSTEM
               ──────────────────────────────────────────────────────────────────
               Dynamic sun lighting with world-specific color adaptation
            */
            if (isSun) {
                #if defined(WORLD_MOON) || defined(WORLD_MARS) || defined(WORLD_MERCURY) || defined(WORLD_GLACIO) || defined(AD_ASTRA_ORBIT)
                    /*
                       AD ASTRA WORLD COMPATIBILITY
                       ──────────────────────────────────────────────────────────
                       @VcorA: Specialized sun lighting for space and planetary environments
                       
                       Features bright, consistent sun color for:
                       • Moon bases with Earth view
                       • Mars surface with reddish atmosphere
                       • Mercury's harsh solar conditions
                       • Glacio's frozen landscapes
                       • Orbital space stations
                    */
                    vec3 sunLightColor = vec3(1.0, 0.95, 0.85); // Bright warm sun color
                    color.rgb *= dot(color.rgb, color.rgb) * sunLightColor * 3.2;
                #else
                    // Standard Overworld sun lighting with dynamic color
                    color.rgb *= dot(color.rgb, color.rgb) * normalize(lightColor) * 3.2;
                #endif
                
                // Apply atmospheric visibility with rain factor consideration
                color.rgb *= 0.25 + (0.75 - 0.25 * rainFactor) * sunVisibility2;
            }
            
            /*
               MOON LIGHTING SYSTEM
               ──────────────────────────────────────────────────────────────────
               Realistic moon rendering with luminance-based brightness
            */
            if (isMoon) {
                color.rgb *= smoothstep1(min1(length(color.rgb))) * 1.3;
            }
            
            /*
               HORIZON ATMOSPHERIC EFFECTS
               ──────────────────────────────────────────────────────────────────
               Apply horizon-based color shifts and atmospheric scattering
            */
            color.rgb *= GetHorizonFactor(VdotU);
            
            /*
               UNDERGROUND VISIBILITY ADJUSTMENT
               ──────────────────────────────────────────────────────────────────
               Reduce celestial visibility in caves and underground areas
            */
            #ifdef CAVE_FOG
                color.rgb *= 1.0 - 0.75 * GetCaveFactor();
            #endif
            
        } else {
            /*
               CUSTOM SKY OBJECTS
               ──────────────────────────────────────────────────────────────────
               @VcorA: Support for modded skyboxes and celestial objects
            */
            #if MC_VERSION >= 11300
                /*
                   MODERN MINECRAFT COMPATIBILITY
                   ──────────────────────────────────────────────────────────────
                   Enhanced rendering for newer Minecraft versions
                   
                   Features:
                   • Ad Astra planet preservation with balanced lighting
                   • Earth view from space without excessive darkening
                   • Color enhancement for distant celestial objects
                */
                color.rgb *= vec3(1.5, 1.5, 1.2); // Enhanced celestial object visibility
            #else
                /*
                   LEGACY VERSION HANDLING
                   ──────────────────────────────────────────────────────────────
                   Discard problematic custom skyboxes in older versions
                   due to rendering inconsistencies
                */
                discard;
            #endif
        }
        
        /*
           ENVIRONMENTAL EFFECTS
           ──────────────────────────────────────────────────────────────────────
           Apply underwater and weather effects to sky visibility
        */
        
        // Underwater sky color adjustment
        if (isEyeInWater == 1) color.rgb *= 0.25;
        
        // Weather-based sky visibility
        #ifdef SUN_MOON_DURING_RAIN
            color.a *= 1.0 - 0.8 * rainFactor;  // Partial visibility during rain
        #else
            color.a *= 1.0 - rainFactor;        // Complete hiding during rain
        #endif
        
        #endif // UNLIT_SKY_OBJECTS
    #endif // OVERWORLD
    
    /*
       NETHER DIMENSION SKY
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Transparent sky system for Nether void rendering
       
       The Nether uses a transparent sky to allow proper void rendering
       and maintain the characteristic dark atmosphere
    */
    #ifdef NETHER
        vec4 color = vec4(0.0); // Completely transparent
    #endif
    
    /*
       END DIMENSION SKY
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Custom End sky color system
       
       Uses predefined End sky color for consistent atmospheric appearance
       that matches the End's unique visual style
    */
    #ifdef END
        vec4 color = vec4(endSkyColor, 1.0); // Solid End sky color
    #endif
    
    // Development debugging system integration
    #ifdef COLOR_CODED_PROGRAMS
        ColorCodeProgram(color, -1);
    #endif
    
    /*
       OUTPUT BUFFER ASSIGNMENT
       ──────────────────────────────────────────────────────────────────────────
       Single color output for sky rendering
    */
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = color;
}

#endif

/*
===============================================================================
   VERTEX SHADER PIPELINE
===============================================================================
   Sky vertex processing with directional vector calculation
*/
#ifdef VERTEX_SHADER

/*
   OUTPUT DATA TO FRAGMENT SHADER
   ────────────────────────────────────────────────────────────────────────────
   Sky rendering vertex data for fragment processing
*/
out vec2 texCoord;       // Texture coordinates for sky objects
flat out vec4 glColor;   // Vertex color from OpenGL state

// Overworld-specific directional vectors for atmospheric calculations
#ifdef OVERWORLD
    flat out vec3 upVec, sunVec; // World up and sun direction vectors
#endif

/*
   MAIN VERTEX PROCESSING
   ────────────────────────────────────────────────────────────────────────────
   @VcorA: Optimized sky vertex transformation
   
   Features:
   • Standard vertex transformation for sky geometry
   • Texture coordinate mapping for celestial objects
   • Directional vector calculation for atmospheric effects
*/
void main() {
    /*
       VERTEX TRANSFORMATION
       ──────────────────────────────────────────────────────────────────────────
       Standard sky geometry transformation
    */
    gl_Position = ftransform();
    
    /*
       TEXTURE COORDINATE SETUP
       ──────────────────────────────────────────────────────────────────────────
       Map texture coordinates for sky objects (sun, moon, stars)
    */
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    
    /*
       COLOR DATA TRANSFER
       ──────────────────────────────────────────────────────────────────────────
       Pass vertex color to fragment shader
    */
    glColor = gl_Color;
    
    /*
       OVERWORLD DIRECTIONAL VECTOR SETUP
       ──────────────────────────────────────────────────────────────────────────
       @VcorA: Calculate world-space directional vectors for atmospheric effects
       
       These vectors are essential for:
       • Sun position tracking and lighting calculations
       • Atmospheric scattering and horizon effects
       • Day/night cycle transitions
       • Weather effect integration
    */
    #ifdef OVERWORLD
        upVec = normalize(gbufferModelView[1].xyz);  // World up direction
        sunVec = GetSunVector();                     // Current sun/moon position
    #endif
}

#endif

/*
===============================================================================
   END OF COSMOS SHADER
   @VcorA - Advanced celestial rendering system with multi-dimensional support
===============================================================================
*/
