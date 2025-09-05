//
//  ContentEntity.swift
//  SampleProject
//
//  Created by Ibuki Onishi on 2025/09/05.
//

import Foundation

struct ContentEntity: Sendable, Identifiable {
    var id: UUID
    var content: String
}
