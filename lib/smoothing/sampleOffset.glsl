

// Jitter offsets - protected against duplicate definitions
#ifndef JITTER_OFFSETS_DEFINED
#define JITTER_OFFSETS_DEFINED
vec2 jitterOffsets[8] = vec2[8](
                        vec2( 0.125,-0.375),
                        vec2(-0.125, 0.375),
                        vec2( 0.625, 0.125),
                        vec2( 0.375,-0.625),
                        vec2(-0.625, 0.625),
                        vec2(-0.875,-0.125),
                        vec2( 0.375,-0.875),
                        vec2( 0.875, 0.875)
                        );
#endif

// EminGT's optimized TAA jitter function
// Applies frame-based offset pattern for temporal anti-aliasing
// @param coord: Original texture coordinates
// @param w: Jitter weight/intensity multiplier
// @return: Jittered coordinates for current frame
#ifndef TAA_JITTER_DEFINED
#define TAA_JITTER_DEFINED
vec2 TAAJitter(vec2 coord, float w) {
    // Calculate frame-specific offset using 8-frame rotation pattern
    vec2 offset = jitterOffsets[int(framemod8)] * (w / vec2(viewWidth, viewHeight));
    
    // Reduce jitter intensity for TAA_MODE 1 to prevent over-smoothing
    #if TAA_MODE == 1 && !defined DH_TERRAIN && !defined DH_WATER
        offset *= 0.125; // Fine-tuned multiplier for optimal quality/performance balance
    #endif
    
    return coord + offset;
}
#endif
