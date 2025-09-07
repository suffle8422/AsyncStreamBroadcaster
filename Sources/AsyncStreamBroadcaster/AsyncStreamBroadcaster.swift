// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import os.lock

/// ブロードキャストに対応したAsyncStreamを提供するクラス
public final class AsyncStreamBroadcaster<Element: Sendable>: Sendable {
    private let bufferingPolicy: AsyncStream<Element>.Continuation.BufferingPolicy
    private let continuations = OSAllocatedUnfairLock<[UUID: AsyncStream<Element>.Continuation]>(initialState: [:])

    public init(
        bufferingPolicy: AsyncStream<Element>.Continuation.BufferingPolicy = .unbounded
    ) {
        self.bufferingPolicy = bufferingPolicy
    }
    
    /// 新しいStreamを作成
    public func makeStream() -> AsyncStream<Element> {
        let id = UUID()
        
        let (stream, continuation) = AsyncStream<Element>.makeStream(
            of: Element.self,
            bufferingPolicy: bufferingPolicy
        )
        
        continuations.withLock { continuations in
            continuations[id] = continuation
        }
        
        continuation.onTermination = { [weak self] _ in
            Task {
                self?.continuations.withLock { continuations in
                    continuations.removeValue(forKey: id)
                }
            }
        }
        
        return stream
    }
    
    /// 全てのStreamに値を送信
    public func yield(_ value: Element) {
        continuations.withLock { continuations in
            for continuation in continuations.values {
                continuation.yield(value)
            }
        }
    }
    
    /// 全てのStreimに終了を通知
    public func finish() {
        continuations.withLock { continuations in
            for continuation in continuations.values {
                continuation.finish()
            }
            
            continuations.removeAll()
        }
    }
}
