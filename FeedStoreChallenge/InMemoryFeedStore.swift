//
//  InMemoryFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Arifin Firdaus on 16/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public final class InMemoryFeedStore: FeedStore {
	private struct Cache {
		let feedImages: [LocalFeedImage]
		let timestamp: Date
	}
	private var cache: Cache?
	private let queue = DispatchQueue(label: "\(type(of: InMemoryFeedStore.self))Queue", qos: .userInitiated, attributes: .concurrent)
	
	public init() { }
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		queue.async(flags: .barrier) { [weak self] in
			guard let self = self else { return }
			
			self.cache = nil
			completion(.none)
		}
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		queue.async(flags: .barrier) { [weak self] in
			guard let self = self else { return }
			
			self.cache = Cache(feedImages: feed, timestamp: timestamp)
			completion(.none)
		}
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		queue.async { [weak self] in
			guard let self = self else { return }
			
			if let savedCache = self.cache {
				completion(.found(feed: savedCache.feedImages, timestamp: savedCache.timestamp))
			} else {
				completion(.empty)
			}
		}
	}
	
}
