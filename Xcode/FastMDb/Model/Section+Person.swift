//
//  Section+Person.swift
//
//  Created by Daniel on 5/8/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

extension ItemSection {

    static func personSections(credit: Credit?,
                               articles: [Article]?,
                               highGross: MediaSearch?,
                               limit: Int) -> [ItemSection] {
        var sections: [ItemSection] = []

        if let section = credit?.images?.profilesSection {
            sections.append(section)
        }

        if let section = credit?.ageSection {
            sections.append(section)
        }

        if let section = credit?.taggedImageSection {
            sections.append(section)
        }

        if let section = Article.newsSection(articles) {
            sections.append(section)
        }

        if let section = credit?.linksSection {
            sections.append(section)
        }

        if let section = credit?.bioSection {
            sections.append(section)
        }

        if let section = credit?.knownForSection {
            sections.append(section)
        }

        if let section = highGross?.highestGrossingSections?.first {
            sections.append(section)
        }

        if let section = credit?.creditsSections(limit: limit) {
            sections.append(contentsOf: section)
        }

        return sections
    }

}

private extension Credit {

    var count: Int {
        let creditCount = [
            movie_credits?.cast.count,
            movie_credits?.crew.count,
            tv_credits?.cast.count,
            tv_credits?.crew.count]
            .compactMap { $0 }
            .reduce(0, +)

        return creditCount
    }

    func knownForActingSections(limit: Int) -> [ItemSection] {
        var sections: [ItemSection] = []

        let s = movieCastSections(limit: limit)
        if s.count > 0 {
            sections.append(contentsOf: s)
        }

        if let section = tvCastSections(limit: 5) {
            sections.append(contentsOf: section)
        }

        let crewSections = movieCrewSections(limit: limit)
        if crewSections.count > 0 {
            sections.append(contentsOf: crewSections)
        }

        if let s = TvCrewSections(limit: limit) {
            sections.append(contentsOf: s)
        }

        return sections
    }

    func knownForOtherSections(limit: Int) -> [ItemSection] {
        var sections: [ItemSection] = []

        let crewSections = movieCrewSections(limit: limit)
        if crewSections.count > 0 {
            sections.append(contentsOf: crewSections)
        }

        if let s = TvCrewSections(limit: limit) {
            sections.append(contentsOf: s)
        }

        let s = movieCastSections(limit: limit)
        if s.count > 0 {
            sections.append(contentsOf: s)
        }

        if let section = tvCastSections(limit: 5) {
            sections.append(contentsOf: section)
        }

        return sections
    }

}

private extension Credit {

    var ageSection: ItemSection? {
          guard
              deathday == nil,
              let birthday = birthday else { return nil }

          var sub: [String] = []

          if let bday = birthday.dateDisplay {
              sub.append("Born \(bday)")
          }

          if let pob = place_of_birth {
              sub.append(pob.trimmingCharacters(in: .whitespacesAndNewlines))
          }

          var item = Item(title: birthday.age, subtitle: sub.joined(separator: "\n"))

          if let url = place_of_birth?.mapUrl {
            item.metadata = Metadata(url: url, destination: .url, link: .map)
          }

          return ItemSection(header: "age", items: [item])
      }

    var bioSection: ItemSection? {
        // biography, imdb
        var bioSection = ItemSection(header: "biography")
        var bioItems: [Item] = []
        if let biography = biography,
           biography.isEmpty == false {
            let magic = 250
            if biography.count > magic {
                let truncated = biography.prefix(magic) + "..."
                let sect = ItemSection(header: "biography", items: [Item(title: biography)])
                let it = Item(title: String(truncated),
                              metadata: Metadata(destination: .sections, sections: [sect]))
                bioItems.append(it)
            } else {
                bioItems.append(Item(title: biography))
            }
        }

        // born, died
        if
            let bday = birthday?.dateDisplay,
            let dday = deathday?.dateDisplay {

            var pob: String?
            if let p = place_of_birth {
                pob = p.trimmingCharacters(in: .whitespacesAndNewlines)
            }

            var bornItem = Item(title: "Born \(bday)", subtitle: pob)

            if let url = place_of_birth?.mapUrl {
                bornItem.metadata = Metadata(url: url, destination: .url)
            }

            bioItems.append(bornItem)

            let item = Item(title: "Died \(dday)", subtitle: "Age \(ageAtDeath ?? "")")
            bioItems.append(item)
        }

        // awards
        if let id = external_ids?.validImdbId {
            let url = Imdb.awardsUrl(id: id, kind: .person)
            let item = Item(title: "Awards & Nominations",
                            metadata: Metadata(url: url, destination: .url))
            bioItems.append(item)
        }

        guard bioItems.count > 0 else { return nil }
        
        bioSection.items = bioItems

        return bioSection
    }

