//
//  ContentsViewModel.swift
//  SampleProject
//
//  Created by Ibuki Onishi on 2025/09/05.
//

import Observation

@MainActor
@Observable
final class ContentViewModel {
    var contents = [ContentEntity]()
    @ObservationIgnored let contentRepository = ContentRepository(modelContainer: ModelContainerProvider.shared.modelContainer)
    @ObservationIgnored var observeTask: Task<Void, Never>? = nil

    init() {
        Task { contents = await contentRepository.fetchALl() }
        observeContents()
    }
    
    deinit { observeTask?.cancel() }
    
    func insertContent(content: ContentEntity) async {
        await contentRepository.insertModel(content)
    }
    
    private func observeContents() {
        observeTask = Task { [weak self, contentRepository] in
            for await _ in contentRepository.dataChangedStream {
                self?.contents = await contentRepository.fetchALl()
            }
        }
    }
}
