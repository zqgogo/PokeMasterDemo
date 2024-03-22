//
//  MainTab.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2023/10/31.
//

import SwiftUI
import UniformTypeIdentifiers

struct MainTab: View {
    @Environment(\.openURL) var openURL
    @EnvironmentObject var store: Store

    init() {
        // 目前设置tabbar 各项item，只能如此设置。
        let appear = UITabBarItemAppearance()
        appear.normal.iconColor = .brown
        appear.normal.titleTextAttributes = [.foregroundColor: UIColor(.brown)]
        
        appear.selected.iconColor = .orange
        appear.selected.titleTextAttributes = [.foregroundColor: UIColor(.red)]
        
        let tabbarAppear = UITabBarAppearance()
        tabbarAppear.stackedLayoutAppearance = appear
        
        UITabBar.appearance().standardAppearance = tabbarAppear
        UITabBar.appearance().backgroundColor = .white
        UITabBar.appearance().backgroundImage = UIImage()
        //        UITabBar.appearance().unselectedItemTintColor = .red
    }
        
    var body: some View {
        NavigationView {
            TabView(selection: $store.appState.mainTab.selIndex) {
                // 1
                PokemonRootView().tabItem {
                    // 2
                    Image(systemName: "list.bullet.below.rectangle").foregroundColor(.black)
                    Text("列表").foregroundColor(.black)
                }
                .tag(AppState.MainTabConfig.TabItemIndex.list)
                
                SettingRootView().tabItem {
                    Image(systemName: "gear")
                    Text("设置")
                }
                .tag(AppState.MainTabConfig.TabItemIndex.settings)
            }
            // 3
            .edgesIgnoringSafeArea(.top)
            .overlaySheet(isPresented: $store.appState.pokemonList.selectionState.panelPresented) {
                panel
            }
    //        .overlay(panel)
        }
        .onOpenURL(perform: { url in
            print(url.absoluteString)
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                return
            }
            switch (components.scheme, components.host) {
            case ("pkmaster", "showPanel"):
                guard let idQuery = components.queryItems?.first(where: {
                    $0.name == "id"
                }), let strId = idQuery.value, let id = Int(strId), id >= 1, id <= 30 else { return }
                store.appState.pokemonList.selectionState = .init(panelPresented: true, selIndex: id)
            default:
                break
            }
        })
    }
    
    var panel: some View {
        // 2
        Group {
            if let selIndex = store.appState.pokemonList.selectionState.selIndex,
                let pks = store.appState.pokemonList.pokemons,
                let model = pks[selIndex]
            {
                PokemonInfoPanelOverlay(
                    model: model)
            } else {
                EmptyView()
            }
        }
    }
}

extension MainTab {
    struct PokemonInfoPanelOverlay: View {
        let model: PokemonViewModel
        var body: some View {
            VStack {
                Spacer()
                PokemonInfoPanel(model: model)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}


struct MainTab_Previews: PreviewProvider {
    static var previews: some View {
        MainTab().environmentObject(Store())
    }
}
