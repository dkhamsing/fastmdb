//
//  Search.swift
//
//  Created by Daniel on 10/10/19.
//  Copyright © 2019 dkhamsing. All rights reserved.
//

import Foundation

struct MediaSearch: Codable {
//    var page: Int
//    var total_pages: Int
    var total_results: Int
    var results: [Media]
}

struct PeopleSearch: Codable {
    var total_results: Int
    var results: [Credit]
}

struct TvSearch: Codable {
    var total_results: Int
    var results: [TV]
}

struct VideoSearch: Codable {
    var results: [Video]
}

struct ReleaseSearch: Codable {
    var results: [ReleaseInfo]
}

extension ReleaseSearch {
    func usCertificationRating(_ countryCode: String) -> String? {
        let usa = results.filter { $0.iso_3166_1 == countryCode }
        if let first = usa.first?.release_dates.first {
            return first.certification
        }

        return nil
    }
}

struct ReleaseInfo: Codable {
    var iso_3166_1: String
    var release_dates: [Release]
}

struct Release: Codable {
    var certification: String
}
