/*
===============================================================================
    shadowcomp.glsl - Shadow Computation System | VcorA
===============================================================================
*/

#include "/lib/shader_modules/shader_master.glsl"

#ifdef SHADOWCOMP

layout (local_size_x = 8, local_size_y = 8, local_size_z = 8) in;

// Basic image storage
writeonly uniform image3D floodfill_img;
writeonly uniform image3D floodfill_img_copy;

// Essential samplers
uniform sampler3D floodfill_sampler;
uniform sampler3D floodfill_sampler_copy;
uniform usampler3D voxel_sampler;

void main() {
    // Basic compute shader implementation
    ivec3 pos = ivec3(gl_GlobalInvocationID);
    
    // Simple light propagation
    vec4 light = vec4(0.0);
    
    // Store the result
    imageStore(floodfill_img, pos, light);
}

#endif
