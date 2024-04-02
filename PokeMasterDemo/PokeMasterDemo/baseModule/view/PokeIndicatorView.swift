//
//  PokeIndicatorView.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2023/11/6.
//

import UIKit
import SwiftUI
import Metal
import MetalKit

struct PokeIndicatorView: UIViewRepresentable {
    
    let isShow: Bool
    
    func makeUIView(context: Context) -> some UIView {
        print("PokeIndicatorView-makeUIView")
        
        let indicatorView = UIActivityIndicatorView(style: .medium)
        return indicatorView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        print("PokeIndicatorView-updateUIView")
        if let view = uiView as? UIActivityIndicatorView {
            isShow ? view.startAnimating() : view.stopAnimating()
        }
    }
}

struct TestView: UIViewRepresentable {
    
//    private let vc = TestMetalViewController()
    var vc = TestMetalRoateViewController()
    
    var slideValue: CGFloat
    var isOn_x: Bool
    var isOn_y: Bool
    var isOn_z: Bool
    
    func makeUIView(context: Context) -> some UIView {
        print("test-makeUIView")
        return vc.view!
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        vc.isOn_x = isOn_x
        vc.isOn_y = isOn_y
        vc.isOn_z = isOn_z
        vc.slideValue = slideValue
    }
    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
}

extension TestView {
//    class Coordinator: NSObject, MTKViewDelegate {
//        var metalView: TestView
//        
//        init(_ metalView: TestView) {
//            self.metalView = metalView
//        }
//        
//        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//            
//        }
//        
//        func draw(in view: MTKView) {
//            
//        }
//    }
}

// MARK: - viewcontroller
struct TestVcView: UIViewControllerRepresentable {
        
    var slideValue: CGFloat
    var isOn_x: Bool
    var isOn_y: Bool
    var isOn_z: Bool
    
    func makeUIViewController(context: Context) -> some UIViewController {
        print("test-makeUIView-vc")
//        return TestMetalRoateViewController()
//        return TestMetalVideoViewController()
        return TestMetalGrayViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
//        guard let vc = uiViewController as? TestMetalRoateViewController else {
//            return
//        }
//        vc.isOn_x = isOn_x
//        vc.isOn_y = isOn_y
//        vc.isOn_z = isOn_z
//        vc.slideValue = slideValue
    }
    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
}
