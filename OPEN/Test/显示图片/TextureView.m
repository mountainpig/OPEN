//
//  TextureView.m
//  OPEN
//
//  Created by jing huang on 2019/11/28.
//  Copyright © 2019 jing huang. All rights reserved.
//

#import "TextureView.h"

@implementation TextureView

- (NSString *)shaderName
{
    return @"textureShader";
}

- (void)render
{
    GLfloat attrArr[] =
    {
        -0.5f, 0.5f, 0.0f,       0, 1,
        -0.5f, -0.5f, 0.0f,      0, 0,
        0.5f, 0.5f, 0.0f,       1, 1,
        0.5f, -0.5f, 0.0f,      1,0,
    };
    GLuint attrBuffer;
    glGenBuffers(1, &attrBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
    glBufferData(GL_ARRAY_BUFFER, 4 * 5 * sizeof(GLfloat), attrArr, GL_DYNAMIC_DRAW);
    GLuint position = glGetAttribLocation(self.myPrograme, "position");
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (float *)NULL);
    
    GLuint textureID = [self setupTexture:@"kunkun.jpg"];

    GLuint textureSlot = glGetUniformLocation(self.myPrograme, "Texture");
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureID);
    glUniform1i(textureSlot, 0);

    GLuint textureCoordsSlot = glGetAttribLocation(self.myPrograme, "TextureCoords");
    glEnableVertexAttribArray(textureCoordsSlot);
    glVertexAttribPointer(textureCoordsSlot, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (float *)NULL + 3);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}


@end
