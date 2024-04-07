//
//  TestMetalSobelViewController.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2024/4/7.
//

import MetalKit
import AVFoundation

class TestMetalSobelViewController: UIViewController {
    // view
    var mtkView: MTKView!
    
    var viewportSize: simd_uint2 = simd_uint2(0, 0)
    var renderPipelineState: MTLRenderPipelineState?
    var computePipelineState: MTLComputePipelineState?
    var commandQueue: MTLCommandQueue?
    var sourceTexture: MTLTexture?
    var destTexture: MTLTexture?
    
    var mCaptureSession: AVCaptureSession?
    var mCaptureDeviceInput: AVCaptureDeviceInput?
    var mCaptureDeviceOutput: AVCaptureVideoDataOutput?
    var mProcessQueue: DispatchQueue?
    var textureCache: CVMetalTextureCache?
    
    var vertices: MTLBuffer?
    var numVertices: UInt32 = 0
    var groupSize: MTLSize = MTLSize(width: 16, height: 16, depth: 1)
    var groupCount: MTLSize = MTLSize(width: 1, height: 1, depth: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize MTKView
        mtkView = MTKView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
//        mtkView = MTKView(frame: view.bounds)
        mtkView.device = MTLCreateSystemDefaultDevice()
        view.addSubview(mtkView)
        mtkView.delegate = self
        mtkView.device = MTLCreateSystemDefaultDevice()
        viewportSize = simd_uint2(UInt32(mtkView.bounds.size.width), UInt32(mtkView.bounds.size.height))
        
        // Create a CVMetalTextureCache
        var textureCache: CVMetalTextureCache?
        CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, mtkView.device!, nil, &textureCache)
        self.textureCache = textureCache
        
        // Custom initialization
        customInit()
    }
    
    func customInit() {
        setupCaptureSession()
        setupPipeline()
        setupVertex()
        setupTexture()
//        setupPicVertex()
//        setupPicTexture()
        setupThreadGroup()
    }
    
    func setupPipeline() {
        guard let defaultLibrary = mtkView.device?.makeDefaultLibrary() else { return }
        
        let vertexFunction = defaultLibrary.makeFunction(name: "vertexShader_6")
        let fragmentFunction = defaultLibrary.makeFunction(name: "samplingShader_6")
        let kernelFunction = defaultLibrary.makeFunction(name: "sobelKernel")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        
        do {
            renderPipelineState = try mtkView.device?.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            print("Failed to create render pipeline state: $error)")
        }
        do {
            computePipelineState = try mtkView.device?.makeComputePipelineState(function: kernelFunction!)
        } catch let error {
            print("Failed to create compute pipeline state: $error)")
        }
        
        commandQueue = mtkView.device?.makeCommandQueue()
    }
    
    func setupVertex() {
        let quadVertices: [LYVertex] = [
            LYVertex(position: simd_float4(1.0, -1.0, 0.0, 1.0), textureCoordinate: simd_float2(1.0, 1.0)),
            LYVertex(position: simd_float4(-1.0, -1.0, 0.0, 1.0), textureCoordinate: simd_float2(0.0, 1.0)),
            LYVertex(position: simd_float4(-1.0, 1.0, 0.0, 1.0), textureCoordinate: simd_float2(0.0, 0.0)),
            
            LYVertex(position: simd_float4(1.0, -1.0, 0.0, 1.0), textureCoordinate: simd_float2(1.0, 1.0)),
            LYVertex(position: simd_float4(-1.0, 1.0, 0.0, 1.0), textureCoordinate: simd_float2(0.0, 0.0)),
            LYVertex(position: simd_float4(1.0, 1.0, 0.0, 1.0), textureCoordinate: simd_float2(1.0, 0.0)),
        ]
        
        vertices = mtkView.device?.makeBuffer(bytes: quadVertices, length: MemoryLayout<LYVertex>.stride * quadVertices.count, options: [])
        numVertices = UInt32(quadVertices.count)
    }
    
    func setupTexture() {
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.pixelFormat = .rgba8Unorm
        textureDescriptor.width = Int(viewportSize.x)
        textureDescriptor.height = Int(viewportSize.y)
        textureDescriptor.usage = [.shaderWrite, .shaderRead]
        
        destTexture = mtkView.device?.makeTexture(descriptor: textureDescriptor)
    }
    
    func setupThreadGroup() {
        groupSize = MTLSize(width: 16, height: 16, depth: 1)
        
        groupCount.width = (Int(viewportSize.x) + groupSize.width - 1) / groupSize.width
        groupCount.height = (Int(viewportSize.y) + groupSize.height - 1) / groupSize.height
        groupCount.depth = 1
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
    
    func setupCaptureSession() {
        mCaptureSession = AVCaptureSession()
        mCaptureSession!.sessionPreset = .high
        
        mProcessQueue = DispatchQueue(label: "com.example.sessionQueue", attributes: .concurrent)
        
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back), let input = try? AVCaptureDeviceInput(device: device) {
            if mCaptureSession?.canAddInput(input) == true {
                mCaptureSession?.addInput(input)
            }
        }
        
        mCaptureDeviceOutput = AVCaptureVideoDataOutput()
        mCaptureDeviceOutput!.alwaysDiscardsLateVideoFrames = true
        
        if mCaptureSession?.canAddOutput(mCaptureDeviceOutput!) == true {
            mCaptureSession?.addOutput(mCaptureDeviceOutput!)
        }
        
        mCaptureDeviceOutput?.setSampleBufferDelegate(self, queue: mProcessQueue)
        
        let connection = mCaptureDeviceOutput?.connection(with: .video)
        connection?.videoOrientation = .portrait
        
        if mCaptureSession?.isRunning == false {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.mCaptureSession?.startRunning()
            }
        }
    }
}

