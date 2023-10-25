//
//  PokemonRootView.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2023/10/25.
//

import SwiftUI

struct PokemonRootView: View {
//    @State var searchStr: String = ""
    
    var body: some View {
        NavigationView {
            PokemonList().navigationBarTitle("宝可梦列表")
        }
//        .searchable(text: $searchStr)
    }
}

struct PokemonRootView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonRootView()
    }
}
