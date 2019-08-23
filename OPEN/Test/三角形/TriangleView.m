//
//  TriangleView.m
//  OPEN
//
//  Created by jing huang on 2019/8/23.
//  Copyright © 2019 jing huang. All rights reserved.
//

#import "TriangleView.h"

@implementation TriangleView

- (void)render
{
    GLfloat attrArr[] =
    {
        0, 0.5f, 0.0f,      1, 0, 0,
        0.5f, -0.5f, 0.0f,       0, 1, 0,
        -0.5f, -0.5f, 0.0f,     0, 0, 1,
    };
    GLuint attrBuffer;
    glGenBuffers(1, &attrBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
    glBufferData(GL_ARRAY_BUFFER, 3 * 6 * sizeof(GLfloat), attrArr, GL_DYNAMIC_DRAW);
    GLuint position = glGetAttribLocation(self.myPrograme, "position");
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 6, (float *)NULL);
    
    GLuint positionColor = glGetAttribLocation(self.myPrograme, "positionColor");
    glEnableVertexAttribArray(positionColor);
    glVertexAttribPointer(positionColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 6, (float *)NULL + 3);
    glDrawArrays(GL_TRIANGLES, 0, 3);
}

@end