    var knownForSection: ItemSection? {
        let magic = 10

        guard
            count > magic,
            let known = known_for_department else { return nil }

        let limit = 5
        var items: [Item]?
        switch known {
        case Known.Directing.rawValue:
            items = movie_credits?.movieDirectingItems
            if let i = tv_credits?.tvDirectingItems {
                items?.append(contentsOf: i)
            }
        case Known.Writing.rawValue:
            items = movie_credits?.movieWritingItems
            if let i = tv_credits?.tvWritingItems {
                items?.append(contentsOf: i)
            }
        case Known.Acting.rawValue:
            items = Credits.actingItems(movie_credits: movie_credits, tv_credits: tv_credits, limit: limit)
        default:
            items = Credits.defaultItems(movie_credits: movie_credits, tv_credits: tv_credits, limit: limit)
        }

        guard
            let i = items,
            i.count > 0 else { return nil }

        return ItemSection(header: "known for", items: i, metadata: Metadata(display: .portraitImage()))
    }

    var linksSection: ItemSection? {
        var items: [Item] = []

        if let instagram = external_ids?.validInstagramId {
            let url = Instagram.url(instagram)
            let imageUrl = url?.urlToSourceLogo
            let item = Item(title: "Instagram", subtitle: instagram,
                            metadata: Metadata(url: url, destination: .url, imageUrl: imageUrl, link: .link))
            items.append(item)
        }

        if let twitter = external_ids?.validTwitterId {
            let url = Twitter.url(twitter)
            let imageUrl = url?.urlToSourceLogo
            let item = Item(title: "Twitter", subtitle: Twitter.username(twitter),
                            metadata: Metadata(url: url, destination: .url, imageUrl: imageUrl, link: .link))
            items.append(item)
        }

        if let name = name {
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

        if let id = external_ids?.validImdbId {
            let url = Imdb.url(id: id, kind: .person)
            let imageUrl = url?.urlToSourceLogo
            let item = Item(title: "IMDb",
                            metadata: Metadata(url: url, destination: .url, imageUrl: imageUrl, link: .link))
            items.append(item)
        }

        return ItemSection(items: items, metadata: Metadata(display: .squareImage()))
    }

}

private extension Credit {

    static func collapsedTvCredits(_ list: [Credit],
                                   job: String = "Writer") -> [CreditWrapper] {
        let uniqueTitles = list
            .map { $0.name }
            .unique

        var items: [CreditWrapper] = []
        for title in uniqueTitles {
            let crews = list.filter { $0.name == title }
            let jobs = crews.compactMap { $0.job }.unique

            if var item = crews.first(where: { $0.job == job }) {
                item.job = jobs.joined(separator: ", ")
                items.append(
                    CreditWrapper(credit: item, additional: crews)
                )
            } else if var item = crews.first {
                item.job = jobs.joined(separator: ", ")
                items.append(
                    CreditWrapper(credit: item, additional: crews)
                )
            }
        }

        return items
    }

    static func collapsedCredits(_ list: [Credit]) -> [Credit] {
        let uniqueTitles = list
            .map { $0.original_title }
            .unique

        var items: [Credit] = []
        for title in uniqueTitles {
            let crews = list.filter { $0.original_title == title }
            let jobs = crews.compactMap { $0.job }.unique

            if var item = crews.first {
                item.job = jobs.joined(separator: ", ")
                items.append(item)
            }
        }

        return items
    }

    static func collapsedMovieCrewItems(_ crew: [Credit]) -> [Item] {
        let items = Credit.collapsedCredits(crew).compactMap { $0.movieCrewItem }
        return items
    }

