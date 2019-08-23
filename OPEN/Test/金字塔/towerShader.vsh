
attribute vec4 position;
attribute vec4 positionColor;
varying lowp vec4 varyColor;

uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;

void main()
{
    varyColor = positionColor;
    gl_Position = projectionMatrix * modelViewMatrix * position;
}

