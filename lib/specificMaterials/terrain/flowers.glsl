// Luminara Shader - Enhanced Glowing Flowers System v2.1
// Only bright, colorful flowers (NO GRASS of any kind) - Fixed max() usage

#ifdef GBUFFERS_TERRAIN
    DoFoliageColorTweaks(color.rgb, shadowMult, snowMinNdotU, viewPos, nViewPos, lViewPos, dither);

    #ifdef COATED_TEXTURES
        doTileRandomisation = false;
    #endif
#endif

// BALANCED GRASS EXCLUSION SYSTEM - exclude grass but allow flowers
bool hasStrongGreenDominance = (color.g > 0.35 && color.g > color.r * 1.2 && color.g > color.b * 1.2);
bool isGrassyTexture = (color.g > 0.3 && color.g > color.r * 1.1 && color.g > color.b * 1.1 && dot(color.rgb, vec3(0.299, 0.587, 0.114)) < 0.6);
bool hasGrassPattern = (color.r < 0.55 && color.b < 0.55 && color.g > 0.35);
bool isLowSaturation = (abs(color.r - color.g) < 0.12 && abs(color.g - color.b) < 0.12 && color.g > 0.3 && max(max(color.r, color.g), color.b) < 0.7);
bool isTallGrass = (color.g > 0.4 && max(color.r, color.b) < color.g * 0.85);
bool isShortGrass = (color.g > 0.32 && color.g < 0.65 && color.r < 0.6 && color.b < 0.6);

// SAVANNA BIOME SPECIFIC GRASS DETECTION - more precise to avoid excluding flowers
bool isSavannaGrass = (color.r > 0.25 && color.g > 0.25 && color.b < 0.35 && abs(color.r - color.g) < 0.15 && max(color.r, color.g) < 0.65);
bool isDriedGrass = (color.r > color.b * 1.2 && color.g > color.b * 1.2 && color.b < 0.4 && max(color.r, color.g) < 0.7 && abs(color.r - color.g) < 0.12);
bool isBrownishGrass = (color.r > 0.25 && color.g > 0.25 && color.r + color.g > color.b * 3.0 && color.b < 0.3 && max(color.r, color.g) < 0.6);
bool isYellowishGrass = (color.r > 0.3 && color.g > 0.3 && color.b < 0.25 && abs(color.r - color.g) < 0.1 && max(color.r, color.g) < 0.65);

// Multiple grass detection criteria - if ANY matches, skip flower effects COMPLETELY
if (hasStrongGreenDominance || isGrassyTexture || hasGrassPattern || isLowSaturation || isTallGrass || isShortGrass || 
    isSavannaGrass || isDriedGrass || isBrownishGrass || isYellowishGrass) {
    // This looks like grass of ANY type (including Savanna grass) - NO GLOWING EFFECTS AT ALL
    materialMask = 0.0;
    emission = 0.0;
    // Early return to prevent any flower processing
} else {
    // Enhanced flower lighting system - more inclusive
    float brightness = dot(color.rgb, vec3(0.299, 0.587, 0.114));

    // More inclusive flower color detection - but ONLY for actual flowers
    // Final grass check: must have strong color saturation to be considered a flower
    float colorSaturation = max(max(color.r, color.g), color.b) - min(min(color.r, color.g), color.b);
    
    if (colorSaturation > 0.12 && color.r > color.g + 0.08 && color.r > color.b + 0.08 && color.r > 0.35) {
        // Red flowers (Rose, Poppy, Red Tulip) - more inclusive
        emission = 1.5 + brightness * 1.2;
        color.rgb *= vec3(1.08, 0.95, 0.92);
    } else if (colorSaturation > 0.12 && color.b > color.r + 0.08 && color.b > color.g + 0.08 && color.b > 0.35) {
        // Blue flowers (Cornflower, Blue Orchid) - more inclusive
        emission = 1.6 + brightness * 1.3;
        color.rgb *= vec3(0.92, 0.95, 1.1);
    } else if (color.r > 0.5 && color.g > 0.5 && color.b < 0.45) {
        // Yellow flowers (Dandelion, Sunflower) - more inclusive, exclude only clear grass
        bool isDefinitelyGrass = (abs(color.r - color.g) < 0.1 && max(color.r, color.g) < 0.65 && color.b > 0.25);
        if (!isDefinitelyGrass) {
            emission = 1.8 + brightness * 1.5;
            color.rgb *= vec3(1.1, 1.08, 0.9);
        }
    } else if (colorSaturation > 0.18 && color.r > 0.5 && color.g < 0.35 && color.b > 0.5) {
        // Purple/Magenta flowers (Allium, Purple Tulip) - more inclusive
        emission = 1.5 + brightness * 1.2;
        color.rgb *= vec3(1.08, 0.92, 1.08);
    } else if (colorSaturation > 0.12 && color.r > 0.55 && color.g > 0.4 && color.b < 0.4) {
        // Orange flowers (Orange Tulip) - exclude only very clear grass colors
        bool isDefinitelyDriedGrass = (abs(color.r - color.g) < 0.08 && max(color.r, color.g) < 0.6 && color.b < 0.3);
        if (!isDefinitelyDriedGrass) {
            emission = 1.7 + brightness * 1.4;
            color.rgb *= vec3(1.1, 1.05, 0.9);
        }
    } else if (color.r > 0.65 && color.g > 0.65 && color.b > 0.65) {
        // White flowers (White Tulip, Oxeye Daisy) - very inclusive for white colors
        emission = 1.4 + brightness * 1.1;
        color.rgb *= vec3(1.04, 1.04, 1.04);
    } else if (colorSaturation > 0.15 && color.r > 0.6 && color.g > 0.4 && color.b > 0.6) {
        // Pink flowers (Pink Tulip) - more inclusive
        emission = 1.3 + brightness * 1.0;
        color.rgb *= vec3(1.05, 0.98, 1.02);
    } else if (colorSaturation > 0.12 && brightness > 0.35 && max(max(color.r, color.g), color.b) > 0.45) {
        // Catch other colorful flowers that might be missed - more inclusive
        emission = 1.0 + brightness * 0.8;
        color.rgb *= vec3(1.02, 1.02, 1.02);
    } else {
        // Special case: Small or pale flowers that might be missed
        bool isPaleFlower = (brightness > 0.5 && colorSaturation > 0.08 && max(max(color.r, color.g), color.b) > 0.6);
        bool isSmallColorfulPatch = (colorSaturation > 0.1 && brightness > 0.4);
        
        if (isPaleFlower || isSmallColorfulPatch) {
            // Very gentle glow for subtle flowers
            emission = 0.8 + brightness * 0.6;
            color.rgb *= vec3(1.02, 1.02, 1.02);
        } else {
            // No clear flower pattern detected
            emission = 0.0;
        }
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
