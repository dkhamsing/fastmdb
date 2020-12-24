//
//  Media.swift
//
//  Created by Daniel on 10/10/19.
//  Copyright © 2019 dkhamsing. All rights reserved.
//

import Foundation
import UIKit

struct Media: Codable {
    var id: Int

    var title: String?
    var original_title: String?

    var budget: Int?
    var revenue: Int?

    var vote_average: Double
    var vote_count: Int

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

    // TV
    var original_name: String?
}

extension Media {
    enum CodingKeys: String, CodingKey {
        case watch = "watch/providers"
        case id,
             title,
             original_title,
             budget, revenue,
             vote_average,
             vote_count,
             original_name,
             belongs_to_collection,
             credits,
             external_ids,
             genres,
             homepage,
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

struct WatchSearch: Codable {
    var results: [String: Watch]
}

extension WatchSearch {
    var watchSection: ItemSection? {
        guard let country = results["US"] else { return nil }
        guard let providers = country.flatrate else { return nil }

        let items: [Item] = providers
            .sorted { $0.provider_name < $1.provider_name }
            .map { Item(title: $0.provider_name, url: country.link, destination: .url) }

        return ItemSection(header: "Watch", items: items)
    }
}

struct Watch: Codable {
    var link: URL?
    var flatrate: [Provider]?
}

struct Provider: Codable {
    var provider_name: String
}

// TODO: move to Review.swift file
struct ReviewSearch: Codable {
    var results: [Review]
}

struct Review: Codable {
    var author, content: String
    var author_details: Author
}

struct Author: Codable {
    var rating: Double?
}

extension Review {
    var listItem: Item {
        var sub: [String] = []

        if let rating = author_details.rating {
            sub.append("\(rating)/10")
        }

        sub.append(author)

        return Item(title: content, subtitle: sub.joined(separator: Tmdb.separator))
    }
}

extension Media {

    var listItemSub: [String] {
        var sub: [String] = []

        if let year = releaseYear {
            sub.append(year)
        }

        if
            let country = original_language,
            country != "en",
            let lang = Languages.List[country] {
            sub.append(lang)
        }
        return sub
    }

    var listItem: Item {
        let sub = listItemSub.joined(separator: Tmdb.separator)

        return Item(id: id, title: titleDisplay, subtitle: sub, destination: .movie, color: ratingColor)
    }

    var listItemCollection: Item {
        var sub = listItemSub

        if let c = credits?.crew {
            let d = c.filter { $0.job == CrewJob.Director.rawValue }
            if d.count > 0 {
                let directors = d.compactMap { $0.name }
                let director = "Directed by \(directors.joined(separator: ", "))"
                sub.append(director)
            }
        }

        return Item(id: id, title: titleDisplay, subtitle: sub.joined(separator: Tmdb.separator), destination: .movie, color: ratingColor)
    }

    var released: Bool {
        guard
            let rel = release_date,
            let date = Tmdb.dateFormatter.date(from: rel),
            date.timeIntervalSinceNow < 0 else { return false }

        return true
    }

    var releaseYear: String? {
        guard release_date.yearDisplay != "" else { return nil }

        return release_date.yearDisplay
    }

    var titleDisplay: String? {
        var t = "\(title ?? original_name ?? "")"
        if title != original_title {
            t.append(" (")
            t.append(original_title ?? "")
            t.append(")")
        }

        return t
    }
}

private extension Media {
    var ratingColor: UIColor? {
        guard
            released,
            vote_count > Tmdb.voteThreshold else { return nil }

        return vote_average.color
    }
}
