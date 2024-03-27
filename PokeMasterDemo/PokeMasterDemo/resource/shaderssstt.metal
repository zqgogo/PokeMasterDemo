//
//  shaders.metal
//  LearnMetal
//
//  Created by loyinglin on 2018/6/21.
//  Copyright © 2018年 loyinglin. All rights reserved.
//

#include <metal_stdlib>
//#import "LYShaderTypes.h"

using namespace metal;

typedef struct
{
    vector_float4 position;
    vector_float2 textureCoordinate;
} LYVertex;

typedef struct
{
    float4 clipSpacePosition [[position]]; // position的修饰符表示这个是顶点
    
    float2 textureCoordinate; // 纹理坐标，会做插值处理
    
} RasterizerData;

vertex RasterizerData // 返回给片元着色器的结构体
vertexShader(uint vertexID [[ vertex_id ]], // vertex_id是顶点shader每次处理的index，用于定位当前的顶点
             constant LYVertex *vertexArray [[ buffer(0) ]]) { // buffer表明是缓存数据，0是索引
    RasterizerData out;
//    out.clipSpacePosition = vertexArray[vertexID].position;
//    out.textureCoordinate = vertexArray[vertexID].textureCoordinate;
    // 反转y坐标
    float4 reversedPosition = vertexArray[vertexID].position;
    reversedPosition.y *= -1.0;
    
    out.clipSpacePosition = reversedPosition;
    out.textureCoordinate = vertexArray[vertexID].textureCoordinate;
    return out;
}

fragment float4
samplingShader(RasterizerData input [[stage_in]], // stage_in表示这个数据来自光栅化。（光栅化是顶点处理之后的步骤，业务层无法修改）
               texture2d<half> colorTexture [[ texture(0) ]]) // texture表明是纹理数据，0是索引
{
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear); // sampler是采样器
    
//    half4 colorSample = colorTexture.sample(textureSampler, input.textureCoordinate); // 得到纹理对应位置的颜色
//    
//    // 将颜色变为红色
//    float4 modifiedColor = float4(1.0, 0.0, 0.0, colorSample.a);
//
////    return modifiedColor;
//    return float4(colorSample);
    
    
    //根据坐标范围改变颜色
//    half4 originalColor = colorTexture.sample(textureSampler, input.textureCoordinate);
//
//        // 定义你要调整颜色的纹理坐标范围
//        float2 rangeStart = float2(0.3, 0.5); // 范围起点
//        float2 rangeEnd = float2(0.7, 0.7); // 范围终点
//
//        // 判断当前纹理坐标是否在范围内
//        bool inRange = (input.textureCoordinate.x >= rangeStart.x && input.textureCoordinate.x <= rangeEnd.x) &&
//                       (input.textureCoordinate.y >= rangeStart.y && input.textureCoordinate.y <= rangeEnd.y);
//
//    if (inRange) {
//            // 对于在范围内的纹理坐标，调整颜色，显式转换为 float 类型后再操作
//            float3 modifiedRGB = float3(originalColor.rgb) * float3(0.5, 1.0, 1.0); // 示例：将范围内颜色的红色通道减半，保持绿色通道和蓝色通道不变
//            originalColor.rgb = half3(modifiedRGB); // 再转换回 half 类型
//        }
//
//        // 在返回前，确保整个 float4 的所有组件都是相同类型，这里转换为 float 类型
//        return float4(float3(originalColor.rgb), originalColor.a);
    
    half4 sourceColor = colorTexture.sample(textureSampler, input.textureCoordinate);

        // 将绿色转变为黑色
        half4 convertedColor = sourceColor;
        if (sourceColor.g > 0.0h) { // 检查绿色分量是否非零
            convertedColor.gbr = half3(0.0h, 0.0h, 0.0h); // 将绿色、蓝色和红色分量设为0，得到黑色
        }

        // 将红色转变为棕色（这里我们简化地选择一种棕色，实际情况可能需要指定具体的棕色）
        if (sourceColor.r > 0.0h) { // 检查红色分量是否非零
            // 为了得到棕色，我们可以混合红色和绿色，以及其他颜色分量，这里给出一个简单的例子
            convertedColor.r = mix(sourceColor.r, 0.5h, 0.5h); // 减少红色强度，向棕色靠拢
            convertedColor.g += 0.2h; // 添加一些绿色分量，模拟棕色
            convertedColor.b -= 0.1h; // 减少一点蓝色分量，使颜色更加偏向棕色
        }

        return float4(convertedColor);
}
