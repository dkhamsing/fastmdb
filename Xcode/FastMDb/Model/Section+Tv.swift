//
//  Section+Tv.swift
//
//  Created by Daniel on 5/8/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

extension TV {
    
    func tvSections(_ articles: [Article]?) -> [Section] {
        var sections: [Section] = []

        if let section = nextEpisodeSection {
            sections.append(section)
        }

        if let section = overviewSection {
            sections.append(section)
        }
        
        if let section = Article.newsSection(articles) {
            sections.append(section)
        }

        if let section = ratingSection {
            sections.append(section)
        }

        if let section = relatedSection {
            sections.append(section)
        }

        if let section = linksSection {
            sections.append(section)
        }

        if let section = createdBySection {
            sections.append(section)
        }

        if let section = networksSection {
            sections.append(section)
        }

        if let section = genresSection {
            sections.append(section)
        }

        if let section = productionSection {
            sections.append(section)
        }

        if let section = castSection {
            sections.append(section)
        }

        if let section = crewSection {
            sections.append(section)
        }

        return sections
    }

}

private extension TV {

    var castSection: Section? {
        guard
            let cast = credits?.cast,
            cast.count > 0 else { return nil }

        let items = cast.map { $0.listItemCast }

        return Section(header: "cast", items: items)
    }

    var createdBySection: Section? {
        guard
            let creators = created_by,
            creators.count > 0 else { return nil }

        let items = creators.map { $0.creatorItem }

        return Section(header: "created by", items: items)
    }

    var crewSection: Section? {
        guard let crew = credits?.crew else { return nil }

        let items = crew.map { $0.listItemCrew }
        guard items.count > 0 else { return nil }

        return Section(header: "crew", items: items)
    }

    var genresSection: Section? {
        guard
            let genres = genres,
            genres.count > 0 else { return nil }

        let items = genres.map { Item(id: $0.id, title: $0.name, destination: .genreTv) }

        return Section(header: "genres", items: items)
    }

    var linksSection: Section? {
        var items: [Item] = []

        if
            let homepage = homepage,
            homepage != "" {
            let item = Item(title: homepageDisplay, url: URL(string: homepage), destination: .url, image: Item.linkImage)
            items.append(item)
        }

        if let instagram = external_ids?.validInstagramId {
            let item = Item(title: "Instagram", subtitle: instagram, url: Instagram.url(instagram), destination: .url, image: Item.linkImage)
            items.append(item)
        }

        if let twitter = external_ids?.twitter_id,
            twitter != "" {
            let item = Item(title: "Twitter", subtitle: Twitter.username(twitter), url: Twitter.url(twitter), destination: .url, image: Item.linkImage)
            items.append(item)
        }

        if name != "" {
            let item = Item(title: "Wikipedia", url: name.wikipediaUrl, destination: .url, image: Item.linkImage)
            items.append(item)
        }

        if let imdb = external_ids?.validImdbId {
            let item = Item(title: "IMDb", url: Imdb.url(id: imdb, kind: .title), destination: .url, image: Item.linkImage)
            items.append(item)
        }

        if name != "" {
            let item = Item(title: "JustWatch", url: name.justWatchUrl, destination: .url, image: Item.videoImage)
            items.append(item)
        }

        if name != "" {
            let item = Item(title: "Watch Options", url: name.googleSearchWatchUrl, destination: .url, image: Item.videoImage)
            items.append(item)
        }

        if name != "" {
            let item = Item(title: "Music", url: name.itunesMusicSearchUrl, destination: .music, image: Item.videoImage)
            items.append(item)
        }

        return Section(header: "links", items: items)
    }

    var networksSection: Section? {
        guard
            let networks = networks,
            networks.count > 0 else { return nil }

        let items = networks.map { Item(id: $0.id, title: $0.name, destination: .network) }

        return Section(header: "networks", items: items)
    }

    var nextEpisodeSection: Section? {
        guard let item = nextEpisodeItem else { return nil }

        return Section(header: "next episode", items: [item])
    }

    var nextEpisodeItem: Item? {
        guard var item = next_episode_to_air?.dateItem else { return nil }

        item.episode = next_episode_to_air
        item.destination = .episode

        if let s = item.subtitle,
            let network = networks?.first?.name {
            item.subtitle = "\(s) on \(network)"
        }

        return item
    }

