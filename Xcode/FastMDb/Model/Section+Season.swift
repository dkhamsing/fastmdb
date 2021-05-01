//
//  Section+Season.swift
//  FastMDb
//
//  Created by Daniel on 5/18/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation
import UIKit

extension ItemSection {
    static func seasonSections(tvId: Int?, season: Season?) -> [ItemSection] {
        var sections: [ItemSection] = []

        if let section = season?.images?.postersSection {
            sections.append(section)
        }

        if let section = season?.airDatesSection {
            sections.append(section)
        }

        if
            let o = season?.overview,
            o != "" {
            let item = Item(title: o)
            let section = ItemSection(header: "overview", items: [item])
            sections.append(section)
        }

        if
            let cast = season?.credits?.cast,
            cast.count > 0 {
            let items = cast.map { $0.listItemCast }
            let section = ItemSection(header: "cast", items: items,
                                      metadata: Metadata(display: .portraitImage))

            sections.append(section)
        }

        let limit = 5

        if
            let crew = season?.credits?.crew,
            crew.count > 0 {
            let names = crew.compactMap { $0.name }.unique
            let top = Array(names.prefix(limit))
            let item = Item(title: top.joined(separator: ", "))

            let section = ItemSection(header: "crew",
                                  items: [item],
                                  footer: crew.count > limit ? String.allCreditsText(crew.count) : String.allCreditsText(),
                                  metadata: Metadata(destination: .items, items: crew.map { $0.listItemCrew }))

            sections.append(section)
        }

        if let episodes = season?.episodes,
            episodes.count > 0 {
            let items = episodes.map { $0.listItem(tvId) }
            let section = ItemSection(header: "\(items.count) episodes", items: items)
            sections.append(section)
        }

        return sections
    }
}

private extension Episode {

    func listItem(_ tvId: Int?) -> Item {
        var sub: [String] = []

        if let episodeNumber = episode_number {
            sub.append("Episode \(episodeNumber)")
        }

        if let airDate = air_date?.dateDisplay {
            sub.append(airDate)
        }

        return Item(title: name, subtitle: sub.joined(separator: Tmdb.separator), color: episodeRatingColor,
                    metadata: Metadata(id: tvId, destination: .episode, episode: self))
    }
}

private extension Season {

    var airDatesSection: ItemSection? {
        guard let airDate = air_date?.dateDisplay else { return nil }
        var items: [Item] = []

        items.append(
            Item(title: airDate, subtitle: "First Episode")
        )

        if
            let episodes = episodes,
            episodes.count > 1,
            let last = episodes.filter ({ $0.air_date != nil }).last,
            let airDate = last.air_date?.dateDisplay {
            items.append(
                Item(title: airDate, subtitle: "Last Episode")
            )
        }

        let section = ItemSection(header: "air dates", items: items)

        return section
    }

}
