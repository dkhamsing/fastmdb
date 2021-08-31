//
//  TV.swift
//
//  Created by Daniel on 5/7/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation
import UIKit

struct TV: Codable {
    var id: Int

    var name: String
    var original_name: String

    var first_air_date: String?
    var last_air_date: String?
    var next_episode_to_air: Episode?

    var number_of_episodes: Int?
    var number_of_seasons: Int?

    var vote_average: Double
    var vote_count: Int

    var created_by: [Credit]?
    var episode_run_time: [Int]?
    var genres: [Genre]?
    var homepage: String?
    var origin_country: [String]?
    var original_language: String?
    var overview: String?
    var networks: [TvNetwork]?
    var poster_path: String?
    var production_companies: [Production]?
    var production_countries: [ProductionCountry]?
    var tagline: String?

    var content_ratings: ContentRatingSearch?
    var recommendations: TvSearch?
    var similar: TvSearch?

    var seasons: [Season]?
    var status: String?

    var credits: Credits?

    var aggregate_credits: Credits?

    var external_ids: ExternalIds?

    var videos: VideoSearch?

    var watch: WatchSearch?

    var images: Images?
}

extension TV {
    enum CodingKeys: String, CodingKey {
        case watch = "watch/providers"
        case id,
             name,
             original_name,
             first_air_date,
             last_air_date,
             next_episode_to_air,
             number_of_episodes,
             number_of_seasons,
             vote_average,
             vote_count,
             created_by,
             episode_run_time,
             genres,
             homepage,
             images,
             origin_country,
             original_language,
             overview,
             networks,
             poster_path,
             production_companies,
             production_countries,
             tagline,
             content_ratings,
             recommendations,
             similar,
             seasons,
             status,
             credits,
             aggregate_credits,
             external_ids,
             videos
    }

    var countryDisplay: String? {
        guard
            let country = origin_country?.first,
            country != "",
            country != "US" else { return nil }

        if let name = Locale.current.localizedString(forRegionCode: country) {
            return name
        }

        return country
    }

    var displayName: String {
        if name != original_name {
            return "\(name) (\(original_name))"
        }
        return name
    }
    
    var listItem: Item {
        var item = listItemNoSub

        var sub: [String] = []
        if first_air_date.yearDisplay != "" {
            sub.append(first_air_date.yearDisplay)
        }
        sub.append(contentsOf: subtitleLanguageCountry)

        item.subtitle = sub.joined(separator: Tmdb.separator)

        return item
    }

    var listItemImage: Item {
        var item = listItemNoSub

        var sub: [String] = []
        if first_air_date.yearDisplay != "" {
            sub.append(first_air_date.yearDisplay)
        }
        sub.append(contentsOf: subtitleLanguageCountry)
        item.subtitle = sub.joined(separator: Tmdb.separator)

        item.metadata = Metadata(id: id, destination: .tv, imageUrl: Tmdb.mediaPosterUrl(path: poster_path, size: .medium))

        return item
    }

    var listItemWithVotes: Item {
        var item = listItemNoSub

        var sub: [String] = []
        if first_air_date.yearDisplay != "" {
            sub.append(first_air_date.yearDisplay)
        }
        sub.append(contentsOf: subtitleLanguageCountry)
        sub.append("\(vote_count) votes")
        sub.append("\(vote_average)")

        item.subtitle = sub.joined(separator: Tmdb.separator)

        return item
    }

    var listItemWithoutYear: Item {
        var item = listItemNoSub
        item.subtitle = subtitleLanguageCountry.joined(separator: Tmdb.separator)

        return item
    }

}

private extension TV {

    var subtitleLanguageCountry: [String] {
        var sub: [String] = []
        if
            let country = original_language,
            country != "en",
            let lang = Languages.List[country] {
            sub.append(lang)
        }
        else if let country = countryDisplay {
            sub.append(country)
        }

        return sub
    }

    var listItemNoSub: Item {
        return Item(title: displayName, color: ratingColor,
                    metadata: Metadata(id: id, destination: .tv))
    }

    var ratingColor: UIColor? {
        guard vote_count > Tmdb.voteThreshold else { return nil }

        return vote_average.color
    }

}
