//
//  PKSafariView.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2024/3/20.
//

import SwiftUI
import SafariServices

struct PKSafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(
        context: UIViewControllerRepresentableContext<PKSafariView>
    ) -> SFSafariViewController {
        let controller = SFSafariViewController(url: url)
        return controller
    }
    
    func updateUIViewController(
        _ uiViewController: SFSafariViewController,
        context: UIViewControllerRepresentableContext<PKSafariView>)
    {
        
    }
}

#Preview {
    PKSafariView(url: URL(string: "https://www.baidu.com")!)
}
