//
//  ContentModel.swift
//  SampleProject
//
//  Created by Ibuki Onishi on 2025/09/05.
//

import Foundation
import SwiftData

@Model
final class ContentModel {
    var id: UUID
    var content: String
    
    init(id: UUID, content: String) {
        self.id = id
        self.content = content
    }
}
