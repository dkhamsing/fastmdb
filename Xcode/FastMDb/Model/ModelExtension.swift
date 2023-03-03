//
//  ModelExtension.swift
//  FastMDb
//
//  Created by Daniel on 9/26/21.
//  Copyright © 2021 dk. All rights reserved.
//

import UIKit

// TV
extension ContentRatingSearch {
    func contentRating(_ countryCode: String) -> String? {
        let countries = results.filter { $0.iso_3166_1 == countryCode }
        guard let first = countries.first else { return nil }

        return first.rating
    }
}

extension Credit {

    enum Known: String {
        case Directing,
             Writing,
             Acting
    }

    var aggregatedRole: String? {
        guard let roles = roles else { return nil }

        let role = roles.first { (role) -> Bool in
            !(role.character ?? "").isEmpty
        }

        return role?.character
    }

    var aggregated: [String] {

        if roles?.count == 1,
           let first = roles?.first {
            var strings: [String] = []

            let name = first.character ?? ""
            if !name.isEmpty {
                strings.append(name)
            }

            if let count = first.episode_count,
               count > 0 {
                strings.append("\(count) episode\(count.pluralized)")
            }

            return strings
        } else if let roles = roles,
                  roles.count > 1 {
            let count = roles
                .map { $0.episode_count ?? 0 }
                .reduce(0, +)

            var role = "\(roles.count) roles"
            if let agRole = aggregatedRole {
                let oneLess = roles.count - 1
                role = "\(agRole) and \(oneLess) other role\(oneLess.pluralized)"
            }

            return [
                role,
                "\(count) episode\(count.pluralized)"
            ]
        }

        return []
    }

    var initials: String? {
        guard let name = name?.split(separator: " "),
              let first = name.first else { return nil }

        var text = String(first.prefix(1))

        if name.indices.contains(1) {
            let last = name[1]
            text = text + String(last.prefix(1))
        }

        return text
    }

    var taggedImageSection: ItemSection? {
        guard let results = tagged_images?.results,
              results.count > 0 else { return nil }

        let items: [Item] = results
            .filter { $0.media.backdrop_path ?? "" != "" }
            .map { item in
                let url = Tmdb.Url.Image.backdrop(path: item.media.backdrop_path, size: .original)
                let imageUrl = Tmdb.Url.Image.backdrop(path: item.media.backdrop_path, size: .medium)
            return Item(
                title: item.media.titleDisplay,
                metadata: Metadata(
                    id: item.media.id,
                    url: url,
                    destination: .safarivc,
                    imageUrl:imageUrl))
        }

        guard items.count > 0 else { return nil }

        var unique: [Item] = []
        for item in items {
            if !unique.contains(item) {
                unique.append(item)
            }
        }

        return ItemSection(items: unique, metadata: Metadata(display: .thumbnailImage()))
    }

    var listItemCast: Item {
        let url = Tmdb.Url.Image.castProfile(path: profile_path, size: .medium)
        return Item(title: titleDisplay, subtitle: character,
                    metadata: Metadata(id: id, destination: .person, imageUrl: url, imageCenterText: initials))
    }

    var listItemCastAggregated: Item {
        var sub: [String] = []
        if let value = titleDisplay {
            sub.append(value)
        }
        sub.append(contentsOf: aggregated)

        let url = Tmdb.Url.Image.castProfile(path: profile_path, size: .medium)
        return Item(title: name, metadata: Metadata(id: id, destination: .person, imageUrl: url, imageCenterText: initials, strings: sub))
    }

    var listItemCrew: Item {
        return Item(title: name, subtitle: job, metadata: Metadata(id: id, destination: .person))
    }

    var listItemPopular: Item {
        var sub: [String] = []
        if let value = name {
            sub.append(value)
        }
        if let known = known_for?.first?.titleDisplay {
            sub.append(known)
        }
        let url = Tmdb.Url.Image.castProfile(path: profile_path, size: .medium)
        return Item(title: name,
                    metadata: Metadata(id: id, destination: .person, imageUrl: url, imageCenterText: initials, strings: sub))
    }

