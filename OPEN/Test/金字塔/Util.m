//
//  Util.m
//  OPEN
//
//  Created by jing huang on 2019/8/26.
//  Copyright © 2019 jing huang. All rights reserved.
//

#import "Util.h"

OPTriangle OPTriangleMake(OPVertex vertexA,OPVertex vertexB,OPVertex vertexC)
{
    OPTriangle   result;
    /*
    OPVertex vertex1 = {vertexA.position, vertexA.color,vertexA.normal};
    result.vertices[0] = vertex1;
    
    OPVertex vertex2 = {vertexB.position, vertexB.color,vertexB.normal};
    result.vertices[1] = vertex2;
    
    OPVertex vertex3 = {vertexC.position, vertexC.color,vertexC.normal};
    result.vertices[2] = vertex3;
    */

    result.vertices[0] = vertexA;
    result.vertices[1] = vertexB;
    result.vertices[2] = vertexC;

    return result;
}

GLKVector3 OPTriangleFaceNormal(const OPTriangle triangle)
{
    GLKVector3 vectorA = GLKVector3Subtract(triangle.vertices[1].position,
                                            triangle.vertices[0].position);
    //vectorB =  v2 - v0
    GLKVector3 vectorB = GLKVector3Subtract(triangle.vertices[2].position,
                                            triangle.vertices[0].position);
    
    return  GLKVector3Normalize(GLKVector3CrossProduct(vectorA, vectorB));
}

void OPTrianglesUpdateFaceNormals(OPTriangle someTriangles[],int count)
{
    for (int i = 0; i<count; i++)
    {
        //计算平面法向量
        GLKVector3 faceNormal = OPTriangleFaceNormal(someTriangles[i]);
        
        //更新每个点的平面法向量
        someTriangles[i].vertices[0].normal = faceNormal;
        someTriangles[i].vertices[1].normal = faceNormal;
        someTriangles[i].vertices[2].normal = faceNormal;
    }
}

//更新颜色
OPTriangle OPTrianglesUpdateFaceColor(OPTriangle triangle,GLKVector3 color)
{

    triangle.vertices[0].color = color;
    triangle.vertices[1].color = color;
    triangle.vertices[2].color = color;
    return triangle;
}
