
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec4 color = texture2D(tex, v_texcoord);
    
    // Reduce blue by 20%
    color.b *= 0.8;

    gl_FragColor = color;
}
