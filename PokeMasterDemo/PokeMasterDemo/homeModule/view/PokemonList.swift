//
//  PokemonList.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2023/10/20.
//

import SwiftUI

struct PokemonList: View {
    @State var expandingIndex: Int?

    var body: some View {
        /// list有复用，scrollview也算一个思路，记录一下。
        List(PokemonViewModel.all) { pokemon in
            PokemonInfoRow(model: pokemon, expanded: self.expandingIndex == pokemon.id)
                .onTapGesture {
                    withAnimation(.spring(response: 0.55, dampingFraction: 0.425, blendDuration: 0)) {
                        if self.expandingIndex == pokemon.id {
                            self.expandingIndex = nil
                        } else {
                            self.expandingIndex = pokemon.id
                        }
                    }
                }
//                .listRowBackground(Color.orange)
                .listRowSeparator(Visibility.hidden)
        }
        .overlay( // 1
            VStack {
                Spacer()
                PokemonInfoPanel(model: .sample(id: 1))
            }.edgesIgnoringSafeArea(.bottom) // 2
        )
        .listStyle(PlainListStyle())
//        .padding()
    }
    
    //        ScrollView {
    //            LazyVStack {
    //                ForEach(PokemonViewModel.all) { pokemon in
    //                    PokemonInfoRow(model: pokemon, expanded: false)
    //                }
    //            }
    //        }
}

struct PokemonList_Previews: PreviewProvider {
    static var previews: some View {
        PokemonList()
    }
}
