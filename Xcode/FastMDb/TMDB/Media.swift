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

    // Credit
    var episodes: [Episode]?
    var seasons: [Season]?
    var character: String?
}

struct Images: Codable {
    var backdrops: [TmdbImage]?
    var profiles: [TmdbImage]?
    var posters: [TmdbImage]?
    var stills: [TmdbImage]?
}

extension Images {
    var backdropItems: [Item] {
        guard let backdrops = backdrops else { return [] }

        let filtered = backdrops.filter { ($0.iso_639_1 ?? "" == "") || ($0.iso_639_1 ?? "" == "en") }
        guard filtered.count > 0 else { return [] }

        let items: [Item] = filtered.map {
            let url = Tmdb.backdropImageUrl(path: $0.file_path, size: .original)
            let imageUrl = Tmdb.backdropImageUrl(path: $0.file_path, size: .medium)
            return Item.imageItem(url: url, imageUrl: imageUrl)
        }

        return items
    }

    var backdropsSection: ItemSection? {
        let items = backdropItems

        guard items.count > 0 else { return nil }

        return ItemSection(items: items, metadata: Metadata(display: .thumbnailImage))
    }

    var postersSection: ItemSection? {
        guard let posters = posters else { return nil }

        let filtered = posters.filter { ($0.iso_639_1 ?? "" == "") || ($0.iso_639_1 ?? "" == "en") }
        guard filtered.count > 0 else { return nil }

        let items: [Item] = filtered.map {
            let url = Tmdb.castProfileUrl(path: $0.file_path, size: .large)
            let imageUrl = Tmdb.castProfileUrl(path: $0.file_path, size: .medium)
            var item = Item.imageItem(url: url, imageUrl: imageUrl)
            item.metadata?.display = .portraitImage
            return item
        }

        return ItemSection(items: items, metadata: Metadata(display: .images))
    }

    var profilesSection: ItemSection? {
        guard let profiles = profiles,
              profiles.count > 0 else { return nil }

        let items: [Item] = profiles.map {
            let url = Tmdb.castProfileUrl(path: $0.file_path, size: .large)
            let imageUrl = Tmdb.castProfileUrl(path: $0.file_path, size: .medium)
            var item = Item.imageItem(url: url, imageUrl: imageUrl)
            item.metadata?.display = .portraitImage
            return item
        }

        return ItemSection(items: items, metadata: Metadata(display: .images))
    }

    var stillsSection: ItemSection? {
        guard let stills = stills,
              !stills.isEmpty else { return nil }

        let items: [Item] = stills.map {
            let url = Tmdb.stillImageUrl(path: $0.file_path, size: .original)
            let imageUrl = Tmdb.stillImageUrl(path: $0.file_path, size: .original)
            return Item.imageItem(url: url, imageUrl: imageUrl)
        }

        return ItemSection(items: items, metadata: Metadata(display: .thumbnailImage))
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

extension WatchSearch {

    static let providersNotInterested = [
        "directv",
        "fubotv",
        "sling tv",
        "spectrum on demand"
    ]

    func watchSectionProvider(_ name: String?) -> ItemSection? {
        guard let country = results["US"],
              let providers = country.flatrate else { return watchSectionGoogleJustWatch(name) }

        let myProviders = providers
            .filter { !WatchSearch.providersNotInterested.contains($0.provider_name.lowercased()) }
            .filter { !$0.provider_name.lowercased().contains("amazon channel") }
            .sorted { $0.provider_name < $1.provider_name }

        let items: [Item] = myProviders.map {
            Item(title: $0.provider_name, metadata: Metadata(url: country.link, destination: .url, imageUrl: $0.iconImageUrl, imageCornerRadius: 12))
        }

        guard items.count > 0 else { return watchSectionGoogleJustWatch(name) }

        return ItemSection(header: "Watch", items: items, metadata: Metadata(display: .squareImage))
    }

    func watchSectionGoogleJustWatch(_ name: String?) -> ItemSection? {
        guard let name = name,
              name != "" else { return nil }

        let google = Item(title: "Google Search",
                          metadata: Metadata(url: name.googleSearchWatchUrl, destination: .url, link: .link))
        let justWatch = Item(title: "JustWatch",
                             metadata: Metadata(url: URL(string: "https://justwatch.com"), destination: .url, link: .link))
        let items = [google, justWatch]

        return ItemSection(header: "Watch", items: items)
    }

    func watchSection(_ name: String?) -> ItemSection? {
        guard let sect = watchSectionProvider(name) else { return nil }

        return sect
    }
}

struct Watch: Codable {
    var link: URL?
    var flatrate: [Provider]?
}

struct Provider: Codable {
    var provider_name: String
    var logo_path: String

    var iconImageUrl: URL? {
        return Tmdb.logoUrl(path: logo_path, size: .small)
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

        return Item(title: titleDisplay, subtitle: sub, color: ratingColor,
                    metadata: Metadata(id: id, destination: .movie))
    }

    var listItemTextImage: Item {
        let sub = listItemSub.joined(separator: Tmdb.separator)
        let imageUrl = Tmdb.stillImageUrl(path: backdrop_path, size: .medium)
        return Item(title: titleDisplay, subtitle: sub, color: ratingColor,
                    metadata: Metadata(id: id, destination: .movie, imageUrl: imageUrl))
    }

    var listItemUpcoming: Item {
        let sub = upcomingDateDisplay
        let imageUrl = Tmdb.stillImageUrl(path: backdrop_path, size: .medium)
        return Item(title: titleDisplay, subtitle: sub, color: ratingColor,
                    metadata: Metadata(id: id, destination: .movie, imageUrl: imageUrl))
    }

    var listItemWithVotes: Item {
        var sub = listItemSub
        sub.append("\(vote_count) votes")
        sub.append("\(vote_average)")
        let imageUrl = Tmdb.stillImageUrl(path: backdrop_path, size: .medium)
        return Item(title: titleDisplay, subtitle: sub.joined(separator: Tmdb.separator), color: ratingColor,
                    metadata: Metadata(id: id, destination: .movie, imageUrl: imageUrl))
    }

    var listItemImage: Item {
        let sub = listItemSub.joined(separator: Tmdb.separator)
        let imageUrl = Tmdb.mediaPosterUrl(path: poster_path, size: .medium)

        return Item(title: titleDisplay, subtitle: sub, color: ratingColor,
                    metadata: Metadata(id: id, destination: .movie, imageUrl: imageUrl))
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

        return Item(title: titleDisplay, subtitle: sub.joined(separator: Tmdb.separator), color: ratingColor,
                    metadata: Metadata(id: id, destination: .movie))
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

    var upcomingDateDisplay: String? {
        guard
            let r = release_date,
            let date = Tmdb.dateFormatter.date(from: r) else { return releaseYear  }

        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .day, for: date) else { return releaseYear }

        let components = calendar.dateComponents([.day], from: Date(), to: interval.end)

        guard let day = components.day, day > 0 else { return releaseYear }

        var strings: [String] = []

        if let year = releaseYear {
            strings.append(year)
        }

        strings.append("To be released in \(day) day\(day.pluralized)")
        return strings.joined(separator: Tmdb.separator)
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