    var listItemTv: Item? {
        return listItemTv()
    }

    func listItemTv(isImage: Bool = false) -> Item? {
        var sub: [String] = []

        if first_air_date.yearDisplay != "" {
            sub.append(first_air_date.yearDisplay)
        }

        if
            let country = original_language,
            country != Tmdb.language,
            let lang = Languages.List[country] {
            sub.append(lang)
        }

        if let c = character, c != "" {
            sub.append(c)
        }

        if let episodes = episode_count,
           episodes > 0 {
            let epString = "\(episodes) episode\(episodes > 1 ? "s" : "")"
            sub.append(epString)
        }

        var sub2 = sub
        if let value = titleDisplay {
            sub2.insert(value, at: 0)
        }

        var imageUrl: URL?
        if isImage {
            if let url = Tmdb.Url.Image.mediaPoster(path: poster_path, size: .medium) {
                imageUrl = url
            } else {
                return nil
            }
        }

        return Item(title: titleDisplay, subtitle: sub.joined(separator: Constant.separator), color: ratingColor,
                    metadata: Metadata(id: id, identifier: credit_id, destination: .tvCredit, imageUrl: imageUrl, strings: sub2)
        )
    }

    var ratingColor: UIColor? {
        guard
            let c = vote_count,
            c > Constant.voteThreshold else { return nil }

        return vote_average?.color
    }

    var releaseYear: String? {
        guard release_date.yearDisplay != "" else { return nil }

        return release_date.yearDisplay
    }

    var titleDisplay: String? {
        var t = "\(title ?? name ?? "")"
        if title != original_title {
            t.append(" (")
            t.append(original_title ?? "")
            t.append(")")
        }

        return t
    }

}

extension CreditResult {

