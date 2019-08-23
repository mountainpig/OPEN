
attribute vec4 position;
attribute vec4 positionColor;
varying lowp vec4 varyColor;

void main()
{
    varyColor = positionColor;
    gl_Position = position;
}
