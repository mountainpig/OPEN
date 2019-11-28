
attribute vec4 position;
attribute vec2 TextureCoords;
varying vec2 TextureCoordsVarying;

void main()
{
    gl_Position = position;
    TextureCoordsVarying = TextureCoords;
}