    func sections(id: Int?) -> [ItemSection] {
        var sections: [ItemSection] = []

        if let section = media.imagesSection {
            sections.append(section)
        }

        var items: [Item] = []

        if let name = person?.name {
            items.append(
                Item(title: name, subtitle: media.character)
            )
        }

        items.append(
            Item(title: media.original_name, metadata: Metadata(id: id, destination: .tv))
        )

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

extension Credits {

    func jobSection(_ jobs: [String], _ header: String) -> ItemSection? {
        let job = crew.filter { item in
            var condition: Bool = false
            for job in jobs {
                condition = condition || item.job == job
            }
            return condition
        }
        guard job.count > 0 else { return nil }

        let items = job.map { $0.listItemCrew }
        return ItemSection(header: header, items: items)
    }

}

extension Episode {
    var dateItem: Item? {
        guard
            let airdate = air_date,
            let display = airdate.dateDisplay else { return nil }

        var inNumberOfDays: String?
        let formatter = Constant.dateFormatter
        if let date = formatter.date(from: airdate),
            let days = Date().daysDifferenceWithDate(date),
            days >= 0 {
            if days == 0 {
                inNumberOfDays = "Today"
            } else if days == 1 {
                inNumberOfDays = "Tomorrow"
            } else {
                inNumberOfDays = "In \(days) days"
            }
        }

        return Item(title: display, subtitle: inNumberOfDays)
    }

    var episodeRatingColor: UIColor? {
        guard vote_count > Constant.voteThreshold else { return nil }

        return vote_average.color
    }

}

extension ExternalIds {
    var validInstagramId: String? {
        guard
            let id = instagram_id,
            id != "" else { return nil }

        return id
    }

    var validImdbId: String? {
        guard
            let id = imdb_id,
            id != "" else { return nil }

        return id
    }

    var validTwitterId: String? {
        guard
            let id = twitter_id,
            id != "" else { return nil }

        return id
    }
}

extension Images {
    var backdropItems: [Item] {
        guard let backdrops = backdrops else { return [] }

        let filtered = backdrops.filter { ($0.iso_639_1 ?? "" == "") || ($0.iso_639_1 ?? "" == Tmdb.language) }
        guard filtered.count > 0 else { return [] }

        let items: [Item] = filtered.map {
            let url = Tmdb.Url.Image.backdrop(path: $0.file_path, size: .original)
            let imageUrl = Tmdb.Url.Image.backdrop(path: $0.file_path, size: .medium)
            return Item.imageItem(url: url, imageUrl: imageUrl)
        }

        return items
    }

    var backdropsSection: ItemSection? {
        let items = backdropItems

        guard items.count > 0 else { return nil }

        return ItemSection(items: items, metadata: Metadata(display: .thumbnailImage()))
    }

    var postersSection: ItemSection? {
        guard let posters = posters else { return nil }

        let filtered = posters.filter { ($0.iso_639_1 ?? "" == "") || ($0.iso_639_1 ?? "" == Tmdb.language) }
        guard filtered.count > 0 else { return nil }

        let items: [Item] = filtered.map {
            let url = Tmdb.Url.Image.castProfile(path: $0.file_path, size: .large)
            let imageUrl = Tmdb.Url.Image.castProfile(path: $0.file_path, size: .medium)
            var item = Item.imageItem(url: url, imageUrl: imageUrl)
            item.metadata?.display = .portraitImage()
            return item
        }

        return ItemSection(items: items, metadata: Metadata(display: .images()))
    }

    var profilesSection: ItemSection? {
        guard let profiles = profiles,
              profiles.count > 0 else { return nil }

        let items: [Item] = profiles.map {
            let url = Tmdb.Url.Image.castProfile(path: $0.file_path, size: .large)
            let imageUrl = Tmdb.Url.Image.castProfile(path: $0.file_path, size: .medium)
            var item = Item.imageItem(url: url, imageUrl: imageUrl)
            item.metadata?.display = .portraitImage()
            return item
        }

        return ItemSection(items: items, metadata: Metadata(display: .images()))
    }

    var stillsSection: ItemSection? {
        guard let stills = stills,
              !stills.isEmpty else { return nil }

        let items: [Item] = stills.map {
            let url = Tmdb.Url.Image.still(path: $0.file_path, size: .original)
            let imageUrl = Tmdb.Url.Image.still(path: $0.file_path, size: .original)
            return Item.imageItem(url: url, imageUrl: imageUrl)
        }

        return ItemSection(items: items, metadata: Metadata(display: .thumbnailImage()))
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
            country != Tmdb.language,
            let lang = Languages.List[country] {
            sub.append(lang)
        }
        return sub
    }

    var listItem: Item {
        let sub = listItemSub.joined(separator: Constant.separator)

        return Item(title: titleDisplay, subtitle: sub, color: ratingColor,
                    metadata: Metadata(id: id, destination: .movie))
    }

    var listItemTextImage: Item {
        let sub = listItemSub.joined(separator: Constant.separator)
        let imageUrl = Tmdb.Url.Image.still(path: backdrop_path, size: .medium)
        return Item(title: titleDisplay, subtitle: sub, color: ratingColor,
                    metadata: Metadata(id: id, destination: .movie, imageUrl: imageUrl))
    }

    var listItemUpcoming: Item {
        let sub = upcomingDateDisplay
        let imageUrl = Tmdb.Url.Image.still(path: backdrop_path, size: .medium)
        return Item(title: titleDisplay, subtitle: sub, color: ratingColor,
                    metadata: Metadata(id: id, destination: .movie, imageUrl: imageUrl))
    }

    var listItemWithVotes: Item {
        var sub = listItemSub

        if let str = Constant.Vote(count: vote_count ?? 0).voteDisplay {
            sub.append(str)
        }

        sub.append("\(vote_average ?? 0)")
        let imageUrl = Tmdb.Url.Image.still(path: backdrop_path, size: .medium)
        return Item(title: titleDisplay, subtitle: sub.joined(separator: Constant.separator), color: ratingColor,
                    metadata: Metadata(id: id, destination: .movie, imageUrl: imageUrl))
    }

    var listItemImage: Item {
        let sub = listItemSub.joined(separator: Constant.separator)
        let imageUrl = Tmdb.Url.Image.mediaPoster(path: poster_path, size: .medium)

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

        if let revenue = revenue, revenue > 0 {
            sub.append(revenue.display + " revenue")
        }

        let imageUrl = Tmdb.Url.Image.still(path: backdrop_path, size: .medium)
        return Item(title: titleDisplay,
                    subtitle: sub.joined(separator: "\n"),
                    color: ratingColor,
                    metadata: Metadata(id: id, destination: .movie, imageUrl: imageUrl))
    }

    var released: Bool {
        guard
            let rel = release_date,
            let date = Constant.dateFormatter.date(from: rel),
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
            let date = Constant.dateFormatter.date(from: r) else { return releaseYear  }

        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .day, for: date) else { return releaseYear }

        let components = calendar.dateComponents([.day], from: Date(), to: interval.end)

        guard let day = components.day, day > 0 else { return releaseYear }

        var strings: [String] = []

        if let year = releaseYear {
            strings.append(year)
        }

        strings.append("To be released in \(day) day\(day.pluralized)")
        return strings.joined(separator: Constant.separator)
    }
}

private extension Media {
    var ratingColor: UIColor? {
        guard
            released,
            vote_count ?? 0 > Constant.voteThreshold else { return nil }

        return vote_average?.color ?? .gray
    }
}

private extension MultiSearchResult {

