//
//  PokemonInfoRow.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2023/10/18.
//

import SwiftUI

struct PokemonInfoRow: View {
    let model = PokemonViewModel.sample(id: 1)
    var body: some View {
        VStack {
            HStack {
                Image("Pokemon-\(model.id)")
                Spacer()
                VStack(alignment: .trailing) {
                    Text(model.name)
                    Text(model.nameEN)
                }
            }
            HStack {
                Spacer()
                Button(action: {}) {
                    Text("Fav")
                }
                Button(action: {}) {
                    Text("Panel")
                }
                Button(action: {}) {
                    Text("Web")
                }
            }
        }.background(Color.green)
    }
}

struct PokemonInfoRow_Previews: PreviewProvider {
    static var previews: some View {
        PokemonInfoRow()
    }
}
