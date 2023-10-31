//
//  SettingView.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2023/10/24.
//

import SwiftUI

struct SettingView: View {
    @ObservedObject var settings = SettingsViewModel()
    @EnvironmentObject var store: Store
    var settingsBinding: Binding<AppState.Settings> {
        $store.appState.settings
    }
    
    var body: some View {
        Form {
            accountSection
            optionSection
            actionSection
        }
    }
}

extension SettingView {
    var accountSection: some View {
        Section(header: Text("账户")) {
            // 1
            Picker(
                selection: $settings.accountBehavior,
                label: Text(""))
            {
                ForEach(SettingsViewModel.AccountBehavior.allCases, id: \.self) {
                    Text($0.text)
                }
            }
            // 2
            .pickerStyle(SegmentedPickerStyle())
            
            // 3
            TextField("电子邮箱", text: $settings.email)
            SecureField("密码", text: $settings.password)
            // 4
            if settings.accountBehavior == .register {
                SecureField("确认密码", text: $settings.verifyPassword)
            }
            Button(settings.accountBehavior.text) {
                print("登录/注册")
            }
        }
    }
    
    var optionSection: some View {
        Section(header: Text("选项")) {
            Toggle("显示英文名", isOn: settingsBinding.showEnglishName)
            
            Picker(
                selection: settingsBinding.sorting,
                label: Text("排序"))
            {
                ForEach(AppState.Settings.Sorting.allCases, id: \.self) {
                    Text($0.text)
                }
            }
            .pickerStyle(.navigationLink)
            
            Toggle("只显示收藏", isOn: settingsBinding.showFavoriteOnly)
        }
    }
    
    var actionSection: some View {
        Section {
            Button("清空缓存") {
                print("清空缓存")
            }
            .foregroundColor(.red)
        }
    }
}


struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView().environmentObject(Store())
    }
}
