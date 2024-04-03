//
//  TestMetalVideoPlayViewController.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2024/4/3.
//

import UIKit
import MetalKit
import GLKit
import Metal
import simd
import AVFoundation

class TestMetalVideoPlayViewController: UIViewController {
    
    var mtkView: MTKView!
    var reader: LYAssetReader!
    var textureCache: CVMetalTextureCache?
    
    var viewportSize: vector_uint2 = vector_uint2(0, 0)
    var pipelineState: MTLRenderPipelineState?
    var commandQueue: MTLCommandQueue?
    var texture: MTLTexture?
    var vertices: MTLBuffer?
    var convertMatrix: MTLBuffer?
    var numVertices: UInt32 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mtkView = MTKView(frame: view.bounds)
        mtkView.device = MTLCreateSystemDefaultDevice()
        view = mtkView
        mtkView.delegate = self
        
        let url = Bundle.main.url(forResource: "test", withExtension: "mov")
        reader = LYAssetReader(withUrl: url!)
        
        viewportSize = vector_uint2(UInt32(UInt(mtkView.drawableSize.width)), UInt32(UInt(mtkView.drawableSize.height)))
        
        if let device = mtkView.device {
            //kCVReturnSuccess
            let _ = CVMetalTextureCacheCreate(nil, nil, device, nil, &textureCache)
        }
        
        customInit()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func customInit() {
        setupPipeline()
        setupVertex()
        setupMatrix()
    }
    
    private func setupMatrix() {
        let kColorConversion601FullRangeMatrix: matrix_float3x3 = {
            return matrix_float3x3(columns: (
                simd_float3(1.0, 1.0, 1.0),
                simd_float3(0.0, -0.343, 1.765),
                simd_float3(1.4, -0.711, 0.0)
            ))
        }()
        
        let kColorConversion601FullRangeOffset: vector_float3 = simd_make_float3(-(16.0/255.0), -0.5, -0.5)
        
        var matrix = LYConvertMatrix(matrix: kColorConversion601FullRangeMatrix, offset: kColorConversion601FullRangeOffset)
        convertMatrix = mtkView.device?.makeBuffer(bytes: &matrix, length: MemoryLayout<LYConvertMatrix>.stride, options: [])
    }
    
    
    private func setupPipeline() {
        guard let device = mtkView.device else { return }
        let defaultLibrary = device.makeDefaultLibrary()
        let vertexFunction = defaultLibrary?.makeFunction(name: "vertexShader_5")
        let fragmentFunction = defaultLibrary?.makeFunction(name: "samplingShader_5")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexFunction
        pipelineStateDescriptor.fragmentFunction = fragmentFunction
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch {
            print("Failed to create pipeline state: $error)")
        }
        
        commandQueue = device.makeCommandQueue()
    }
    
    private func setupVertex() {
        var quadVertices: [LYVertex] = [
            LYVertex(position: simd_float4(1.0, -1.0, 0.0, 1.0), textureCoordinate: simd_float2(1.0, 1.0)),
            LYVertex(position: simd_float4(-1.0, -1.0, 0.0, 1.0), textureCoordinate: simd_float2(0.0, 1.0)),
            LYVertex(position: simd_float4(-1.0, 1.0, 0.0, 1.0), textureCoordinate: simd_float2(0.0, 0.0)),
            LYVertex(position: simd_float4(1.0, -1.0, 0.0, 1.0), textureCoordinate: simd_float2(1.0, 1.0)),
            LYVertex(position: simd_float4(-1.0, 1.0, 0.0, 1.0), textureCoordinate: simd_float2(0.0, 0.0)),
            LYVertex(position: simd_float4(1.0, 1.0, 0.0, 1.0), textureCoordinate: simd_float2(1.0, 0.0))
        ]
        
        vertices = mtkView.device?.makeBuffer(bytes: &quadVertices, length: MemoryLayout<LYVertex>.stride * quadVertices.count, options: [])
        numVertices = UInt32(quadVertices.count)
    }
    
    private func setupTexture(withEncoder encoder: MTLRenderCommandEncoder, buffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) else { return }
        var textureY: MTLTexture?
        var textureUV: MTLTexture?
        
