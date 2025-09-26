// Luminara Shader - Enhanced Grass and Small Flowers System
// DISABLED: User requested no glowing tall grass

// Luminara Shader: Tall grass glow effects disabled per user request
/*
// Subtle glowing effects for grass with flowers (EXCLUDING short grass)

// Check for small colorful patches that might be small flowers in grass
float grassBrightness = dot(color.rgb, vec3(0.299, 0.587, 0.114));
vec3 colorDiff = abs(color.rgb - vec3(grassBrightness));
float colorVariation = max(colorDiff.r, max(colorDiff.g, colorDiff.b));

// Exclude short grass - only apply to plants with significant color variation
// AND avoid typical grass colors (green-dominant with low saturation)
bool isTypicalGrass = (color.g > color.r * 1.1 && color.g > color.b * 1.1 && grassBrightness < 0.6);

// If there's significant color variation AND it's not typical green grass, it might be flowers mixed with grass
if (colorVariation > 0.12 && grassBrightness > 0.25 && !isTypicalGrass) {
    // Small flower detection in grass - more strict criteria
    if (color.r > color.g * 1.3 && color.r > 0.45) {
        // Red/Pink flowers in grass - bright and saturated
        emission = 0.8 + grassBrightness * 1.0;
        color.rgb *= vec3(1.05, 0.98, 0.95);
    } else if (color.b > color.r * 1.4 && color.b > 0.45) {
        // Blue flowers in grass - bright and saturated
        emission = 0.9 + grassBrightness * 1.2;
        color.rgb *= vec3(0.95, 0.98, 1.08);
    } else if (color.r > 0.65 && color.g > 0.65 && color.b < 0.35) {
        // Yellow flowers in grass - bright yellow, not green
        emission = 1.1 + grassBrightness * 1.5;
        color.rgb *= vec3(1.08, 1.05, 0.92);
    } else if (color.r > 0.75 && color.g > 0.75 && color.b > 0.75) {
        // White flowers in grass - very bright
        emission = 0.7 + grassBrightness * 0.8;
        color.rgb *= vec3(1.02, 1.02, 1.02);
    }
    
    // Only add effects if emission was actually set (meaning a flower was detected)
    if (emission > 0.0) {
        // Add subtle time variation
        vec3 worldPosGrass = playerPos + cameraPosition;
        float timeVar = sin(frameTimeCounter * 1.5 + dot(worldPosGrass.xz, vec2(7.54, 15.87))) * 0.5 + 0.5;
        emission *= (0.9 + 0.1 * timeVar);
        
        // Reduce at distance
        emission *= max(0.3, 1.0 - lViewPos / 48.0);
        
        materialMask = 0.0;
    }
}
*/
