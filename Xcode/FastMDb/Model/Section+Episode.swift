
//
//  Section+Episode.swift
//
//  Created by Daniel on 5/12/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

extension Episode {
    var episodeSections: [Section] {
        var sections: [Section] = []

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

    var crewSection: Section? {
        guard let crew = crew else { return nil }

        var filtered = crew

        for job in CrewJob.allCases {
            filtered = filtered.filter { $0.job != job.rawValue }
        }

        let items = filtered.map { $0.listItemCrew }

        guard items.count > 0 else { return nil }

        return Section(header: "crew", items: items)
    }

    var directorSection: Section? {
        guard let crew = crew else { return nil }

        let directors = crew.filter { $0.job == CrewJob.Director.rawValue }
        guard directors.count > 0 else { return nil }

        let items = directors.map { $0.listItemCrew }

        return Section(header: "directed by", items: items)
    }

    var guestStarsSection: Section? {
        guard let guests = guest_stars else { return nil }

        let items = guests.map { $0.listItemCast }

        guard items.count > 0 else { return nil }

        let section = Section(header: "Guest Stars", items: items)

        return section
    }

    var mainSection: Section {
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

        if let item = nextEpisodeItem {
            items.append(item)
        }

        if let o = overview,
            o != "" {
            let item = Item(title: o)
            items.append(item)
        }

        return Section(items: items)
    }

    var ratingSection: Section? {
        guard let rating = ratingDisplay else { return nil }

        let item = Item(title: rating, subtitle: voteDisplay, color: vote_average.color)
        let section = Section(header: "rating", items: [item])
        return section
    }

    var writingSection: Section? {
        guard let crew = crew else { return nil }

        let writers = crew.filter { $0.job == CrewJob.Teleplay.rawValue || $0.job == CrewJob.Writer.rawValue }
        guard writers.count > 0 else { return nil }

        let items = writers.map { $0.listItemCrew }

        return Section(header: "written by", items: items)
    }

}

private extension Episode {
    var ratingDisplay: String? {
        guard vote_count > Tmdb.voteThreshold else { return nil }

        return "\(vote_average)/10"
    }

    var voteDisplay: String? {
        guard vote_count > Tmdb.voteThreshold else { return nil }

        return "\(vote_count) votes"
    }
}
