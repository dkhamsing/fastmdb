//
//  MultiSearchResult.swift
//  FastMDb
//
//  Created by Daniel on 9/25/21.
//  Copyright © 2021 dk. All rights reserved.
//

struct MultiSearchResult: Codable {
    var media_type: String
    var id: Int?

    var poster_path: String?
    var backdrop_path: String?
    var overview: String?
    var name: String?
    var vote_average: Double?

    // person
    var profile_path: String?
    var known_for: [Media]?

    // movie
    var original_title: String?
    var release_date: String?
    var title: String?

    // tv
    var first_air_date: String?
    var original_name: String?
}
