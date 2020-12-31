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
}

struct Images: Codable {
    var backdrops: [TmdbImage]?
    var profiles: [TmdbImage]?
    var stills: [TmdbImage]?
}

extension Images {
    var backdropsSection: ItemSection? {
        guard let backdrops = backdrops else { return nil }

        let filtered = backdrops.filter { ($0.iso_639_1 ?? "" == "") || ($0.iso_639_1 ?? "" == "en") }
        guard filtered.count > 0 else { return nil }

        let items: [Item] = filtered.map {
            let url = Tmdb.backdropImageUrl(path: $0.file_path, size: .original)
            let imageUrl = Tmdb.backdropImageUrl(path: $0.file_path, size: .medium)
            return Item.ImageItem(url: url, imageUrl: imageUrl)
        }

        return ItemSection(items: items, display: .thumbnail)
    }

    var profilesSection: ItemSection? {
        guard let profiles = profiles,
              profiles.count > 1 else { return nil }

        let items: [Item] = profiles.map {
            let url = Tmdb.castProfileUrl(path: $0.file_path, size: .large)
            let imageUrl = Tmdb.castProfileUrl(path: $0.file_path, size: .medium)
            return Item.ImageItem(url: url, imageUrl: imageUrl)
        }

        return ItemSection(items: items.suffix(items.count-1), display: .collection)
    }

    var stillsSection: ItemSection? {
        guard let stills = stills,
              !stills.isEmpty else { return nil }

        let items: [Item] = stills.map {
            let url = Tmdb.stillImageUrl(path: $0.file_path, size: .original)
            let imageUrl = Tmdb.stillImageUrl(path: $0.file_path, size: .original)
            return Item.ImageItem(url: url, imageUrl: imageUrl)
        }

        return ItemSection(items: items, display: .thumbnail)
    }
}

struct TmdbImage: Codable {
    var file_path: String
    var iso_639_1: String?
}

extension Media {
    enum CodingKeys: String, CodingKey {
        case watch = "watch/providers"
        case id,
             title,
             original_title,
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

extension WatchSearch {

    static let providersNotInterested = [
        "directv",
        "fubotv",
        "sling tv",
        "spectrum on demand"
    ]

    func watchItems(_ name: String?) -> [Item]? {
        guard let country = results["US"] else { return watchItemsGoogle(name) }
        guard let providers = country.flatrate else { return watchItemsGoogle(name) }

        let items: [Item] = providers
            .map { $0.provider_name }
            .unique
            .filter { !WatchSearch.providersNotInterested.contains($0.lowercased()) }
            .filter { !$0.lowercased().contains("amazon channel") }
            .sorted { $0 < $1 }
            .map { Item(title: $0, url: country.link, destination: .url, image: Item.linkImage) }

        guard items.count > 0 else { return watchItemsGoogle(name) }

        return items
    }

    func watchItemsGoogle(_ name: String?) -> [Item]? {
        guard let name = name,
              name != "" else { return nil }

        let item = Item(title: "Google Search", url: name.googleSearchWatchUrl, destination: .url, image: Item.linkImage)
        return [item]
    }

    func watchSection(_ name: String?) -> ItemSection? {
        guard let items = watchItems(name) else { return nil }

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
