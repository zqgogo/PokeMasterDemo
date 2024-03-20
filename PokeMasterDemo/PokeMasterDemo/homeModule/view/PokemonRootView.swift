//
//  PokemonRootView.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2023/10/25.
//

import SwiftUI

struct PokemonRootView: View {
    //    @State var searchStr: String = ""
    @EnvironmentObject var store: Store
    
    var body: some View {
        NavigationView {
            if store.appState.pokemonList.pokemons == nil {
                if let err = store.appState.pokemonList.loadError {
                    Button(action: {
                        self.store.dispatch(.loadPokemons)
                    }, label: {
                        VStack {
                            HStack {
                                Image("arrow.clockwise")
                                Text("Retry")
                            }
                            Text(err.localizedDescription)
                                .font(Font(UIFont.systemFont(ofSize: 12)))
                                .foregroundColor(.gray)

                        }
                    })
                } else {
                    if store.appState.pokemonList.loadingPokemons {
                        Text("Loading...")
                    } else {
                        Text("unknow")
                    }
                }
            } else {
                // 2
                PokemonList()
                    .navigationBarTitle("宝可梦列表")
            }
        }
        .onAppear {
            self.store.dispatch(.loadPokemons)
        }
        //        .searchable(text: $searchStr)
    }
}

struct PokemonRootView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonRootView().environmentObject(Store())
    }
}
