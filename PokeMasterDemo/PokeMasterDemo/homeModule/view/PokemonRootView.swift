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
                // 1
                Text("Loading...").onAppear {
                    self.store.dispatch(.loadPokemons)
                }
            } else {
                // 2
                PokemonList()
                    .navigationBarTitle("宝可梦列表")
            }
        }
        //        .searchable(text: $searchStr)
    }
}

struct PokemonRootView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonRootView().environmentObject(Store())
    }
}
