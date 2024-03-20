//
//  AppState.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2023/10/31.
//

import Foundation
import Combine

struct AppState {
    // 1
    var settings = Settings()
    var pokemonList = PokemonListData()
}

enum AppAction {
    case login(email: String, password: String)
    case register(email: String, password: String)
    case accountBehaviorDone(result: Result<UserModel, AppError>)
    case signOut
    case emailValid(valid: Bool)
    case passwordValid(valid: Bool)
    case loadPokemons
    case loadPokemonsDone(
    result: Result<[PokemonViewModel], AppError>
    )
    case clearCache
    case togglePanelPresenting(presenting: Bool, selIndex: Int)
}

extension AppState {
    struct PokemonListData {
        //TODO: 这儿到底是否有缓存成功？--主要是获取的时候，还有没有每次都获取，另外也需要强制刷新的选项。--后面完善一下。
        @FileStorage(directory: .cachesDirectory, fileName: "pokemons.json")
        var pokemons: [Int: PokemonViewModel]?
        var loadingPokemons = false
        var loadError: AppError?
        var allPokemonsByID: [PokemonViewModel] {
            guard let pokemons = pokemons?.values else {
                return []
            }
            return pokemons.sorted { $0.id < $1.id }
        }
        
        var selectionState: PokemonSelectionState = PokemonSelectionState()
        
        struct PokemonSelectionState {
            var panelPresented: Bool = false
            var selIndex: Int?
        }
    }
        
    // 2
    struct Settings {
        enum AccountBehavior: CaseIterable {
            case register, login
        }
        //
        //        var accountBehavior = AccountBehavior.login
        //        var email = ""
        //        var password = ""
        //        var verifyPassword = ""
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
        
        
        //TODO: 这儿的架构有问题，暂时可以先跟着书走，但是后面弄完了，要想想如何修改，主要是class引入到struct里，可能会有问题，值引用和地址引用的混合可能会出现的问题。---最主要的还是，这儿是class，照理来说应该是viewmodel了，但这里应该是model，这块的隔离如何做？
        // 这儿到时候尝试移到store里去做，还是保持model的纯洁性比较好。---好好思考@publish什么情况下加？自定义的publisher又该如何做，什么情况下才有需要做。
        class AccountChecker {
            @Published var accountBehavior = AccountBehavior.login
            @Published var email = ""
            @Published var password = ""
            @Published var verifyPassword = ""
            
            //TODO: 如何构造publisher？时机，功能，作用？
            var isEmailValid: AnyPublisher<Bool, Never> {
                // 2
                let remoteVerify = $email
                    .debounce(
                        for: .milliseconds(500),
                        scheduler: DispatchQueue.main
                    )
                    .removeDuplicates()
                    .flatMap { email -> AnyPublisher<Bool, Never> in
                        let validEmail = email.isValidEmailAddress
                        let canSkip = self.accountBehavior == .login
                        switch (validEmail, canSkip) {
                            // 3
                        case (false, _):
                            return Just(false).eraseToAnyPublisher()
                            // 4
                        case (true, false):
                            return EmailCheckingRequest(email: email)
                                .publisher
                                .eraseToAnyPublisher()
                        case (true, true):
                            return Just(true).eraseToAnyPublisher()
                        }
                    }
                
                let emailLocalValid =
                $email.map { $0.isValidEmailAddress }
                let canSkipRemoteVerify =
                $accountBehavior.map { $0 == .login }
                
                return Publishers.CombineLatest3(
                    emailLocalValid, canSkipRemoteVerify, remoteVerify
                )
                .map { $0 && ($1 || $2) }
                .eraseToAnyPublisher()
            }
            
            /// 只处理注册
            var isPasswordValid: AnyPublisher<Bool, Never> {
                let isReg = $accountBehavior.map { $0 == .register }
                let passwordElement = $password.map { $0 }
                let verifyPasswordElement = $verifyPassword.map { $0 }
                return Publishers.CombineLatest3(
                    isReg, passwordElement, verifyPasswordElement
                )
                .map { currIsReg, pwd, verPwd in
                    if currIsReg {
                        return !pwd.isEmpty && !verPwd.isEmpty && pwd == verPwd
                    }
                    return true
                }
                .eraseToAnyPublisher()
            }
        }
        
        var checker = AccountChecker()
        var isEmailValid = false
        var isPasswordValid = false
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
