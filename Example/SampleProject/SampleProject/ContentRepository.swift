//
//  ContentRepository.swift
//  SampleProject
//
//  Created by Ibuki Onishi on 2025/09/05.
//

import SwiftData
import AsyncStreamBroadcaster

@ModelActor
actor ContentRepository {
    private nonisolated let dataChangedStreamBroadcaster = AsyncStreamBroadcaster<Void>()
    
    nonisolated var dataChangedStream: AsyncStream<Void> {
        dataChangedStreamBroadcaster.makeStream()
    }
    
    func fetchALl() async -> [ContentEntity] {
        let fetchDescriptor = FetchDescriptor<ContentModel>()
        let models = try? modelContext.fetch(fetchDescriptor)
        
        guard let models else { return [] }
        return models.map { model in
            ContentEntity(id: model.id, content: model.content)
        }
    }
    
    func insertModel(_ entity: ContentEntity) async {
        let model = ContentModel(
            id: entity.id,
            content: entity.content
        )
        modelContext.insert(model)
        try? modelContext.save()
        
        dataChangedStreamBroadcaster.yield(())
    }
}
