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

enum AppAction {
    case login(email: String, password: String)
    case accountBehaviorDone(result: Result<UserModel, AppError>)
    case signOut
}

extension AppState {
    // 2
    struct Settings {
        enum AccountBehavior: CaseIterable {
            case register, login
        }
        
        var accountBehavior = AccountBehavior.login
        var email = ""
        var password = ""
        var verifyPassword = ""
        var error: AppError? {
            didSet {
                let tmp = error == nil ? false : true
                if tmp != isHaveError {
                    isHaveError = tmp
                }
            }
        }
        var isHaveError: Bool = false {
            didSet {
                if error != nil, isHaveError == false {
                    error = nil
                }
            }
        }
        
        enum Sorting: CaseIterable {
            case id, name, color, favorite
        }
        
        @UserDefaultsStorage(initialValue: true, keypath: "showEnglishName")
        var showEnglishName: Bool
        @UserDefaultsStorage(initialValue: Sorting.id, keypath: "sorting")
        var sorting: Sorting
        @UserDefaultsStorage(initialValue: false, keypath: "showFavoriteOnly")
        var showFavoriteOnly: Bool
        
        @FileStorage(directory: .documentDirectory, fileName: "user.json")
        var loginUser: UserModel?
        
        var loginRequesting = false
    }
}

extension AppState.Settings.Sorting {
    var text: String {
        switch self {
        case .id: return "ID"
        case .name: return "名字"
        case .color: return "颜色"
        case .favorite: return "最爱"
        }
    }
}

extension AppState.Settings.AccountBehavior {
    var text: String {
        switch self {
        case .register: return "注册"
        case .login: return "登录"
        }
    }
}
