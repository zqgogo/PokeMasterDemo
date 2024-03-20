//
//  PokemonList.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2023/10/20.
//

import SwiftUI

struct PokemonList: View {
    @EnvironmentObject var store: Store
    
    @State var expandingIndex: Int?
    
    @State private var searchText = ""
    @State private var showCancelButton: Bool = false
    
    var body: some View {
        VStack(spacing: 12) {
            //TODO: 这儿差一个搜索，看用封装uikit还是，直接swift UI模拟。
            // Search view
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                    
                    TextField("search", text: $searchText, onEditingChanged: { isEditing in
                        self.showCancelButton = true
                    }, onCommit: {
                        print("onCommit")
                    }).foregroundColor(.primary)
                    
                    Button(action: {
                        self.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill").opacity(searchText == "" ? 0 : 1)
                    }
                }
                .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
                .foregroundColor(.secondary)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10.0)
                
                if showCancelButton  {
                    Button("Cancel") {
                        UIApplication.shared.endEditing(true) // this must be placed before the other commands here
                        self.searchText = ""
                        self.showCancelButton = false
                    }
                    .foregroundColor(Color(.systemBlue))
                }
            }
            .padding(.horizontal)
//            .navigationBarHidden(showCancelButton) // .animation(.default) // animation does not work properly
            
            /// list有复用，scrollview也算一个思路，记录一下。
//            List(PokemonViewModel.all) { pokemon in
            List(Array(store.appState.pokemonList.allPokemonsByID.enumerated()), id: \.0) { (index, pokemon) in
                PokemonInfoRow(model: pokemon, expanded: self.expandingIndex == pokemon.id, panelCallback: {
//                    let target =
//                    !self.store.appState.pokemonList
//                        .selectionState.panelPresented
                    self.store.dispatch(
                        .togglePanelPresenting(presenting: true, selIndex: index)
                    )
                })
                .onTapGesture(perform: {
                    // 列表单元格点按事件
                    withAnimation(.spring(response: 0.55, dampingFraction: 0.425, blendDuration: 0)) {
                        if self.expandingIndex == pokemon.id {
                            self.expandingIndex = nil
                        } else {
                            self.expandingIndex = pokemon.id
                        }
                    }
                })
                //                .listRowBackground(Color.orange)
                    .listRowSeparator(Visibility.hidden)
            }
//            .overlay( // 1
//                VStack {
//                    Spacer()
//                    PokemonInfoPanel(model: .sample(id: 1))
//                }.edgesIgnoringSafeArea(.bottom) // 2
//            )
            .listStyle(PlainListStyle())
            .navigationBarTitle(Text("Search"))
        }
    }
    
    
    //        ScrollView {
    //            LazyVStack {
    //                ForEach(PokemonViewModel.all) { pokemon in
    //                    PokemonInfoRow(model: pokemon, expanded: false)
    //                }
    //            }
    //        }
}

struct PokemonList_Previews: PreviewProvider {
    static var previews: some View {
        PokemonList().environmentObject(Store())
    }
}
