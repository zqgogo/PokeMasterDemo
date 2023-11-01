//
//  SettingsViewModel.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2023/10/24.
//

// 本类已被废弃，被AppState替代

//import UIKit
//
//class SettingsViewModel: ObservableObject {
//
//    @Published var accountBehavior = AppState.Settings.AccountBehavior.login
//    @Published var email = ""
//    @Published var password = ""
//    @Published var verifyPassword = ""
//    @Published var showEnglishName = true
//    @Published var sorting = AppState.Settings.Sorting.id
//    @Published var showFavoriteOnly = false
//}
//
//extension AppState.Settings.Sorting {
//    var text: String {
//        switch self {
//        case .id: return "ID"
//        case .name: return "名字"
//        case .color: return "颜色"
//        case .favorite: return "最爱"
//        }
//    }
//}
//
//extension AppState.Settings.AccountBehavior {
//    var text: String {
//        switch self {
//        case .register: return "注册"
//        case .login: return "登录"
//        }
//    }
//}
