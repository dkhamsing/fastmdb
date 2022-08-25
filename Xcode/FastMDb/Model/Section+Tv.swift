//
//  Section+Tv.swift
//
//  Created by Daniel on 5/8/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation
import UIKit

extension TV {
    
    func sections(articles: [Article]?, albums: [iTunes.Album]?) -> [ItemSection] {
        var list: [ItemSection] = []

        if let section = imagesSection {
            list.append(section)
        }
        
        if let section = nextEpisodeSection {
            list.append(section)
        }

        if let section = overviewSection {
            list.append(section)
        }

        if let section = seasonSection {
            list.append(section)
        }

        if let section = seasonSpecialSection {
            list.append(section)
        }

        if let section = Article.newsSection(articles) {
            list.append(section)
        }

        if let section = watchSection {
            list.append(section)
        }

        if let section = networksSection {
            list.append(section)
        }

        if let section = castSection {
            list.append(section)
        }

        if let section = ratingSection {
            list.append(section)
        }

        if let section = linksSection {
            list.append(section)
        }

        if let section = mediaSection(albums: albums) {
            list.append(section)
        }

        if let section = createdBySection {
            list.append(section)
        }

        if let section = storySection {
            list.append(section)
        }

        if let section = productionSection {
            list.append(section)
        }

        if let section = genresSection {
            list.append(section)
        }

        if let section = recommendedSection {
            list.append(section)
        }

        if let section = similarSection {
            list.append(section)
        }

        if let section = crewSection {
            list.append(section)
        }

        return list
    }

}

private extension TV {

    var castSection: ItemSection? {
        guard
            let cast = aggregate_credits?.cast,
            cast.count > 0 else { return nil }

        let items = cast.map { $0.listItemCastAggregated }

        return ItemSection(header: "cast", items: items, metadata: Metadata(display: .portraitImage()))
    }

    var createdBySection: ItemSection? {
        guard
            let creators = created_by,
            creators.count > 0 else { return nil }

        let items = creators.map { $0.creatorItem }

        return ItemSection(header: "created by", items: items)
    }

    // TODO: filter out created by, story
    var crewSection: ItemSection? {
        guard let crew = credits?.crew else { return nil }

        let items = crew.map { $0.listItemCrew }
        guard items.count > 0 else { return nil }

        return ItemSection(header: "crew", items: items)
    }

    var genresSection: ItemSection? {
        guard
            let genres = genres,
            genres.count > 0 else { return nil }

        let items = genres.map { Item(title: $0.name, metadata: Metadata(id: $0.id, destination: .genreTv)) }

        return ItemSection(header: "genres", items: items, metadata: Metadata(display: .tags()))
    }

    var imagesSection: ItemSection? {
        return ItemSection.imagesSection(poster_path: poster_path, images: images)
    }

    var linksSection: ItemSection? {
        var items: [Item] = []

        if
            let homepage = homepage,
            homepage != "" {
            let url = URL(string: homepage)
            let imageUrl = url?.urlToSourceLogo
            let item = Item(title: homepageDisplay,
                            metadata: Metadata(url: url, destination: .url, imageUrl: imageUrl, link: .link))
            items.append(item)
        }

        if let instagram = external_ids?.validInstagramId {
            let url = Instagram.url(instagram)
            let imageUrl = url?.urlToSourceLogo
            let item = Item(title: "Instagram", subtitle: instagram,
                            metadata: Metadata(url: url, destination: .url, imageUrl: imageUrl, link: .link))
            items.append(item)
        }

        if let twitter = external_ids?.twitter_id,
            twitter != "" {
            let url = Twitter.url(twitter)
            let imageUrl = url?.urlToSourceLogo
            let item = Item(title: "Twitter", subtitle: "",
                            metadata: Metadata(url: url, destination: .url, imageUrl: imageUrl, link: .link))
            items.append(item)
        }

        if name != "" {
            let url = name.wikipediaUrl
            let imageUrl = url?.urlToSourceLogo
            let item = Item(title: "Wikipedia",
                            metadata: Metadata(url: url, destination: .url, imageUrl: imageUrl, link: .link))
            items.append(item)
        }

        if let url = tmdbUrl {
            let imageUrl = url.urlToSourceLogo
            let item = Item(metadata: Metadata(url: url, destination: .url, imageUrl: imageUrl, link: .link))
            items.append(item)
        }

        if let imdb = external_ids?.validImdbId {
            let url = Imdb.url(id: imdb, kind: .title)
            let imageUrl = url?.urlToSourceLogo
            let item = Item(title: "IMDb",
                            metadata: Metadata(url: url, destination: .url, imageUrl: imageUrl, link: .link))
            items.append(item)
        }

        return ItemSection(header: "links", items: items, metadata: Metadata(display: .squareImage()))
    }

    func mediaSection(albums: [iTunes.Album]?) -> ItemSection? {
        var items: [Item] = []

        if
            let videos = videos?.results,
            videos.count > 0 {
            let item = Item(title: "Video Clips",
                            metadata: Metadata(destination: .videos, items: videos.map { $0.listItem }, link: .video))
            items.append(item)
        }

        if let albums = albums {
            let item = Item(title: "Apple Music",
                            metadata: Metadata(destination: .music, albums: albums, link: .video))
            items.append(item)
        } else if let id = external_ids?.validImdbId,
                  isValidWatchStatus {            
            let url = Imdb.soundtrackUrl(id: id, kind: .title)
            let item = Item(title: "IMDb Soundtrack",
                            metadata: Metadata(url: url, destination: .url, link: .link))
            items.append(item)
        }

        guard items.count > 0 else { return nil }

        return ItemSection(header: "media", items: items)
    }

