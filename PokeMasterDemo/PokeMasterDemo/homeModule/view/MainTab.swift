//
//  MainTab.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2023/10/31.
//

import SwiftUI

struct MainTab: View {
    var body: some View {
        TabView {
            // 1
            PokemonRootView().tabItem {
                // 2
                Image(systemName: "list.bullet.below.rectangle")
                Text("列表")
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
