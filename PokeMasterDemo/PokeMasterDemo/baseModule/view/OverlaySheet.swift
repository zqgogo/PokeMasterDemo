//
//  OverlaySheet.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2024/3/20.
//

/// SwiftUI 提供了三种对手势进行组合的方式，分别是代表手势需要顺次发生的 SequenceGesture、需要同时发生的 SimultaneousGesture 和只能有一个发生的 ExclusiveGesture。我们不会详细展开讨论细节，但是如果你对手势有组合的要求的话 (比如想要区分直接拖拽和长按以后的拖拽)，可以详细对这几个类型进行研究。

import SwiftUI

struct OverlaySheet<Content: View>: View {
    private let isPresented: Binding<Bool>
    private let makeContent: () -> Content
    
    @GestureState private var translation = CGPoint.zero
    
    init(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.isPresented = isPresented
        self.makeContent = content
    }
    
    var body: some View {
        ZStack {
            // 添加一个背景视图
            Color.black.opacity(isPresented.wrappedValue ? 0.3 : 0)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    // 点击背景视图时隐藏 Sheet
                    isPresented.wrappedValue = false
                }
            
            VStack {
                Spacer()
                makeContent()
            }
            .offset(y: (isPresented.wrappedValue ?
                        0 : UIScreen.main.bounds.height) + max(0, translation.y))
    //        .animation(.interpolatingSpring(stiffness: 70, damping: 12), value: isPresented.wrappedValue)
            .animation(.interpolatingSpring(stiffness: 70, damping: 12))
            .edgesIgnoringSafeArea(.bottom)
            .gesture(panelDraggingGesture)
        }
    }
    
    var panelDraggingGesture: some Gesture {
        // 1
        DragGesture()
        // 2
            .updating($translation) { current, state, _ in
                state.y = current.translation.height
            }
        // 3
            .onEnded { state in
                if state.translation.height > 250 {
                    self.isPresented.wrappedValue = false
                }
            }
    }
}


extension View {
    func overlaySheet<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        overlay(
            OverlaySheet(isPresented: isPresented, content: content)
        )
    }
}

//#Preview {
//    OverlaySheet()
//}
