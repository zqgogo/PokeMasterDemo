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
