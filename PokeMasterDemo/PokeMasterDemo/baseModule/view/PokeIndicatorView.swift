//
//  PokeIndicatorView.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2023/11/6.
//

import UIKit
import SwiftUI

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
