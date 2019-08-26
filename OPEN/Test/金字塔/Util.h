//
//  Util.h
//  OPEN
//
//  Created by jing huang on 2019/8/26.
//  Copyright © 2019 jing huang. All rights reserved.
//

#import <GLKit/GLKit.h>

//顶点数据结构
typedef struct {
    GLKVector3  position; //顶点向量
    GLKVector3  color;    //颜色
    GLKVector3  normal;   //法线向量
}OPVertex;

typedef struct {
    OPVertex vertices[3];
}OPTriangle;

//
OPTriangle OPTriangleMake(OPVertex vertexA,OPVertex vertexB,OPVertex vertexC);

//求法向量
GLKVector3 OPTriangleFaceNormal(const OPTriangle triangle);

//更新法向量
void OPTrianglesUpdateFaceNormals(OPTriangle someTriangles[],int count);
