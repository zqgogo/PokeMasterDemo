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
    
    var body: some View {
        //        VStack {
        //            Image(systemName: "globe")
        //                .imageScale(.large)
        //                .foregroundColor(.accentColor)
        //            Text("Hello, world!")
        //        }
        //        .padding()
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
