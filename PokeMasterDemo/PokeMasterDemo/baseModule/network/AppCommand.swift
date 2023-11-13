//
//  AppCommand.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2023/11/1.
//

import Foundation
import Combine

protocol AppCommand {
    func execute(in store: Store)
}

struct LoginAppCommand: AppCommand {
    let email: String
    let password: String
    let token = SubscriptionToken()
    
    func execute(in store: Store) {
        LoginRequest(
            email: email,
            password: password
        ).publisher
            .sink(
                receiveCompletion: { complete in
                    if case .failure(let error) = complete {
                        // 2
                        store.dispatch(
                            .accountBehaviorDone(result: .failure(error))
                        )
                    }
                    token.unseal()
                },
                receiveValue: { user in
                    // 3
                    store.dispatch(
                        .accountBehaviorDone(result: .success(user))
                    )
                }
            ).seal(in: token)
    }
}

struct WriteUserAppCommand: AppCommand {
    let user: UserModel
    
    func execute(in store: Store) {
        try? FileHelper.writeJSON(
            user,
            to: .documentDirectory,
            fileName: "user.json")
    }
}

struct LoadPokemonsCommand: AppCommand {
    func execute(in store: Store) {
        let token = SubscriptionToken()
        
        LoadPokemonRequest.all
            .sink(
                receiveCompletion: { complete in
                    if case .failure(let error) = complete {
                        store.dispatch(
                            .loadPokemonsDone(result: .failure(error))
                        )
                    }
                    token.unseal()
                },
                receiveValue: { value in
                    store.dispatch(
                        .loadPokemonsDone(result: .success(value))
                    )
                }
            )
            .seal(in: token)
    }
}

struct RegisterAppCommand: AppCommand {
    let email: String
    let password: String
    let token = SubscriptionToken()
    
    func execute(in store: Store) {
        RegisterRequest(
            email: email,
            password: password
        ).publisher
            .sink(
                receiveCompletion: { complete in
                    if case .failure(let error) = complete {
                        // 2
                        store.dispatch(
                            .accountBehaviorDone(result: .failure(error))
                        )
                    }
                    token.unseal()
                },
                receiveValue: { user in
                    // 3
                    store.dispatch(
                        .accountBehaviorDone(result: .success(user))
                    )
                }
            ).seal(in: token)
    }
}
