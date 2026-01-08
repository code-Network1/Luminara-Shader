subsurfaceMode = 2;

#ifdef GBUFFERS_TERRAIN
    materialMask = OSIEBCA * 253.0; // Reduced Edge TAA

    #ifdef COATED_TEXTURES
        doTileRandomisation = false;
    #endif
#endif

#ifdef IPBR
    float factor = min1(pow2(color.g - 0.15 * (color.r + color.b)) * 2.5);
    smoothnessG = factor * 0.4;
    highlightMult = factor * 4.0 + 2.0;
    float fresnel = clamp(1.0 + dot(normalM, normalize(viewPos)), 0.0, 1.0);
    highlightMult *= 1.0 - pow2(pow2(fresnel));
#endif

// Luminara Shader: Firefly effect on leaves disabled to remove floating glowing elements
/*
// Add subtle firefly-like glow to leaves at night
#ifdef OVERWORLD
    float timeOfDay = sunAngle;
    float isNight = float(timeOfDay > 0.52 && timeOfDay < 0.98); // Night time
    
    // Create subtle random glow pattern for fireflies on leaves
    vec3 worldPos = playerPos + cameraPosition;
    float fireflyNoise = fract(sin(dot(floor(worldPos * 0.5), vec3(12.9898, 78.233, 45.164))) * 43758.5453);
    float fireflyChance = fireflyNoise * fireflyNoise; // Make it rarer
    
    if (fireflyChance > 0.85 && isNight > 0.5) { // Only on some leaves at night
        float flickerTime = syncedTime * 3.0 + fireflyNoise * 10.0;
        float flicker = 0.5 + 0.5 * sin(flickerTime) * sin(flickerTime * 1.7);
        
        // Subtle yellow-green firefly glow
        emission = flicker * 0.08 * (1.0 - sunFactor); // Very subtle glow
        color.rgb = mix(color.rgb, vec3(1.2, 1.4, 0.8), emission * 0.3);
    }
#endif
*/

#ifdef SNOWY_WORLD
    snowMinNdotU = min(pow2(pow2(color.g)), 0.1);
    color.rgb = color.rgb * 0.5 + 0.5 * (color.rgb / glColor.rgb);
#endif

#if SHADOW_QUALITY > -1 && SHADOW_QUALITY < 3 && defined OVERWORLD
    shadowMult = vec3(sqrt1(max0(max(lmCoordM.y, min1(lmCoordM.x * 2.0)) - 0.95) * 20.0));
#endif
