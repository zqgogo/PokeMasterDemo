//
//  PokemonInfoPanel.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2023/10/23.
//

import SwiftUI

struct PokemonInfoPanel: View {
    let model: PokemonViewModel
    // 1
    var abilities: [AbilityViewModel] {
        AbilityViewModel.sample(pokemonID: model.id)
    }
    
    @State var darkBlur = false
    
    var body: some View {
        VStack {
            Button {
                darkBlur.toggle()
            } label: {
                Text("切换模糊效果")
            }

            topIndicator
            Group {
                Header(model: model)
                pokemonDescription
            }.animation(nil, value: 1)
            Divider()
            AbilityList(model: model, abilityModels: abilities)
        }
        .padding(EdgeInsets(top: 12, leading: 30, bottom: 30, trailing: 30))
//        .background(.white)
        .blurBackground(style: darkBlur ? .systemMaterialDark : .systemMaterial)
        .cornerRadius(20)
        .fixedSize(horizontal: false, vertical: true)
    }
}

extension PokemonInfoPanel {
    var topIndicator: some View {
        RoundedRectangle(cornerRadius: 3)
            .frame(width: 40, height: 6)
            .opacity(0.2)
    }
    
    struct Header: View {
        let model: PokemonViewModel
        
        var body: some View {
            HStack(spacing: 18) {
                pokemonIcon
                nameSpecies
                verticalDivider
                VStack(spacing: 12) {
                    bodyStatus
                    typeInfo
                }
            }
        }
        
        var pokemonIcon: some View {
            Image("Pokemon-\(model.id)")
                .resizable()
                .frame(width: 68, height: 68)
        }
        
        var nameSpecies: some View {
            // model.name - 宝可梦中文名 (秒蛙种子)
            // model.nameEN - 宝可梦英文名 (Bulbasaur)
            // model.color - 主题色
            // model.genus - 宝可梦种类 (种子宝可梦)
            VStack(spacing: 10) {
                VStack {
                    Text(model.name)
                        .font(.system(size: 22))
                        .fontWeight(.bold)
                        .foregroundColor(model.color)
                    
                    Text(model.nameEN)
                        .font(.system(size: 13))
                        .fontWeight(.bold)
                        .foregroundColor(model.color)
                }
                
                Text(model.genus)
                    .font(.system(size: 13))
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
            }
        }
        
        var verticalDivider: some View {
            Rectangle()
                .frame(width: 1, height: 44)
                .foregroundColor(.black)
                .opacity(0.1)
        }
        
        var bodyStatus: some View {
            // model.height - 身高
            // model.weight - 体重
            // model.color - 主题色
            VStack(alignment: .leading) {
                HStack {
                    Text("身高")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                    
                    Text(model.height)
                        .font(.system(size: 11))
                        .fontWeight(.bold)
                        .foregroundColor(model.color)
                }
                
                HStack {
                    Text("体重")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                    
                    Text(model.weight)
                        .font(.system(size: 11))
                        .fontWeight(.bold)
                        .foregroundColor(model.color)
                }
            }
        }
        
        var typeInfo: some View {
            // model.types - 宝可梦属性
            // model.types[i].color - 属性颜色
            // model.types[i].name - 属性名字 (草，毒)
            HStack {
                ForEach(model.types) { item in
                    Text(item.name)
                        .foregroundColor(.white)
                        .font(.system(size: 11))
                        .frame(width:36, height: 14)
                        .background(item.color)
                        .cornerRadius(7)
                }
            }
        }
    }
    
    var pokemonDescription: some View {
        Text(model.descriptionText)
            .font(.callout)
            .foregroundColor(Color(hex: 0x666666))
            .fixedSize(horizontal: false, vertical: true)
    }
    
    struct AbilityList: View {
        let model: PokemonViewModel
        let abilityModels: [AbilityViewModel]?
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("技能")
                    .font(.headline)
                    .fontWeight(.bold)
                if abilityModels != nil {
                    ForEach(abilityModels!) { ability in
                        Text(ability.name)
                            .font(.subheadline)
                            .foregroundColor(self.model.color)
                        Text(ability.descriptionText)
                            .font(.footnote)
                            .foregroundColor(Color(hex: 0xAAAAAA))
                        // 1
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            // 2
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct PokemonInfoPanel_Previews: PreviewProvider {
    static var previews: some View {
        PokemonInfoPanel(model: .sample(id: 1))
    }
}
