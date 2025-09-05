//
//  ModelContainerProvider.swift
//  SampleProject
//
//  Created by Ibuki Onishi on 2025/09/05.
//

import SwiftData

final class ModelContainerProvider {
    static let shared = ModelContainerProvider()
    let modelContainer: ModelContainer
    
    private init() {
        let schema = Schema([ContentModel.self])
        let modelConfiguration = ModelConfiguration(schema: schema)
        modelContainer = try! ModelContainer(for: schema, configurations: modelConfiguration)
    }
}
