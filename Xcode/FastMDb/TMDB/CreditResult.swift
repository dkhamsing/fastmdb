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

        var items = [ Item(id: id, title: media.original_name, destination: .tv) ]
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
                .map { $0.listItem(tvId: id) }
            if !items.isEmpty {
                var strings: [String] = [
                    "\(season.count) season\(season.count.pluralized)",
                ]

                if let value = media.episodes,
                   !value.isEmpty {
                    let count = value.count
                    strings.append(
                        "\(count) episode\(count.pluralized)"
                    )
                }

                sections.append(ItemSection(
                                    header: strings.joined(separator: ", "),
                                    items: items))
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
                let it = sorted.filter { $0.season_number ?? 0 == season }.map { $0.listItem }
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

    var listItem: Item {
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

        return Item(id: id, title: name, subtitle: sub.joined(separator: "\n"), destination: .episode, episode: self, color: episodeRatingColor)
    }
}

