//
//  BlurView.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2023/10/23.
//

import UIKit
import SwiftUI

struct BlurView: UIViewRepresentable {
    
    let style: UIBlurEffect.Style
    
//    private var blurView: UIVisualEffectView
    private let parView: UIView
    
    init(style: UIBlurEffect.Style) {
        print("init")
        self.style = style
        
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        parView = view
    }
    
    func makeUIView(context: Context) -> some UIView {
        print("makeUIView")
        
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.tag = 999
        // 2
        parView.addSubview(blurView)
        NSLayoutConstraint.activate([
            blurView.heightAnchor
                .constraint(equalTo: parView.heightAnchor),
            blurView.widthAnchor
                .constraint(equalTo: parView.widthAnchor)
        ])
        return parView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        print("updateUIView")
        DispatchQueue.main.async {
            if let bView = self.parView.viewWithTag(999) {
                bView.removeFromSuperview()
            }
            let blurView = UIVisualEffectView(effect: UIBlurEffect(style: style))
            blurView.translatesAutoresizingMaskIntoConstraints = false
            self.parView.addSubview(blurView)
            NSLayoutConstraint.activate([
                blurView.heightAnchor
                    .constraint(equalTo: parView.heightAnchor),
                blurView.widthAnchor
                    .constraint(equalTo: parView.widthAnchor)
            ])
        }
    }
}

extension View {
    func blurBackground(style: UIBlurEffect.Style) -> some View {
        ZStack {
            BlurView(style: style)
            self
        }
    }
}