    var overviewSection: Section? {

        var items: [Item] = []

        if displayName != "" {

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

            if let s = statusDisplay {
                sub.append(s)
            }

            if
                let season = seasonDisplay,
                let s = seasons?.first,
                let c = s.episode_count,
                c > 0 {
                sub.append(season)
            }

            if let episodeCount = episodeCountDisplay {
                sub.append(episodeCount)
            }

            if
                let runtimes = episode_run_time,
                runtimes.count > 0,
                let runtime = runtimes.first {
                let item = "\(runtime)min"
                sub.append(item)
            }

            var item = Item(title: displayName, subtitle: sub.joined(separator: Tmdb.separator))

            if
                let s = seasons?.first,
                let c = s.episode_count,
                c > 0 {
                item.destination = .items
                item.destinationTitle = "Seasons"
                item.items = self.remappedSeasonItems
            }

            items.append(item)

        }

        if
            let o = overview,
            o != "" {
            items.append(Item(title: o))
        }

        if
            let videos = videos?.results,
            videos.count > 0 {
//            let item = Item(title: "Video Clips", destination: .items, destinationTitle: "Videos", items: videos.map { $0.listItem } )
            let item = Item(title: "Video Clips", destination: .videos, items: videos.map { $0.listItem })
            items.append(item)
        }

        return Section(header: "tv", items: items)
    }

    var productionSection: Section? {
        guard
            let companies = production_companies,
            companies.count > 0 else { return nil }

        let names = companies.map { $0.name }
        let item = Item(title: names.joined(separator: ", "), destination: .items, destinationTitle: "Production", items: companies.map { $0.listItem })

        return Section(header: "production", items: [item])
    }

    var ratingSection: Section? {
        guard let rating = ratingDisplay else { return nil }

        let item = Item(title: rating, subtitle: voteDisplay, color: vote_average.color)
        let section = Section(header: "rating", items: [item])
        
        return section
    }

    var relatedSection: Section? {
        var relatedItems: [Item] = []

        if
            let recs = recommendations?.results,
            recs.count > 0 {

            let titles = recs.map { $0.name }
            let items = recs.map { $0.listItem }
            let top3 = Array(titles.prefix(3))
            let item = Item(title: top3.joined(separator: ", "), subtitle: "Recommendations", destination: .items, destinationTitle: "Recommendations", items: items)
            relatedItems.append(item)
        }

        if
            let recs = similar?.results,
            recs.count > 0 {

        let titles = recs.map { $0.name }
        let items = recs.map { $0.listItem }
        let top3 = Array(titles.prefix(3))
        let item = Item(title: top3.joined(separator: ", "), subtitle: "Similar", destination: .items, destinationTitle: "Similar", items: items)
            relatedItems.append(item)
        }

        guard relatedItems.count > 0 else { return nil }

        return Section(header: "related", items: relatedItems)
    }

}

private extension Credit {
    var creatorItem: Item {
        return Item(id: id, title: name, destination: .person)
    }
}

private extension Season {
    func listItem(tvId: Int?) -> Item {
        var sub: [String] = []

        if let _ = air_date {
            sub.append(air_date.yearDisplay)
        }

        if let c = episode_count,
            c > 0 {
            let string = "\(c) episode\(c.pluralized)"
            sub.append(string)
        }

        return Item(id: tvId, title: name, subtitle: sub.joined(separator: Tmdb.separator), destination: .season, seasonNumber: season_number)
    }
}

private extension TV {

    var aired: String? {
        guard let _ = first_air_date  else { return nil }

        if first_air_date.yearDisplay == endYearDisplay {
            return endYearDisplay
        }

        return ("\(first_air_date.yearDisplay) - \(endYearDisplay)")
    }

    var endYearDisplay: String {
        if isCurrent {
            return "present"
        }

        return last_air_date.yearDisplay
    }

    var episodeCountDisplay: String? {
        guard
            let count = number_of_episodes,
            count > 0 else { return nil }

        return "\(count) episode\(count == 1 ? "" : "s")"
    }

    var homepageDisplay: String? {
        guard
            let homepage = homepage,
            let url = URL(string: homepage) else { return nil }
        let host = url.host
        let display = host?.replacingOccurrences(of: "www.", with: "")

        return display
    }

    var isCurrent: Bool {
        switch status {
        case "Returning Series",
             "In Production":
            return true
        default:
            return false
        }
    }

    var ratingDisplay: String? {
        guard vote_count > Tmdb.voteThreshold else { return nil }

        return "\(vote_average)/10"
    }

    var voteDisplay: String? {
        guard vote_count > Tmdb.voteThreshold else { return nil }

        return "\(vote_count) votes"
    }

    var remappedSeasonItems: [Item] {
        var items: [Item] = []
        if let seasons = seasons {
            items = seasons.filter {
                let count = $0.episode_count
                return count ?? 0 > 0
            }.map { $0.listItem(tvId: id) }
        }

        return items
    }

    var seasonDisplay: String? {
        guard
            let count = number_of_seasons,
            count > 0 else { return nil }

        return "\(count) season\(count == 1 ? "" : "s")"
    }

    var statusDisplay: String? {
        if let s = status?.validStatus {
            return s
        }

        if let aired = aired {
            return aired
        }

        return "Air date n/a"
    }

}
