//
//  CreditResult.swift
//  FastMDb
//
//  Created by Daniel on 4/24/21.
//  Copyright © 2021 dk. All rights reserved.
//

import Foundation

struct CreditResult: Codable {
    var media: Media
    var job: String?
}

extension CreditResult {

    func sections(id: Int?) -> [ItemSection] {
        var sections: [ItemSection] = []

        if let section = media.imagesSection {
            sections.append(section)
        }

        var items = [ Item(title: media.original_name, metadata: Metadata(id: id, destination: .tv)) ]
        if !media.overview.isEmpty {
            items.append(Item(subtitle: media.overview))
        }
        sections.append(ItemSection(items: items))

        if let section = media.ratingTvCreditSection {
            sections.append(section)
        }

        if let season = media.seasons {
            let items = season
                .sorted { $0.season_number < $1.season_number }

            let specials = items
                .filter { $0.season_number == 0 }
                .map { $0.listItem(tvId: id) }
            if !specials.isEmpty {
                sections.append(ItemSection(items: specials))
            }

            let regularSeasons = items
                .filter { $0.season_number > 0 }

            if !regularSeasons.isEmpty {
                let regularItems = regularSeasons.map { $0.listItem(tvId: id) }

                var strings: [String] = [
                    "\(regularSeasons.count) season\(regularSeasons.count.pluralized)",
                ]

                if let value = media.episodes,
                   !value.isEmpty {
                    let count = value.count
                    strings.append(
                        "\(count) episode\(count.pluralized)"
                    )
                }

                sections.append(ItemSection(header: strings.joined(separator: ", "), items: regularItems))
            }
        }

        if let episodes = media.episodes {

            let sorted = episodes.sorted {
                if $0.season_number ?? 0 != $1.season_number ?? 0 {
                    return $0.season_number ?? 0 < $1.season_number ?? 0
                }
                return $0.episode_number ?? 0 < $1.episode_number ?? 0
            }

            let seasons = sorted.map { $0.season_number ?? 0 }.unique
            for season in seasons {
                let it = sorted.filter { $0.season_number ?? 0 == season }.map { $0.listItem(id) }
                sections.append(ItemSection(header: "\(Season.seasonName(season)): \(it.count) episode\(it.count.pluralized)", items: it))
            }

        }

        return sections
    }

}

private extension Episode {
    var seasonName: String {
        guard let season = season_number else { return ""}
        return Season.seasonName(season)
    }

    func listItem(_ id: Int?) -> Item {
        var call: String = "" // TODO: call is reused elsewhere?

        call.append(seasonName + ", ")

        if let episodeNumber = episode_number {
            call.append("Episode \(episodeNumber)")
        }

        var sub: [String] = []
        if !call.isEmpty {
            sub.append(call)
        }

        if let airDate = air_date?.dateDisplay {
            sub.append(airDate)
        }

        return Item(title: name, subtitle: sub.joined(separator: "\n"), color: episodeRatingColor,
                    metadata: Metadata(id: id, destination: .episode, episode: self))
    }
}

