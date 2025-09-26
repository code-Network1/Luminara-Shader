/**
 * ═══════════════════════════════════════════════════════════════════════════════════════
 *                              LUMINARA SHADER - BLOCK LIGHT SYSTEM
 *                          Enhanced & Optimized Color Management System
 * ═══════════════════════════════════════════════════════════════════════════════════════
 * 
 * Comprehensive block lighting and material color system for Minecraft shaders.
 * Provides specialized lighting for different block types with precise color handling.
 * 
 * Features:
 * - Dynamic block-specific light colors
 * - Material-based special effects
 * - Candle lighting system with color variants
 * - Advanced tinting for special materials
 * - Optimized color calculations
 * 
 * Enhanced by VcorA - Part of Luminara Shader Pack
 * ═══════════════════════════════════════════════════════════════════════════════════════
 */

// ═══════════════════════════════════════════════════════════════════════════════════════
//                              CORE LIGHTING CONFIGURATION
// ═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Base blocklight color - Foundation for all block lighting calculations
 * Uses custom RGB multipliers for fine-tuned lighting balance
 */
const vec3 blocklightCol = vec3(0.1775, 0.108, 0.0775) * vec3(XLIGHT_R, XLIGHT_G, XLIGHT_B);

// ═══════════════════════════════════════════════════════════════════════════════════════
//                            SPECIALIZED LIGHT COLOR DEFINITIONS
// ═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Fire and Heat-based Light Sources
 * Optimized for realistic flame and heat representation
 */
const vec3 fireSpecialLightColor = vec3(2.05, 0.83, 0.27) * 3.8;     // Warm orange flame
const vec3 lavaSpecialLightColor = vec3(3.0, 0.9, 0.2) * 4.0;       // Bright molten orange
const vec4 soulFireSpecialColor = vec4(vec3(0.3, 2.0, 2.2), 0.3);   // Cool blue soul fire

/**
 * Magical and Portal Light Sources
 * Enhanced mystical lighting effects
 */
const vec3 netherPortalSpecialLightColor = vec3(2.5, 2.0, 0.6) * 0.8;  // Golden portal light
const vec3 redstoneSpecialLightColor = vec3(4.0, 0.1, 0.1);            // Bright redstone glow

/**
 * Candle Lighting Configuration
 * Unified settings for all candle types
 */
const float candleColorMult = 2.0;     // Global candle color multiplier
const float candleExtraLight = 0.004;  // Additional light emission for candles

// ═══════════════════════════════════════════════════════════════════════════════════════
//                              ENHANCED LIGHTING FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Advanced Special Light Detail Enhancement
 * Applies sophisticated lighting detail to improve overall visual quality
 * 
 * @param light     - Input/output light color vector (modified in place)
 * @param albedo    - Surface material albedo color
 * @param emission  - Material emission factor (0.0 = no emission, 1.0 = full emission)
 * 
 * Algorithm:
 * 1. Clamps light to positive values
 * 2. Applies tone mapping to prevent oversaturation
 * 3. Balances emission influence
 * 4. Enhances detail through albedo interaction
 */
void AddSpecialLightDetail(inout vec3 light, in vec3 albedo, in float emission) {
    // Ensure positive light values
    vec3 lightM = max(light, vec3(0.0));
    
    // Apply tone mapping for better color distribution
    lightM /= (0.2 + 0.8 * GetLuminance(lightM));
    
    // Balance emission influence on final lighting
    lightM *= (1.0 / (1.0 + emission)) * 0.22;
    
    // Apply base light modification
    light *= 0.9;
    
    // Enhance detail through albedo interaction
    light += pow2(lightM / (albedo + 0.1));
}
// ═══════════════════════════════════════════════════════════════════════════════════════
//                        MATERIAL-SPECIFIC BLOCKLIGHT COLOR SYSTEM
// ═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Advanced Material-Based Light Color Provider
 * 
 * Returns specialized blocklight colors for specific material types with precise control
 * over light intensity, color temperature, and extra emission properties.
 * 
 * @param mat - Material ID to process (integer identifier)
 * @return vec4 - RGBA where RGB = light color, A = extra light intensity
 * 
 * Technical Notes:
 * - RGB values control color temperature and saturation
 * - Higher RGB values increase color dominance and travel distance
 * - Alpha > 0 enables extra light emission beyond vanilla lightmap
 * - Values are carefully balanced for realistic lighting behavior
 * 
 * Material Range: 0-97 (with future expansion capability)
 */
