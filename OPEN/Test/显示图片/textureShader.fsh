//varying lowp vec4 varyColor;

precision highp float;
uniform sampler2D Texture;
varying vec2 TextureCoordsVarying;

void main()
{
    gl_FragColor = texture2D(Texture, vec2(TextureCoordsVarying.x,1.0 - TextureCoordsVarying.y));
//    gl_FragColor = vec4(mask.rgb, 1.0);
}

