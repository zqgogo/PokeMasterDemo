//
//  SettingView.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2023/10/24.
//

import SwiftUI

struct SettingView: View {
    //已废弃
//    @ObservedObject var settings = SettingsViewModel()
    
    @EnvironmentObject var store: Store
    var settings: AppState.Settings {
        store.appState.settings
    }
    
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
            if settings.loginUser == nil {
                Picker(
                    selection: settingsBinding.accountBehavior,
                    label: Text(""))
                {
                    ForEach(AppState.Settings.AccountBehavior.allCases, id: \.self) {
                        Text($0.text)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                TextField("电子邮箱", text: settingsBinding.email)
                SecureField("密码", text: settingsBinding.password)

                if settings.accountBehavior == .register {
                    SecureField("确认密码", text: settingsBinding.verifyPassword)
                }
                Button(settings.accountBehavior.text) {
                    print("登录/注册")
                    self.store.dispatch(
                        .login(
                            email: self.settings.email,
                            password: self.settings.password
                        )
                    )
                }
            } else {
                Text(settings.loginUser!.email)
                Button("注销") {
                    print("注销")
                }
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
