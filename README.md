# AsyncStreamBroadcaster

A Swift package providing a thread-safe broadcaster for distributing values to multiple AsyncStream subscribers concurrently.

## Overview

`AsyncStreamBroadcaster` enables you to broadcast values from a single source to multiple `AsyncStream` consumers. It's perfect for scenarios where you need to distribute the same data to multiple concurrent listeners, such as:

- Real-time data feeds (stock prices, sensor data, etc.)
- Event broadcasting systems
- Push notification distribution
- Live updates to multiple UI components

## Features

- **Thread-Safe**: Uses `OSAllocatedUnfairLock` for optimal concurrent access
- **Dynamic Subscription Management**: Subscribers can join and leave at any time
- **Automatic Cleanup**: Streams are automatically removed when cancelled or terminated
- **Sendable Compliant**: Full Swift Concurrency support
- **Customizable Buffering**: Support for different buffering policies
- **Zero Dependencies**: Pure Swift implementation

## Requirements

- iOS 17.0+
- Swift 6.1+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/AsyncStreamBroadcaster.git", from: "1.0.0")
]
```

Or add it through Xcode:
1. Go to File → Add Package Dependencies
2. Enter the repository URL
3. Select your desired version

## Usage

### Basic Broadcasting

```swift
import AsyncStreamBroadcaster

// Create a broadcaster
let broadcaster = AsyncStreamBroadcaster<String>()

// Create multiple streams
let stream1 = broadcaster.makeStream()
let stream2 = broadcaster.makeStream()
let stream3 = broadcaster.makeStream()

// Start consuming from streams
Task {
    for await value in stream1 {
        print("Stream 1 received: \(value)")
    }
}

Task {
    for await value in stream2 {
        print("Stream 2 received: \(value)")
    }
}

Task {
    for await value in stream3 {
        print("Stream 3 received: \(value)")
    }
}

// Broadcast values to all streams
broadcaster.yield("Hello")
broadcaster.yield("World")
broadcaster.finish() // Close all streams
```

### Custom Buffering Policy

```swift
// Create broadcaster with custom buffering
let broadcaster = AsyncStreamBroadcaster<Int>(
    bufferingPolicy: .bufferingOldest(10)
)

let stream = broadcaster.makeStream()

// Values will be buffered according to the specified policy
broadcaster.yield(1)
broadcaster.yield(2)
broadcaster.yield(3)
```

### Late Subscription

Streams created after values have been broadcasted will only receive subsequent values:

```swift
let broadcaster = AsyncStreamBroadcaster<Int>()

// Broadcast some values
broadcaster.yield(1)
broadcaster.yield(2)

// Create a late subscriber
let lateStream = broadcaster.makeStream()

Task {
    for await value in lateStream {
        print("Late subscriber received: \(value)")
        // Will only receive values 3, 4, 5...
    }
}

// Continue broadcasting
broadcaster.yield(3) // Late subscriber receives this
broadcaster.yield(4) // Late subscriber receives this
```

## API Reference

### AsyncStreamBroadcaster

#### Initializer

```swift
public init(bufferingPolicy: AsyncStream<Element>.Continuation.BufferingPolicy = .unbounded)
```

Creates a new broadcaster with the specified buffering policy.

#### Methods

##### `makeStream() -> AsyncStream<Element>`

Creates and returns a new `AsyncStream` that will receive broadcasted values.

##### `yield(_ value: Element)`

Broadcasts a value to all active streams.

##### `finish()`

Closes all active streams and cleans up resources.

## Implementation Details

- **Thread Safety**: Uses `OSAllocatedUnfairLock` for efficient synchronization
- **Memory Management**: Automatically removes terminated stream continuations
- **UUID-based Tracking**: Each stream is tracked with a unique identifier
- **Sendable Compliance**: Safe to use across concurrency contexts

## Examples

### Real-time Data Feed

```swift
struct StockPriceFeed {
    private let broadcaster = AsyncStreamBroadcaster<StockPrice>()
    
    func subscribe() -> AsyncStream<StockPrice> {
        broadcaster.makeStream()
    }
    
    func updatePrice(_ price: StockPrice) {
        broadcaster.yield(price)
    }
    
    func close() {
        broadcaster.finish()
    }
}

// Usage
let feed = StockPriceFeed()

// Multiple subscribers
Task {
    for await price in feed.subscribe() {
        updateUI(with: price)
    }
}

Task {
    for await price in feed.subscribe() {
        logPrice(price)
    }
}

// Update prices from external source
feed.updatePrice(StockPrice(symbol: "AAPL", price: 150.25))
```

## Testing

The package includes comprehensive tests covering:

- Single and multiple stream broadcasting
- Stream termination and cleanup
- Late subscription behavior
- Buffering policies
- Concurrent access patterns
- Stream cancellation handling

Run tests using:

```bash
swift test
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Built with Swift Concurrency and AsyncStream
- Inspired by reactive programming patterns
- Designed for modern Swift concurrent applications