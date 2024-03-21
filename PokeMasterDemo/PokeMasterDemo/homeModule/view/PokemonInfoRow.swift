//
//  PokemonInfoRow.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2023/10/18.
//

import SwiftUI
import Kingfisher

struct PokemonInfoRow: View {
    @EnvironmentObject var store: Store

    let model: PokemonViewModel
    var expanded: Bool
    var panelCallback: (() -> Void)?
    var favCallback: (() -> Void)?
        
    var body: some View {
        VStack {
            HStack {
//                Image("Pokemon-\(model.id)")
                KFImage(model.iconImageURL)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .aspectRatio(contentMode: .fit)
                    .shadow(radius: 4)
                Spacer()
                VStack(alignment: .trailing) {
                    Text(model.name)
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                    Text(model.nameEN)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
            }
            .padding(.top, 12)
            
            Spacer()
            
            HStack(spacing: expanded ? 20 : -30) {
                Spacer()
                Button(action: {
                    print("fav")
                    favCallback?()
                }) {
                    Image(systemName: "star")
                        .modifier(ToolButtonModifier())
                }
                .buttonStyle(BorderlessButtonStyle())
                
                Button(action: {
                    print("panel")
                    panelCallback?()
                }) {
                    Image(systemName: "chart.bar")
                        .modifier(ToolButtonModifier())
                }
                // 设置样式，激活触发范围。
                .buttonStyle(BorderlessButtonStyle())
                
                //TODO: 这儿单独使用NavigationLink会有各种各样的问题，主要是手势冲突，单击优先响应cell，长按才响应nav，而且范围也有问题。---只能暂时先这样解决，套到按钮里，控制参数变化来搞定。
                Button(action: {
                    print("web")
                    store.appState.pokemonList.isDetailWebViewShow = true
                }) {
//                    Image(systemName: "info.circle")
//                        .modifier(ToolButtonModifier())
                    //MARK: 去掉小箭头，设置范围。
                    HStack {
                        NavigationLink(
                            destination:
                                PKSafariView(url: model.detailPageURL) {
                                    store.appState.pokemonList.isDetailWebViewShow = false
                                }
                                .navigationBarTitle(
                                    Text(model.name),
                                    displayMode: .inline
                                ), isActive: expanded ? $store.appState.pokemonList.isDetailWebViewShow : .constant(false),
                            label: {
    //                                Image(systemName: "info.circle")
    //                                    .modifier(ToolButtonModifier())
                                EmptyView()
                            }
                        )
                        .opacity(0)
                        .background {
                            Image(systemName: "info.circle")
                                .modifier(ToolButtonModifier())
                        }
                    }
                }
                .buttonStyle(BorderlessButtonStyle())
                .frame(width: 45, height: 30, alignment: .center)
            }
            .padding(.bottom, 12)
            .opacity(expanded ? 1.0 : 0.0)
            .frame(maxHeight: expanded ? .infinity : 0)
        }
        .frame(maxHeight: expanded ? 120 : 80)
        .padding(.leading, 23)
        .padding(.trailing, 15)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(model.color, style: StrokeStyle(lineWidth: 4))
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.white, model.color]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
        )
        .padding(.horizontal)
        .animation(.default, value: expanded)
//        .onTapGesture {
//            withAnimation(.spring(response: 0.55, dampingFraction: 0.425, blendDuration: 0)) {
//                self.expanded.toggle()
//            }
//        }
    }
}

extension PokemonInfoRow {
    struct ToolButtonModifier: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.system(size: 25))
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
        }
    }
    
    struct StaticButtonStyle: ButtonStyle {
        /// 设置样式，去掉小箭头--.buttonStyle(StaticButtonStyle())
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
        }
    }
    
    struct GestureView<Content: View>: View {
        let content: Content
        
        init(@ViewBuilder content: () -> Content) {
            self.content = content()
        }
        
        var body: some View {
            content
                .contentShape(Rectangle()) // 确保整个区域可以响应手势
//                .gesture(TapGesture().onEnded({ _ in
//                    // 处理点击事件
//                    print("web-tap")
//                }))
        }
    }
}



struct PokemonInfoRow_Previews: PreviewProvider {
    static var previews: some View {
        PokemonInfoRow(model: .sample(id: 1), expanded: false)
        PokemonInfoRow(model: .sample(id: 21), expanded: true)
        PokemonInfoRow(model: .sample(id: 25), expanded: false)
    }
}
