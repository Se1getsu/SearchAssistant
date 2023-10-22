//
//  HistorysList.swift
//  Search Assistant
//
//  Created by Masaki Doi on 2023/10/08.
//

import SwiftUI

struct HistorysList: View {
    @ObservedObject var vm: ViewModel
    
    var body: some View {
        List {
            Section {
                ForEach(vm.historys.indices, id: \.self) { i in
                    HStack {
                        Text(vm.historys[i].platform.iconCharacter)
                            .font(.title3)
                            .bold()
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(vm.historys[i].platform.imageColor)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                        
                        Button(vm.historys[i].input) {
                            vm.Search(vm.historys[i].input, platform: vm.historys[i].platform)
                        }
                        .font(.body)
                            .foregroundStyle(.primary)
                            .padding(.leading, 4)
                        
                        Spacer()
                       
                        Text(vm.getStringDate(from: vm.historys[i].date))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 4)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            withAnimation {
                                vm.removeHistory(at: i)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                    }
                }
            } header: {
                Text("Historys")
            } footer: {
                HStack {
                    Spacer()
                    Button {
                        vm.isShowPromptToConfirmDeletionOFAllHistorys = true
                    } label: {
                        Text("全履歴を削除")
                            .foregroundStyle(vm.historys.isEmpty ? .gray : .red)
                            .font(.title3)
                    }
                    .disabled(vm.historys.isEmpty)
                    Spacer()
                }
                .padding(.top, 5)
            }
        }
    }
}

#Preview {
    HistorysList(vm: ViewModel.shared)
}