    var networksSection: ItemSection? {
        guard
            let networks = networks,
            networks.count > 0 else { return nil }

        let items = networks.map { Item(title: $0.name, metadata: Metadata(id: $0.id, destination: .network)) }

        return ItemSection(header: "networks", items: items)
    }

    var nextEpisodeSection: ItemSection? {
        guard let item = nextEpisodeItem else { return nil }

        return ItemSection(header: "next episode", items: [item])
    }

    var nextEpisodeItem: Item? {
        guard var item = next_episode_to_air?.dateItem else { return nil }

        if let s = item.subtitle,
            let network = networks?.first?.name {
            item.subtitle = "\(s) on \(network)"
        }

        item.metadata = Metadata(id: id, destination: .episode, episode: next_episode_to_air)

        return item
    }

    var overviewSection: ItemSection? {

        var items: [Item] = []

        if displayName != "" {

            var sub: [String] = []

            if
                let country = original_language,
                country != Tmdb.language,
                let lang = Languages.List[country] {
                sub.append(lang)
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

            var subt = sub.joined(separator: Constant.separator)

            if let country = countryDisplay {
                subt += "\n\(country)"
            } else if let countries = production_countries,
                countries.count > 0 {
                subt += "\n" + countries.map { $0.name }.joined(separator: ", ")
            }

            // content rating
            if let contentRating = content_ratings?.contentRating("US") {
                subt += "\nRated " + contentRating
            }

            let item = Item(title: displayName, subtitle: subt)

            items.append(item)

        }

        if let item = taglineOverviewItem {
            items.append(item)
        }

        // awards
        if let id = external_ids?.validImdbId,
           isValidWatchStatus {
            let url = Imdb.awardsUrl(id: id, kind: .title)
            let item = Item(title: "Awards & Nominations",
                            metadata: Metadata(url: url, destination: .url))
            items.append(item)
        }

        return ItemSection(header: "tv", items: items)
    }

    var productionSection: ItemSection? {
        guard
            let companies = production_companies,
            companies.count > 0 else { return nil }

        let items = companies.map { $0.listItem }

        return ItemSection(header: "production", items: items, metadata: Metadata(display: .tags()))
    }

    var ratingSection: ItemSection? {
        guard vote_count > 0 else {
            let item = Item(subtitle: "Unrated")
            return ItemSection(header: "rating", items: [item])
        }

        let helper = Constant.Vote(count: vote_count, average: vote_average)
        let rating = helper.ratingDisplayAttributed
        let vote = helper.voteDisplay

        var color: UIColor?
        if vote_count > Constant.voteThreshold {
            color = vote_average.color
        }

        let item = Item(attributedTitle: rating, subtitle: vote, color: color)
        return ItemSection(header: "rating", items: [item])
    }

    var recommendedSection: ItemSection? {
        guard let recs = recommendations?.results,
              recs.count > 0 else { return nil }

        let items = recs.map { $0.listItemImage }

        return ItemSection(header: "recommended", items: items, metadata: Metadata(display: .portraitImage()))
    }

    var seasonSection: ItemSection? {
        let items: [Item] = remappedSeasonItems

        guard items.count > 0 else { return nil }

        let header = "\(items.count) season\(items.count.pluralized)"
        return ItemSection(header: header, items: items, metadata: Metadata(display: .portraitImage()))
    }

    var seasonSpecialSection: ItemSection? {
        var items: [Item] = []
        if let seasons = seasons {
            items = seasons
                .filter { $0.season_number == 0 }
                .map { $0.listItem(tvId: id) }
        }

        guard items.count > 0 else { return nil }

        return ItemSection(items: items)
    }

    var similarSection: ItemSection? {
        guard let recs = similar?.results,
              recs.count > 0 else { return nil }

        let items = recs.map { $0.listItemImage }

        return ItemSection(header: "similar", items: items, metadata: Metadata(display: .portraitImage()))
    }

    var storySection: ItemSection? {
        guard let credits = credits else { return nil }

        return credits.jobSection([CrewJob.Novel.rawValue,
                           CrewJob.Story.rawValue,
                           CrewJob.ShortStory.rawValue], "story")
    }

    var taglineOverviewItem: Item? {
        if let value = overview,
           !value.isEmpty {
            var item = Item(subtitle: value)

            if let tagline = tagline,
               tagline.isEmpty == false {
                item.title = tagline
            }

            return item
        }

        return nil
    }

    var tmdbUrl: URL? {
        return Tmdb.Url.Web.tv.detailURL(id)
    }

    var watchSection: ItemSection? {
        guard isValidWatchStatus else { return nil }
        return watch?.watchSection(name)
    }

}

private extension Credit {
    var creatorItem: Item {
        return Item(title: name, metadata: Metadata(id: id, destination: .person))
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

    var isValidWatchStatus: Bool {
        switch status ?? "" {
        case "In Production",
             "Planned":
            return false
        default:
            return true
        }
    }

    var remappedSeasonItems: [Item] {
        var items: [Item] = []
        if let seasons = seasons {
            items = seasons
                .filter { $0.season_number != 0 }
                .filter {
                    let count = $0.episode_count
                    return count ?? 0 > 0
                }
                .map { $0.listItem(tvId: id) }
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