    func creditsSections(limit: Int) -> [ItemSection] {
        var sections: [ItemSection] = []
        if let known = known_for_department {

            if known == "Acting" {
                let s = self.knownForActingSections(limit: limit)
                if s.count > 0 {
                    sections.append(contentsOf: s)
                }
            } else {
                let s = self.knownForOtherSections(limit: limit)
                if s.count > 0 {
                    sections.append(contentsOf: s)
                }
            }

        } else {

            let s = self.knownForActingSections(limit: limit)
            if s.count > 0 {
                sections.append(contentsOf: s)
            }

        }

        return sections
    }

    func creditsUpcoming(_ list: [Credit]) -> [Credit] {
        let upcoming = list
            .filter {
                let noReleaseDate = $0.release_date == nil || $0.release_date == ""

                var releaseDateInFuture = false
                if let inFuture = $0.release_date?.inFuture,
                    inFuture == true {
                    releaseDateInFuture = true
                }

                return releaseDateInFuture || noReleaseDate
        }.sorted { $0.release_date ?? "" > $1.release_date ?? "" }

        return upcoming
    }

    func movieCastReleasedSection(cast: [Credit]?, limit: Int) -> ItemSection? {
        guard let cast = cast else { return nil }

        let upcoming = creditsUpcoming(cast)
        let alreadyDisplayed = upcoming.map { $0.original_title }
        let sorted = cast
            .filter { alreadyDisplayed.contains($0.original_title) == false }
            .sorted(by: { $0.release_date ?? "" > $1.release_date ?? ""})
        let top = Array(sorted.prefix(limit))

        guard top.count > 0 else { return nil }

        let topItems = top.map { $0.movieCastItem }

        var castTotal: String?
        if cast.count > limit {
            castTotal = String.allCreditsText(cast.count)
        }

        let section = ItemSection(header: "movies\(Constant.separator)latest", items: topItems, footer: castTotal,
                                  metadata: Metadata(destination: .items, destinationTitle: "Movies", items: cast.map { $0.movieCastItem }))

        return section
    }

    func movieCastUpcomingSection(_ cast: [Credit]?) -> ItemSection? {
        guard let cast = cast else { return nil }

        let upcoming = creditsUpcoming(cast)
        guard upcoming.count > 0 else { return nil }

        let i = upcoming.map { $0.movieCastItem }
        let section = ItemSection(header: "movies\(Constant.separator)upcoming", items: i)
        return section
    }

    func movieCastSections(limit: Int) -> [ItemSection] {
        var sections: [ItemSection] = []

        if let section = movieCastUpcomingSection(movie_credits?.cast) {
            sections.append(section)
        }

        if let section = movieCastReleasedSection(cast: movie_credits?.cast, limit: limit) {
            sections.append(section)
        }

        return sections
    }

    func movieCrewReleasedSection(crew: [Credit]?,
                                  isShowingDirector: Bool = false,
                                  header: String = "movie credits\(Constant.separator)latest",
                                  limit: Int) -> ItemSection? {
        guard let crew = crew else { return nil }

        let upcoming = creditsUpcoming(crew)
        let released = upcoming.map { $0.original_title }
        let crewSorted = crew
            .filter { released.contains($0.original_title) == false }
            .sorted(by: { $0.release_date ?? "" > $1.release_date ?? ""})

        let temp = Credit.collapsedMovieCrewItems(crewSorted)
        var collapsedItems: [Item] = []
        if !isShowingDirector {
            collapsedItems = temp
        } else {
            for item in temp {
                let subtitles = (item.subtitle ?? "").components(separatedBy: ", ")
                for sub in subtitles {
                    let subItem = sub.components(separatedBy: Constant.separator)
                    if subItem.contains(CrewJob.Director.rawValue) {
                        collapsedItems.append(item)
                    }
                }
            }
        }

        guard collapsedItems.count > 0 else { return nil }

        var total: String?
        if collapsedItems.count > limit {
            total = String.allCreditsText(collapsedItems.count)
        }

        let section = ItemSection(header: header, items: Array(collapsedItems.prefix(limit)), footer: total,
                                  metadata: Metadata(destination: .items, destinationTitle: "Movies", items: collapsedItems))

        return section
    }

    func movieCrewUpcomingSection(_ crew: [Credit]?) -> ItemSection? {
        guard let crew = crew else { return nil }

        let upcoming = creditsUpcoming(crew)
        let upcomingCollapsed = Credit.collapsedMovieCrewItems(upcoming)
        guard upcomingCollapsed.count > 0 else {return nil }

        let section = ItemSection(header: "movie credits\(Constant.separator)upcoming", items: upcomingCollapsed)

        return section
    }

