//
//  Media.swift
//
//  Created by Daniel on 10/10/19.
//  Copyright © 2019 dkhamsing. All rights reserved.
//

import Foundation

struct Media: Codable {
    var id: Int

    var title: String?
    var original_title: String?

    var budget: Int?
    var revenue: Int?

    var vote_average: Double
    var vote_count: Int

    var backdrop_path: String?
    var belongs_to_collection: MediaCollection?
    var credits: Credits?
    var external_ids: ExternalIds?
    var genres: [Genre]?
    var homepage: String?
    var original_language: String?
    var overview: String
    var production_companies: [Production]?
    var production_countries: [ProductionCountry]?
    var poster_path: String?
    var recommendations: MediaSearch?
    var reviews: ReviewSearch?
    var release_date: String?
    var release_dates: ReleaseSearch?
    var runtime: Int?
    var similar: MediaSearch?
    var status: String?
    var tagline: String?
    var videos: VideoSearch?
    var watch: WatchSearch?

    var images: Images?

    // TV
    var original_name: String?

    // Credit
    var episodes: [Episode]?
    var seasons: [Season]?
    var character: String?
}

extension Media {
    enum CodingKeys: String, CodingKey {
        case watch = "watch/providers"
        case id,
             title,
             original_title,
             episodes,
             seasons,
             character,
             backdrop_path,
             budget, revenue,
             vote_average,
             vote_count,
             original_name,
             belongs_to_collection,
             credits,
             external_ids,
             genres,
             homepage,
             images,
             original_language,
             overview,
             production_companies,
             production_countries,
             poster_path,
             recommendations,
             reviews,
             release_date,
             release_dates,
             runtime,
             similar,
             status,
             tagline,
             videos
    }
}
