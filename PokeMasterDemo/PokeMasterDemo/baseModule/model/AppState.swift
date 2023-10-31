//
//  AppState.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2023/10/31.
//

import Foundation

struct AppState {
    // 1
    var settings = Settings()
}

extension AppState {
    // 2
    struct Settings {
        enum Sorting: CaseIterable {
            case id, name, color, favorite
        }
        var showEnglishName = true
        var sorting = Sorting.id
        var showFavoriteOnly = false
    }
}
