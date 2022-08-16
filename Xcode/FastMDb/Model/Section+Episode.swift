
//
//  Section+Episode.swift
//
//  Created by Daniel on 5/12/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

extension Episode {
    var episodeSections: [ItemSection] {
        var sections: [ItemSection] = []

        sections.append(mainSection)

        if let section = ratingSection {
            sections.append(section)
        }

        if let section = writingSection {
            sections.append(section)
        }

        if let section = directorSection {
            sections.append(section)
        }

        if let section = guestStarsSection {
            sections.append(section)
        }

        if let section = crewSection {
            sections.append(section)
        }

        return sections
    }
}

private extension Episode {

    var crewSection: ItemSection? {
        guard let crew = crew else { return nil }

        var filtered = crew

        for job in CrewJob.allCases {
            filtered = filtered.filter { $0.job != job.rawValue }
        }

        let items = filtered.map { $0.listItemCrew }

        guard items.count > 0 else { return nil }

        return ItemSection(header: "crew", items: items)
    }

    var directorSection: ItemSection? {
        guard let crew = crew else { return nil }

        let directors = crew.filter { $0.job == CrewJob.Director.rawValue }
        guard directors.count > 0 else { return nil }

        let items = directors.map { $0.listItemCrew }

        return ItemSection(header: "directed by", items: items)
    }

    var guestStarsSection: ItemSection? {
        guard let guests = guest_stars else { return nil }

        let items = guests.map { $0.listItemCast }

        guard items.count > 0 else { return nil }

        let section = ItemSection(header: "Guest Stars", items: items, 
                                  metadata: Metadata(display: .portraitImage()))

        return section
    }

    var mainSection: ItemSection {
        var items: [Item] = []

        if let name = name {
            var sub: String?
            if let e = episode_number,
                let s = season_number {
                sub = "Season \(s), Episode \(e)"
            }
            let item = Item(title: name, subtitle: sub)
            items.append(item)
        }

        if let item = dateItem {
            items.append(item)
        }

        if let o = overview,
            o != "" {
            let item = Item(title: o)
            items.append(item)
        }

        return ItemSection(items: items)
    }

    var ratingSection: ItemSection? {
        guard let rating = ratingDisplay else { return nil }

        let item = Item(title: rating, subtitle: voteDisplay, color: vote_average.color)
        let section = ItemSection(header: "rating", items: [item])
        return section
    }

    var writingSection: ItemSection? {
        guard let crew = crew else { return nil }

        let writers = crew.filter { $0.job == CrewJob.Teleplay.rawValue || $0.job == CrewJob.Writer.rawValue }
        guard writers.count > 0 else { return nil }

        let items = writers.map { $0.listItemCrew }

        return ItemSection(header: "written by", items: items)
    }

}

private extension Episode {
    var ratingDisplay: String? {
        guard vote_count > Constant.voteThreshold else { return nil }

        return "\(String(format: "%.2f", vote_average))/10"
    }

    var voteDisplay: String? {
        guard vote_count > Constant.voteThreshold else { return nil }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0

        let number = NSNumber(value: vote_count)
        guard let formattedValue = formatter.string(from: number) else { return nil }

        return "\(formattedValue) votes"
    }
}
