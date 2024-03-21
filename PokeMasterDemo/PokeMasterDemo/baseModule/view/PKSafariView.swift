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
    let onFinished: () -> Void
    
    func makeUIViewController(
        context: UIViewControllerRepresentableContext<PKSafariView>
    ) -> SFSafariViewController {
        let controller = SFSafariViewController(url: url)
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(
        _ uiViewController: SFSafariViewController,
        context: UIViewControllerRepresentableContext<PKSafariView>) {
        
    }
    
    // 3
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

class Coordinator: NSObject, SFSafariViewControllerDelegate {
    let parent: PKSafariView
    init(_ parent: PKSafariView) {
        self.parent = parent
    }
    
    func safariViewControllerDidFinish(
        _ controller: SFSafariViewController) {
        parent.onFinished()
    }
}

#Preview {
    PKSafariView(url: URL(string: "https://www.baidu.com")!) {
    }
}