vec4 GetSpecialBlocklightColor(in int mat) {
    // Optimized nested conditional structure for performance
    if (mat < 50) {
        if (mat < 26) {
            if (mat < 14) {
                if (mat < 8) {
                    // Basic Light Sources (0-7)
                    if (mat == 2) return vec4(fireSpecialLightColor, 0.0);             // Torch
                    #ifndef END
                        if (mat == 3) return vec4(vec3(1.0, 1.0, 1.0) * 4.0, 0.0);   // End Rod - Base light reference
                    #else
                        if (mat == 3) return vec4(vec3(1.25, 0.5, 1.25) * 4.0, 0.0); // End Rod (End dimension variant)
                    #endif
                    if (mat == 4) return vec4(vec3(0.7, 1.5, 2.0) * 3.0, 0.0);       // Beacon - Cool blue light
                    if (mat == 5) return vec4(fireSpecialLightColor, 0.0);            // Fire
                    if (mat == 6) return vec4(vec3(0.7, 1.5, 1.5) * 1.7, 0.0);       // Sea Pickle (Waterlogged)
                    if (mat == 7) return vec4(vec3(1.1, 0.85, 0.35) * 5.0, 0.0);     // Ochre Froglight
                } else {
                    // Enhanced Light Sources (8-13)
                    if (mat == 8) return vec4(vec3(0.6, 1.3, 0.6) * 4.5, 0.0);       // Verdant Froglight
                    if (mat == 9) return vec4(vec3(1.1, 0.5, 0.9) * 4.5, 0.0);       // Pearlescent Froglight
                    if (mat == 10) return vec4(vec3(1.7, 0.9, 0.4) * 4.0, 0.0);      // Glowstone
                    if (mat == 11) return vec4(fireSpecialLightColor, 0.0);           // Jack o'Lantern
                    if (mat == 12) return vec4(fireSpecialLightColor, 0.0);           // Lantern
                    if (mat == 13) return vec4(lavaSpecialLightColor, 0.8);           // Lava - High emission
                }
            } else {
                if (mat < 20) {
                    // Utility Light Sources (14-19)
                    if (mat == 14) return vec4(lavaSpecialLightColor, 0.0);           // Lava Cauldron
                    if (mat == 15) return vec4(fireSpecialLightColor, 0.0);           // Campfire (Lit)
                    if (mat == 16) return vec4(vec3(1.7, 0.9, 0.4) * 4.0, 0.0);      // Redstone Lamp (Lit)
                    if (mat == 17) return vec4(vec3(1.7, 0.9, 0.4) * 2.0, 0.0);      // Respawn Anchor (Lit)
                    if (mat == 18) return vec4(vec3(1.0, 1.25, 1.5) * 3.4, 0.0);     // Sea Lantern
                    if (mat == 19) return vec4(vec3(3.0, 0.9, 0.2) * 3.0, 0.0);      // Shroomlight
                } else {
                    // Special Utility Blocks (20-25)
                    if (mat == 20) return vec4(vec3(2.3, 0.9, 0.2) * 3.4, 0.0);      // Cave Vines with Glow Berries
                    if (mat == 21) return vec4(fireSpecialLightColor * 0.7, 0.0);     // Furnace (Lit)
                    if (mat == 22) return vec4(fireSpecialLightColor * 0.7, 0.0);     // Smoker (Lit)
                    if (mat == 23) return vec4(fireSpecialLightColor * 0.7, 0.0);     // Blast Furnace (Lit)
                    if (mat == 24) return vec4(fireSpecialLightColor * 0.25 * candleColorMult, candleExtraLight); // Standard Candles
                    if (mat == 25) return vec4(netherPortalSpecialLightColor * 2.0, 0.4); // Nether Portal - High emission
                }
            }
        } else {
            if (mat < 38) {
                if (mat < 32) {
                    // Soul Fire Family & Redstone (26-31)
                    if (mat == 26) return vec4(netherPortalSpecialLightColor, 0.0);   // Crying Obsidian
                    if (mat == 27) return soulFireSpecialColor;                       // Soul Fire
                    if (mat == 28) return soulFireSpecialColor;                       // Soul Torch
                    if (mat == 29) return soulFireSpecialColor;                       // Soul Lantern
                    if (mat == 30) return soulFireSpecialColor;                       // Soul Campfire (Lit)
                    if (mat == 31) return vec4(redstoneSpecialLightColor * 0.5, 0.1); // Redstone Ores (Lit)
                } else {
                    // Redstone & Special Blocks (32-37)
                    if (mat == 32) return vec4(redstoneSpecialLightColor * 0.3, 0.1); // Redstone Ores (Unlit)
                    if (mat == 33) return vec4(vec3(1.4, 1.1, 0.5), 0.0);            // Enchanting Table
                    #if GLOWING_LICHEN > 0
                        if (mat == 34) return vec4(vec3(0.8, 1.1, 1.1), 0.05);       // Glow Lichen (IntegratedPBR)
                    #else
                        if (mat == 34) return vec4(vec3(0.4, 0.55, 0.55), 0.0);      // Glow Lichen (Vanilla)
                    #endif
                    if (mat == 35) return vec4(redstoneSpecialLightColor * 0.25, 0.0); // Redstone Torch
                    if (mat == 36) return vec4(vec3(0.325, 0.15, 0.425) * 2.0, 0.05); // Amethyst Cluster/Buds, Sculk Sensor
                    if (mat == 37) return vec4(lavaSpecialLightColor * 0.1, 0.1);     // Magma Block
                }
            } else {
                if (mat < 44) {
                    // Mystical & Rare Blocks (38-43)
                    if (mat == 38) return vec4(vec3(2.0, 0.5, 1.5) * 0.3, 0.1);      // Dragon Egg
                    if (mat == 39) return vec4(vec3(2.0, 1.0, 1.5) * 0.25, 0.1);     // Chorus Flower
                    if (mat == 40) return vec4(vec3(2.5, 1.2, 0.4) * 0.1, 0.1);      // Brewing Stand
                    if (mat == 41) return vec4(redstoneSpecialLightColor * 0.4, 0.15); // Redstone Block
                    if (mat == 42) return vec4(vec3(0.75, 0.75, 3.0) * 0.277, 0.15); // Lapis Block
                    if (mat == 43) return vec4(vec3(1.7, 0.9, 0.4) * 0.45, 0.05);    // Iron Ores
                } else {
                    // Ore Collection (44-49)
                    if (mat == 44) return vec4(vec3(1.7, 1.1, 0.2) * 0.45, 0.1);     // Gold Ores
                    if (mat == 45) return vec4(vec3(1.7, 0.8, 0.4) * 0.45, 0.05);    // Copper Ores
                    if (mat == 46) return vec4(vec3(0.75, 0.75, 3.0) * 0.2, 0.1);    // Lapis Ores
                    if (mat == 47) return vec4(vec3(0.5, 3.5, 0.5) * 0.3, 0.1);      // Emerald Ores
                    if (mat == 48) return vec4(vec3(0.5, 2.0, 2.0) * 0.4, 0.15);     // Diamond Ores
                    if (mat == 49) return vec4(vec3(1.5, 1.5, 1.5) * 0.3, 0.05);     // Nether Quartz Ore
                }
            }
        }
    } else {
        // Materials 50+ (Extended Range)
        if (mat < 74) {
            if (mat < 62) {
                if (mat < 56) {
                    // Nether Materials & Trial Blocks (50-55)
                    if (mat == 50) return vec4(vec3(1.7, 1.1, 0.2) * 0.45, 0.05);    // Nether Gold Ore
                    if (mat == 51) return vec4(vec3(1.7, 1.1, 0.2) * 0.45, 0.05);    // Gilded Blackstone
                    if (mat == 52) return vec4(vec3(1.8, 0.8, 0.4) * 0.6, 0.15);     // Ancient Debris
                    if (mat == 53) return vec4(vec3(1.4, 0.2, 1.4) * 0.3, 0.05);     // Spawner
                    if (mat == 54) return vec4(vec3(3.1, 1.1, 0.3) * 1.0, 0.1);      // Trial Spawner/Vault (Active)
                    if (mat == 55) return vec4(vec3(1.7, 0.9, 0.4) * 4.0, 0.0);      // Copper Bulb (Bright, Lit)
                } else {
                    // Copper & Sculk Systems (56-61)
                    if (mat == 56) return vec4(vec3(1.7, 0.9, 0.4) * 2.0, 0.0);      // Copper Bulb (Dim, Lit)
                    if (mat == 57) return vec4(vec3(0.1, 0.3, 0.4) * 0.5, 0.0005);   // Sculk Family
                    if (mat == 58) return vec4(vec3(0.0, 1.4, 1.4) * 4.0, 0.15);     // End Portal Frame (Active)
                    if (mat == 59) return vec4(0.0);                                  // Bedrock (No light)
                    if (mat == 60) return vec4(vec3(3.1, 1.1, 0.3) * 0.125, 0.0125); // Command Block
                    if (mat == 61) return vec4(vec3(3.0, 0.9, 0.2) * 0.125, 0.0125); // Nether Fungi
                }
            } else {
                if (mat < 68) {
                    // Nether Wood & Redstone Systems (62-67)
                    if (mat == 62) return vec4(vec3(3.5, 0.6, 0.4) * 0.3, 0.05);     // Crimson Stem/Hyphae
                    if (mat == 63) return vec4(vec3(0.3, 1.9, 1.5) * 0.3, 0.05);     // Warped Stem/Hyphae
                    if (mat == 64) return vec4(vec3(1.0, 1.0, 1.0) * 0.45, 0.1);     // Structure Blocks
                    if (mat == 65) return vec4(vec3(3.0, 0.9, 0.2) * 0.125, 0.0125); // Weeping Vines Plant
                    if (mat == 66) return vec4(redstoneSpecialLightColor * 0.05, 0.002); // Redstone Wire (Lit)
                    if (mat == 67) return vec4(redstoneSpecialLightColor * 0.125, 0.0125); // Repeater/Comparator (Lit)
                } else {
                    // Trial System & Colored Candles Start (68-73)
                    if (mat == 68) return vec4(vec3(0.75), 0.0);                      // Vault (Inactive)
                    if (mat == 69) return vec4(vec3(1.3, 1.6, 1.6) * 1.0, 0.1);      // Trial Spawner/Vault (Ominous)
                    if (mat == 70) return vec4(vec3(1.0, 0.1, 0.1) * candleColorMult, candleExtraLight); // Red Candles
                    if (mat == 71) return vec4(vec3(1.0, 0.4, 0.1) * candleColorMult, candleExtraLight); // Orange Candles
                    if (mat == 72) return vec4(vec3(1.0, 1.0, 0.1) * candleColorMult, candleExtraLight); // Yellow Candles
                    if (mat == 73) return vec4(vec3(0.1, 1.0, 0.1) * candleColorMult, candleExtraLight); // Lime Candles
                }
            }
        } else {
            if (mat < 86) {
                if (mat < 80) {
                    // Colored Candles Collection (74-79)
                    if (mat == 74) return vec4(vec3(0.3, 1.0, 0.3) * candleColorMult, candleExtraLight); // Green Candles
                    if (mat == 75) return vec4(vec3(0.3, 0.8, 1.0) * candleColorMult, candleExtraLight); // Cyan Candles
                    if (mat == 76) return vec4(vec3(0.5, 0.65, 1.0) * candleColorMult, candleExtraLight); // Light Blue Candles
                    if (mat == 77) return vec4(vec3(0.1, 0.15, 1.0) * candleColorMult, candleExtraLight); // Blue Candles
                    if (mat == 78) return vec4(vec3(0.7, 0.3, 1.0) * candleColorMult, candleExtraLight); // Purple Candles
                    if (mat == 79) return vec4(vec3(1.0, 0.1, 1.0) * candleColorMult, candleExtraLight); // Magenta Candles
                } else {
                    // Special Flora & Future Materials (80-85)
                    if (mat == 80) return vec4(vec3(1.0, 0.4, 1.0) * candleColorMult, candleExtraLight); // Pink Candles
                    if (mat == 81) return vec4(vec3(2.8, 1.1, 0.2) * 0.125, 0.0125);  // Open Eyeblossom
                    if (mat == 82) return vec4(vec3(2.8, 1.1, 0.2) * 0.3, 0.05);      // Creaking Heart (Active)
                    if (mat == 83) return vec4(vec3(1.6, 1.6, 0.7) * 0.3, 0.05);      // Firefly Bush
                    // Reserved slots 84-85
                    if (mat == 84) return vec4(0.0);
                    if (mat == 85) return vec4(0.0);
                }
            } else {
                // Future Expansion Slots (86-97)
                if (mat < 92) {
                    if (mat == 86) return vec4(0.0);
                    if (mat == 87) return vec4(0.0);
                    if (mat == 88) return vec4(0.0);
                    if (mat == 89) return vec4(0.0);
                    if (mat == 90) return vec4(0.0);
                    if (mat == 91) return vec4(0.0);
                } else {
                    if (mat == 92) return vec4(0.0);
                    if (mat == 93) return vec4(0.0);
                    if (mat == 94) return vec4(0.0);
                    if (mat == 95) return vec4(0.0);
                    if (mat == 96) return vec4(0.0);
                    if (mat == 97) return vec4(0.0);
                }
            }
        }
    }

    // Fallback: Enhanced default blocklight for unrecognized materials
    return vec4(blocklightCol * 20.0, 0.0);
}

