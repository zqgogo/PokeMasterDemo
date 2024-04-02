//
//  TestMetalGrayViewController.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2024/4/2.
//

import UIKit
import MetalKit

class TestMetalGrayViewController: UIViewController {
    
    // view
    var mtkView: MTKView!
    
    // data
    var viewportSize: CGSize = .zero
    var renderPipelineState: MTLRenderPipelineState?
    var computePipelineState: MTLComputePipelineState?
    var commandQueue: MTLCommandQueue?
    var sourceTexture: MTLTexture?
    var destTexture: MTLTexture?
    var vertices: MTLBuffer?
    var numVertices: UInt32 = 0
    var groupSize: MTLSize = MTLSize(width: 0, height: 0, depth: 0)
    var groupCount: MTLSize = MTLSize(width: 0, height: 0, depth: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 初始化 MTKView
        mtkView = MTKView(frame: view.bounds)
        mtkView.device = MTLCreateSystemDefaultDevice() // 获取默认的device
        view = mtkView
        mtkView.delegate = self
        viewportSize = CGSize(width: mtkView.drawableSize.width, height: mtkView.drawableSize.height)
        
        customInit()
    }
    
    func customInit() {
        setupPipeline()
        setupVertex()
        setupTexture()
        setupThreadGroup()
    }
    
    // 设置渲染管道和计算管道
    func setupPipeline() {
        guard let defaultLibrary = mtkView.device?.makeDefaultLibrary() else { return }
        let vertexFunction = defaultLibrary.makeFunction(name: "vertexShader_gray")
        let fragmentFunction = defaultLibrary.makeFunction(name: "samplingShader_gray")
        let kernelFunction = defaultLibrary.makeFunction(name: "grayKernel")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexFunction
        pipelineStateDescriptor.fragmentFunction = fragmentFunction
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        
        do {
            // 创建图形渲染管道，耗性能操作不宜频繁调用
            renderPipelineState = try mtkView.device?.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch let error {
            print("Error creating render pipeline: $error)")
        }
        
        do {
            // 创建计算管道，耗性能操作不宜频繁调用
            computePipelineState = try mtkView.device?.makeComputePipelineState(function: kernelFunction!)
        } catch let error {
            print("Error creating compute pipeline: $error)")
        }
        
        commandQueue = mtkView.device?.makeCommandQueue()
    }
    
    // 设置顶点
    func setupVertex() {
        let quadVertices: [LYVertex] = [
            // 顶点坐标，分别是x、y、z、w；    纹理坐标，x、y；
            LYVertex(position: vector_float4(0.5, Float(-0.5 / viewportSize.height * viewportSize.width), 0.0, 1.0), textureCoordinate: vector_float2(1.0, 1.0)),
            LYVertex(position: vector_float4(-0.5, Float(-0.5 / viewportSize.height * viewportSize.width), 0.0, 1.0), textureCoordinate: vector_float2(0.0, 1.0)),
            LYVertex(position: vector_float4(-0.5,  Float(0.5 / viewportSize.height * viewportSize.width), 0.0, 1.0), textureCoordinate: vector_float2(0.0, 0.0)),
            
            LYVertex(position: vector_float4(0.5, Float(-0.5 / viewportSize.height * viewportSize.width), 0.0, 1.0), textureCoordinate: vector_float2(1.0, 1.0)),
            LYVertex(position: vector_float4(-0.5,  Float(0.5 / viewportSize.height * viewportSize.width), 0.0, 1.0), textureCoordinate: vector_float2(0.0, 0.0)),
            LYVertex(position: vector_float4(0.5,  Float(0.5 / viewportSize.height * viewportSize.width), 0.0, 1.0), textureCoordinate: vector_float2(1.0, 0.0)),
        ]
        
//        let quadVertices: [LYVertex] = [
//            LYVertex(position: vector_float4(0.5, -0.5, 0.0, 1.0), textureCoordinate: vector_float2(1.0, 1.0)),
//            LYVertex(position: vector_float4(-0.5, -0.5, 0.0, 1.0), textureCoordinate: vector_float2(0.0, 1.0)),
//            LYVertex(position: vector_float4(-0.5, 0.5, 0.0, 1.0), textureCoordinate: vector_float2(0.0, 0.0)),
//            
//            LYVertex(position: vector_float4(0.5, -0.5, 0.0, 1.0), textureCoordinate: vector_float2(1.0, 1.0)),
//            LYVertex(position: vector_float4(-0.5, 0.5, 0.0, 1.0), textureCoordinate: vector_float2(0.0, 0.0)),
//            LYVertex(position: vector_float4(0.5, 0.5, 0.0, 1.0), textureCoordinate: vector_float2(1.0, 0.0))
//        ]
        
        vertices = mtkView.device?.makeBuffer(bytes: quadVertices, length: MemoryLayout<LYVertex>.stride * quadVertices.count, options: .storageModeShared)
        numVertices = UInt32(quadVertices.count)
    }
    
    // 设置纹理
    func setupTexture() {
        guard let image = UIImage(named: "abc") else { return }
        
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: Int(image.size.width), height: Int(image.size.height), mipmapped: false)
        textureDescriptor.usage = [.shaderRead]
        sourceTexture = mtkView.device?.makeTexture(descriptor: textureDescriptor)
        
        let region = MTLRegionMake3D(0, 0, 0, Int(image.size.width), Int(image.size.height), 1)
//        if let imageBytes = loadImage(image: image) {
//            sourceTexture?.replace(region: region, mipmapLevel: 0, withBytes: imageBytes, bytesPerRow: Int(image.size.width) * 4)
//            free(imageBytes)
//        }
        
        guard let cgImage = image.cgImage else { return print("Failed to get CGImage from UIImage.") }
        let imageBytes = convertUIImageToRawBytes(cgImage: cgImage, width: Int(image.size.width), height: Int(image.size.height))
        
        if let imageDataBytes = imageBytes?.withUnsafeBytes({ $0.baseAddress! }) {
            sourceTexture?.replace(region: region, mipmapLevel: 0, withBytes: imageDataBytes, bytesPerRow: 4 * Int(image.size.width))
        }
        
        textureDescriptor.usage = [.shaderWrite, .shaderRead]
        destTexture = mtkView.device?.makeTexture(descriptor: textureDescriptor)
    }
    
