//
//  Store.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2023/10/31.
//

import Foundation
import Combine

// 3
class Store: ObservableObject {
    @Published var appState = AppState()
}
