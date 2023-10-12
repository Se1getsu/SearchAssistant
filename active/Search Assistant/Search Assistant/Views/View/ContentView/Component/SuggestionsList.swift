//
//  SuggestionsList.swift
//  Search Assistant
//
//  Created by Masaki Doi on 2023/10/08.
//

import SwiftUI

/*
 
 SuggestionListの表示条件は、テキストフィールドに何か入力があること

 suggestionsの取得に失敗した場合、suggestionsが空になる
 
 空白(スペース)のみが入力された時、「データ取得に失敗しました」と表示される
 アプリを起動してすぐに検索すると、一瞬「データ取得に失敗しました」と表示される
 これらはどうするか
 
 
 
*/

struct SuggestionsList: View {
    @ObservedObject var vm: ViewModel
    @Binding var input: String
    
    var body: some View {
        if vm.suggestions.isEmpty {
            Text("データ取得に失敗しました。")
                .frame(maxHeight: .infinity)
        } else {
            List {
                Section {
                    ForEach(vm.suggestions.indices, id: \.self) { i in
                        HStack {
                            Button(vm.suggestions[i]) {
                                input.removeAll()
                                vm.Search(vm.suggestions[i])
                            }
                            
                            .font(.body)
                                .foregroundStyle(.primary)
                                .padding(.leading, 4)
                            Spacer()
                            Text("on Google")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .padding(.vertical, 4)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                } header: {
                    Text("Suggestions")
                }
            }
        }
    }
}

#Preview {
    SuggestionsList(vm: ViewModel.shared, input: Binding.constant(""))
}
