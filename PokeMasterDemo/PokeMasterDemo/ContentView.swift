//
//  ContentView.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2023/10/18.
//

import SwiftUI

struct ContentView: View {
    @State var selectedIndex = 0
    let names = [
        "onevcat | Wei Wang",
        "zaq | Hao Zang",
        "tyyqa | Lixiao Yang"
    ]
    
    @State var toggleX = false
    @State var toggleY = false
    @State var toggleZ = false
    @State var slideRate: CGFloat = 0
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Toggle(isOn: $toggleX) {
                        Text("X轴")
                    }
                    Toggle(isOn: $toggleY) {
                        Text("Y轴")
                    }
                    Toggle(isOn: $toggleZ) {
                        Text("Z轴")
                    }
                }.padding()
                
                VStack {
                    Text("旋转速率: \(slideRate / 20)")
                    Slider(value: $slideRate) {
                        Text("旋转速率")
                    } minimumValueLabel: {
                        Text("0")
                    } maximumValueLabel: {
                        Text("10")
                    }
                }
            }
            
            TestVcView(slideValue: slideRate, isOn_x: toggleX, isOn_y: toggleY, isOn_z: toggleZ)
                .background(.gray)
                .frame(width: 200, height: 200)
        }
        .padding()
        //        ChatView()
        HStack(alignment: .select) {
            Text("User:")
                .font(.footnote)
                .foregroundColor(.green)
                .alignmentGuide(.select) { d in
                    d[.bottom] + CGFloat(self.selectedIndex) * 20.3
                }
            Image(systemName: "person.circle")
                .foregroundColor(.green)
                .alignmentGuide(.select) { d in
                    d[VerticalAlignment.center]
                }
            
            VStack(alignment: .leading) {
                ForEach(0..<names.count) { index in
                    Text(self.names[index])
                        .foregroundColor(
                            self.selectedIndex == index ? .green : .primary
                        )
                        .onTapGesture {
                            self.selectedIndex = index
                        }
                        .alignmentGuide(
                            self.selectedIndex == index ? .select : .center
                        ) { d in
                            if self.selectedIndex == index {
                                return d[VerticalAlignment.center]
                            } else {
                                return 0
                            }
                        }
                }
            }
        }
        .background(.red)
    }
}

extension VerticalAlignment {
    struct SelectAlignment: AlignmentID {
        static func defaultValue(
            in context: ViewDimensions
        ) -> CGFloat {
            context[VerticalAlignment.center]
        }
    }
    static let select =
    VerticalAlignment(SelectAlignment.self)
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