    func movieCrewSections(limit: Int) -> [ItemSection] {
        var sections: [ItemSection] = []

        if let section = movieCrewUpcomingSection(movie_credits?.crew) {
            sections.append(section)
        }

        if let section = movieCrewReleasedSection(
            crew: movie_credits?.crew,
            isShowingDirector: true,
            header: "director credits",
            limit: limit) {
            sections.append(section)
        }

        if let section = movieCrewReleasedSection(crew: movie_credits?.crew, limit: limit) {
            sections.append(section)
        }

        return sections
    }

    var tmdbUrl: URL? {
        return Tmdb.Url.Web.person.detailURL(id)
    }

    func tvCrewItem(isImage: Bool = false,
                    isCredit: Bool = true,
                    additional: [Credit] = []) -> Item? {
        if isImage, Tmdb.Url.Image.mediaPoster(path: poster_path, size: .medium) == nil {
            return nil
        }

        var sub: [String] = []
        if first_air_date.yearDisplay != "" {
            sub.append(first_air_date.yearDisplay)
        }
        if let job = job {
            sub.append(job)
        }

        var sub2 = sub
        if let value = titleDisplay {
            sub2.insert(value, at: 0)
        }

        let url = Tmdb.Url.Image.mediaPoster(path: poster_path, size: .xxl)
        let imageUrl = Tmdb.Url.Image.mediaPoster(path: poster_path, size: .medium)

        var sections: [ItemSection] = []
        sections.append(
            ItemSection(items: [ Item(metadata: Metadata(url: url, destination: .safarivc, imageUrl: imageUrl, display: .portraitImage())) ],
                        metadata: Metadata(display: .images()))
        )

        sections.append(
            ItemSection(items: [Item(title: titleDisplay, metadata: Metadata(id: id, destination: .tv))] )
        )

        let items = additional.map {
            Item(title: $0.job,
                 metadata: Metadata(id: id,
                                    identifier: $0.credit_id,
                                    destination: .tvCredit))
        }

        sections.append(
            ItemSection(items: items)
        )

        var destination: Destination
        if items.count == 0 {
            destination = .tv
        } else if items.count == 1 {
            destination = .tvCredit
        } else {
            destination = isCredit ? .sections : .tv
        }

        return Item(title: titleDisplay,
                    subtitle: sub.joined(separator: Constant.separator),
                    color: ratingColor,
                    metadata: Metadata(id: id,
                                       identifier: credit_id,
                                       destination: destination,
                                       destinationTitle: titleDisplay,
                                       sections: sections,
                                       imageUrl: imageUrl,
                                       strings: sub2))
    }

    var tvCastSectionLatest: ItemSection? {
        guard
            let c = tv_credits ,
            c.cast.count > 0 else { return nil }

        let limit = 5

        let items = c.cast
            .sorted { $0.first_air_date ?? "" > $1.first_air_date ?? "" }
            .compactMap { $0.listItemTv }
            .prefix(limit)

        guard items.count > 0 else { return nil }

        let prefix = Array(items)
        let section = ItemSection(header: "tv\(Constant.separator)latest", items: prefix)

        return section
    }

    func tvCastSections(limit: Int) -> [ItemSection]? {
        guard
            let c = tv_credits ,
            c.cast.count > 0 else { return nil }

        var sections: [ItemSection] = []

        if let section = tvCastSectionLatest {
            sections.append(section)
        }

        let temp = c.cast
            .sorted { $0.episode_count ?? 0 > $1.episode_count ?? 0 }
            .compactMap { $0.listItemTv }

        var items: [Item] = []
        for item in temp {
            if let section = tvCastSectionLatest,
               let sectionItems = section.items,
               !sectionItems.contains(item),
               !items.contains(item) {
                items.append(item)
            }
        }

        if items.count == 0 && sections.count == 0 {
            return nil
        }

        var total: String?
        if items.count > limit {
            total = String.allCreditsText(items.count)
        }

        let prefix = Array(items.prefix(limit))

        let section = ItemSection(header: "tv\(Constant.separator)more", items: prefix, footer: total,
                                  metadata: Metadata(destination: .items, destinationTitle: "TV", items: c.cast.compactMap { $0.listItemTv }))

        if items.count > 0 {
            sections.append(section)
        }

        return sections
    }

