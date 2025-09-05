//
//  ContentView.swift
//  SampleProject
//
//  Created by Ibuki Onishi on 2025/09/05.
//

import SwiftUI

struct ContentView: View {
    @State var viewModel = ContentViewModel()
    
    var body: some View {
        VStack {
            Button("コンテンツ追加") {
                Task {
                    await viewModel.contentRepository.insertModel(
                        ContentEntity(
                            id: UUID(),
                            content: Date().ISO8601Format()
                        )
                    )
                }
            }
            
            List(viewModel.contents) { content in
                Text(content.content)
            }
        }
    }
}

#Preview {
    ContentView()
}
