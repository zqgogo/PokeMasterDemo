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
    private let vc = TestMetalRoateViewController()
    
    func makeUIView(context: Context) -> some UIView {
        print("test-makeUIView")
        return vc.view!
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
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
