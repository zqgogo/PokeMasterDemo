//
//  TestMetalTextureCubeViewController.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2024/4/8.
//

import MetalKit
import GLKit

class TestMetalTextureCubeViewController: UIViewController {

    // View properties
    var mtkView: MTKView!
    var rotationEyePosition = false
    var rotationEyeLookat = false
    var slider = 0.0
    var angle: Float = 0
    var angleLook: Float = 0
    
    // 3D properties
    var eyePosition: GLKVector3 = GLKVector3Make(0.0, 0.0, 0.0)
    var lookAtPosition: GLKVector3 = GLKVector3Make(0.0, 0.0, 0.0)
    var upVector: GLKVector3 = GLKVector3Make(0.0, 1.0, 0.0)
    
    // Rendering properties
    var viewportSize: simd_uint2 = simd_uint2(0, 0)
    var pipelineState: MTLRenderPipelineState!
    var depthStencilState: MTLDepthStencilState!
    var commandQueue: MTLCommandQueue!
    var texture: MTLTexture!
    var vertices: MTLBuffer!
    var verticesCount: UInt32 = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setup3DEnvironment()
    }
    
    private func setupView() {
        mtkView = MTKView(frame: view.bounds)
        mtkView.device = MTLCreateSystemDefaultDevice()
        //        view.addSubview(mtkView)
        view = mtkView
        mtkView.delegate = self
        mtkView.preferredFramesPerSecond = 60
    }
    
    private func setup3DEnvironment() {
        viewportSize = simd_uint2(UInt32(mtkView.layer.frame.size.width), UInt32(mtkView.layer.frame.size.height))
        eyePosition = GLKVector3Make(0.0, 0.0, 0.0)
        lookAtPosition = GLKVector3Make(0.0, 0.0, 0.0)
        upVector = GLKVector3Make(0.0, 1.0, 0.0)
        
        setupPipeline()
        setupVertices()
        setupTexture()
    }
    
    func setupPipeline() {
        guard let device = mtkView.device else { return }
        guard let defaultLibrary = device.makeDefaultLibrary() else { return }
        guard let vertexFunction = defaultLibrary.makeFunction(name: "vertexShader_7_cube") else { return }
        guard let fragmentFunction = defaultLibrary.makeFunction(name: "samplingShader_7_cube") else { return }
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            print("Failed to create pipeline state: $error)")
        }
        commandQueue = device.makeCommandQueue()
    }
    
    func setupVertices() {
        // Define the vertices for the cube
        let quadVertices: [LYVertex] = [
            // 上面
            LYVertex(position: vector_float4(-6.0, 6.0, 6.0, 1.0), color: vector_float3 (1.0, 0.0, 0.0), textureCoordinate: vector_float2(0.0, 2.0/6.0)), // 左上 0
            LYVertex(position: vector_float4(-6.0, -6.0, 6.0, 1.0), color: vector_float3 (0.0, 0.0, 1.0), textureCoordinate: vector_float2(0.0, 3.0/6.0)), // 左下 2
            LYVertex(position: vector_float4(6.0, -6.0, 6.0, 1.0), color: vector_float3 (1.0, 1.0, 1.0), textureCoordinate: vector_float2(1.0, 3.0/6.0)), // 右下 3
            
            LYVertex(position:  vector_float4(-6.0, 6.0, 6.0, 1.0), color: vector_float3 (1.0, 0.0, 0.0), textureCoordinate: vector_float2(0.0, 2.0/6.0)), // 左上 0
            LYVertex(position:  vector_float4(6.0, 6.0, 6.0, 1.0), color: vector_float3 (0.0, 1.0, 0.0), textureCoordinate: vector_float2(1.0, 2.0/6.0)), // 右上 1
            LYVertex(position:  vector_float4(6.0, -6.0, 6.0, 1.0), color: vector_float3 (1.0, 1.0, 1.0), textureCoordinate: vector_float2(1.0, 3.0/6.0)), // 右下 3
            
            // 下面
            LYVertex(position:  vector_float4(-6.0, 6.0, -6.0, 1.0), color: vector_float3 (1.0, 0.0, 0.0), textureCoordinate: vector_float2(0.0, 4.0/6.0)), // 左上 4
            LYVertex(position:  vector_float4(6.0, 6.0, -6.0, 1.0), color: vector_float3 (0.0, 1.0, 0.0), textureCoordinate: vector_float2(1.0, 4.0/6.0)), // 右上 5
            LYVertex(position:  vector_float4(6.0, -6.0, -6.0, 1.0), color: vector_float3 (1.0, 1.0, 1.0), textureCoordinate: vector_float2(1.0, 3.0/6.0)), // 右下 7
            
            LYVertex(position:  vector_float4(-6.0, 6.0, -6.0, 1.0), color: vector_float3 (1.0, 0.0, 0.0), textureCoordinate: vector_float2(0.0, 4.0/6.0)), // 左上 4
            LYVertex(position:  vector_float4(-6.0, -6.0, -6.0, 1.0), color: vector_float3 (0.0, 0.0, 1.0), textureCoordinate: vector_float2(0.0, 3.0/6.0)), // 左下 6
            LYVertex(position:  vector_float4(6.0, -6.0, -6.0, 1.0), color: vector_float3 (1.0, 1.0, 1.0), textureCoordinate: vector_float2(1.0, 3.0/6.0)), // 右下 7
            
            // 左面
            LYVertex(position:  vector_float4(-6.0, 6.0, 6.0, 1.0), color: vector_float3 (1.0, 0.0, 0.0), textureCoordinate: vector_float2(0.0, 1.0/6.0)), // 左上 0
            LYVertex(position:  vector_float4(-6.0, -6.0, 6.0, 1.0), color: vector_float3 (0.0, 0.0, 1.0), textureCoordinate: vector_float2(1.0, 1.0/6.0)), // 左下 2
            LYVertex(position:  vector_float4(-6.0, 6.0, -6.0, 1.0), color: vector_float3 (1.0, 0.0, 0.0), textureCoordinate: vector_float2(0.0, 2.0/6.0)), // 左上 4
            
            LYVertex(position:  vector_float4(-6.0, -6.0, 6.0, 1.0), color: vector_float3 (0.0, 0.0, 1.0), textureCoordinate: vector_float2(1.0, 1.0/6.0)), // 左下 2
            LYVertex(position:  vector_float4(-6.0, 6.0, -6.0, 1.0), color: vector_float3 (1.0, 0.0, 0.0), textureCoordinate: vector_float2(0.0, 2.0/6.0)), // 左上 4
            LYVertex(position:  vector_float4(-6.0, -6.0, -6.0, 1.0), color: vector_float3 (0.0, 0.0, 1.0), textureCoordinate: vector_float2(1.0, 2.0/6.0)), // 左下 6
            
            // 右面
            LYVertex(position:  vector_float4(6.0, 6.0, 6.0, 1.0), color: vector_float3 (0.0, 1.0, 0.0), textureCoordinate: vector_float2(1.0, 0.0/6.0)), // 右上 1
            LYVertex(position:  vector_float4(6.0, -6.0, 6.0, 1.0), color: vector_float3 (1.0, 1.0, 1.0), textureCoordinate: vector_float2(0.0, 0.0/6.0)), // 右下 3
            LYVertex(position:  vector_float4(6.0, 6.0, -6.0, 1.0), color: vector_float3 (0.0, 1.0, 0.0), textureCoordinate: vector_float2(1.0, 1.0/6.0)), // 右上 5
            
            LYVertex(position:  vector_float4(6.0, -6.0, 6.0, 1.0), color: vector_float3 (1.0, 1.0, 1.0), textureCoordinate: vector_float2(0.0, 0.0/6.0)), // 右下 3
            LYVertex(position:  vector_float4(6.0, 6.0, -6.0, 1.0), color: vector_float3 (0.0, 1.0, 0.0), textureCoordinate: vector_float2(1.0, 1.0/6.0)), // 右上 5
            LYVertex(position:  vector_float4(6.0, -6.0, -6.0, 1.0), color: vector_float3 (1.0, 1.0, 1.0), textureCoordinate: vector_float2(0.0, 1.0/6.0)), // 右下 7
            
            // 前面
            LYVertex(position:  vector_float4(-6.0, -6.0, 6.0, 1.0), color: vector_float3 (0.0, 0.0, 1.0), textureCoordinate: vector_float2(0.0, 4.0/6.0)), // 左下 2
            LYVertex(position:  vector_float4(6.0, -6.0, 6.0, 1.0), color: vector_float3 (1.0, 1.0, 1.0), textureCoordinate: vector_float2(1.0, 4.0/6.0)), // 右下 3
            LYVertex(position:  vector_float4(6.0, -6.0, -6.0, 1.0), color: vector_float3 (1.0, 1.0, 1.0), textureCoordinate: vector_float2(1.0, 5.0/6.0)), // 右下 7
            
            LYVertex(position:  vector_float4(-6.0, -6.0, 6.0, 1.0), color: vector_float3 (0.0, 0.0, 1.0), textureCoordinate: vector_float2(0.0, 4.0/6.0)), // 左下 2
            LYVertex(position:  vector_float4(-6.0, -6.0, -6.0, 1.0), color: vector_float3 (0.0, 0.0, 1.0), textureCoordinate: vector_float2(0.0, 5.0/6.0)), // 左下 6
            LYVertex(position:  vector_float4(6.0, -6.0, -6.0, 1.0), color: vector_float3 (1.0, 1.0, 1.0), textureCoordinate: vector_float2(1.0, 5.0/6.0)), // 右下 7
            
            // 后面
            LYVertex(position:  vector_float4(-6.0, 6.0, 6.0, 1.0), color: vector_float3 (1.0, 0.0, 0.0), textureCoordinate: vector_float2(1.0, 5.0/6.0)), // 左上 0
            LYVertex(position:  vector_float4(6.0, 6.0, 6.0, 1.0), color: vector_float3 (0.0, 1.0, 0.0), textureCoordinate: vector_float2(0.0, 5.0/6.0)), // 右上 1
            LYVertex(position:  vector_float4(6.0, 6.0, -6.0, 1.0), color: vector_float3 (0.0, 1.0, 0.0), textureCoordinate: vector_float2(0.0, 6.0/6.0)), // 右上 5
            
            LYVertex(position:  vector_float4(-6.0, 6.0, 6.0, 1.0), color: vector_float3 (1.0, 0.0, 0.0), textureCoordinate: vector_float2(1.0, 5.0/6.0)), // 左上 0
            LYVertex(position:  vector_float4(-6.0, 6.0, -6.0, 1.0), color: vector_float3 (1.0, 0.0, 0.0), textureCoordinate: vector_float2(1.0, 6.0/6.0)), // 左上 4
            LYVertex(position:  vector_float4(6.0, 6.0, -6.0, 1.0), color: vector_float3 (0.0, 1.0, 0.0), textureCoordinate: vector_float2(0.0, 6.0/6.0)), // 右上 5
        ]
        
        // Create the vertex buffer
        vertices = mtkView.device!.makeBuffer(bytes: quadVertices, length: MemoryLayout<LYVertex>.stride * quadVertices.count, options: [])
        verticesCount = UInt32(quadVertices.count)
    }
    
    func setupTexture() {
        guard let image = UIImage(named: "cube") else { return }
        
        let textureDescriptor = MTLTextureDescriptor.textureCubeDescriptor(pixelFormat: .rgba8Unorm, size: Int(image.size.width), mipmapped: false)
        texture = mtkView.device!.makeTexture(descriptor: textureDescriptor)
        
        let region = MTLRegionMake2D(0, 0, Int(image.size.width), Int(image.size.width))
        let pixels = image.size.width * image.size.width
        
        guard let imageBytes = loadImage(image: image) else { return }
        // 创建一个 UnsafeMutableRawBufferPointer 来包装 imageBytes
        let buffer = UnsafeMutableRawBufferPointer(start: imageBytes, count: Int(pixels) * 4 * 6)
        
        for i in 0 ..< 6 {
            // 使用偏移量创建一个新的 UnsafeMutableRawPointer 指向当前切片的数据
            // 计算当前切片的偏移量
            let offset = i * Int(pixels) * 4
            guard let slicePointer = buffer.baseAddress?.advanced(by: offset) else {
                continue
            }
            texture.replace(region: region, mipmapLevel: 0, slice: i, withBytes: slicePointer, bytesPerRow: 4 * Int(image.size.width), bytesPerImage: Int(pixels) * 4)
        }
    }
    
    private func loadImage(image: UIImage) -> UnsafeMutableRawPointer? {
        guard let cgImage = image.cgImage else {
            return nil
        }
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel: Int = 4
        let bytesPerRow = width * bytesPerPixel
        let totalBytes = height * bytesPerRow
        let data = malloc(totalBytes)
        
        guard let context = CGContext(data: data, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: cgImage.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        
        context.draw(cgImage, in: CGRect(origin: .zero, size: image.size))
        
        return data
    }
    
    func getMetalMatrixFromGLKMatrix(_ matrix: GLKMatrix4) -> matrix_float4x4 {
        return matrix_float4x4(
            simd_make_float4(matrix.m00, matrix.m01, matrix.m02, matrix.m03),
            simd_make_float4(matrix.m10, matrix.m11, matrix.m12, matrix.m13),
            simd_make_float4(matrix.m20, matrix.m21, matrix.m22, matrix.m23),
            simd_make_float4(matrix.m30, matrix.m31, matrix.m32, matrix.m33)
        )
    }
    
    func setupMatrixWithEncoder(_ renderEncoder: MTLRenderCommandEncoder) {
        if rotationEyePosition {
            angle += Float(slider)
        }
        if rotationEyeLookat {
            angleLook += Float(slider)
        }
        
        eyePosition = GLKVector3Make(2.0 * sin(angle), 2.0 * cos(angle), 0.0)
        lookAtPosition = GLKVector3Make(2.0 * sin(angleLook), 2.0 * cos(angleLook), 2.0)
        
        let size = view.bounds.size
        let aspect = size.width / size.height
        let projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(85.0), Float(aspect), 0.1, 100.0)
        let modelViewMatrix = GLKMatrix4MakeLookAt(
            eyePosition.x,
            eyePosition.y,
            eyePosition.z,
            lookAtPosition.x,
            lookAtPosition.y,
            lookAtPosition.z,
            upVector.x,
            upVector.y,
            upVector.z
        )
        
        var matrix = LYMatrix(projectionMatrix: getMetalMatrixFromGLKMatrix(projectionMatrix), modelViewMatrix: getMetalMatrixFromGLKMatrix(modelViewMatrix))
        
        //        let rawPointer = withUnsafePointer(to: &matrix) { UnsafeMutableRawPointer(mutating: $0) }
        renderEncoder.setVertexBytes(&matrix, length: MemoryLayout<LYMatrix>.stride, index: LYVertexInputIndex.matrix.rawValue)
    }
}

