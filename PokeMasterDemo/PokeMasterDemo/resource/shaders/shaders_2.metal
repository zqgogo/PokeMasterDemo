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
    vector_float4 position;
    vector_float3 color;
    vector_float2 textureCoordinate;
} LYVertex;


typedef struct
{
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 modelViewMatrix;
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

typedef struct
{
    float4 clipSpacePosition [[position]];
    float3 pixelColor;
    float2 textureCoordinate;
    
} RasterizerData;

vertex RasterizerData // 顶点
vertexShader_2(uint vertexID [[ vertex_id ]],
             constant LYVertex *vertexArray [[ buffer(LYVertexInputIndexVertices) ]],
             constant LYMatrix *matrix [[ buffer(LYVertexInputIndexMatrix) ]]) {
    RasterizerData out;
    out.clipSpacePosition = matrix->projectionMatrix * matrix->modelViewMatrix * vertexArray[vertexID].position;
    out.textureCoordinate = vertexArray[vertexID].textureCoordinate;
    out.pixelColor = vertexArray[vertexID].color;
    
//    out.clipSpacePosition = vertexArray[vertexID].position;
    
    return out;
}

fragment float4 // 片元
samplingShader_2(RasterizerData input [[stage_in]],
               texture2d<half> textureColor [[ texture(LYFragmentInputIndexTexture) ]])
{
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear);
    
    half4 colorTex = textureColor.sample(textureSampler, input.textureCoordinate);
//    half4 colorTex = half4(input.pixelColor.x, input.pixelColor.y, input.pixelColor.z, 1);
    return float4(colorTex);
//    return float4(1.0, 0.0, 0.0, 1.0); // 返回红色
}