extension TestMetalSobelViewController {
    private func setupPicTexture() {
        //尝试图片
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
    
    private func setupPicVertex() {
        let quadVertices: [LYVertex] = [
            LYVertex(position: vector_float4(0.5, -0.5, 0.0, 1.0), textureCoordinate: vector_float2(1.0, 1.0)),
            LYVertex(position: vector_float4(-0.5, -0.5, 0.0, 1.0), textureCoordinate: vector_float2(0.0, 1.0)),
            LYVertex(position: vector_float4(-0.5, 0.5, 0.0, 1.0), textureCoordinate: vector_float2(0.0, 0.0)),

            LYVertex(position: vector_float4(0.5, -0.5, 0.0, 1.0), textureCoordinate: vector_float2(1.0, 1.0)),
            LYVertex(position: vector_float4(-0.5, 0.5, 0.0, 1.0), textureCoordinate: vector_float2(0.0, 0.0)),
            LYVertex(position: vector_float4(0.5, 0.5, 0.0, 1.0), textureCoordinate: vector_float2(1.0, 0.0))
        ]
        
        vertices = mtkView.device?.makeBuffer(bytes: quadVertices, length: MemoryLayout<LYVertex>.stride * quadVertices.count, options: .storageModeShared)
        numVertices = UInt32(quadVertices.count)
    }
}

extension TestMetalSobelViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        viewportSize = simd_uint2(UInt32(size.width), UInt32(size.height))
    }
    
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue?.makeCommandBuffer(),
              let sourceTexture = sourceTexture else {
            return
        }
        
        let computeEncoder = commandBuffer.makeComputeCommandEncoder()
        computeEncoder?.setComputePipelineState(computePipelineState!)
        computeEncoder?.setTexture(sourceTexture, index: LYFragmentTextureIndex.textureSource.rawValue)
        computeEncoder?.setTexture(destTexture, index: LYFragmentTextureIndex.textureDest.rawValue)
        computeEncoder?.dispatchThreadgroups(groupCount, threadsPerThreadgroup: groupSize)
        computeEncoder?.endEncoding()
        
        guard let renderPassDescriptor = view.currentRenderPassDescriptor,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }
        
        renderEncoder.setViewport(MTLViewport(originX: 0, originY: 0, width: Double(viewportSize.x), height: Double(viewportSize.y), znear: 0, zfar: 1))
        renderEncoder.setRenderPipelineState(renderPipelineState!)
        renderEncoder.setVertexBuffer(vertices, offset: 0, index: 0)
        renderEncoder.setFragmentTexture(destTexture, index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: Int(numVertices))
        
        renderEncoder.endEncoding()
        
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
}

extension TestMetalSobelViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        
        var texture: CVMetalTexture?
        let status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache!, pixelBuffer, nil, .bgra8Unorm, Int(width), Int(height), 0, &texture)
        
        if status == kCVReturnSuccess {
            mtkView.drawableSize = CGSize(width: width, height: height)
            sourceTexture = CVMetalTextureGetTexture(texture!)
        }
    }
}


extension TestMetalSobelViewController {
    struct LYVertex {
        var position: simd_float4
        var textureCoordinate: simd_float2
    }
    
    enum LYVertexInputIndex: Int {
        case vertices = 0
    }
    
    enum LYFragmentTextureIndex: Int {
        case textureSource = 0
        case textureDest = 1
    }
}
