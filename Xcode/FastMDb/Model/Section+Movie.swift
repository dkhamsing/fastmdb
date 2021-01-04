//
//  Section+Movie.swift
//
//  Created by Daniel on 5/8/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation
import UIKit

extension Media {
    
    func sections(articles: [Article]?,
                  albums: [iTunes.Album]?,
                  limit: Int) -> [ItemSection] {
        var list: [ItemSection] = []

        if let section = imagesSection {
            list.append(section)
        }

        if let section = metadataSection {
            list.append(section)
        }

        if let section = Article.newsSection(articles) {            
            list.append(section)
        }

        if let section = ratingSection {
            list.append(section)
        }

        if let section = boxOfficeSection {
            list.append(section)
        }

        if let section = credits?.castSection(limit: limit) {
            list.append(section)
        }

        if let section = watchSection {
            list.append(section)
        }

        if let section = linksSection {
            list.append(section)
        }

        if let section = languageSection {
            list.append(section)
        }

        if let section = mediaSection(albums: albums) {
            list.append(section)
        }

        let credits = self.credits
        if let section = credits?.directorSection {
            list.append(section)
        }

        if let section = credits?.writerSection {
            list.append(section)
        }

        if let section = productionSection {
            list.append(section)
        }

        if let section = genreSection {
            list.append(section)
        }

        if let section = googleSection {
            list.append(section)
        }

        if let section = credits?.creditsSection(limit: 6) {
            list.append(section)
        }

        if let section = recommendedSection {
            list.append(section)
        }

        if let section = similarSection {
            list.append(section)
        }

        return list
    }
}

private extension Media {

    var boxOfficeSection: ItemSection? {
        if let revenue = revenue,
            revenue > 0 {

            let item = Item(title: revenue.display, subtitle: budgetDisplay, destination: .moviesSortedBy, sortedBy: Tmdb.byRevenue, releaseYear: releaseYear, color: boxOfficeColor)
            return ItemSection(header: "box office", items: [item])
        }

        guard
            let budget = budget,
            budget > 0 else { return nil }

        let i = Item(title: budget.display)
        return ItemSection(header: "budget", items: [i])
    }

    var genreSection: ItemSection? {
        guard let genre = genres,
              genre.count > 0 else { return nil }

        let items = genre.map { Item(id: $0.id, title: $0.name, destination: .genreMovie) }
        return ItemSection(header: "genre", items: items, display: .tags)
    }

    var googleSection: ItemSection? {
        var items: [Item] = []

        if let name = title {
            let item = Item(title: "Awards & Nominations", url: name.googleSearchAwardsUrl, destination: .url, image: Item.linkImage)
            items.append(item)
        }

        if let name = title {
            let item = Item(title: "Music", url: name.googleSearchMusicUrl, destination: .url, image: Item.linkImage)
            items.append(item)
        }

        guard items.count > 0 else { return nil }

        return ItemSection(header: "google", items: items)
    }

    // TODO: this is duplicated in tv
    var imagesSection: ItemSection? {
        var items: [Item] = []
        
        if !(poster_path ?? "").isEmpty {
            let url = Tmdb.mediaPosterUrl(path: poster_path, size: .xxl)
            let imageUrl = Tmdb.mediaPosterUrl(path: poster_path, size: .large)
            let posterItem = Item(url: url, destination: .safarivc, imageUrl: imageUrl, display: .portraitImage)
            items.append(posterItem)
        }
        
        if let it = images?.backdropItems {
            items.append(contentsOf: it)
        }
        
        guard items.count > 0 else { return nil }
        
        return ItemSection(items: items, display: .images)
    }

    var languageSection: ItemSection? {
        guard let lang = languageDisplay else { return nil }

        return ItemSection(header: "language", items: [Item(title: lang)])
    }

    var linksSection: ItemSection? {
        var items: [Item] = []

        if
            let homepage = homepage,
            homepage != "" {
            let url = URL(string: homepage)
            let imageUrl = url?.urlToSourceLogo
            let item = Item(title: homepageDisplay, url: url, destination: .url, image: Item.linkImage, imageUrl: imageUrl)
            items.append(item)
        }

        if let name = title {
            let url = name.wikipediaUrl
            let imageUrl = url?.urlToSourceLogo
            let item = Item(title: "Wikipedia", url: url, destination: .url, image: Item.linkImage, imageUrl: imageUrl)
            items.append(item)
        }

        if
            let id = external_ids?.validImdbId {
            let url = Imdb.url(id: id, kind: .title)
            let imageUrl = url?.urlToSourceLogo
            let item = Item(title: "IMDb", url: url, destination: .url, image: Item.linkImage, imageUrl: imageUrl)
            items.append(item)
        }

        if let name = title {
            let url = name.rottenTomatoestUrl
            let imageUrl = url?.urlToSourceLogo
            let item = Item(title: "Rotten Tomatoes", url: url, destination: .url, image: Item.linkImage, imageUrl: imageUrl)
            items.append(item)
        }

        if let name = title {
            let url = name.letterboxdUrl
            let imageUrl = url?.urlToSourceLogo
            let item = Item(title: "Letterboxd", url: url, destination: .url, image: Item.linkImage, imageUrl: imageUrl)
            items.append(item)
        }

        guard items.count > 0 else { return nil }

        return ItemSection(items: items, display: .squareImage)
    }

