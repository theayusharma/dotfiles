
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec4 color = texture2D(tex, v_texcoord);

    // Reduce blue to 60% (strong filter)
    color.b *= 0.4;

    // Slightly boost red and green to add warmth
    color.r *= 1.1;
    color.g *= 1.05;

    // Optional: Dim overall brightness by 10%
    color.rgb *= 0.9;

    gl_FragColor = color;
}
