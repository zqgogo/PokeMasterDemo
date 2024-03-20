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
        .overlay(content: {
            if settings.loginRequesting {
                ProgressView {
                    Text(settings.loginRequesting ? "登录中..." : "111")
                }
            }
        })
        .alert("错误提示", isPresented: settingsBinding.isHaveError, presenting: settings.error, actions: { error in
            Button("okk") {
                
            }
        }, message: { error in
            Text(error.localizedDescription)
        })
//        .alert(item: settingsBinding.error) { error in
//            Alert(title: Text(error.localizedDescription))
//        }
    }
}

extension SettingView {
    var accountSection: some View {
        Section(header: Text("账户")) {
            if settings.loginUser == nil {
                Picker(
                    selection: settingsBinding.checker.accountBehavior,
                    label: Text(""))
                {
                    ForEach(AppState.Settings.AccountBehavior.allCases, id: \.self) {
                        Text($0.text)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                TextField("电子邮箱", text: settingsBinding.checker.email)
                    .foregroundColor(settings.isEmailValid ? .green : .red)
                SecureField("密码", text: settingsBinding.checker.password)

                if settings.checker.accountBehavior == .register {
                    SecureField("确认密码", text: settingsBinding.checker.verifyPassword)
                }
                
                //这儿包一层，或者使用不同id就可以解决progressView的刷新问题。--必须包在整个if的外层，不能仅仅是progressView自己包一层。
                HStack {
                    if settings.loginRequesting {
                        //TODO: 这儿的progressView在from和list中，第二次以后就不显示了，推测和复用机制或者from的优化机制有关。---后面再研究。----不是列表的情况下没问题。
                        ProgressView {
                            Text(settings.checker.accountBehavior == .register ? "注册中..." : "登录中...")
                        }
                        //.id(UUID())
//                        PokeIndicatorView(isShow: settings.loginRequesting)
                    } else {
                        Button(settings.checker.accountBehavior.text) {
                            if settings.checker.accountBehavior == .register {
                                print("注册")
                                self.store.dispatch(.register(email: self.settings.checker.email, password: self.settings.checker.password))
                                
                            } else {
                                print("登录")
                                self.store.dispatch(
                                    .login(
                                        email: self.settings.checker.email,
                                        password: self.settings.checker.password
                                    )
                                )
                            }
                        }
                        .disabled(!settings.isPasswordValid && !settings.isEmailValid)
                    }
                }
                
            } else {
                Text(settings.loginUser!.email)
                Button("注销") {
                    print("注销")
                    self.store.dispatch(.signOut)
                }
            }
        }
        .autocorrectionDisabled()
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
                self.store.dispatch(.clearCache)
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
