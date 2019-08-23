//
//  EarthView.m
//  OPEN
//
//  Created by jing huang on 2019/8/23.
//  Copyright © 2019 jing huang. All rights reserved.
//

#import "EarthView.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "sphere.h"

@interface EarthView ()<GLKViewDelegate>
{
    EAGLContext *context;
    GLKBaseEffect *cEffect;
}
@property (nonatomic) GLKMatrixStackRef modelviewMatrixStack;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexPositionBuffer;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexNormalBuffer;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexTextureCoordBuffer;

@property (nonatomic) GLfloat earthRotationAngleDegrees;
@property (nonatomic) GLfloat moonRotationAngleDegrees;
@end

@implementation EarthView

static const GLfloat  SceneEarthAxialTiltDeg = 23.5f;
static const GLfloat  SceneDaysPerMoonOrbit = 28.0f;
static const GLfloat  SceneMoonRadiusFractionOfEarth = 0.25;
static const GLfloat  SceneMoonDistanceFromEarth = 2.0;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.delegate = self;
    [self setUpConfig];
    [self setUpEffect];
    [self setUpVertexData];
    [self setUpTexture];
    return self;
}

-(void)setUpConfig
{
    context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:context];
    self.context = context;
    self.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    self.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    glClearColor(0, 0, 0, 1.0);
    glEnable(GL_DEPTH_TEST);
}

- (void)setUpEffect
{
    cEffect = [[GLKBaseEffect alloc] init];
    [self configureLight];
    
    GLfloat   aspectRatio =
    (self.bounds.size.width) /
    (self.bounds.size.height);
    
    cEffect.transform.projectionMatrix =
    GLKMatrix4MakeOrtho(
                        -2.0 * aspectRatio,
                        2.0 * aspectRatio,
                        -2.0,
                        2.0,
                        1.0,
                        120.0);
    
    cEffect.transform.modelviewMatrix =
    GLKMatrix4MakeTranslation(0.0f, 0.0f, -5.0);
    
}

- (void)setUpVertexData
{
    self.modelviewMatrixStack = GLKMatrixStackCreate(kCFAllocatorDefault);
    GLKMatrixStackLoadMatrix4(self.modelviewMatrixStack,
                              cEffect.transform.modelviewMatrix);
    
    //顶点数据缓存
    self.vertexPositionBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                                 initWithAttribStride:(3 * sizeof(GLfloat))
                                 numberOfVertices:sizeof(sphereVerts) / (3 * sizeof(GLfloat))
                                 bytes:sphereVerts
                                 usage:GL_STATIC_DRAW];
    self.vertexNormalBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                               initWithAttribStride:(3 * sizeof(GLfloat))
                               numberOfVertices:sizeof(sphereNormals) / (3 * sizeof(GLfloat))
                               bytes:sphereNormals
                               usage:GL_STATIC_DRAW];
    self.vertexTextureCoordBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                                     initWithAttribStride:(2 * sizeof(GLfloat))
                                     numberOfVertices:sizeof(sphereTexCoords) / (2 * sizeof(GLfloat))
                                     bytes:sphereTexCoords
                                     usage:GL_STATIC_DRAW];
    
    [self.vertexPositionBuffer
     prepareToDrawWithAttrib:GLKVertexAttribPosition
     numberOfCoordinates:3
     attribOffset:0
     shouldEnable:YES];
    [self.vertexNormalBuffer
     prepareToDrawWithAttrib:GLKVertexAttribNormal
     numberOfCoordinates:3
     attribOffset:0
     shouldEnable:YES];
    [self.vertexTextureCoordBuffer
     prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
     numberOfCoordinates:2
     attribOffset:0
     shouldEnable:YES];
}

- (void)setUpTexture
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@(1),GLKTextureLoaderOriginBottomLeft, nil];
    GLKTextureInfo *earthTexture = [GLKTextureLoader textureWithCGImage:[UIImage imageNamed:@"Earth512x256.jpg"].CGImage options:options error:nil];

    cEffect.texture2d0.enabled = GL_TRUE;
    cEffect.texture2d0.name = earthTexture.name;
}

//太阳光
- (void)configureLight
{
    cEffect.light0.enabled = GL_TRUE;
    cEffect.light0.diffuseColor = GLKVector4Make(1,1,1,1);// Alpha
    cEffect.light0.position = GLKVector4Make(1,0,0.8,0);
    cEffect.light0.ambientColor = GLKVector4Make(0.2,0.2,0.2,1);// Alpha
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [self drawEarth];
}

- (void)drawEarth
{
    
    self.earthRotationAngleDegrees += 360.0f / 60.0f;
    
    GLKMatrixStackPush(self.modelviewMatrixStack);
    
    GLKMatrixStackRotate(self.modelviewMatrixStack,
                         GLKMathDegreesToRadians(SceneEarthAxialTiltDeg),
                         1.0, 0.0, 0.0);

    GLKMatrixStackRotate(self.modelviewMatrixStack,
                         GLKMathDegreesToRadians(self.earthRotationAngleDegrees),
                         0.0, 1.0, 0.0);

    cEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
    
    [cEffect prepareToDraw];
    
    [AGLKVertexAttribArrayBuffer
     drawPreparedArraysWithMode:GL_TRIANGLES
     startVertexIndex:0
     numberOfVertices:sphereNumVerts];
    
    GLKMatrixStackPop(self.modelviewMatrixStack);
    cEffect.transform.modelviewMatrix =
    GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
}

@end
