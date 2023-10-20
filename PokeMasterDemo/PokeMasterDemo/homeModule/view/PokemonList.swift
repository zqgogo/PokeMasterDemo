//
//  PokemonList.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2023/10/20.
//

import SwiftUI

struct PokemonList: View {
    var body: some View {
        List(PokemonViewModel.all) { pokemon in
            PokemonInfoRow(model: pokemon, expanded: false)
        }
    }
}

struct PokemonList_Previews: PreviewProvider {
    static var previews: some View {
        PokemonList()
    }
}