    var credit: Credit {
        return Credit(id: id, name: name, title: title, poster_path: poster_path, profile_path: profile_path, first_air_date: first_air_date, known_for: known_for, vote_average: vote_average, release_date: release_date)
    }

    var media: Media {
        return Media(id: id ?? 0, title: title, original_title: original_title, vote_average: vote_average ?? 0, vote_count: 0, backdrop_path: backdrop_path ?? "", overview: overview ?? "", poster_path: poster_path, release_date: release_date)
    }

    var tv: TV {
        return TV(id: id ?? 0,
                  name: name ?? "",
                  original_name: original_name ?? "",
                  first_air_date: first_air_date,
                  vote_average: vote_average ?? 0,
                  vote_count: 0,
                  backdrop_path: backdrop_path)
    }

}

extension MultiSearch {

    var movie: MediaSearch {
        return MediaSearch(total_results: movieResults.count, results: movieResults)
    }

    var people: PeopleSearch {
        return PeopleSearch(total_results: peopleResults.count, results: peopleResults)
    }

    var tv: TvSearch {
        return TvSearch(total_results: tvResults.count, results: tvResults)
    }

}

private extension MultiSearch {

    enum MediaType: String {
        case person, movie, tv
    }

    var movieResults: [Media] {
        return results
            .filter { $0.media_type == MediaType.movie.rawValue }
            .map { $0.media }
    }

    var peopleResults: [Credit] {
        return results
            .filter { $0.media_type == MediaType.person.rawValue }
            .map { $0.credit }
    }

    var tvResults: [TV] {
        return results
            .filter { $0.media_type == MediaType.tv.rawValue }
            .map { $0.tv }
    }

}

extension Production {
    var listItem: Item {
        return Item(title: name, metadata: Metadata(id: id, destination: .production))
    }
}

extension Provider {
    var iconImageUrl: URL? {
        return Tmdb.Url.Image.logo(path: logo_path, size: .small)
    }
}

// Movie
extension ReleaseSearch {
    func contentRating(_ countryCode: String) -> String? {
        let countries = results.filter { $0.iso_3166_1 == countryCode }
        guard let ratings = countries.first?.release_dates.map({ $0.certification }) else { return nil }

        return ratings.first(where: {!$0.isEmpty} )
    }
}

extension Review {
    var listItem: Item {
        var sub: [String] = []

        if let rating = author_details.rating {
            sub.append("\(rating)/10")
        }

        sub.append(author)

        return Item(title: content, subtitle: sub.joined(separator: Constant.separator))
    }
}

extension Season {
    func listItem(tvId: Int?) -> Item {
        let imageUrl = Tmdb.Url.Image.mediaPoster(path: poster_path, size: .medium)

        let text = season_number > 0 ? "\(season_number)" : ""
        return Item(title: name, metadata: Metadata(id: tvId, destination: .season, seasonNumber: season_number, imageUrl: imageUrl, imageCenterText: text, strings: strings))
    }

