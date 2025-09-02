import Testing
@testable import AsyncStreamBroadcaster

@Suite("AsyncStreamBroadcasterテスト")
struct AsyncStreamBroadcasterTests {
    
    @Test("単一ストリームへのブロードキャスト")
    func singleStreamBroadcast() async {
        let broadcaster = AsyncStreamBroadcaster<Int>()
        let stream = broadcaster.makeStream()
        
        let task = Task {
            var values: [Int] = []
            for await value in stream {
                values.append(value)
                if values.count == 3 {
                    break
                }
            }
            return values
        }
        
        broadcaster.yield(1)
        broadcaster.yield(2)
        broadcaster.yield(3)
        
        let result = await task.value
        #expect(result == [1, 2, 3])
    }

    @Test("複数ストリームへの同時ブロードキャスト")
    func multipleStreamsBroadcast() async {
        let broadcaster = AsyncStreamBroadcaster<String>()
        let stream1 = broadcaster.makeStream()
        let stream2 = broadcaster.makeStream()
        let stream3 = broadcaster.makeStream()
        
        let task1 = Task {
            var values: [String] = []
            for await value in stream1 {
                values.append(value)
                if values.count == 2 {
                    break
                }
            }
            return values
        }
        
        let task2 = Task {
            var values: [String] = []
            for await value in stream2 {
                values.append(value)
                if values.count == 2 {
                    break
                }
            }
            return values
        }
        
        let task3 = Task {
            var values: [String] = []
            for await value in stream3 {
                values.append(value)
                if values.count == 2 {
                    break
                }
            }
            return values
        }
        
        broadcaster.yield("hello")
        broadcaster.yield("world")
        
        let result1 = await task1.value
        let result2 = await task2.value
        let result3 = await task3.value
        
        #expect(result1 == ["hello", "world"])
        #expect(result2 == ["hello", "world"])
        #expect(result3 == ["hello", "world"])
    }

    @Test("ストリームの終了処理")
    func streamFinishing() async {
        let broadcaster = AsyncStreamBroadcaster<Int>()
        let stream1 = broadcaster.makeStream()
        let stream2 = broadcaster.makeStream()
        
        let task1 = Task {
            var values: [Int] = []
            for await value in stream1 {
                values.append(value)
            }
            return values
        }
        
        let task2 = Task {
            var values: [Int] = []
            for await value in stream2 {
                values.append(value)
            }
            return values
        }
        
        broadcaster.yield(42)
        broadcaster.finish()
        
        let result1 = await task1.value
        let result2 = await task2.value
        
        #expect(result1 == [42])
        #expect(result2 == [42])
    }

    @Test("遅延サブスクライブ")
    func lateSubscription() async throws {
        let broadcaster = AsyncStreamBroadcaster<Int>()
        
        broadcaster.yield(1)
        broadcaster.yield(2)
        
        let lateStream = broadcaster.makeStream()
        let task = Task {
            var values: [Int] = []
            for await value in lateStream {
                values.append(value)
                if values.count == 2 {
                    break
                }
            }
            return values
        }
        
        broadcaster.yield(3)
        broadcaster.yield(4)
        
        let result = await task.value
        #expect(result == [3, 4])
    }

    @Test("バッファリングポリシー - Unbounded",
          arguments: [
            AsyncStream<Int>.Continuation.BufferingPolicy.unbounded,
            .bufferingOldest(5)
          ])
    func bufferingPolicies(policy: AsyncStream<Int>.Continuation.BufferingPolicy) async throws {
        let broadcaster = AsyncStreamBroadcaster<Int>(bufferingPolicy: policy)
        let stream = broadcaster.makeStream()
        
        let task = Task {
            var values: [Int] = []
            for await value in stream {
                values.append(value)
                if values.count == 3 {
                    break
                }
            }
            return values
        }
        
        broadcaster.yield(10)
        broadcaster.yield(20)
        broadcaster.yield(30)
        
        let result = await task.value
        #expect(result == [10, 20, 30])
    }

    @Test("並行アクセス")
    func concurrentAccess() async throws {
        let broadcaster = AsyncStreamBroadcaster<Int>()
        let streamsCount = 10
        
        let tasks = (0..<streamsCount).map { index in
            Task {
                let stream = broadcaster.makeStream()
                var values: [Int] = []
                for await value in stream {
                    values.append(value)
                    if values.count == 3 {
                        break
                    }
                }
                return (index, values)
            }
        }
        
        let broadcastTask = Task {
            for i in 1...3 {
                broadcaster.yield(i * 100)
                try await Task.sleep(for: .milliseconds(10))
            }
        }
        
        let results = await withTaskGroup(of: (Int, [Int]).self) { group in
            for task in tasks {
                group.addTask { await task.value }
            }
            
            var allResults: [Int: [Int]] = [:]
            for await result in group {
                allResults[result.0] = result.1
            }
            return allResults
        }
        
        try await broadcastTask.value
        
        let expectedValues = [100, 200, 300]
        for (_, values) in results {
            #expect(values == expectedValues)
        }
        #expect(results.count == streamsCount)
    }

    @Test("ストリームのキャンセル処理")
    func streamCancellation() async throws {
        let broadcaster = AsyncStreamBroadcaster<Int>()
        let stream1 = broadcaster.makeStream()
        let stream2 = broadcaster.makeStream()
        
        let task1 = Task {
            var values: [Int] = []
            for await value in stream1 {
                values.append(value)
                if values.count == 1 {
                    break
                }
            }
            return values
        }
        
        let task2 = Task {
            var values: [Int] = []
            for await value in stream2 {
                values.append(value)
                if values.count == 2 {
                    break
                }
            }
            return values
        }
        
        broadcaster.yield(1)
        broadcaster.yield(2)

        let result1 = await task1.value
        #expect(result1 == [1])
        
        let result2 = await task2.value
        #expect(result2 == [1, 2])
    }
}
