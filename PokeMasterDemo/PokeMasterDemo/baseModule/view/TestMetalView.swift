////
////  TestMetalView.swift
////  PokeMasterDemo
////
////  Created by qilitech.ltd on 2024/3/26.
////
//
//import UIKit
//import MetalKit
//import Metal
//
//class TestMetalView: UIView {
//    
//    private var device: MTLDevice!
//    private var commandQueue: MTLCommandQueue!
//    private var pipelineState: MTLRenderPipelineState!
//    private var vertexBuffer: MTLBuffer!
//    private var texture: MTLTexture!
//    private var viewportSize: CGSize = CGSize.zero
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        commonInit()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//        commonInit()
//    }
//    
//    private func commonInit() {
//        device = MTLCreateSystemDefaultDevice()!
//        commandQueue = device.makeCommandQueue()!
//        setupRenderResources()
//    }
//    
//    private func setupRenderResources() {
//        // 设置渲染管道、顶点缓冲区、纹理等...
//        // 这部分代码与之前Objective-C示例中的代码类似，但使用Swift语法
//        // 例如，加载着色器、创建纹理、顶点缓冲区等
//        // 这里需要根据实际情况填写代码，以下是一个简化的示例
//        let defaultLibrary = device.makeDefaultLibrary()
//        let vertexFunction = defaultLibrary?.makeFunction(name: "vertexShader")
//        let fragmentFunction = defaultLibrary?.makeFunction(name: "fragmentShader")
//        let pipelineDescriptor = MTLRenderPipelineDescriptor()
//        pipelineDescriptor.vertexFunction = vertexFunction
//        pipelineDescriptor.fragmentFunction = fragmentFunction
//        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
//        do {
//            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
//        } catch {
//            fatalError("Failed to create pipeline state: $error)")
//        }
//        
//        let quadVertices: [TestMetalView.Vertex] = [
//            TestMetalView.Vertex(position: simd_float4(0.5, -0.5, 0, 1), textureCoordinate: simd_float2(1, 1)),
//            TestMetalView.Vertex(position: simd_float4(-0.5, -0.5, 0, 1), textureCoordinate: simd_float2(0, 1)),
//            TestMetalView.Vertex(position: simd_float4(-0.5, 0.5, 0, 1), textureCoordinate: simd_float2(0, 0)),
//            TestMetalView.Vertex(position: simd_float4(0.5, 0.5, 0, 1), textureCoordinate: simd_float2(1, 0))
//        ]
//        vertexBuffer = device.makeBuffer(bytes: quadVertices, length: MemoryLayout<TestMetalView.Vertex>.size * quadVertices.count, options: [])
//        
//        let textureLoader = MTKTextureLoader(device: device)
//        if let textureURL = Bundle.main.url(forResource: "textureImage", withExtension: "png") {
//            do {
//                texture = try textureLoader.newTexture(URL: textureURL)
//            } catch {
//                fatalError("Failed to load texture: $error)")
//            }
//        }
//        
//        // 设置视口的初始大小
//        viewportSize.width = Double(frame.size.width)
//        viewportSize.height = Double(frame.size.height)
//    }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        viewportSize = bounds.size
//        // 当视图布局更新时，可能需要重新创建或更新渲染资源
//    }
//    
//    func draw() {
//        guard let drawable = self.currentDrawable() else { return }
//        let commandBuffer = commandQueue.makeCommandBuffer()!
//        let renderPassDescriptor = self.currentRenderPassDescriptor()
//        renderPassDescriptor!.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.5, 0.5, 1.0)
//        
//        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor!) else { return }
//        renderEncoder.setRenderPipelineState(pipelineState)
//        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
//        renderEncoder.setFragmentTexture(texture, index: 0)
//        renderEncoder.setViewport(MTLViewport(originX: 0, originY: 0, width: Double(viewportSize.width), height: Double(viewportSize.height), znear: -1.0, zfar: 1.0))
//        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
//        renderEncoder.endEncoding()
//        
//        commandBuffer.present(drawable)
//        commandBuffer.commit()
//    }
//    
//    func currentDrawable() -> MTLDrawable? {
//        return self.currentDrawable()
//    }
//    
//    func currentRenderPassDescriptor() -> MTLRenderPassDescriptor? {
//        guard let drawable = self.currentDrawable() else { return nil }
//        return self.renderPassDescriptor(for: drawable.texture!)
//    }
//
//    
//    
//    struct Vertex {
//        var position: vector_float4
//        var textureCoordinate: vector_float2
//    }
//}