        // textureY setup
        let width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0)
        let height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0)
        let pixelFormatY = MTLPixelFormat.r8Unorm
        
        var texture: CVMetalTexture?
        let status = CVMetalTextureCacheCreateTextureFromImage(nil, textureCache!, pixelBuffer, nil, pixelFormatY, width, height, 0, &texture)
        if status == kCVReturnSuccess {
            textureY = CVMetalTextureGetTexture(texture!)
            texture = nil
        }
        
        // textureUV setup
        let widthUV = CVPixelBufferGetWidthOfPlane(pixelBuffer, 1)
        let heightUV = CVPixelBufferGetHeightOfPlane(pixelBuffer, 1)
        let pixelFormatUV = MTLPixelFormat.rg8Unorm
        let statusUV = CVMetalTextureCacheCreateTextureFromImage(nil, textureCache!, pixelBuffer, nil, pixelFormatUV, widthUV, heightUV, 1, &texture)
        if statusUV == kCVReturnSuccess {
            textureUV = CVMetalTextureGetTexture(texture!)
            texture = nil
        }
        
        if let textureY = textureY, let textureUV = textureUV {            encoder.setFragmentTexture(textureY, index: LYFragmentTextureIndex.textureY.rawValue)
            encoder.setFragmentTexture(textureUV, index: LYFragmentTextureIndex.textureUV.rawValue)
        }
//        CFRelease(pixelBuffer)
    }
}

extension TestMetalVideoPlayViewController: MTKViewDelegate {
    // MTKViewDelegate methods
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {        
        viewportSize = vector_uint2(UInt32(size.width), UInt32(size.height))
    }
    
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue?.makeCommandBuffer(),
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let sampleBuffer = reader.readBuffer() else {
            return
        }
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.5, 0.5, 1.0)
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        renderEncoder.setViewport(MTLViewport(originX: 0.0, originY: 0.0, width: Double(viewportSize.x), height: Double(viewportSize.y), znear: -1.0, zfar: 1.0))
        renderEncoder.setRenderPipelineState(pipelineState!)
        renderEncoder.setVertexBuffer(vertices, offset: 0, index: LYVertexInputIndex.vertices.rawValue)
        
        setupTexture(withEncoder: renderEncoder, buffer: sampleBuffer)
        
        renderEncoder.setFragmentBuffer(convertMatrix!, offset: 0, index: LYFragmentBufferIndex.matrix.rawValue)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: Int(numVertices))
        renderEncoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
}

extension TestMetalVideoPlayViewController {
    struct LYVertex {
        var position: vector_float4
        var textureCoordinate: vector_float2
    }
    
    struct LYConvertMatrix {
        var matrix: matrix_float3x3
        var offset: vector_float3
    }
    
    enum LYVertexInputIndex: Int {
        case vertices = 0
    }
    
    enum LYFragmentBufferIndex: Int {
        case matrix = 0
    }
    
    enum LYFragmentTextureIndex: Int {
        case textureY = 0
        case textureUV = 1
    }
    
    class LYAssetReader: NSObject {
        var readerVideoTrackOutput: AVAssetReaderTrackOutput?
        var assetReader: AVAssetReader?
        let videoUrl: URL
        let lock = NSLock()
        
        init(withUrl url: URL) {
            self.videoUrl = url
            super.init()
            customInit()
        }
        
        private func customInit() {
            let inputOptions: [String: Any] = [AVURLAssetPreferPreciseDurationAndTimingKey: true]
            let inputAsset = AVURLAsset(url: videoUrl, options: inputOptions)
            
            inputAsset.loadValuesAsynchronously(forKeys: ["tracks"]) { [weak self] in
                DispatchQueue.global(qos: .default).async {
                    guard let strongSelf = self else { return }
                    do {
                        let tracks = try inputAsset.tracks(withMediaType: .video).first
                        strongSelf.process(withAsset: inputAsset, track: tracks)
                    } catch let error as NSError {
                        print("Error loading asset tracks: $error.localizedDescription)")
                    }
                }
            }
        }
        
        private func process(withAsset asset: AVURLAsset, track: AVAssetTrack?) {        lock.lock()
            print("processWithAsset")
            assetReader = try? AVAssetReader(asset: asset)
            let outputSettings: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
            readerVideoTrackOutput = AVAssetReaderTrackOutput(track: track!, outputSettings: outputSettings)
            readerVideoTrackOutput?.alwaysCopiesSampleData = false
            assetReader?.add(readerVideoTrackOutput!)
            if assetReader?.startReading() == false {
                print("Error reading from file at URL: $videoUrl)")
            }
            
            lock.unlock()
        }
        
        func readBuffer() -> CMSampleBuffer? {
            lock.lock()
            var sampleBuffer: CMSampleBuffer?
            
            if let readerOutput = readerVideoTrackOutput {
                sampleBuffer = readerOutput.copyNextSampleBuffer()
            }
            
            if let assetReader = assetReader, assetReader.status == .completed {
                print("customInit")
                readerVideoTrackOutput = nil
                assetReader.cancelReading()
                self.assetReader = nil
                customInit()
            }
            
            lock.unlock()
            return sampleBuffer
        }
    }
}