    func mediaSection(albums: [iTunes.Album]?) -> ItemSection? {
        var items: [Item] = []

        if
            let videos = videos?.results,
            videos.count > 0 {
            let item = Item(title: "Video Clips", destination: .videos, items: videos.map { $0.listItem }, image: Item.videoImage)
            items.append(item)
        }

        if let albums = albums {
            let item = Item(title: "Apple Music",  destination: .music, image: Item.videoImage, albums: albums)
            items.append(item)
        }

        guard items.count > 0 else { return nil }

        return ItemSection(header: "media", items: items)
    }

    var metadataSection: ItemSection? {
        var metadata: [String] = []

        // year
        if let s = statusDisplay {
            metadata.append(s)
        }

        // runTime
        if let r = runTimeDisplay {
            metadata.append(r)
        }

        // countries
        if
            let countries = production_countries,
            countries.count > 0 {
            metadata.append(countries.map { $0.name }.joined(separator: ", "))
        }

        var items: [Item] = []

        var metString = metadata.joined(separator: Tmdb.separator)

        if let contentRating = release_dates?.contentRating("US") {
            metString += "\nRated " + contentRating
        }

        items.append(
            Item(title:titleDisplay, subtitle: metString)
        )

        if let release = releaseDateDisplay {
            let item = Item(title: release, subtitle: releaseDateSubtitle)
            items.append(item)
        } else if let item = recentReleaseItem {
            items.append(item)
        }

        if let item = taglineOverviewItem {
            items.append(item)
        }

        if let c = belongs_to_collection {
            let item = Item(id: c.id, title: c.name, destination: .collection)
            items.append(item)
        }

        return ItemSection(header: "movie", items: items)
    }

    var productionSection: ItemSection? {
        guard let companies = production_companies,
              companies.count > 0 else { return nil }

        let items: [Item] = companies.map { $0.listItem }
        return ItemSection(header: "production", items: items, display: .tags)
    }

    var ratingSection: ItemSection? {
        guard let rating = ratingDisplay else { return nil }

        let item = Item(title: rating, subtitle: voteDisplay, color: vote_average.color)
        var section = ItemSection(header: "rating", items: [item])

        if let count = reviews?.results.count,
           count > 1 {
            let reviewItems = reviews?.results.map { $0.listItem }
            section.destinationItems = reviewItems
            section.destinationTitle = "Reviews"
            section.destination = .items
            section.footer = "\(count) reviews"
        }

        return section
    }

    var recommendedSection: ItemSection? {
        guard let recs = recommendations?.results,
              recs.count > 0 else { return nil }

        let items: [Item] = recs.map { $0.listItemImage }

        return ItemSection(header: "Recommendations", items: items, display: .portraitImage)
    }

    var similarSection: ItemSection? {
        guard let recs = similar?.results,
              recs.count > 0 else { return nil }

        let items: [Item] = recs.map { $0.listItemImage }
        return ItemSection(header: "Similar", items: items, display: .portraitImage)
    }

    var watchSection: ItemSection? {
        return watch?.watchSection(title)
    }

    var taglineOverviewItem: Item? {
        if let value = overviewDisplay {
            var item = Item(subtitle: value)

            if let tagline = tagline,
               tagline.isEmpty == false {
                item.title = tagline
            }

            return item
        }

        return nil
    }

    var statusDisplay: String? {
        if let s = status?.validStatus {
            return s
        }

        if let s = status,
            s == "Canceled" {
            return s
        }

        if let year = releaseYear {
            return year
        }

        return "Release date not available"
    }

}

private extension Credits {

    func castSection(limit: Int) -> ItemSection? {
        guard cast.count > 0 else { return nil }

        let items = cast.map { $0.listItemCast }

        return ItemSection(header: "cast", items: items, destination: .items, destinationTitle: "Cast", display: .portraitImage)
    }

