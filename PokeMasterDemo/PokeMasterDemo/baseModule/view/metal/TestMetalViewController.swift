//
//  TestMetalViewController.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2024/3/27.
//

import UIKit
import MetalKit
import Metal
import CoreGraphics

class TestMetalViewController: UIViewController {
    
    private var mtkView: MTKView!
    
    var viewportSize: vector_float2 = vector_float2.zero
    var pipelineState: MTLRenderPipelineState?
    var commandQueue: MTLCommandQueue?
    var texture: MTLTexture?
    var verticesBuffer: MTLBuffer?
    var numVertices: Int = 0
    
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
        mtkView = MTKView(frame: view.bounds)
        mtkView.device = device
        mtkView.delegate = self
        mtkView.framebufferOnly = true
//        view.addSubview(mtkView)
        view = mtkView
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
        guard let vertexFunction = library.makeFunction(name: "vertexShader_1"),
              let fragmentFunction = library.makeFunction(name: "samplingShader_1") else {
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
            LYVertex(position: vector_float4(0.5, -0.5, 0.0, 1.0), texCoord: vector_float2(1.0, 1.0)),
            LYVertex(position: vector_float4(-0.5, -0.5, 0.0, 1.0), texCoord: vector_float2(0.0, 1.0)),
            LYVertex(position: vector_float4(-0.5, 0.5, 0.0, 1.0), texCoord: vector_float2(0.0, 0.0)),
            
            LYVertex(position: vector_float4(0.5, -0.5, 0.0, 1.0), texCoord: vector_float2(1.0, 1.0)),
            LYVertex(position: vector_float4(-0.5, 0.5, 0.0, 1.0), texCoord: vector_float2(0.0, 0.0)),
            LYVertex(position: vector_float4(0.5, 0.5, 0.0, 1.0), texCoord: vector_float2(1.0, 0.0)),
        ]
        
        verticesBuffer = mtkView.device?.makeBuffer(bytes: quadVertices, length: MemoryLayout<LYVertex>.stride * quadVertices.count, options: .storageModeShared)
        numVertices = quadVertices.count
    }
    
    // 设置纹理
    private func setupTexture() {
        guard let image = UIImage(named: "Pokemon-9") else { return print("Failed to load texture image.") }
        
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.pixelFormat = .rgba8Unorm
        textureDescriptor.width = Int(image.size.width)
        textureDescriptor.height = Int(image.size.height)
        textureDescriptor.usage = [.renderTarget, .shaderRead]
        
        texture = mtkView.device?.makeTexture(descriptor: textureDescriptor)
        
        guard let cgImage = image.cgImage else { return print("Failed to get CGImage from UIImage.") }
        let imageBytes = convertUIImageToRawBytes(cgImage: cgImage, width: Int(image.size.width), height: Int(image.size.height))
        
        if let imageDataBytes = imageBytes?.withUnsafeBytes({ $0.baseAddress! }) {
            let region = MTLRegionMake2D(0, 0, Int(image.size.width), Int(image.size.height))
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
}

extension TestMetalViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        viewportSize = vector_float2(x: Float(size.width), y: Float(size.height))
    }
    
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue?.makeCommandBuffer(),
              let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 0.5, blue: 0.5, alpha: 1.0)
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        
        renderEncoder.setViewport(MTLViewport(originX: 0.0, originY: 0.0, width: Double(Float(viewportSize.x)), height: Double(Float(viewportSize.y)), znear: -1.0, zfar: 1.0))
        renderEncoder.setRenderPipelineState(pipelineState!)
        
        renderEncoder.setVertexBuffer(verticesBuffer!, offset: 0, index: 0)
        renderEncoder.setFragmentTexture(texture!, index: 0)
        
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: Int(UInt32(numVertices)))
        
        renderEncoder.endEncoding()
        
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
    
    // 定义顶点结构体（假设已在LYShaderTypes.swift中定义）
    struct LYVertex {
        var position: vector_float4
        var texCoord: vector_float2
    }
}