    // 计算线程组
    func setupThreadGroup() {
        groupSize = MTLSize(width: 16, height: 16, depth: 1)
        
        groupCount.width = (sourceTexture?.width ?? 0 + groupSize.width - 1) / groupSize.width
        groupCount.height = (sourceTexture?.height ?? 0 + groupSize.height - 1) / groupSize.height
        groupCount.depth = 1 // 我们是2D纹理，深度设为1
    }
    
    // 加载图片
    func loadImage(image: UIImage) -> UnsafeMutablePointer<UInt8>? {
        guard let cgImage = image.cgImage else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerRow = width * 4
        let spriteData = UnsafeMutablePointer<UInt8>.allocate(capacity: bytesPerRow * height)
        
        guard let spriteContext = CGContext(data:(spriteData), width: width, height: height, bitsPerComponent: 8, bytesPerRow: 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        
        spriteContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        spriteContext.flush()
        return spriteData
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
}

extension TestMetalGrayViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        viewportSize = CGSize(width: size.width, height: size.height)
    }
    
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue?.makeCommandBuffer() else { return }
        
//        commandBuffer.addCompletedHandler { (buffer) in
//            buffer.commit()
//        }
        
        // 创建计算指令的编码器
        guard let computeEncoder = commandBuffer.makeComputeCommandEncoder() else { return }
        computeEncoder.setComputePipelineState(computePipelineState!)
        computeEncoder.setTexture(sourceTexture, index: LYFragmentInputIndex.textureSource.rawValue)
        computeEncoder.setTexture(destTexture, index: LYFragmentInputIndex.textureDest.rawValue)
        computeEncoder.dispatchThreadgroups(groupCount, threadsPerThreadgroup: groupSize)
        computeEncoder.endEncoding()
        
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 0.5, blue: 0.5, alpha: 1.0)
        
        // MTLRenderPassDescriptor描述一系列attachments的值，类似GL的FrameBuffer；同时也用来创建MTLRenderCommandEncoder
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        renderEncoder.setViewport(MTLViewport(originX: 0.0, originY: 0.0, width: Double(viewportSize.width), height: Double(viewportSize.height), znear: -1.0, zfar: 1.0))
        renderEncoder.setRenderPipelineState(renderPipelineState!)
        renderEncoder.setVertexBuffer(vertices, offset: 0, index: 0)
        renderEncoder.setFragmentTexture(destTexture, index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: Int(numVertices))
        
        renderEncoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)         
        commandBuffer.commit()
    }
    
    // 定义顶点结构体（假设已在LYShaderTypes.swift中定义）
    struct LYVertex {
        var position: vector_float4
        var textureCoordinate: vector_float2
    }
    
    enum LYVertexInputIndex: Int {
        case vertices = 0
    }
    
    enum LYFragmentInputIndex: Int {
        case textureSource = 0
        case textureDest = 1
    }
}
