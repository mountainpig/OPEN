attribute vec4 position;
attribute vec2 textCoordinate;
varying lowp vec2 varyTextCoord;

uniform lowp vec4 positionColor;
varying lowp vec4 varyColor;

uniform float pointSize;

void main()
{
    gl_PointSize = pointSize;
    varyColor = positionColor;
//    varyTextCoord = textCoordinate;
    gl_Position = position;
}
