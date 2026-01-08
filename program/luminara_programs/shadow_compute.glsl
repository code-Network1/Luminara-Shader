/*
═══════════════════════════════════════════════════════════════════════════════
    🌟 luminara_programs | shadow_compute - نظام حوسبة الظلال المتقدم | EminGT 🌟
═══════════════════════════════════════════════════════════════════════════════

    Advanced Shadow Computation & Light Propagation System
    نظام حوسبة الظلال وانتشار الضوء المتقدم

    ⚡ الميزات الأساسية / Core Features:
    ----------------------------------------
    • نظام حوسبة الإضاءة الملونة المتقدم / Advanced Colored Lighting Computation
    • خوارزميات انتشار الضوء ثلاثي الأبعاد / 3D Light Propagation Algorithms
    • نظام تحسين الأداء المتكيف / Adaptive Performance Optimization
    • معالجة متوازية للفوكسل / Parallel Voxel Processing
    • تقنيات التملئة الفيضية / Flood-fill Techniques
    • نظام إدارة الذاكرة الذكي / Smart Memory Management

    🎯 الأنظمة الفرعية / Subsystems:
    --------------------------------
    [نظام الحوسبة المتوازية] - Parallel Compute System with Work Groups
    [معالجة الفوكسل] - Voxel Processing with Light Sampling
    [تحسين الأداء] - Performance Optimizations (Half Rate, Behind Player)
    [انتشار الضوء] - Light Propagation with Color Tinting
    [إدارة الذاكرة] - Memory Management with Image Storage

    📈 التحسينات المتقدمة / Advanced Optimizations:
    ----------------------------------------------
    ★ Work Group Configuration: تكوين مجموعات العمل المحسن
    ★ Half Rate Updates: تحديثات نصف المعدل لتحسين الأداء
    ★ Behind Player Culling: إخفاء المناطق خلف اللاعب
    ★ Adaptive Light Sampling: أخذ عينات الضوء التكيفي
    ★ Memory Optimization: تحسين استخدام الذاكرة


═══════════════════════════════════════════════════════════════════════════════
*/

/////////////////////////////////////
// Luminara Shader - Enhanced by EminGT //
/////////////////////////////////////

// ═══════════════════════════════════════════════════════════════════════════════
// Core Library Includes | مكتبات النظام الأساسية
// ═══════════════════════════════════════════════════════════════════════════════
#include "/lib/shader_modules/shader_master.glsl"

// ═══════════════════════════════════════════════════════════════════════════════
// Shadow Compute Implementation | تطبيق حوسبة الظلال
// ═══════════════════════════════════════════════════════════════════════════════
#ifdef SHADOWCOMP

// ─────────────────────────────────────────────────────────────────────────────
// Enhanced Performance Optimizations
// ─────────────────────────────────────────────────────────────────────────────
#define OPTIMIZATION_ACL_HALF_RATE_UPDATES    // Half rate updates
#define OPTIMIZATION_ACL_BEHIND_PLAYER        // Behind player culling

// ─────────────────────────────────────────────────────────────────────────────
// Advanced Compute Configuration | تكوين الحوسبة المتقدم
// ─────────────────────────────────────────────────────────────────────────────
layout (local_size_x = 8, local_size_y = 8, local_size_z = 8) in;

// نظام تكوين مجموعات العمل التكيفي / Adaptive Work Group Configuration System
#if COLORED_LIGHTING_INTERNAL == 128
	const ivec3 workGroups = ivec3(16, 8, 16);      // تكوين صغير / Small configuration
#elif COLORED_LIGHTING_INTERNAL == 192
	const ivec3 workGroups = ivec3(24, 12, 24);     // تكوين متوسط / Medium configuration
#elif COLORED_LIGHTING_INTERNAL == 256
	const ivec3 workGroups = ivec3(32, 16, 32);     // تكوين كبير / Large configuration
#elif COLORED_LIGHTING_INTERNAL == 384
	const ivec3 workGroups = ivec3(48, 24, 48);     // تكوين فائق / Extra large configuration
#elif COLORED_LIGHTING_INTERNAL == 512
	const ivec3 workGroups = ivec3(64, 32, 64);     // تكوين ضخم / Huge configuration
#elif COLORED_LIGHTING_INTERNAL == 768
	const ivec3 workGroups = ivec3(96, 32, 96);     // تكوين عملاق / Ultra configuration
#elif COLORED_LIGHTING_INTERNAL == 1024
	const ivec3 workGroups = ivec3(128, 32, 128);   // تكوين أقصى / Maximum configuration
#endif

