//
//  MainTab.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2023/10/31.
//

import SwiftUI

struct MainTab: View {
    
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
    }
}


struct MainTab_Previews: PreviewProvider {
    static var previews: some View {
        MainTab().environmentObject(Store())
    }
}
