//
//  Store.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2023/10/31.
//
// 另外，这儿还是需要思考，如何不过多的抽象，太多层的抽象看的头疼，而且也不利于理解，只适合比较浅的知道大概干了什么，稍微深挖一下，反而不如直接写的清晰。或许维护更好点，但如何取得这个平衡，还需要思考，既可以简单看到底层实现，又可以满足抽象，方便维护。

import Foundation
import Combine

class Store: ObservableObject {
    @Published var appState = AppState()
    private var disposeBag = [AnyCancellable]()
    
    init() {
        setupObservers()
    }
    
    private func setupObservers() {
        appState.settings.checker.isEmailValid.sink { [weak self] isValid in
            self?.dispatch(.emailValid(valid: isValid))
        }.store(in: &disposeBag)
        
        appState.settings.checker.isPasswordValid.sink { [weak self] isValid in
            self?.dispatch(.passwordValid(valid: isValid))
        }.store(in: &disposeBag)
    }
    
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
    //TODO: 这儿感觉可能会乱掉，必须在处理的时候理清楚，不会交叉触发才行，做好隔离，每次都是一种状态来改变UI，command携带太多可能也会乱掉，最好只影响一种数据，而不会造成更多的交叉影响，比如影响了某个数据，这个数据又影响其他数据和状态，进而又影响UI，这种情况之类的。---需要架构的时候，就做好隔离才行。--思考能否搞成数据流向的形式，也比较清晰。--可以尝试搞一个这样的框架来。--最好能适配swiftui以及普通的swift项目。--而且要低侵入性，也思考一下热更新和包网页，以及组件化之类的。
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
        case .signOut:
            appState.settings.loginUser = nil
        case .emailValid(valid: let valid):
            appState.settings.isEmailValid = valid
        case .passwordValid(valid: let valid):
            appState.settings.isPasswordValid = valid
        case .loadPokemons:
            if appState.pokemonList.loadingPokemons {
                break
            }
            appState.pokemonList.loadingPokemons = true
            appCommand = LoadPokemonsCommand()
        case .loadPokemonsDone(result: let result):
            appState.pokemonList.loadingPokemons = false
            switch result {
            case .success(let models):
                appState.pokemonList.pokemons =
                // 3
                Dictionary(
                    uniqueKeysWithValues: models.map { ($0.id, $0) }
                )
            case .failure(let error):
                // 4
                print(error)
            }
        case .register(email: let email, password: let password):
            guard !appState.settings.loginRequesting else {
                break
            }
            appState.settings.loginRequesting = true
            // 2
            appCommand = RegisterAppCommand(
                email: email, password: password
            )
        case .clearCache:
            appState.pokemonList.pokemons = nil
            // 清理登录信息
            try? FileHelper.delete(
                from: .documentDirectory,
                fileName: "user.json"
            )
        }
        return (appState, appCommand)
    }
}
