//
//  Search.swift
//
//  Created by Daniel on 10/10/19.
//  Copyright © 2019 dkhamsing. All rights reserved.
//

struct ContentRatingSearch: Codable {
    var results: [ContentRating]
}

struct ImageSearch: Codable {
    var results: [TaggedMedia]
}

struct MediaSearch: Codable {
    var total_results: Int
    var results: [Media]
}

struct MultiSearch: Codable {
    var total_results: Int
    var results: [MultiSearchResult]
}

struct PeopleSearch: Codable {
    var total_results: Int
    var results: [Credit]
}

struct ProviderSearch: Codable {
    var results: [Provider]
}

struct ReleaseSearch: Codable {
    var results: [ReleaseInfo]
}

struct ReviewSearch: Codable {
    var results: [Review]
}

struct TvSearch: Codable {
    var total_results: Int
    var results: [TV]
}

struct VideoSearch: Codable {
    var results: [Video]
}

struct WatchSearch: Codable {
    var results: [String: Watch]
}
