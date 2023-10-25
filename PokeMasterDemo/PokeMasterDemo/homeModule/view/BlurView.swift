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
    
    init(style: UIBlurEffect.Style) {
        print("init")
        self.style = style
    }
    
    func makeUIView(context: Context) -> some UIView {
        print("makeUIView")
        
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.tag = 999
        // 2
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        view.addSubview(blurView)
        NSLayoutConstraint.activate([
            blurView.heightAnchor
                .constraint(equalTo: view.heightAnchor),
            blurView.widthAnchor
                .constraint(equalTo: view.widthAnchor)
        ])
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        print("updateUIView")
        DispatchQueue.main.async {
            if let bView = uiView.viewWithTag(999) as? UIVisualEffectView {
                bView.effect = UIBlurEffect(style: style)
            }
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