    func creditsSection(limit: Int) -> ItemSection? {
        var filtered = crew
        for job in CrewJob.allCases {
            filtered = filtered.filter { $0.job != job.rawValue }
        }

        let uniqueNames = filtered
            .map { $0.name }
            .unique

        var items: [Item] = []
        for name in uniqueNames {
            let crew = filtered.filter { $0.name == name}

            var item = Item()
            if let c = crew.first {
                item = Item(id: c.id, title: c.name, destination: .person)
            }

            let jobs = crew.map { $0.job ?? "" }
            item.subtitle = jobs.joined(separator: ", ")

            items.append(item)
        }

        let c = Array(filtered.prefix(limit))

        guard c.count > 0 else { return nil }

        var crewTotal: String?

        if crew.count > limit {
            crewTotal = String.allCreditsText(crew.count)
        }

        let prefixed = Array(items.prefix(limit))

        return ItemSection(header: "crew", items: prefixed, footer: crewTotal, destination: .items, destinationItems: items, destinationTitle: "Crew")
    }

    var directorSection: ItemSection? {
        let director = crew.filter { $0.job == CrewJob.Director.rawValue }
        guard director.count > 0 else { return nil }

        let items = director.map { $0.listItemCrew }
        return ItemSection(header: "directed by", items: items)
    }

    var writerSection: ItemSection? {
        let writtenBy = crew.filter { $0.job == CrewJob.Screenplay.rawValue || $0.job == CrewJob.Teleplay.rawValue || $0.job == CrewJob.Writer.rawValue }
        guard writtenBy.count > 0 else { return nil }

        let items = writtenBy.map { $0.listItemCrew }

        return ItemSection(header: "written by", items: items)
    }

}

private extension Media {

    var boxOfficeColor: UIColor? {
        guard
            let budget = budget,
            budget > 0,
            let revenue = revenue,
            revenue > 0 else { return nil }

        let color = revenue > budget ? UIColor.systemGreen : UIColor.systemRed

        let ratio = CGFloat(revenue - budget) / CGFloat(budget)
//        print(ratio)
        switch ratio {
        case 0...1:
            return color.withAlphaComponent(ratio)
        default:
            return color
        }

    }

    var budgetDisplay: String? {
        guard
            let budget = budget,
            budget > 0 else { return nil }

        return "\(budget.display) budget"
    }

    var homepageDisplay: String? {
        guard
            let homepage = homepage,
            let url = URL(string: homepage) else { return nil }
        let host = url.host
        let display = host?.replacingOccurrences(of: "www.", with: "")

        return display
    }

    var languageDisplay: String? {
        guard
            let lang = original_language,
            lang != "en" else { return nil }

        guard let value = Languages.List[lang] else { return lang }

        return value
    }

    var overviewDisplay: String? {
        let od = overview.trimmingCharacters(in: .whitespacesAndNewlines)
        guard od != "" else { return nil }
        return od
    }

    var voteDisplay: String? {
        guard vote_count > Tmdb.voteThreshold else { return nil }

        return "\(vote_count) votes"
    }

    var ratingDisplay: String? {
        guard
            released,
            vote_count > Tmdb.voteThreshold else { return nil }

        return "\(vote_average)/10"
    }

    var recentReleaseItem: Item? {
        guard
            let r = release_date,
            let date = Tmdb.dateFormatter.date(from: r),
            let year = date.yearDifferenceWithDate(Date()),
            year < 1 else { return nil }

        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .day, for: Date()) else { return nil }

        let components = calendar.dateComponents([.day, .month, .year], from: date, to: interval.end)

        let sub = "Released \(components.duration) ago"

        return Item(title: release_date?.dateDisplay, subtitle: sub)
    }

    var releaseDateDisplay: String? {
        guard
            let r = release_date,
            let date = Tmdb.dateFormatter.date(from: r),
            date.timeIntervalSinceNow > 0 else { return nil }

        return release_date?.dateDisplay
    }

    var releaseDateSubtitle: String? {
        let sub = "Release Date"

        guard
            let r = release_date,
            let date = Tmdb.dateFormatter.date(from: r) else { return sub }

        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .day, for: date) else { return sub }

        let components = calendar.dateComponents([.day, .month, .year], from: Date(), to: interval.end)

        return "To be released in \(components.duration)"
    }

    var runTimeDisplay: String? {
        guard
            let unwrapped = runtime,
            unwrapped > 0 else { return nil }

        let (h,m) = unwrapped.duration

        if (h == 0) {
            return "\(m)m"
        }

        return "\(h)h \(m)m"
    }

}

private extension DateComponents {
    var duration: String {
        var string: [String] = []

        if let y = year,
            y > 0 {
            string.append("\(y) year\(y.pluralized)")
        }

        if let m = month,
            m > 0 {
            string.append("\(m) month\(m.pluralized)")
        }

        if let d = day,
            d > 0 {
            string.append("\(d) day\(d.pluralized)")
        }

        return string.joined(separator: " ")
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

private extension Int {

    var duration: (Int, Int) {
        let h = Int(self / 60)
        let m = Int(self % 60)

        return (h, m)
    }

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
