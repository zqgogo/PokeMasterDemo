//
//  shaders.metal
//  LearnMetal
//
//  Created by loyinglin on 2018/6/21.
//  Copyright © 2018年 loyinglin. All rights reserved.
//

#include <metal_stdlib>
//#import "LYShaderTypes.h"
#include <simd/simd.h>

using namespace metal;

typedef struct
{
    float4 clipSpacePosition [[position]];
    float3 pixelColor;
    float3 textureCoordinate;
    
} RasterizerData;

typedef struct
{
    vector_float4 position; // 顶点
    vector_float3 color; // 颜色
    vector_float2 textureCoordinate; // 纹理
} LYVertex;


typedef struct
{
    matrix_float4x4 projectionMatrix; // 投影变换
    matrix_float4x4 modelViewMatrix; // 模型变换
} LYMatrix;

typedef enum LYVertexInputIndex
{
    LYVertexInputIndexVertices     = 0,
    LYVertexInputIndexMatrix       = 1,
} LYVertexInputIndex;



typedef enum LYFragmentInputIndex
{
    LYFragmentInputIndexTexture     = 0,
} LYFragmentInputIndex;

vertex RasterizerData
vertexShader_7_cube(uint vertexID [[ vertex_id ]],
             constant LYVertex *vertexArray [[ buffer(LYVertexInputIndexVertices) ]],
             constant LYMatrix *matrix [[ buffer(LYVertexInputIndexMatrix) ]]) {
    RasterizerData out;
    out.clipSpacePosition = matrix->projectionMatrix * matrix->modelViewMatrix * vertexArray[vertexID].position;
    out.textureCoordinate = vertexArray[vertexID].position.xyz;
    out.pixelColor = vertexArray[vertexID].color;
    
    return out;
}

fragment float4
samplingShader_7_cube(RasterizerData input [[stage_in]],
               texturecube<half> textureColor [[ texture(LYFragmentInputIndexTexture) ]])
{
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear);
    
    half4 colorTex = textureColor.sample(textureSampler, input.textureCoordinate);
//    half4 colorTex = half4(input.pixelColor.x, input.pixelColor.y, input.pixelColor.z, 1); // 方便调试
    return float4(colorTex);
}