// ═══════════════════════════════════════════════════════════════════════════════════════
//                          ADVANCED MATERIAL TINTING SYSTEM
// ═══════════════════════════════════════════════════════════════════════════════════════

/**
 * Specialized Material Tint Color Array
 * 
 * Provides precise color tinting for various material types and decorative blocks.
 * Each index corresponds to a material ID with a 200+ offset for organization.
 * 
 * Color Selection Philosophy:
 * - Realistic color representation based on real-world materials
 * - Enhanced saturation for better visibility in-game
 * - Balanced brightness to prevent oversaturation
 * - Consistency across similar material families
 * 
 * Index Mapping: Array[n] = Material ID (200 + n)
 */
const vec3[] specialTintColor = vec3[](
    // Dye-based Materials (200-215)
    vec3(1.0, 1.0, 1.0),        // 200: White - Pure white for clean appearance
    vec3(1.0, 0.3, 0.1),        // 201: Orange - Warm vibrant orange
    vec3(1.0, 0.1, 1.0),        // 202: Magenta - Rich magenta with good contrast
    vec3(0.5, 0.65, 1.0),       // 203: Light Blue - Soft sky blue
    vec3(1.0, 1.0, 0.1),        // 204: Yellow - Bright sunshine yellow
    vec3(0.1, 1.0, 0.1),        // 205: Lime - Electric lime green
    vec3(1.0, 0.4, 1.0),        // 206: Pink - Soft rose pink
    vec3(0.7, 0.7, 0.7),        // 207: Gray - Neutral medium gray
    vec3(0.9, 0.9, 0.9),        // 208: Light Gray - Bright silver gray
    vec3(0.3, 0.8, 1.0),        // 209: Cyan - Ocean cyan blue
    vec3(0.7, 0.3, 1.0),        // 210: Purple - Royal purple
    vec3(0.1, 0.15, 1.0),       // 211: Blue - Deep ocean blue
    vec3(1.0, 0.75, 0.5),       // 212: Brown - Warm earth brown
    vec3(0.3, 1.0, 0.3),        // 213: Green - Forest green
    vec3(1.0, 0.1, 0.1),        // 214: Red - Vibrant crimson red
    vec3(0.2, 0.2, 0.2),        // 215: Black - Deep charcoal black
    
    // Special Material Types (216-219)
    vec3(0.5, 0.65, 1.0),       // 216: Ice - Cool crystalline blue
    vec3(0.95, 0.95, 0.95),     // 217: Glass - Clear transparent tint
    vec3(0.85, 0.85, 0.85),     // 218: Glass Pane - Slightly dimmed glass
    vec3(0.0, 0.0, 0.0)         // 219+: Default/Undefined - No tint
);

/**
 * ═══════════════════════════════════════════════════════════════════════════════════════
 *                              END OF BLOCK LIGHT SYSTEM
 *                          Enhanced Luminara Shader Pack Component
 * ═══════════════════════════════════════════════════════════════════════════════════════
 * 
 * This enhanced block light color system provides:
 * - 97+ predefined material light colors
 * - Advanced candle lighting with 16 color variants
 * - Specialized tinting for decorative materials
 * - Optimized performance through efficient conditionals
 * - Future expansion capability for new materials
 * 
 * Maintained by VcorA - Luminara Shader Development Team
 * ═══════════════════════════════════════════════════════════════════════════════════════
 */
