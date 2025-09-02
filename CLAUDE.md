# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Development Commands

### Testing
- **Run all tests**: `swift test` or XcodeBuildMCP `test_device` command  
- **XcodeBuildMCP preferred**: Use XcodeBuildMCP tools instead of xcrun commands when available

### Building
- **Build package**: `swift build` or XcodeBuildMCP `build_device` command
- **Clean build artifacts**: `swift package clean`

### Package Management
- **Update dependencies**: `swift package update`
- **Resolve dependencies**: `swift package resolve`

## Architecture Overview

### Project Structure
このプロジェクトはSwift Packageとして構成されており、AsyncStreamのブロードキャスト機能を提供するライブラリです。

### Core Components

#### AsyncStreamBroadcaster (Sources/AsyncStreamBroadcaster/AsyncStreamBroadcaster.swift)
- **目的**: 単一のソースから複数のAsyncStreamに値をブロードキャストする
- **主要API**:
  - `makeStream()`: 新しいAsyncStreamを作成
  - `yield(_ value:)`: 全てのストリームに値を送信
  - `finish()`: 全てのストリームを終了
- **内部実装**: 
  - `Storage`クラスがスレッドセーフなブロードキャスト機能を提供
  - `OSAllocatedUnfairLock`を使用した排他制御
  - UUID管理によるStreamの登録・削除

### Testing Framework
- Swift Testing framework (import Testing)を使用
- テストファイル: `Tests/AsyncStreamBroadcasterTests/AsyncStreamBroadcasterTests.swift`

### Concurrency Design
- `Sendable`プロトコルに準拠した並行プログラミング対応
- `@unchecked Sendable`を使った内部Storageクラス
- スレッドセーフな継続管理による複数ストリームの同期ブロードキャスト

### Platform Requirements
- iOS 17.0以上
- Swift 6.1以上