//
//  MainTab.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2023/10/31.
//

import SwiftUI

struct MainTab: View {
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
            TabView {
                // 1
                PokemonRootView().tabItem {
                    // 2
                    Image(systemName: "list.bullet.below.rectangle").foregroundColor(.black)
                    Text("列表").foregroundColor(.black)
                }
                SettingRootView().tabItem {
                    Image(systemName: "gear")
                    Text("设置")
                }
            }
            // 3
            .edgesIgnoringSafeArea(.top)
            .overlaySheet(isPresented: $store.appState.pokemonList.selectionState.panelPresented) {
                panel
            }
    //        .overlay(panel)
        }
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
