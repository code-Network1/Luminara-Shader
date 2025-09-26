// Luminara Shader - Enhanced Glowing Flowers System
// Only bright, colorful flowers (NO GRASS of any kind)

#ifdef GBUFFERS_TERRAIN
    DoFoliageColorTweaks(color.rgb, shadowMult, snowMinNdotU, viewPos, nViewPos, lViewPos, dither);

    #ifdef COATED_TEXTURES
        doTileRandomisation = false;
    #endif
#endif

// Double-check: Exclude anything that looks like typical grass
bool hasStrongGreenDominance = (color.g > 0.35 && color.g > color.r * 1.2 && color.g > color.b * 1.2);
if (hasStrongGreenDominance) {
    // This looks like grass, skip flower effects
    materialMask = 0.0;
} else {
    // Enhanced flower lighting system - more inclusive
    float brightness = dot(color.rgb, vec3(0.299, 0.587, 0.114));

    // More inclusive flower color detection
    if (color.r > color.g + 0.1 && color.r > color.b + 0.1 && color.r > 0.4) {
        // Red flowers (Rose, Poppy, Red Tulip) - more inclusive
        emission = 1.5 + brightness * 1.2;
        color.rgb *= vec3(1.08, 0.95, 0.92);
    } else if (color.b > color.r + 0.1 && color.b > color.g + 0.1 && color.b > 0.4) {
        // Blue flowers (Cornflower, Blue Orchid) - more inclusive
        emission = 1.6 + brightness * 1.3;
        color.rgb *= vec3(0.92, 0.95, 1.1);
    } else if (color.r > 0.6 && color.g > 0.6 && color.b < 0.4) {
        // Yellow flowers (Dandelion, Sunflower) - more inclusive
        emission = 1.8 + brightness * 1.5;
        color.rgb *= vec3(1.1, 1.08, 0.9);
    } else if (color.r > 0.5 && color.g < 0.35 && color.b > 0.5) {
        // Purple/Magenta flowers (Allium, Purple Tulip) - more inclusive
        emission = 1.5 + brightness * 1.2;
        color.rgb *= vec3(1.08, 0.92, 1.08);
    } else if (color.r > 0.6 && color.g > 0.45 && color.b < 0.35) {
        // Orange flowers (Orange Tulip) - more inclusive
        emission = 1.7 + brightness * 1.4;
        color.rgb *= vec3(1.1, 1.05, 0.9);
    } else if (color.r > 0.7 && color.g > 0.7 && color.b > 0.7) {
        // White flowers (White Tulip, Oxeye Daisy) - more inclusive
        emission = 1.4 + brightness * 1.1;
        color.rgb *= vec3(1.04, 1.04, 1.04);
    } else if (color.r > 0.6 && color.g > 0.4 && color.b > 0.6) {
        // Pink flowers (Pink Tulip) - more inclusive
        emission = 1.3 + brightness * 1.0;
        color.rgb *= vec3(1.05, 0.98, 1.02);
    } else if (brightness > 0.4 && max(max(color.r, color.g), color.b) > 0.5) {
        // Catch other colorful flowers that might be missed
        emission = 1.0 + brightness * 0.8;
        color.rgb *= vec3(1.02, 1.02, 1.02);
    } else {
        // No clear flower pattern detected
        emission = 0.0;
    }

    // Only apply effects if we detected a clear flower
    if (emission > 0.0) {
        // Add subtle time-based flickering
        vec3 worldPosFlower = playerPos + cameraPosition;
        float timeNoise = sin(frameTimeCounter * 1.5 + dot(worldPosFlower.xz, vec2(12.9898, 78.233))) * 0.5 + 0.5;
        timeNoise = timeNoise * 0.08 + 0.92; // Very gentle flickering (reduced from 0.12)
        emission *= timeNoise;

        // Modest night enhancement
        float timeOfDay = sunAngle;
        float isNight = float(timeOfDay > 0.52 && timeOfDay < 0.98);
        float nightFactor = 1.0 + isNight * 0.3; // Reduced from 0.6
        emission *= nightFactor;

        // Distance-based brightness adjustment
        float distanceFactor = 1.0 - min(lViewPos / 64.0, 0.5);
        emission *= (0.6 + 0.4 * distanceFactor); // Slightly reduced base

        materialMask = 0.0; // No SSAO for glowing flowers
    }
}