// ─────────────────────────────────────────────────────────────────────────────
// 3D Direction Vectors for Light Sampling | متجهات الاتجاه ثلاثي الأبعاد لأخذ عينات الضوء
// ─────────────────────────────────────────────────────────────────────────────
ivec3[6] face_offsets = ivec3[6](
	ivec3( 1,  0,  0),    // +X اتجاه / +X direction
	ivec3( 0,  1,  0),    // +Y اتجاه / +Y direction
	ivec3( 0,  0,  1),    // +Z اتجاه / +Z direction
	ivec3(-1,  0,  0),    // -X اتجاه / -X direction
	ivec3( 0, -1,  0),    // -Y اتجاه / -Y direction
	ivec3( 0,  0, -1)     // -Z اتجاه / -Z direction
);

// ─────────────────────────────────────────────────────────────────────────────
// Advanced Image Storage Interface | واجهة تخزين الصور المتقدمة
// ─────────────────────────────────────────────────────────────────────────────
writeonly uniform image3D floodfill_img;       // صورة التملئة الفيضية الأساسية / Primary flood-fill image
writeonly uniform image3D floodfill_img_copy;  // نسخة صورة التملئة الفيضية / Flood-fill image copy

// ═══════════════════════════════════════════════════════════════════════════════
// Enhanced Light Sampling Functions | دوال أخذ عينات الضوء المحسنة
// ═══════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────────────────
// Advanced Light Sample Extraction | استخراج عينة الضوء المتقدم
// ─────────────────────────────────────────────────────────────────────────────
vec4 GetLightSample(sampler3D lightSampler, ivec3 pos) {
	return texelFetch(lightSampler, pos, 0);
}

// ─────────────────────────────────────────────────────────────────────────────
// Enhanced Light Averaging Algorithm | خوارزمية متوسط الضوء المحسنة
// ─────────────────────────────────────────────────────────────────────────────
vec4 GetLightAverage(sampler3D lightSampler, ivec3 pos, ivec3 voxelVolumeSize) {
	// أخذ عينة الضوء الحالية / Get current light sample
	vec4 light_old = GetLightSample(lightSampler, pos);
	
	// أخذ عينات الضوء من جميع الجهات الستة / Sample light from all six directions
	vec4 light_px  = GetLightSample(lightSampler, clamp(pos + face_offsets[0], ivec3(0), voxelVolumeSize - 1));
	vec4 light_py  = GetLightSample(lightSampler, clamp(pos + face_offsets[1], ivec3(0), voxelVolumeSize - 1));
	vec4 light_pz  = GetLightSample(lightSampler, clamp(pos + face_offsets[2], ivec3(0), voxelVolumeSize - 1));
	vec4 light_nx  = GetLightSample(lightSampler, clamp(pos + face_offsets[3], ivec3(0), voxelVolumeSize - 1));
	vec4 light_ny  = GetLightSample(lightSampler, clamp(pos + face_offsets[4], ivec3(0), voxelVolumeSize - 1));
	vec4 light_nz  = GetLightSample(lightSampler, clamp(pos + face_offsets[5], ivec3(0), voxelVolumeSize - 1));

	// حساب متوسط الضوء مع تحسين انتشار الضوء / Calculate light average with enhanced propagation
	vec4 light = light_old + light_px + light_py + light_pz + light_nx + light_ny + light_nz;
    return light / 7.2; // أعلى قليلاً من 7 لمنع انتشار الضوء بعيداً جداً / Slightly higher than 7 to prevent light from travelling too far
}

// ─────────────────────────────────────────────────────────────────────────────
// Essential Library Includes | المكتبات الأساسية المطلوبة
// ─────────────────────────────────────────────────────────────────────────────
#include "/lib/effects/effects_unified.glsl"

