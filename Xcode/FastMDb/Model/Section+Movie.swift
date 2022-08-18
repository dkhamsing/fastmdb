//
//  Section+Movie.swift
//
//  Created by Daniel on 5/8/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation
import UIKit

extension Media {
    
    func sections(mdm: DataProviderModel, limit: Int) -> [ItemSection] {
        var list: [ItemSection] = []

        if let section = imagesSection {
            list.append(section)
        }

        if let section = metadataSection {
            list.append(section)
        }

        if let section = Article.newsSection(mdm.articles) {
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

        if let section = mediaSection(albums: mdm.albums) {
            list.append(section)
        }

        let credits = self.credits
        if let section = credits?.directorSection {
            list.append(section)
        }

        if let section = credits?.cinematographerSection {
            list.append(section)
        }

        if let section = credits?.writerSection {
            list.append(section)
        }

        if let section = credits?.storySection {
            list.append(section)
        }

        if let section = credits?.scoreSection {
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

        if let section = moreDirectorSection(mdm.moreDirector) {
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

extension Media {

    var imagesSection: ItemSection? {
        return ItemSection.imagesSection(poster_path: poster_path, images: images)
    }

}

extension Media {

    var ratingTvCreditSection: ItemSection? {
        guard vote_count > 0 else { return nil }

        let rating = "\(vote_average)/10"
        let item = Item(title: rating, subtitle: voteDisplay, color: vote_average.color)
        var section = ItemSection(header: "rating", items: [item])

        if let count = reviews?.results.count,
           count > 1 {
            let reviewItems = reviews?.results.map { $0.listItem }
            section.footer = "\(count) reviews"
            section.metadata = Metadata(destination: .items, destinationTitle: "Reviews", items: reviewItems)
        }

        return section
    }
}

private extension Media {

    var boxOfficeSection: ItemSection? {
        if let revenue = revenue,
            revenue > 0 {

            let item = Item(title: revenue.display, subtitle: budgetDisplay, color: boxOfficeColor,
                            metadata: Metadata(destination: .moviesSortedBy, sortedBy: .byRevenue, releaseYear: releaseYear))
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

        let items = genre.map { Item(title: $0.name,
                                     metadata: Metadata(id: $0.id, destination: .genreMovie)) }
        return ItemSection(header: "genre", items: items, metadata: Metadata(display: .tags()))
    }

    var googleSection: ItemSection? {
        guard status == "Released" else { return nil }

        var items: [Item] = []

        if let name = title {
            let item = Item(title: "Music",
                            metadata: Metadata(url: name.googleSearchMusicUrl, destination: .url, link: .link))
            items.append(item)
        }

        guard items.count > 0 else { return nil }

        return ItemSection(header: "google", items: items)
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
            let item = Item(title: homepageDisplay,
                            metadata: Metadata(url: url, destination: .url, imageUrl: imageUrl, link: .link))
            items.append(item)
        }

        if let name = title {
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

        if let name = title {
            let url = name.boxOfficeMojoUrl
            let imageUrl = url?.urlToSourceLogo
            let item = Item(title: "Box Office Mojo",
                            metadata: Metadata(url: url, destination: .url, imageUrl: imageUrl, link: .link))
            items.append(item)
        }

        if
            let id = external_ids?.validImdbId {
            let url = Imdb.url(id: id, kind: .title)
            let imageUrl = url?.urlToSourceLogo
            let item = Item(title: "IMDb",
                            metadata: Metadata(url: url, destination: .url, imageUrl: imageUrl, link: .link))
            items.append(item)
        }

        if let name = title {
            let url = name.rottenTomatoestUrl
            let imageUrl = url?.urlToSourceLogo
            let item = Item(title: "Rotten Tomatoes",
                            metadata: Metadata(url: url, destination: .url, imageUrl: imageUrl, link: .link))
            items.append(item)
        }

        if let name = title {
            let url = name.letterboxdUrl
            let imageUrl = url?.urlToSourceLogo
            let item = Item(title: "Letterboxd",
                            metadata: Metadata(url: url, destination: .url, imageUrl: imageUrl, link: .link))
            items.append(item)
        }

        guard items.count > 0 else { return nil }

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

        // rating
        if let contentRating = release_dates?.contentRating("US") {
            let text = "Rated " + contentRating
            metadata.append(text)
        }

        let metString = metadata.joined(separator: Constant.separator)

        var items: [Item] = []

        items.append(
            Item(title: titleDisplay, subtitle: metString)
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

        if let countries = production_countries,
           countries.count > 0 {
            let item = Item(title: countries.map { $0.name }.joined(separator: ", "),
                            subtitle: "Production Countries")
            items.append(item)
        }

        // awards
        if let id = external_ids?.validImdbId,
           status ?? "" == "Released" {
            let url = Imdb.awardsUrl(id: id, kind: .title)
            let item = Item(title: "Awards & Nominations",
                            metadata: Metadata(url: url, destination: .url))
            items.append(item)
        }

        if let c = belongs_to_collection {
            let item = Item(title: c.name, metadata: Metadata(id: c.id, destination: .collection))
            items.append(item)
        }

        return ItemSection(items: items)
    }

    func moreDirectorSection(_ md: MoreDirector?) -> ItemSection? {
        guard let md = md else { return nil }

        let items = md.media?.map { $0.listItemImage }
        return ItemSection(header: "More by \(md.name ?? "the same director")",
                           items: items,
                           metadata: Metadata(display: .portraitImage()))
    }

    var productionSection: ItemSection? {
        guard let companies = production_companies,
              companies.count > 0 else { return nil }

        let items: [Item] = companies.map { $0.listItem }
        return ItemSection(header: "production", items: items, metadata: Metadata(display: .tags()))
    }

    var ratingSection: ItemSection? {
        guard let rating = ratingDisplay else { return nil }

        let item = Item(attributedTitle: rating, subtitle: voteDisplay, color: vote_average.color)
        var section = ItemSection(header: "rating", items: [item])

        if let count = reviews?.results.count,
           count > 1 {
            let reviewItems = reviews?.results.map { $0.listItem }
            section.footer = "\(count) reviews"
            section.metadata = Metadata(destination: .items, destinationTitle: "Reviews", items: reviewItems)
        }

        return section
    }

    var recommendedSection: ItemSection? {
        guard let recs = recommendations?.results,
              recs.count > 0 else { return nil }

        let items: [Item] = recs.map { $0.listItemImage }

        return ItemSection(header: "Recommendations", items: items, metadata: Metadata(display: .portraitImage()))
    }

    var similarSection: ItemSection? {
        guard let recs = similar?.results,
              recs.count > 0 else { return nil }

        let items: [Item] = recs.map { $0.listItemImage }
        return ItemSection(header: "Similar", items: items, metadata: Metadata(display: .portraitImage()))
    }

    var watchSection: ItemSection? {
        guard status ?? "" == "Released" else { return nil }        
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

    var tmdbUrl: URL? {
        return Tmdb.Url.Web.movie.detailURL(id)
    }

}

private extension Credits {

    func castSection(limit: Int) -> ItemSection? {
        guard cast.count > 0 else { return nil }

        let items = cast.map { $0.listItemCast }

        return ItemSection(header: "cast", items: items,
                           metadata: Metadata(destination: .items, destinationTitle: "Cast", display: .portraitImage()))
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
                item = Item(title: c.name, metadata: Metadata(id: c.id, destination: .person))
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

        return ItemSection(header: "crew", items: prefixed, footer: crewTotal,
                           metadata: Metadata(destination: .items, destinationTitle: "Crew", items: items))
    }

    var cinematographerSection: ItemSection? {
        return jobSection([CrewJob.Cinematographer.rawValue], "cinematography by")
    }


    var directorSection: ItemSection? {
        return jobSection([CrewJob.Director.rawValue], "directed by")
    }

    var scoreSection: ItemSection? {
        return jobSection([CrewJob.Score.rawValue,
                           CrewJob.Music.rawValue], "score by")
    }

    var storySection: ItemSection? {
        return jobSection([CrewJob.Novel.rawValue,
                           CrewJob.Story.rawValue,
                           CrewJob.OriginalWriter.rawValue,
                           CrewJob.ShortStory.rawValue], "story")
    }

    var writerSection: ItemSection? {
        let jobs = [CrewJob.Screenplay.rawValue,
                    CrewJob.Teleplay.rawValue,
                    CrewJob.Writer.rawValue]
        return jobSection(jobs, "written by")
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
            lang != Tmdb.language else { return nil }

        guard let value = Languages.List[lang] else { return lang }

        return value
    }

    var overviewDisplay: String? {
        let od = overview.trimmingCharacters(in: .whitespacesAndNewlines)
        guard od != "" else { return nil }
        return od
    }

    var voteDisplay: String? {
        return Constant.Vote(count: vote_count).voteDisplay
    }

    var ratingDisplay: NSAttributedString? {
        guard released else { return nil }

        return Constant.Vote(count: vote_count, average: vote_average).ratingDisplayAttributed
    }

    var recentReleaseItem: Item? {
        guard
            let r = release_date,
            let date = Constant.dateFormatter.date(from: r),
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
            let date = Constant.dateFormatter.date(from: r),
            date.timeIntervalSinceNow > 0 else { return nil }

        return release_date?.dateDisplay
    }

    var releaseDateSubtitle: String? {
        let sub = "Release Date"

        guard
            let r = release_date,
            let date = Constant.dateFormatter.date(from: r) else { return sub }

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

        return m > 0 ? "\(h)h \(m)m" : "\(h)h"
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



private extension Int {

    var duration: (Int, Int) {
        let h = Int(self / 60)
        let m = Int(self % 60)

        return (h, m)
    }

}
