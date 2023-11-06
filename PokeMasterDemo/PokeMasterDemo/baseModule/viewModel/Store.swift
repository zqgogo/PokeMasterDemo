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
        appState = result.0
        if let command = result.1 {
#if DEBUG
            print("[COMMAND]: \(command)")
#endif
            command.execute(in: self)
        }
    }
}

extension Store {
    static func reduce(
        state: AppState,
        action: AppAction
    ) -> (AppState, AppCommand?)
    {
        var appState = state
        var appCommand: AppCommand?
        
        switch action {
        case .login(let email, let password):
            // 1
            guard !appState.settings.loginRequesting else {
                break
            }
            appState.settings.loginRequesting = true
            // 2
            appCommand = LoginAppCommand(
                email: email, password: password
            )
        case .accountBehaviorDone(let result):
            appState.settings.loginRequesting = false
            switch result {
            case .success(let user):
                appState.settings.loginUser = user
                appCommand = WriteUserAppCommand(user: user)
            case .failure(let error):
                print("Error: \(error)")
                appState.settings.error = error
            }
        }
        return (appState, appCommand)
    }
}
