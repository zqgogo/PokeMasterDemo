//
//  UserModel.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2023/11/1.
//

import Foundation

struct UserModel: Codable {
    var email: String
    // 2
    var favoritePokemonIDs: Set<Int>
    // 3
    func isFavoritePokemon(id: Int) -> Bool {
        favoritePokemonIDs.contains(id)
    }
}