    var strings: [String] {
        guard season_number > 0 else { return [name] }

        var sub: [String] = [name]

        if let _ = air_date {
            sub.append(air_date.yearDisplay)
        }

        if let c = episode_count,
            c > 0 {
            let string = "\(c) episode\(c.pluralized)"
            sub.append(string)
        }

        return sub
    }

    static func seasonName(_ season: Int) -> String {
        return season == 0 ?
            "Specials":
            "Season \(season)"
    }
}

extension TaggedMedia {
    var destination: Destination? {
        switch media_type {
        case "movie":
            return .movie
        case "tv":
            return .tv
        default:
            print("not implemented yet for \(media_type)")
            return nil
        }
    }
}

extension Tmdb.Url.Kind.Movies {
    var systemImage: UIImage? {
        var string: String = ""
        switch self {
        case .popular:
            string = "star"
        case .now_playing:
            string = "play"
        case .highest_grossing:
            string = "dollarsign.circle"
        case .top_rated:
            string = "hand.thumbsup"
        case .top_rated_movies, .top_rated_tv:
            string = "heart"
        case .upcoming:
            string = "calendar"
        }

        return UIImage(systemName: string)
    }
}

extension TV {
    var countryDisplay: String? {
        guard
            let country = origin_country?.first,
            country != "",
            country != "US" else { return nil }

        if let name = Locale.current.localizedString(forRegionCode: country) {
            return name
        }

        return country
    }

    var displayName: String {
        if name != original_name {
            return "\(name) (\(original_name))"
        }
        return name
    }

    var listItem: Item {
        var item = listItemNoSub

        var sub: [String] = []
        if first_air_date.yearDisplay != "" {
            sub.append(first_air_date.yearDisplay)
        }
        sub.append(contentsOf: subtitleLanguageCountry)

        item.subtitle = sub.joined(separator: Constant.separator)

        return item
    }

    var listItemTextImage: Item {
        var item = listItemNoSub

        var sub: [String] = []
        if first_air_date.yearDisplay != "" {
            sub.append(first_air_date.yearDisplay)
        }
        sub.append(contentsOf: subtitleLanguageCountry)

        item.subtitle = sub.joined(separator: Constant.separator)

        let imageUrl = Tmdb.Url.Image.still(path: backdrop_path, size: .medium)

        var met = item.metadata
        met?.imageUrl = imageUrl
        item.metadata = met

        return item
    }

    var listItemImage: Item {
        var item = listItemNoSub

        var sub: [String] = []
        if first_air_date.yearDisplay != "" {
            sub.append(first_air_date.yearDisplay)
        }
        sub.append(contentsOf: subtitleLanguageCountry)
        item.subtitle = sub.joined(separator: Constant.separator)

        item.metadata = Metadata(id: id, destination: .tv, imageUrl: Tmdb.Url.Image.mediaPoster(path: poster_path, size: .medium))

        return item
    }

    var listItemWithVotes: Item {
        var item = listItemNoSub

        var sub: [String] = []
        if first_air_date.yearDisplay != "" {
            sub.append(first_air_date.yearDisplay)
        }
        sub.append(contentsOf: subtitleLanguageCountry)

        if let str = Constant.Vote(count: vote_count).voteDisplay {
            sub.append(str)
        }
        
        sub.append("\(vote_average)")

        item.subtitle = sub.joined(separator: Constant.separator)

        return item
    }

    var listItemWithoutYear: Item {
        var item = listItemNoSub
        item.subtitle = subtitleLanguageCountry.joined(separator: Constant.separator)

        return item
    }

}

private extension TV {

    var subtitleLanguageCountry: [String] {
        var sub: [String] = []
        if
            let country = original_language,
            country != Tmdb.language,
            let lang = Languages.List[country] {
            sub.append(lang)
        }
        else if let country = countryDisplay {
            sub.append(country)
        }

        return sub
    }

    var listItemNoSub: Item {
        return Item(title: displayName, color: ratingColor,
                    metadata: Metadata(id: id, destination: .tv))
    }