    func TvCrewSections(limit: Int) -> [ItemSection]? {
        var sections: [ItemSection] = []

        if let section = TvCrewSectionCreator {
            sections.append(section)
        }

        if let section = TvCrewSectionUpcoming(limit: limit) {
            sections.append(section)
        }

        if let section = TvCrewSectionLatest(limit: limit) {
            sections.append(section)
        }

        guard sections.count > 0 else { return nil }

        return sections
    }

    var TvCrewSectionCreator: ItemSection? {
        guard let crew = tv_credits?.crew else { return nil }

        let items = Credit.collapsedTvCredits(crew)
            .filter { ($0.credit.job ?? "").contains("Creator") }
            .filter { $0.credit.first_air_date ?? "" != "" }
            .filter {
                var releaseDateInFuture = false
                if let inFuture = $0.credit.first_air_date?.inFuture,
                   inFuture == false {
                    releaseDateInFuture = true
                }

                return releaseDateInFuture
            }
            .sorted { $0.credit.first_air_date ?? "" > $1.credit.first_air_date ?? "" }
            .compactMap { $0.credit.tvCrewItem(additional: $0.additional) }

        guard items.count > 0 else { return nil }

        return ItemSection(header: "tv\(Constant.separator)creator", items: items)
    }

    func TvCrewSectionUpcoming(limit: Int) -> ItemSection? {
        guard let crew = tv_credits?.crew else { return nil }

        let items = Credit.collapsedTvCredits(crew)
            .map { $0.credit }
            .filter {
                let noRelease = $0.first_air_date ?? "" == ""

                var releaseDateInFuture = false
                if let inFuture = $0.first_air_date?.inFuture,
                   inFuture == true {
                    releaseDateInFuture = true
                }

                return releaseDateInFuture || noRelease
            }
            .compactMap { $0.tvCrewItem(isCredit: false) }

        guard items.count > 0 else { return nil }

        var total: String?
        if items.count > limit {
            total = String.allCreditsText(items.count)
        }

        return ItemSection(header: "tv credits\(Constant.separator)upcoming", items: Array(items.prefix(limit)), footer: total,
                           metadata: Metadata(destination: .items, destinationTitle: "TV", items: items))
    }

    func TvCrewSectionLatest(limit: Int) -> ItemSection? {
        guard let crew = tv_credits?.crew else { return nil }

        let temp = Credit.collapsedTvCredits(crew)
            .filter { $0.credit.first_air_date ?? "" != "" }
            .filter {
                    var releaseDateInFuture = false
                    if let inFuture = $0.credit.first_air_date?.inFuture,
                        inFuture == true {
                        releaseDateInFuture = true
                    }

                    return !releaseDateInFuture
            }
            .sorted { $0.credit.first_air_date ?? "" > $1.credit.first_air_date ?? ""}
            .compactMap { $0.credit.tvCrewItem(additional: $0.additional) }

        var items: [Item] = []
        for item in temp {
            if let section = TvCrewSectionCreator,
               let sectionItems = section.items,
               !sectionItems.contains(item) {
                items.append(item)
            }
        }

        if items.count == 0 {
            items = temp
        }

        guard items.count > 0 else { return nil }

        var total: String?
        if items.count > limit {
            total = String.allCreditsText(items.count)
        }

        return ItemSection(header: "tv credits\(Constant.separator)latest", items: Array(items.prefix(limit)), footer: total,
                           metadata: Metadata(destination: .items, destinationTitle: "TV", items: items))
    }

}

private extension Credits {

    static func actingItems(movie_credits: Credits?, tv_credits: Credits?, limit: Int) -> [Item] {
        var items: [Item] = []
        if let m = movie_credits?.cast {
            let movies = m
                .filter { $0.ratingColor != nil }
                .filter { $0.vote_average ?? 0 > 6 }
                .prefix(limit)
            items = Array(movies).map { $0.movieCastImageItem }
        }

        if let tv = tv_credits?.cast {
            let sorted = tv
                .filter { $0.ratingColor != nil }
                .filter { $0.vote_average ?? 0 > 6 }
                .sorted{ $0.episode_count ?? 0 > $1.episode_count ?? 0 }
                .prefix(limit)

            let tvItems: [Item] = Array(sorted).compactMap { $0.listItemTv(isImage: true) }
            items.append(contentsOf: tvItems)
        }

        return items
    }

