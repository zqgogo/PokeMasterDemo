//
//  TestMetalVideoViewController.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2024/4/1.
//

import MetalKit
import GLKit
import AVFoundation
import CoreMedia
import MetalPerformanceShaders

class TestMetalVideoViewController: UIViewController {
    // view
    var mtkView: MTKView!
    
    // capture
    var mCaptureSession: AVCaptureSession!
    var mCaptureDeviceInput: AVCaptureDeviceInput!
    var mCaptureDeviceOutput: AVCaptureVideoDataOutput!
    var mProcessQueue: DispatchQueue!
    var textureCache: CVMetalTextureCache?
    
    // data
    var commandQueue: MTLCommandQueue!
    var texture: MTLTexture?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMetal()
        setupCaptureSession()
    }
    
    func setupMetal() {
        mtkView = MTKView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        mtkView.device = MTLCreateSystemDefaultDevice()
        view.addSubview(mtkView)
        mtkView.delegate = self
        mtkView.framebufferOnly = false
        commandQueue = mtkView.device?.makeCommandQueue()
        CVMetalTextureCacheCreate(nil, nil, mtkView.device!, nil, &textureCache)
    }
    
    func setupCaptureSession() {
        mCaptureSession = AVCaptureSession()
        mCaptureSession.sessionPreset = .high
        
        mProcessQueue = DispatchQueue(label: "mProcessQueue", attributes: .concurrent)
        
        guard let inputCamera = AVCaptureDevice.devices(for: .video).first(where: { $0.position == .back }) else { return }
        mCaptureDeviceInput = try? AVCaptureDeviceInput(device: inputCamera)
        
        if mCaptureSession.canAddInput(mCaptureDeviceInput) {
            mCaptureSession.addInput(mCaptureDeviceInput)
        }
        
        mCaptureDeviceOutput = AVCaptureVideoDataOutput()
        mCaptureDeviceOutput.alwaysDiscardsLateVideoFrames = false
        
        let videoSettings: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        mCaptureDeviceOutput.videoSettings = videoSettings as [String: Any]?
        
        mCaptureDeviceOutput.setSampleBufferDelegate(self, queue: mProcessQueue)
        
        if mCaptureSession.canAddOutput(mCaptureDeviceOutput) {
            mCaptureSession.addOutput(mCaptureDeviceOutput)
        }
        
        if let connection = mCaptureDeviceOutput.connection(with: .video) {
            connection.videoOrientation = .portrait
        }
        
        mCaptureSession.startRunning()
    }
    
}

extension TestMetalVideoViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        if let texture = texture, let commandBuffer = commandQueue.makeCommandBuffer() {
            guard let drawingTexture = view.currentDrawable?.texture else { return }
            
            let filter = MPSImageGaussianBlur.init(device: mtkView.device!, sigma: 1)
            
            filter.encode(commandBuffer: commandBuffer, sourceTexture: texture, destinationTexture: drawingTexture)
            
            commandBuffer.present(view.currentDrawable!)
            commandBuffer.commit()
            self.texture = nil
        }
    }
}

extension TestMetalVideoViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            let width = CVPixelBufferGetWidth(pixelBuffer)
            let height = CVPixelBufferGetHeight(pixelBuffer)

            var tmpTexture: CVMetalTexture?
            let status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache!, pixelBuffer, nil, .bgra8Unorm, Int(width), Int(height), 0, &tmpTexture)
            
            if status == kCVReturnSuccess {
                mtkView.drawableSize = CGSize(width: Int(width), height: Int(height))
                self.texture = CVMetalTextureGetTexture(tmpTexture!)
            }
        }
    }
}

