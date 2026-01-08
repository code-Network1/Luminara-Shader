float factor = pow2(pow2(color.r));
smoothnessG = factor * 0.65;
smoothnessD = smoothnessG * 0.6;

// Luminara Shader: Enhanced End Stone with subtle magical glow
#ifdef END
    vec3 worldPos = playerPos + cameraPosition;
    float magicalPulse = sin(frameTimeCounter * 2.0 + worldPos.x * 0.1 + worldPos.z * 0.1) * 0.5 + 0.5;
    vec3 endGlow = vec3(0.15, 0.08, 0.25) * magicalPulse * 0.3;
    color.rgb += endGlow * factor;
    emission = factor * magicalPulse * 0.4;
#endif

#ifdef COATED_TEXTURES
    noiseFactor = 0.66;
#endif
