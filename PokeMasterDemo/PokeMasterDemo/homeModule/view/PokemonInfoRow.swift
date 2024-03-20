//
//  PokemonInfoRow.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2023/10/18.
//

import SwiftUI
import Kingfisher

struct PokemonInfoRow: View {

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
                .buttonStyle(BorderlessButtonStyle())
                
//                Button(action: {
//                    print("web")
//                }) {
//                    Image(systemName: "info.circle")
//                        .modifier(ToolButtonModifier())
//                }
//                .buttonStyle(BorderlessButtonStyle())
                NavigationLink(
                    destination:
                        PKSafariView(url: model.detailPageURL)
                        .navigationBarTitle(
                            Text(model.name),
                            displayMode: .inline
                        ),
                    label: {
                        Image(systemName: "info.circle")
                            .modifier(ToolButtonModifier())
                    }
                )
                .buttonStyle(PlainButtonStyle())
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
}



struct PokemonInfoRow_Previews: PreviewProvider {
    static var previews: some View {
        PokemonInfoRow(model: .sample(id: 1), expanded: false)
        PokemonInfoRow(model: .sample(id: 21), expanded: true)
        PokemonInfoRow(model: .sample(id: 25), expanded: false)
    }
}