// ═══════════════════════════════════════════════════════════════════════════════
// Main Shadow Computation Function | الدالة الرئيسية لحوسبة الظلال
// ═══════════════════════════════════════════════════════════════════════════════
void main() {
	// ─────────────────────────────────────────────────────────────────────────
	// Enhanced Position and Offset Calculation | حساب الموضع والإزاحة المحسن
	// ─────────────────────────────────────────────────────────────────────────
	ivec3 pos = ivec3(gl_GlobalInvocationID);
	vec3 posM = vec3(pos) / vec3(voxelVolumeSize);
	vec3 posOffset = floor(previousCameraPosition) - floor(cameraPosition);
	ivec3 previousPos = ivec3(vec3(pos) - posOffset);

	// ─────────────────────────────────────────────────────────────────────────
	// Advanced Distance-Based Optimization | تحسين قائم على المسافة المتقدم
	// ─────────────────────────────────────────────────────────────────────────
	ivec3 absPosFromCenter = abs(pos - voxelVolumeSize / 2);
	if (absPosFromCenter.x + absPosFromCenter.y + absPosFromCenter.z > 16) {
	#ifdef OPTIMIZATION_ACL_BEHIND_PLAYER
		// حساب موضع الرؤية للتحسين / Calculate view position for optimization
		vec4 viewPos = gbufferProjectionInverse * vec4(0.0, 0.0, 1.0, 1.0);
		viewPos /= viewPos.w;
		vec3 nPlayerPos = normalize(mat3(gbufferModelViewInverse) * viewPos.xyz);
		
		// تحسين: إخفاء المناطق خلف اللاعب / Optimization: cull areas behind player
		if (dot(normalize(posM - 0.5), nPlayerPos) < 0.0) {
			#ifdef COLORED_LIGHT_FOG
				// نظام التبديل المزدوج للأداء / Double buffering system for performance
				if ((frameCounter & 1) == 0) {
					imageStore(floodfill_img_copy, pos, GetLightSample(floodfill_sampler, previousPos));
				} else {
					imageStore(floodfill_img, pos, GetLightSample(floodfill_sampler_copy, previousPos));
				}
			#endif
			return;
		}
	#endif
	}

	// ─────────────────────────────────────────────────────────────────────────
	// Enhanced Light Processing and Voxel Analysis | معالجة الضوء وتحليل الفوكسل المحسن
	// ─────────────────────────────────────────────────────────────────────────
	vec4 light = vec4(0.0);
	uint voxel = texelFetch(voxel_sampler, pos, 0).x;

	// نظام التبديل المزدوج للإطارات / Frame-based double buffering system
	if ((frameCounter & 1) == 0) {
		// معالجة الفوكسل الصلبة / Process solid voxels
		if (voxel == 1u) {
			imageStore(floodfill_img_copy, pos, vec4(0.0));
			return;
		}
		
		#ifdef OPTIMIZATION_ACL_HALF_RATE_UPDATES
			// تحسين: تحديثات نصف المعدل / Optimization: half rate updates
			if (posM.x < 0.5) {
				imageStore(floodfill_img_copy, pos, GetLightSample(floodfill_sampler, previousPos));
				return;
			}
		#endif
		
		// حساب متوسط الضوء المحسن / Calculate enhanced light average
		light = GetLightAverage(floodfill_sampler, previousPos, voxelVolumeSize);
	} else {
		// معالجة الإطار البديل / Process alternate frame
		if (voxel == 1u) {
			imageStore(floodfill_img, pos, vec4(0.0));
			return;
		}
		
		#ifdef OPTIMIZATION_ACL_HALF_RATE_UPDATES
			// تحسين: تحديثات نصف المعدل للإطار البديل / Optimization: half rate updates for alternate frame
			if (posM.x > 0.5) {
				imageStore(floodfill_img, pos, GetLightSample(floodfill_sampler_copy, previousPos));
				return;
			}
		#endif
		
		// حساب متوسط الضوء من المصدر البديل / Calculate light average from alternate source
		light = GetLightAverage(floodfill_sampler_copy, previousPos, voxelVolumeSize);
	}

	// ─────────────────────────────────────────────────────────────────────────
	// Advanced Block Light Processing | معالجة إضاءة الكتل المتقدمة
	// ─────────────────────────────────────────────────────────────────────────
	if (voxel == 0u || voxel >= 200u) {
		// معالجة الكتل الملونة الخاصة / Process special colored blocks
		if (voxel >= 200u) {
			vec3 tint = specialTintColor[min(voxel - 200u, specialTintColor.length() - 1u)];
			light.rgb *= tint; // تطبيق التلوين الخاص / Apply special tinting
		}
	} else {
		// معالجة كتل مصادر الضوء / Process light source blocks
		vec4 color = GetSpecialBlocklightColor(int(voxel));
		light = max(light, vec4(pow2(color.rgb), color.a)); // تحسين سطوع مصادر الضوء / Enhanced light source brightness
	}

	// ─────────────────────────────────────────────────────────────────────────
	// Final Image Storage with Double Buffering | تخزين الصورة النهائي مع التبديل المزدوج
	// ─────────────────────────────────────────────────────────────────────────
	if ((frameCounter & 1) == 0) {
		imageStore(floodfill_img_copy, pos, light);
	} else {
		imageStore(floodfill_img, pos, light);
	}
}

#endif

/*
═══════════════════════════════════════════════════════════════════════════════
    ✨ تم إنجاز shadow_compute.glsl بنجاح - EminGT ✨
    🌟 Shadow_compute.glsl completed successfully - EminGT 🌟
    
    🎯 نظام حوسبة الظلال والإضاءة الملونة المتقدم مكتمل
    🎯 Advanced Shadow Computation & Colored Lighting System Complete
    
    💎 تم بناؤه بفخر من قبل EminGT
    💎 Proudly built by EminGT
═══════════════════════════════════════════════════════════════════════════════
*/
