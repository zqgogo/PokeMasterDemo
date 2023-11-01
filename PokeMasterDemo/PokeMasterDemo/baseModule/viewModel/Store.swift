//
//  Store.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2023/10/31.
//

import Foundation
import Combine

class Store: ObservableObject {
    @Published var appState = AppState()
    
    func dispatch(_ action: AppAction) {
    #if DEBUG
        print("[ACTION]: \(action)")
    #endif
        let result = Store.reduce(state: appState, action: action)
        appState = result
    }
}

extension Store {
    static func reduce(
        state: AppState,
        action: AppAction
    ) -> AppState
    {
        var appState = state
        // 1
        switch action {
        case .login(let email, let password):
            // 2
            if password == "123456" {
                let user = UserModel(email: email, favoritePokemonIDs: [])
                // 3
                appState.settings.loginUser = user
            }
        }
        return appState
    }
}
