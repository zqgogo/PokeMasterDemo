//
//  SubscriptionToken.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2023/11/1.
//

import Foundation
import Combine

class SubscriptionToken {
    var cancellable: AnyCancellable?
    func unseal() { cancellable = nil }
}

extension AnyCancellable {
    func seal(in token: SubscriptionToken) {
        token.cancellable = self
    }
}
