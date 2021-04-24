//
//  Season.swift
//
//  Created by Daniel on 5/14/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

struct Season: Codable {
    var id: Int

    var air_date: String?
    var credits: Credits?
    var episode_count: Int?
    var episodes: [Episode]?
    var name: String
    var overview: String?
    var poster_path: String?
    var season_number: Int

    var images: Images?
}

extension Season {
    func listItem(tvId: Int?) -> Item {
        let imageUrl = Tmdb.mediaPosterUrl(path: poster_path, size: .medium)

        let text = season_number > 0 ? "\(season_number)" : ""
        return Item(id: tvId, title: name, destination: .season, seasonNumber: season_number, imageUrl: imageUrl, imageCenterText: text, strings: strings)
    }

    var strings: [String] {
        guard season_number > 0 else { return [name] }

        var sub: [String] = [name]

        if let _ = air_date {
            sub.append(air_date.yearDisplay)
        }

        if let c = episode_count,
            c > 0 {
            let string = "\(c) episode\(c.pluralized)"
            sub.append(string)
        }

        return sub
    }
}
