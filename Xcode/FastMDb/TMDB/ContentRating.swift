//
//  ContentRating.swift
//  FastMDb
//
//  Created by Daniel on 12/24/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

extension ReleaseSearch {
    func contentRating(_ countryCode: String) -> String? {
        let countries = results.filter { $0.iso_3166_1 == countryCode }
        guard let ratings = countries.first?.release_dates.map({ $0.certification }) else { return nil }

        return ratings.first(where: {!$0.isEmpty} )
    }
}

struct ReleaseInfo: Codable {
    var iso_3166_1: String
    var release_dates: [Release]
}

struct Release: Codable {
    var certification: String
}

struct ContentRatingSearch: Codable {
    var results: [ContentRating]
}

extension ContentRatingSearch {
    func contentRating(_ countryCode: String) -> String? {
        let countries = results.filter { $0.iso_3166_1 == countryCode }
        guard let first = countries.first else { return nil }

        return first.rating
    }
}

struct ContentRating: Codable {
    var iso_3166_1: String
    var rating: String
}