extension TestMetalTextureCubeViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        viewportSize = simd_uint2(UInt32(size.width), UInt32(size.height))
    }
    
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue?.makeCommandBuffer(),
              let renderPassDescriptor = view.currentRenderPassDescriptor else {
            return
        }
        
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.6, 0.6, 1.0)
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        
        renderEncoder.setViewport(MTLViewport(originX: 0.0, originY: 0.0, width: Double(viewportSize.x), height: Double(viewportSize.y), znear: 0.0, zfar: 1.0))
        renderEncoder.setRenderPipelineState(pipelineState)
        
        setupMatrixWithEncoder(renderEncoder)
        
        renderEncoder.setVertexBuffer(vertices, offset: 0, index: LYVertexInputIndex.vertices.rawValue)
        
        renderEncoder.setFragmentTexture(texture, index: LYFragmentInputIndex.texture.rawValue)
        
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: Int(verticesCount))
        
        renderEncoder.endEncoding()
        
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
    
    struct LYVertex {
        var position: vector_float4 // 顶点
        var color: vector_float3 // 颜色
        var textureCoordinate: vector_float2 // 纹理
    }
    
    struct LYMatrix {
        var projectionMatrix: matrix_float4x4 // 投影变换
        var modelViewMatrix: matrix_float4x4 // 模型变换
    }
    
    enum LYVertexInputIndex: Int {
        case vertices = 0
        case matrix = 1
    }
    
    enum LYFragmentInputIndex: Int {
        case texture = 0
    }
}
