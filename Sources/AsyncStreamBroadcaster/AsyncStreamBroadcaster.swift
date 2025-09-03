// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import os.lock

/// ブロードキャストに対応したAsyncStreamを提供するクラス
public struct AsyncStreamBroadcaster<Element: Sendable>: Sendable {
    private let storage: Storage
    
    public init(
        bufferingPolicy: AsyncStream<Element>.Continuation.BufferingPolicy = .unbounded
    ) {
        self.storage = Storage(bufferingPolicy: bufferingPolicy)
    }
    
    /// 新しいStreamを作成
    public func makeStream() -> AsyncStream<Element> {
        return storage.subscribe()
    }
    
    /// 全てのStreamに値を送信
    public func yield(_ value: Element) {
        storage.broadcast(value)
    }
    
    /// 全てのStreimに終了を通知
    public func finish() {
        storage.finish()
    }
    
    private final class Storage: @unchecked Sendable {
        private var continuations: [UUID: AsyncStream<Element>.Continuation] = [:]
        private let lock = OSAllocatedUnfairLock()
        private let bufferingPolicy: AsyncStream<Element>.Continuation.BufferingPolicy
        
        init(bufferingPolicy: AsyncStream<Element>.Continuation.BufferingPolicy) {
            self.bufferingPolicy = bufferingPolicy
        }
        
        func subscribe() -> AsyncStream<Element> {
            let id = UUID()
            
            let (stream, continuation) = AsyncStream<Element>.makeStream(
                of: Element.self,
                bufferingPolicy: bufferingPolicy
            )
            
            lock.withLock {
                continuations[id] = continuation
            }
            
            continuation.onTermination = { [weak self] _ in
                guard let self else { return }
                _ = lock.withLock {
                    continuations.removeValue(forKey: id)
                }
            }
            
            return stream
        }
        
        func broadcast(_ value: Element) {
            let currentContinuations = lock.withLock { continuations }
            
            for continuation in currentContinuations.values {
                continuation.yield(value)
            }
        }
        
        func finish() {
            let currentContinuations = lock.withLock {
                let continuations = self.continuations
                self.continuations.removeAll()
                return continuations
            }
            
            for continuation in currentContinuations.values {
                continuation.finish()
            }
        }
    }
}