    static func defaultItems(movie_credits: Credits?, tv_credits: Credits?, limit: Int) -> [Item] {
        var items: [Item] = []

        if let media = movie_credits?.crew.prefix(limit) {
            items = Array(media).compactMap { $0.movieCrewItem(isImage: true) }
        }

        if let media = tv_credits?.crew {
            let collapsedCredits = Credit.collapsedCredits(media).prefix(limit)
            items.append(contentsOf: Array(collapsedCredits).compactMap { $0.tvCrewItem(isImage: true) })
        }

        return items
    }

    var topDirectingCredits: [Credit] {
        let limit = 5

        let directors = crew
            .sorted  { $0.popularity ?? 0 > $1.popularity ?? 0}
            .filter { $0.job == CrewJob.Director.rawValue }

        return Array(directors.prefix(limit))
    }

    var movieDirectingItems: [Item] {
        let items = topDirectingCredits.compactMap { $0.movieCrewItem(isImage: true) }
        return items
    }

    var tvDirectingItems: [Item] {
        let items = topDirectingCredits.compactMap { $0.tvCrewItem(isImage: true) }
        return items
    }

    var topWritingCredits: [Credit] {
        let limit = 5

        let writers = crew
            .sorted  { $0.popularity ?? 0 > $1.popularity ?? 0 }
            .filter { $0.job == CrewJob.Teleplay.rawValue || $0.job == CrewJob.Writer.rawValue }

        return Array(writers.prefix(limit))
    }

    var movieWritingItems: [Item] {
        let items = topWritingCredits.compactMap { $0.movieCrewItem(isImage: true) }
        return items
    }

    var tvWritingItems: [Item] {
        let items: [Item] = topWritingCredits.compactMap { $0.tvCrewItem(isImage: true) }
        return items
    }

}

private extension Credit {

    var ageAtDeath: String? {
        let formatter = Constant.dateFormatter

        guard
            let bday = birthday,
            let bdayDate = formatter.date(from: bday) else { return nil }

        guard let dday = deathday,
            let ddayDate = formatter.date(from: dday) else { return nil }

        guard let age = bdayDate.yearDifferenceWithDate(ddayDate) else { return nil }

        return String(age)
    }
    
    var movieCastItem: Item {
        return Item(title: titleDisplay, subtitle: movieCastSubtitle, color: ratingColor,
                    metadata: Metadata(id: id, destination: .movie))
    }

    var movieCastImageItem: Item {
        var sub: [String] = []
        if let value = titleDisplay {
            sub.append(value)
        }
        sub.append(contentsOf: movieCastSubtitles)

        let imageUrl = Tmdb.Url.Image.mediaPoster(path: poster_path, size: .medium)
        return Item(title: titleDisplay, color: ratingColor,
                    metadata: Metadata(id: id, destination: .movie, imageUrl: imageUrl, strings: sub))
    }

    var movieCastSubtitles: [String] {
        var sub: [String] = []

        if let year = releaseYear {
            sub.append(year)
        }

        if
            let character = character,
            character.isEmpty == false {
            sub.append(character)
        }

        return sub
    }

    var movieCastSubtitle: String {
        return movieCastSubtitles.joined(separator: Constant.separator)
    }

    var movieCrewItem: Item? {
        return movieCrewItem()
    }

    func movieCrewItem(isImage: Bool = false) -> Item? {
        var sub: [String] = []
        if let year = releaseYear {
            sub.append(year)
        }
        if let j = job {
            sub.append(j)
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
                    metadata: Metadata(id: id, destination: .movie, imageUrl: imageUrl, strings: sub2))
    }

}

private extension String {

    var age: String? {
        let formatter = Constant.dateFormatter
        guard let date = formatter.date(from: self) else { return nil }

        guard let age = date.yearDifferenceWithDate(Date()) else { return nil }

        return String(age)
    }

    var mapUrl: URL? {
        let baseUrl = Map.urlBase
        guard let encodedName = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }

        let finalUrl = baseUrl + encodedName
        return URL(string: finalUrl)
    }

}
