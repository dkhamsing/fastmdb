//
//  Credit.swift
//
//  Created by Daniel on 10/10/19.
//  Copyright © 2019 dkhamsing. All rights reserved.
//

import Foundation
import UIKit

struct Credit: Codable {
    var id: Int

    var name: String?
    var original_name: String?

    var title: String?
    var original_title: String?

    var poster_path: String?
    var profile_path: String?

    var episode_count: Int?
    var first_air_date: String?

    var known_for_department: String?
    var known_for: [Media]?

    var movie_credits: Credits?
    var tv_credits: Credits?

    var vote_average: Double?
    var vote_count: Int?

    var biography: String?
    var birthday: String?
    var place_of_birth: String?
    var character: String?
    var deathday: String?
    var external_ids: ExternalIds?
    var genre_ids: [Int]?
    var original_language: String?
    var popularity: Double?
    var release_date: String?

    // Crew
    var job: String?
}

extension Credit {

    var listItemCast: Item {
        return Item(id: id, title: titleDisplay, subtitle: character, destination: .person)
    }

    var listItemCrew: Item {
        return Item(id: id, title: name, subtitle: job, destination: .person)
    }

    var listItemTv: Item {
        var sub: [String] = []

        if first_air_date.yearDisplay != "" {
            sub.append(first_air_date.yearDisplay)
        }

        if
            let country = original_language,
            country != "en",
            let lang = Languages.List[country] {
            sub.append(lang)
        }

        if let c = character, c != "" {
            sub.append(c)
        }

        if let episodes = episode_count {
            let epString = "\(episodes) episode\(episodes > 1 ? "s" : "")"
            sub.append(epString)
        }

        return Item(id: id, title: titleDisplay, subtitle: sub.joined(separator: Tmdb.separator), destination: .tv, color: ratingColor)
    }

    var ratingColor: UIColor? {
        guard
            let c = vote_count,
            c > Tmdb.voteThreshold else { return nil }

        return vote_average?.color
    }

    var releaseYear: String? {
        guard release_date.yearDisplay != "" else { return nil }

        return release_date.yearDisplay
    }

    var titleDisplay: String? {
        var t = "\(title ?? name ?? "")"
        if title != original_title {
            t.append(" (")
            t.append(original_title ?? "")
            t.append(")")
        }

        return t
    }

}
