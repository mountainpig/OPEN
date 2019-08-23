//
//  TowerView.m
//  OPEN
//
//  Created by jing huang on 2019/8/23.
//  Copyright © 2019 jing huang. All rights reserved.
//

#import "TowerView.h"
#import "GLESMath.h"
#import "GLESUtils.h"

@interface TowerView()
{
    float xDegree;
    float yDegree;
    float zDegree;
    BOOL zFight;
    BOOL xFight;
    BOOL yFight;
    NSTimer *timer;
}
@end

@implementation TowerView


- (void)dealloc
{
    
}

- (void)addBtn
{
    
    __weak typeof (self) weakSelf = self;
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:weakSelf selector:@selector(reDegree) userInfo:nil repeats:YES];
    
    xDegree = 0;
    yDegree = 0;
    UIButton *_clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _clearButton.tag = 100;
    [_clearButton setTitle:@"x" forState:UIControlStateNormal];
    [_clearButton addTarget:self action:@selector(xRotate) forControlEvents:UIControlEventTouchUpInside];
    _clearButton.frame = CGRectMake(0, 100, 60, 40);
    [self addSubview:_clearButton];
    
    UIButton *colorButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [colorButton setTitle:@"y" forState:UIControlStateNormal];
    [colorButton addTarget:self action:@selector(yRotate) forControlEvents:UIControlEventTouchUpInside];
    colorButton.frame = CGRectMake((self.frame.size.width - 60)/2, 100, 60, 40);
    [self addSubview:colorButton];
    
    colorButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [colorButton setTitle:@"z" forState:UIControlStateNormal];
    [colorButton addTarget:self action:@selector(zRotate) forControlEvents:UIControlEventTouchUpInside];
    colorButton.frame = CGRectMake(self.frame.size.width - 60, 100, 60, 40);
    [self addSubview:colorButton];
}

- (void)xRotate
{
    xFight = !xFight;
}

- (void)yRotate
{
    yFight = !yFight;
}


- (void)zRotate
{
    zFight = !zFight;
}

- (void)reDegree
{
    if (xFight) {
        xDegree += 10;
    }
    if (yFight) {
        yDegree += 10;
    }
    if (zFight) {
        zDegree += 10;
    }
    [self render];
}

- (NSString *)shaderName
{
    [self addBtn];
    return @"towerShader";
}

- (void)render
{
    glClearColor(0, 0.0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    GLfloat attrArr[] =
    {
        0, 0.5f, 0.0f,           1, 0, 0,
        0.5f, -0.5f, 0.5f,       0, 1, 0,
        0.5f, -0.5f, -0.5f,     0, 0, 1,
        -0.5f, -0.5f, -0.5f,     0, 1, 0,
        -0.5f, -0.5f, 0.5f,     0, 0, 1,
    };
    
    GLuint indices[] =
    {
        0, 1, 2,
        0, 2, 3,
        0, 3, 4,
        0, 4, 1,
        2, 4, 3,
        2, 1, 4,
    };
    
    GLuint attrBuffer;
    glGenBuffers(1, &attrBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
    GLuint position = glGetAttribLocation(self.myPrograme, "position");
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 6, (float *)NULL);
    
    GLuint positionColor = glGetAttribLocation(self.myPrograme, "positionColor");
    glEnableVertexAttribArray(positionColor);
    glVertexAttribPointer(positionColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 6, (float *)NULL + 3);
    
    
    GLuint projectionMatrixSlot = glGetUniformLocation(self.myPrograme, "projectionMatrix");
    GLuint modelViewMatrixSlot = glGetUniformLocation(self.myPrograme, "modelViewMatrix");
    float width = self.frame.size.width;
    float height = self.frame.size.height;

    KSMatrix4 _projectionMatrix;
    ksMatrixLoadIdentity(&_projectionMatrix);
    float aspect = width / height; //长宽比
    ksPerspective(&_projectionMatrix, 30.0, aspect, 5.0f, 20.0f);
    glUniformMatrix4fv(projectionMatrixSlot, 1, GL_FALSE, (GLfloat*)&_projectionMatrix.m[0][0]);
    
    KSMatrix4 _modelViewMatrix;
    ksMatrixLoadIdentity(&_modelViewMatrix);
    ksTranslate(&_modelViewMatrix, 0.0, 0.0, -10.0);

    KSMatrix4 _rotationMatrix;
    ksMatrixLoadIdentity(&_rotationMatrix);
    ksRotate(&_rotationMatrix, xDegree, 1.0, 0.0, 0.0); //绕X轴
    ksRotate(&_rotationMatrix, yDegree, 0.0, 1.0, 0.0); //绕Y轴
    ksRotate(&_rotationMatrix, zDegree, 0.0, 0.0, 1.0); //绕Z轴
    ksMatrixMultiply(&_modelViewMatrix, &_rotationMatrix, &_modelViewMatrix);
    
    glUniformMatrix4fv(modelViewMatrixSlot, 1, GL_FALSE, (GLfloat*)&_modelViewMatrix.m[0][0]);

    glEnable(GL_CULL_FACE);
    
    
    glDrawElements(GL_TRIANGLES, sizeof(indices) / sizeof(indices[0]), GL_UNSIGNED_INT, indices);
    [self.myContext presentRenderbuffer:GL_RENDERBUFFER];
}


@end
