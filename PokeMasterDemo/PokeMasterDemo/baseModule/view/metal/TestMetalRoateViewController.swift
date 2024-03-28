//
//  TestMetalRoateViewController.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2024/3/28.
//

import UIKit
import MetalKit
import Metal
import CoreGraphics
import GLKit

class TestMetalRoateViewController: UIViewController {

    private var mtkView: MTKView!
    
    var viewportSize: vector_float2 = vector_float2.zero
    var pipelineState: MTLRenderPipelineState?
    var commandQueue: MTLCommandQueue?
    var texture: MTLTexture?
    var verticesBuffer: MTLBuffer?
    var indexs: MTLBuffer?
    var indexCount: Int = 0
    
    var rotate_x = 0.2
    var rotate_y = 0.3
    var rotate_z = CGFloat.pi
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初始化MTKView
        setupMetalKitView()
        
        // 自定义初始化
        customInit()
    }
    
    // 设置MetalKitView
    private func setupMetalKitView() {
        guard let device = MTLCreateSystemDefaultDevice() else { fatalError("Metal is not supported on this device.") }
        mtkView = MTKView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        mtkView.device = device
        mtkView.delegate = self
//        mtkView.framebufferOnly = true
        view.insertSubview(mtkView, at: 0)
//        view = mtkView
        viewportSize = vector_float2(x: Float(mtkView.drawableSize.width), y: Float(mtkView.drawableSize.height))
    }
    
    // 自定义初始化方法
    private func customInit() {
        setupPipeline()
        setupVertices()
        setupTexture()
    }
    
    // 设置渲染管道
    private func setupPipeline() {
        guard let library = mtkView.device?.makeDefaultLibrary() else { fatalError("Failed to create default Metal library.") }
        guard let vertexFunction = library.makeFunction(name: "vertexShader_2"),
              let fragmentFunction = library.makeFunction(name: "samplingShader_2") else {
            fatalError("Failed to find shader functions.")
        }
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexFunction
        pipelineStateDescriptor.fragmentFunction = fragmentFunction
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        
        do {
            pipelineState = try mtkView.device?.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch {
            fatalError("Failed to create render pipeline state: \(error.localizedDescription)")
        }
        
        commandQueue = mtkView.device?.makeCommandQueue()
    }
    
    // 设置顶点
    private func setupVertices() {
        let quadVertices: [LYVertex] = [
            LYVertex(position: vector_float4(-0.5, 0.5, 0.0, 1.0), color: vector_float3(0.0, 0.0, 0.5), texCoord: vector_float2(0.0, 1.0)),
            LYVertex(position: vector_float4(0.5, 0.5, 0.0, 1.0), color: vector_float3(0.0, 0.5, 0.0), texCoord: vector_float2(1.0, 1.0)),
            LYVertex(position: vector_float4(-0.5, -0.5, 0.0, 1.0), color: vector_float3(0.5, 0.0, 1.0), texCoord: vector_float2(0.0, 0.0)),
            LYVertex(position: vector_float4(0.5, -0.5, 0.0, 1.0), color: vector_float3(0.0, 0.0, 0.5), texCoord: vector_float2(1.0, 0.0)),
            LYVertex(position: vector_float4(0.0, 0.5, 1.0, 1.0), color: vector_float3(1.0, 1.0, 1.0), texCoord: vector_float2(0.5, 0.5))
        ]
        
        verticesBuffer = mtkView.device?.makeBuffer(bytes: quadVertices, length: MemoryLayout<LYVertex>.stride * quadVertices.count, options: .storageModeShared)

        let indices: [UInt32] = [
            // 索引
            0, 3, 2,
            0, 1, 3,
            0, 2, 4,
            0, 4, 1,
            2, 3, 4,
            1, 4, 3
        ]

        indexs = mtkView.device?.makeBuffer(bytes: indices, length: MemoryLayout<UInt32>.stride * indices.count, options: .storageModeShared)
        indexCount = indices.count
    }
    
    // 设置纹理
    private func setupTexture() {
        guard let image = UIImage(named: "Pokemon-9") else { return print("Failed to load texture image.") }
        
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.pixelFormat = .rgba8Unorm
        textureDescriptor.width = Int(image.size.width)
        textureDescriptor.height = Int(image.size.height)
        
        texture = mtkView.device?.makeTexture(descriptor: textureDescriptor)
        
        guard let cgImage = image.cgImage else { return print("Failed to get CGImage from UIImage.") }
        let imageBytes = convertUIImageToRawBytes(cgImage: cgImage, width: Int(image.size.width), height: Int(image.size.height))
        
        if let imageDataBytes = imageBytes?.withUnsafeBytes({ $0.baseAddress! }) {
            let region = MTLRegionMake3D(0, 0, 0, Int(image.size.width), Int(image.size.height), 1)
            texture?.replace(region: region, mipmapLevel: 0, withBytes: imageDataBytes, bytesPerRow: 4 * Int(image.size.width))
        }
    }
    
    // 将UIImage转化为raw bytes
    private func convertUIImageToRawBytes(cgImage: CGImage, width: Int, height: Int) -> Data? {
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let totalBytes = bytesPerRow * height
        
        guard let pixelData = malloc(totalBytes),
              let context = CGContext(data: pixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(origin: .zero, size: CGSize(width: width, height: height)))
        let imageData = Data(bytesNoCopy: pixelData, count: totalBytes, deallocator: .free)
        
        return imageData
    }
    
    func getMetalMatrix(from glkMatrix: GLKMatrix4) -> matrix_float4x4 {
        let metalMatrix = matrix_float4x4(
            columns: (
                simd_float4(glkMatrix.m00, glkMatrix.m01, glkMatrix.m02, glkMatrix.m03),
                simd_float4(glkMatrix.m10, glkMatrix.m11, glkMatrix.m12, glkMatrix.m13),
                simd_float4(glkMatrix.m20, glkMatrix.m21, glkMatrix.m22, glkMatrix.m23),
                simd_float4(glkMatrix.m30, glkMatrix.m31, glkMatrix.m32, glkMatrix.m33)
            )
        )
        return metalMatrix
    }
    
    func setupMatrix(with renderEncoder: MTLRenderCommandEncoder) {
        let viewSize = self.view.bounds.size
        let aspect = abs(viewSize.width / viewSize.height)
        let projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90.0), Float(aspect), 0.1, 10.0)
        var modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0, 0.0, -2.0)
        
