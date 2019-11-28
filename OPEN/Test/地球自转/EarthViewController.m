//
//  EarthViewController.m
//  OPEN
//
//  Created by jing huang on 2019/8/23.
//  Copyright © 2019 jing huang. All rights reserved.
//

#import "EarthViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "sphere.h"

@interface EarthViewController ()
{
    EAGLContext *context;
    GLKBaseEffect *cEffect;
    float _rate;
}
@property (nonatomic) GLKMatrixStackRef modelviewMatrixStack;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexPositionBuffer;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexNormalBuffer;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexTextureCoordBuffer;

@property (nonatomic) GLfloat earthRotationAngleDegrees;
@property (nonatomic) GLfloat moonRotationAngleDegrees;

@property (nonatomic, strong) GLKTextureInfo *earthTexture;
@property (nonatomic, strong) GLKTextureInfo *moonTexture;
@end


@implementation EarthViewController

//static const GLfloat  SceneEarthAxialTiltDeg = 23.5f;
//static const GLfloat  SceneDaysPerMoonOrbit = 28.0f;
static const GLfloat  SceneMoonRadiusFractionOfEarth = 0.25;
static const GLfloat  SceneMoonDistanceFromEarth = 1.0;

- (void)dealloc
{
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpConfig];
    [self setUpEffect];
    [self setUpVertexData];
    [self setUpTexture];
    [self addAdjustBtn];
}

#pragma mark - draw
- (void)addAdjustBtn
{
    UIButton *bigBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bigBtn.frame = CGRectMake(10, 80, 60, 40);
    [self.view addSubview:bigBtn];
    bigBtn.backgroundColor = [UIColor whiteColor];
    [bigBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [bigBtn setTitle:@"big" forState:UIControlStateNormal];
    [bigBtn addTarget:self action:@selector(bigClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *smallBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    smallBtn.frame = CGRectMake(90, 80, 60, 40);
    [self.view addSubview:smallBtn];
    smallBtn.backgroundColor = [UIColor whiteColor];
    [smallBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [smallBtn setTitle:@"small" forState:UIControlStateNormal];
    [smallBtn addTarget:self action:@selector(smallClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)bigClick
{
    _rate -= 0.1;
    _rate = MAX(0.1, _rate);
    GLfloat   aspectRatio =
    (self.view.bounds.size.width) /
    (self.view.bounds.size.height);
    cEffect.transform.projectionMatrix =
    GLKMatrix4MakeFrustum(
                        -1.0 * aspectRatio* _rate,
                        1.0 * aspectRatio* _rate,
                        -1.0 * _rate,
                        1.0* _rate,
                        1.0,
                        120.0);
}

- (void)smallClick
{
    _rate += 0.1;
    GLfloat   aspectRatio =
    (self.view.bounds.size.width) /
    (self.view.bounds.size.height);
    cEffect.transform.projectionMatrix =
    GLKMatrix4MakeFrustum(
                        -1.0 * aspectRatio* _rate,
                        1.0 * aspectRatio* _rate,
                        -1.0 * _rate,
                        1.0* _rate,
                        1.0,
                        120.0);
}

-(void)setUpConfig
{
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:context];
    GLKView *view = (GLKView *)self.view;
    view.context = context;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    glClearColor(0, 0, 0, 1.0);
    glEnable(GL_DEPTH_TEST);
}

- (void)setUpEffect
{
    cEffect = [[GLKBaseEffect alloc] init];
    [self configureLight];
    
    GLfloat   aspectRatio =
    (self.view.bounds.size.width) /
    (self.view.bounds.size.height);
    
    _rate = 1;
    cEffect.transform.projectionMatrix =
    GLKMatrix4MakeFrustum(
                        -1.0 * aspectRatio* _rate,
                        1.0 * aspectRatio* _rate,
                        -1.0 * _rate,
                        1.0* _rate,
                        1.0,
                        120.0);
    
    cEffect.transform.modelviewMatrix =
    GLKMatrix4MakeTranslation(0.0f, 0.0f, -2);
    
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
    self.earthTexture = [GLKTextureLoader textureWithCGImage:[UIImage imageNamed:@"Earth512x256.jpg"].CGImage options:options error:nil];
    self.moonTexture = [GLKTextureLoader textureWithCGImage:[UIImage imageNamed:@"Moon256x128.png"].CGImage options:options error:nil];
    cEffect.texture2d0.enabled = GL_TRUE;
    cEffect.texture2d0.name = self.earthTexture.name;
    cEffect.texture2d0.target = self.earthTexture.target;
    
    cEffect.texture2d1.enabled =  GL_TRUE;
    cEffect.texture2d1.name = self.moonTexture.name;
    cEffect.texture2d1.target = self.moonTexture.target;
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
//    [self drawMoon];
}

- (void)drawEarth
{
//    cEffect.texture2d0.name = self.earthTexture.name;
//    cEffect.texture2d0.target = self.earthTexture.target;
    
    cEffect.textureOrder = [NSArray arrayWithObjects: cEffect.texture2d0, cEffect.texture2d1, nil];
    
    self.earthRotationAngleDegrees += 1;
    
    GLKMatrixStackPush(self.modelviewMatrixStack);
    /*
    GLKMatrixStackRotate(self.modelviewMatrixStack,
                         GLKMathDegreesToRadians(SceneEarthAxialTiltDeg),
                         1.0, 0.0, 0.0);
    */
    GLKMatrixStackRotate(self.modelviewMatrixStack,
                         GLKMathDegreesToRadians(self.earthRotationAngleDegrees),
                         0.0, 1.0, 0.0);
    
    cEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
    
    [cEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, sphereNumVerts);;
    
    GLKMatrixStackPop(self.modelviewMatrixStack);
    
    /*
    cEffect.transform.modelviewMatrix =
    GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
    GLKMatrixStackPush(self.modelviewMatrixStack);
    GLKMatrixStackTranslate(self.modelviewMatrixStack,
                            0.0, SceneMoonDistanceFromEarth * 1, 0);
    GLKMatrixStackRotate(self.modelviewMatrixStack,
                         GLKMathDegreesToRadians(self.earthRotationAngleDegrees),
                         0.0, 1.0, 0.0);
    cEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
    [cEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, sphereNumVerts);
    GLKMatrixStackPop(self.modelviewMatrixStack);
    cEffect.transform.modelviewMatrix =
    GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
*/
    
}

- (void)drawMoon
{
    
    self.moonRotationAngleDegrees += 360.0f / 60.0f;
    
//    cEffect.texture2d0.name = self.moonTexture.name;
//    cEffect.texture2d0.target = self.moonTexture.target;
    
    cEffect.textureOrder = [NSArray arrayWithObjects: cEffect.texture2d1, cEffect.texture2d0, nil];
    
    
    GLKMatrixStackPush(self.modelviewMatrixStack);
    
    GLKMatrixStackRotate(
                         self.modelviewMatrixStack,
                         GLKMathDegreesToRadians(self.moonRotationAngleDegrees),
                         0.0, 1.0, 0.0);
    GLKMatrixStackTranslate(
                            self.modelviewMatrixStack,
                            0.0, 0.0, SceneMoonDistanceFromEarth);
    GLKMatrixStackScale(
                        self.modelviewMatrixStack,
                        SceneMoonRadiusFractionOfEarth,
                        SceneMoonRadiusFractionOfEarth,
                        SceneMoonRadiusFractionOfEarth);

    
    cEffect.transform.modelviewMatrix =
    GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
    
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