    var ratingColor: UIColor? {
        guard vote_count > Constant.voteThreshold else { return nil }

        return vote_average.color
    }

}

extension Video {
    var listItem: Item {
        let sub = [site, type]
        return Item(title: name, subtitle: sub.joined(separator: Constant.separator),
                    metadata: Metadata(url: url, destination: .url, link: .video))
    }

    var url: URL? {
        switch site.lowercased() {
        case "youtube":
            let baseUrl = YouTube.urlBase
            let url = URL(string: "\(baseUrl)/\(key)")

            return url
        case "vimeo":
            let baseUrl = "https://vimeo.com/"
            let url = URL(string: "\(baseUrl)/\(key)")

            return url
        default:
            return nil
        }
    }
}

extension WatchSearch {

    static let providersNotInterested = [
        "directv",
        "fubotv",
        "netflix basic with ads",
        "sling tv",
        "spectrum on demand"
    ]

    func watchSectionProvider(_ name: String?) -> ItemSection? {
        guard let country = results["US"],
              let providers = country.flatrate else { return watchSectionGoogleJustWatch(name) }

        let myProviders = providers
            .filter { !WatchSearch.providersNotInterested.contains($0.provider_name.lowercased()) }
            .filter { !$0.provider_name.lowercased().contains("amazon channel") }
            .filter { !$0.provider_name.lowercased().contains("apple tv channel") }
            .filter { !$0.provider_name.lowercased().contains("roku premium") }
            .sorted { $0.provider_name < $1.provider_name }

//        print(myProviders, "**")

        let items: [Item] = myProviders.map {
            Item(title: $0.provider_name, metadata: Metadata(url: country.link, destination: .url, imageUrl: $0.iconImageUrl, imageCornerRadius: 12))
        }

        guard items.count > 0 else { return watchSectionGoogleJustWatch(name) }

        return ItemSection(header: "Watch", items: items, metadata: Metadata(display: .squareImage()))
    }

    func watchSectionGoogleJustWatch(_ name: String?) -> ItemSection? {
        guard let name = name,
              name != "" else { return nil }

        let google = Item(title: "Google Search",
                          metadata: Metadata(url: name.googleSearchWatchUrl, destination: .url, link: .link))
        let justWatch = Item(title: "JustWatch",
                             metadata: Metadata(url: URL(string: "https://justwatch.com"), destination: .url, link: .link))
        let items = [google, justWatch]

        return ItemSection(header: "Watch ⚠️", items: items)//⚠
    }

    func watchSection(_ name: String?) -> ItemSection? {
        guard let sect = watchSectionProvider(name) else { return nil }

        return sect
    }
}

extension Int {
    /// Credits: https://stackoverflow.com/questions/48371093/swift-4-formatting-numbers-into-friendly-ks
    var display: String {
        let num = abs(Double(self))
        let sign = (self < 0) ? "-" : ""

        switch num {
        case 1_000_000_000...:
            var formatted = num / 1_000_000_000
            formatted = formatted.truncate(places: 2)
            return "\(sign)\(formatted)B"

        case 1_000_000...:
            var formatted = num / 1_000_000
            formatted = formatted.truncate(places: 1)
            return "\(sign)\(formatted)M"

        case 1_000...:
            var formatted = num / 1_000
            formatted = formatted.truncate(places: 1)
            return "\(sign)\(formatted)K"

        case 0...:
            return "\(self)"

        default:
            return "\(sign)\(self)"

        }
    }
}

private extension Date {
    func daysDifferenceWithDate(_ date: Date?) -> Int? {
        guard let date = date else { return nil }

        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .day, for: date) else { return nil }

        let components = calendar.dateComponents([.day], from: self, to: interval.end)

        return components.day
    }
}

private extension Double {
    func truncate(places: Int) -> Double {
        let multiplier = pow(10, Double(places))
        let newDecimal = multiplier * self // move the decimal right
        let truncated = Double(Int(newDecimal)) // drop the fraction
        let originalDecimal = truncated / multiplier // move the decimal back
        return originalDecimal
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

        return Item(title: name,
                    subtitle: sub.joined(separator: "\n"),
                    color: episodeRatingColor,
                    metadata: Metadata(id: id, destination: .episode, episode: self))
    }
}
