shader_type canvas_item;

/**
 * The size of the pattern. Larger values produce more details.
 */
uniform float scale: hint_range(0.1, 100.0) = 5.0;

/**
 * Controls the noise amplitude.
 */
uniform float amplitude: hint_range(0.0, 1.0) = 0.5;

/**
 * Controls the noise gain.
 */
uniform float gain: hint_range(0.0, 1.0) = 0.5;

/**
 * Controls the noise frequency.
 */
uniform float frequency: hint_range(0.0, 100.0) = 2.0;

/**
 * The number of octaves for FBM noise.
 */
uniform int octaves: hint_range(0, 24) = 6;

/**
 * Controls the noise shift in the horizontal direction.
 */
uniform float shiftX: hint_range(0.0, 100.0) = 100.0;

/**
 * Controls the noise shift in the vertical direction.
 */
uniform float shiftY: hint_range(0.0, 100.0) = 100.0;

/**
 * Controls the complexity of the pattern. When enabled, the noise is
 * calculated by combining multiple passes of FBM. When disabled, only one FBM
 * pass is used.
 */
uniform bool useDomainWarping = true;

/**
 * Controls the pattern shift in the horizontal directly. Note: only used if
 * domain warping is enabled.
 */
uniform float patternShiftX: hint_range(0.0, 500.0) = 4.0;

/**
 * Controls the pattern shift in the vertical directly. Note: only used if
 * domain warping is enabled.
 */
uniform float patternShiftY: hint_range(0.0, 500.0) = 4.0;

/**
 * Use exact height values. Setting to false converts heights to 1/10th values
 * and creates a stepped color pattern.
 */
uniform bool smoothHeights = true;

/**
 * Adjusts the height of the pattern. Higher values will push the pattern more
 * towards the right side of the gradient texture. Lower values do the
 * opposite.
 */
uniform float heightModifier: hint_range(0.1, 5.0) = 1.0;

/**
 * Multiplies the height by itself n number of times. This causes the low
 * values to be pushed lower.
 */
uniform int depthCount: hint_range(0, 10) = 1;

/**
 * Enable or disable normal mapping.
 */
uniform bool enableNormalMapping = true;

/**
 * The light direction for the normal map.
 */
uniform vec3 lightDirection = vec3(0.0, 1.0, 0.0);

/**
 * The light color.
 */
uniform vec3 lightColor = vec3(1.0);

/**
 * A normal map for added texture.
 */
uniform sampler2D normalMap: repeat_enable;

/*
 * The brightness of and individual instance.
 */
instance uniform float brightness = 1.0;

const mat2 m2 = mat2(vec2(0.8, -0.6),vec2(0.6, 0.8));
const vec2 resolution = vec2(1920.0, 1080.0);

float random (vec2 st) {
	return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

	return mix(a, b, u.x) +
		(c - a)* u.y * (1.0 - u.x) +
		(d - b) * u.x * u.y;
}

float fbm(vec2 st) {
    float value = 0.0;
	//vec2 shift = vec2(shiftX + TIME, shiftY + sin(TIME));
	vec2 shift = vec2(shiftX, shiftY);
	float a = amplitude;

    for (int i = 0; i < octaves; i++) {
        value += a * noise(st);
        st = st * m2 * frequency + shift;
        a *= gain;

    }
    return value;
}

float pattern(vec2 p) {
	vec2 q;
	q.x = fbm(p + vec2(0.0, 0.0));
	q.y = fbm(p + vec2(5.2,1.3));

	//q += TIME * 0.1;

	vec2 r;
	r.x = fbm(p + 3.0 * q + vec2(1.7, 9.2));
	r.y = fbm(p + 3.0 * q + vec2(8.3, 2.8));

    return fbm(p + vec2(patternShiftX, patternShiftY) * r);
}

void fragment() {
	vec2 p = FRAGCOORD.xy * SCREEN_PIXEL_SIZE;
	p.x *= (100.0 / SCREEN_PIXEL_SIZE.x) / (100.0 / SCREEN_PIXEL_SIZE.y);
	p *= scale;
	//p.x += sin(TIME);
	//p.y += cos(TIME);

	float height = 0.0;
	if (useDomainWarping) {
		height = min(pattern(p) * heightModifier, 1.0);
	} else {
		height = min(fbm(p) * heightModifier, 1.0);
	}

	for (int d = 0; d < depthCount; d++) {
		height *= height;
	}

	if (!smoothHeights) {
		int iheight = int(height * 100.0);
		height = float(iheight) / 100.0;
	}

	vec2 gradientUV = vec2(height, 0.0);
	vec3 color = texture(TEXTURE, gradientUV).rgb;

	if (enableNormalMapping) {
		vec3 normal = texture(normalMap, UV).rgb;
		normal = normalize(normal * 2.0 - 1.0);
		float diff = dot(normal, lightDirection);
		color *= diff + lightColor;
	}

	color *= brightness;
	COLOR = vec4(color, 1.0);
}

