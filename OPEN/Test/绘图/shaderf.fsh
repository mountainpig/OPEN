//precision highp float;
varying lowp vec2 varyTextCoord;
uniform sampler2D colorMap;
varying lowp vec4 varyColor;

void main()
{
//    gl_FragColor = texture2D(colorMap, varyTextCoord);
    gl_FragColor = varyColor * texture2D(colorMap, gl_PointCoord);
}
