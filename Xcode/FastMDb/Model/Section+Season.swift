//
//  Section+Season.swift
//  FastMDb
//
//  Created by Daniel on 5/18/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation
import UIKit

extension Section {
    static func seasonSections(_ season: Season?) -> [Section] {
          var sections: [Section] = []

          if
              let o = season?.overview,
              o != "" {
              let item = Item.init(title: o)
              let section = Section(header: "overview", items: [item])
              sections.append(section)
          }

          let limit = 5

          if
              let cast = season?.credits?.cast,
              cast.count > 0 {

              let items = cast.map { $0.listItemCast }
              let topItems = Array(items.prefix(limit))
              var section = Section(header: "cast", items: topItems)

              if cast.count > limit {
                  section.footer = String.allCreditsText(cast.count)
                  section.destinationItems = cast.map { $0.listItemCast }
                  section.destination = .items
              }

              sections.append(section)
          }

          if
              let crew = season?.credits?.crew,
              crew.count > 0 {
              let names = crew.compactMap { $0.name }.unique
              let top = Array(names.prefix(limit))
              let item = Item(title: top.joined(separator: ", "))

              let section = Section(header: "crew",
                                    items: [item],
                                    footer: crew.count > limit ? String.allCreditsText(crew.count) : String.allCreditsText(),
                                    destination: .items,
                                    destinationItems: crew.map { $0.listItemCrew })

              sections.append(section)
          }

          if let episodes = season?.episodes,
              episodes.count > 0 {
              let items = episodes.map { $0.listItem }
              let section = Section(header: "episodes", items: items)
              sections.append(section)
          }

          return sections
      }
}

private extension Episode {
    var episodeRatingColor: UIColor? {
        guard vote_count > Tmdb.voteThreshold else { return nil }

        return vote_average.color
    }

    var listItem: Item {
        var sub: [String] = []

        if let episodeNumber = episode_number {
            sub.append("Episode \(episodeNumber)")
        }

        if let airDate = air_date?.dateDisplay {
            sub.append(airDate)
        }

        return Item(title: name, subtitle: sub.joined(separator: Tmdb.separator), destination: .episode, episode: self, color: episodeRatingColor)
    }
}