//        if rotationX.isOn {
//            x += slider.value
//        }
//        if rotationY.isOn {
//            y += slider.value
//        }
//        if rotationZ.isOn {
//            z += slider.value
//        }
        
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, Float(rotate_x), 1, 0, 0)
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, Float(rotate_y), 0, 1, 0)
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, Float(rotate_z), 0, 0, 1)
        
        let metalProjectionMatrix = getMetalMatrix(from: projectionMatrix)
        let metalModelViewMatrix = getMetalMatrix(from: modelViewMatrix)
        
        var matrix: LYMatrix = LYMatrix(projectionMatrix: metalProjectionMatrix, modelViewMatrix: metalModelViewMatrix)
        let pointer = UnsafeRawPointer(&matrix).assumingMemoryBound(to: LYMatrix.self)
        
        renderEncoder.setVertexBytes(pointer, length: MemoryLayout<LYMatrix>.stride, index: LYVertexInputIndex.matrix.rawValue)
    }
}

extension TestMetalRoateViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        viewportSize = vector_float2(x: Float(size.width), y: Float(size.height))
    }
    
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue?.makeCommandBuffer(),
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let indexBuffers = indexs else { return }
        
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 0.5, blue: 0.5, alpha: 1.0)
        renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadAction.clear
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        
        renderEncoder.setViewport(MTLViewport(originX: 0.0, originY: 0.0, width: Double(Float(viewportSize.x)), height: Double(Float(viewportSize.y)), znear: -1.0, zfar: 1.0))
        renderEncoder.setRenderPipelineState(pipelineState!)
        setupMatrix(with: renderEncoder)
       
        renderEncoder.setVertexBuffer(verticesBuffer!, offset: 0, index: LYVertexInputIndex.vertices.rawValue)
        renderEncoder.setFrontFacing(.counterClockwise)
        renderEncoder.setCullMode(.back)
        
        renderEncoder.setFragmentTexture(texture!, index: LYFragmentInputIndex.texture.rawValue)
        renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: indexCount, indexType: .uint32, indexBuffer: indexBuffers, indexBufferOffset: 0)

        renderEncoder.endEncoding()
        
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
    
    // 定义顶点结构体（假设已在LYShaderTypes.swift中定义）
    struct LYVertex {
        var position: vector_float4
        var color: vector_float3
        var texCoord: vector_float2
    }
    
    struct LYMatrix {
        var projectionMatrix: matrix_float4x4
        var modelViewMatrix: matrix_float4x4
    }
    
    enum LYVertexInputIndex: Int {
        case vertices = 0
        case matrix = 1
    }
    
    enum LYFragmentInputIndex: Int {
        case texture = 0
    }
}
