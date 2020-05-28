//
//  Section+Person.swift
//
//  Created by Daniel on 5/8/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

extension Section {
    static func personSections(credit: Credit?, articles: [Article]?, limit: Int) -> [Section] {
        var sections: [Section] = []

        if let section = credit?.ageSection {
            sections.append(section)
        }

        if let section = Article.newsSection(articles) {
            sections.append(section)
        }

        if let section = credit?.bioSection {
            sections.append(section)
        }

        if let section = credit?.knownForSection {
            sections.append(section)
        }

        if let section = credit?.linksSection {
            sections.append(section)
        }

        if let s = credit?.creditsSections(limit: limit) {
            sections.append(contentsOf: s)
        }

        return sections
    }

}

private extension Credit {

    func knownForActingSections(limit: Int) -> [Section] {
        var sections: [Section] = []

        if let section = movieCastSection(limit: limit) {
            sections.append(section)
        }

        if let section = tvCastSection(limit: limit) {
            sections.append(section)
        }

        if let section = crewMovieSection(limit: limit) {
            sections.append(section)
        }

        if let section = crewTvSection(limit: limit) {
            sections.append(section)
        }

        return sections
    }

    func knownForOtherSections(limit: Int) -> [Section] {
        var sections: [Section] = []

        if let section = crewMovieSection(limit: limit) {
            sections.append(section)
        }

        if let section = crewTvSection(limit: limit) {
            sections.append(section)
        }

        if let section = movieCastSection(limit: limit) {
            sections.append(section)
        }

        if let section = tvCastSection(limit: limit) {
            sections.append(section)
        }

        return sections
    }

}

private extension Credit {

    var ageSection: Section? {
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

          var item = Item(title: birthday.age, subtitle: sub.joined(separator: Tmdb.separator))

          if let url = place_of_birth?.mapUrl {
              item.url = url
              item.destination = .url
              item.image = Item.mapImage
          }

          return Section(header: "age", items: [item])
      }

    var bioSection: Section? {
        // biography, imdb
        var bioSection = Section(header: "biography")
        var bioItems: [Item] = []
        if
            let biography = biography,
            biography.isEmpty == false {
            bioItems.append(Item(title: biography))
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
                bornItem.url = url
                bornItem.destination = .url
            }

            bioItems.append(bornItem)

            let item = Item(title: "Died \(dday)", subtitle: "Age \(ageAtDeath ?? "")")
            bioItems.append(item)
        }

        guard bioItems.count > 0 else { return nil }
        bioSection.items = bioItems

        return bioSection
    }

    var knownForSection: Section? {

        var creditCount: Int = 0

        if let c = movie_credits?.cast.count {
            creditCount += c
        }
        if let c = movie_credits?.crew.count {
            creditCount += c
        }
        if let c = tv_credits?.cast.count {
            creditCount += c
        }
        if let c = tv_credits?.crew.count {
            creditCount += c
        }

        guard
            creditCount > 10,
            let known = known_for_department else { return nil }

        let limit = 2
        var items: [Item] = []

        if known == "Directing" {
            let f = movie_credits?.crew
                .sorted  { $0.popularity ?? 0 > $1.popularity ?? 0}
                .filter { $0.job == CrewJob.Director.rawValue }

            if let f = f {
                let top = Array(f.prefix(limit))
                items = top.map { $0.movieCrewItem }
            }

            // TODO: tv credits directors
        }
        else if known == "Writing" {
            if let crew = movie_credits?.crew {
                let writers = crew
                    .sorted  { $0.popularity ?? 0 > $1.popularity ?? 0 }
                    .filter { $0.job == CrewJob.Teleplay.rawValue || $0.job == CrewJob.Writer.rawValue }
                guard writers.count > 0 else { return nil }

                let top = Array(writers.prefix(limit))
                items = top.map { $0.movieCrewItem }
            }

            // TODO: tv credits writing

        }
        else if known == "Acting" {

            if let media = movie_credits?.cast.prefix(limit) {
                items = Array(media).map { $0.movieCastItem }
            }

            if
                items.count == 0,
                let media = tv_credits?.cast.first {
                var sub: String?
                if media.first_air_date.yearDisplay != "" {
                    sub = media.first_air_date.yearDisplay
                }
                let item = Item(id: media.id, title: media.titleDisplay, subtitle: sub, destination: .tv)
                items.append(item)
            }

        }
        else {

            if let media = movie_credits?.crew.prefix(limit) {
                items = Array(media).map { $0.movieCrewItem }
            }

            if
                items.count == 0,
                let media = tv_credits?.crew.first {
                var sub: [String] = []
                if media.first_air_date.yearDisplay != "" {
                    sub.append(media.first_air_date.yearDisplay)
                }
                if let job = media.job {
                    sub.append(job)
                }

                let item = Item(id: media.id, title: media.titleDisplay, subtitle: sub.joined(separator: Tmdb.separator), destination: .tv)
                items.append(item)
            }

        }

        guard items.count > 0 else { return nil }

        return Section(header: "known for", items: items)
    }

    var linksSection: Section? {
        var items: [Item] = []

        if let instagram = external_ids?.validInstagramId {
            let item = Item(title: "Instagram", subtitle: instagram, url: Instagram.url(instagram), destination: .url, image: Item.linkImage)
            items.append(item)
        }

        if let twitter = external_ids?.validTwitterId {
            let item = Item(title: "Twitter", subtitle: Twitter.username(twitter), url: Twitter.url(twitter), destination: .url, image: Item.linkImage)
            items.append(item)
        }

        if let name = name {
            let item = Item(title: "Wikipedia", url: name.wikipediaUrl, destination: .url, image: Item.linkImage)
            items.append(item)
        }

        if let id = external_ids?.validImdbId {
            let item = Item(title: "IMDb", url: Imdb.url(id: id, kind: .person), destination: .url, image: Item.linkImage)
            items.append(item)
        }

        return Section(header: "links", items: items)
    }
}

private extension Credit {

    func creditsSections(limit: Int) -> [Section] {
        var sections: [Section] = []
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

    func crewMovieSection(limit: Int) -> Section? {

        guard let credits = movie_credits else { return nil }

        let crewSorted = credits.crew.sorted(by: { $0.release_date ?? "" > $1.release_date ?? ""})

        let uniqueTitles = crewSorted
            .map { $0.original_title }
            .unique

        var items: [Item] = []
        for title in uniqueTitles {
            let crews = crewSorted.filter { $0.original_title == title}

            var item = Item()
            var sub: [String] = []
            if let c = crews.first {
                item = Item(id: c.id, title: c.titleDisplay, destination: .movie, color: c.ratingColor)

                if let year = c.releaseYear {
                  sub.append(year)
                }
            }

            let jobs = crews.map { $0.job ?? "" }
            let jobString = jobs.joined(separator: ", ")

            sub.append(jobString)

            item.subtitle = sub.joined(separator: Tmdb.separator)
            items.append(item)
        }

        guard items.count > 0 else { return nil }

        var total: String?
        if items.count > limit {
            total = String.allCreditsText(items.count)
        }

        return Section(header: "movie credits", items: Array(items.prefix(limit)), footer: total, destination: .items, destinationItems: items, destinationTitle: "Movies")

    }

    func crewTvSection(limit: Int) -> Section? {

        guard let crew = tv_credits?.crew else { return nil }

        let crewSorted = crew.sorted(by: { $0.first_air_date ?? "" > $1.first_air_date ?? ""})

        let uniqueTitles = crewSorted
            .map { $0.name }
            .unique

        var items: [Item] = []
        for title in uniqueTitles {
            let crews = crewSorted.filter { $0.name == title}

            var item = Item()
            var sub: [String] = []
            if let c = crews.first {
                item = Item(id: c.id, title: c.titleDisplay, destination: .tv, color: c.ratingColor)

                if c.first_air_date.yearDisplay != "" {
                    sub.append(c.first_air_date.yearDisplay)
                }
            }

            let jobs = crews.map { $0.job ?? "" }
            let jobString = jobs.joined(separator: ", ")

            sub.append(jobString)

            item.subtitle = sub.joined(separator: Tmdb.separator)
            items.append(item)
        }

        guard items.count > 0 else { return nil }

        var total: String?
        if items.count > limit {
            total = String.allCreditsText(items.count)
        }

        return Section(header: "tv credits", items: Array(items.prefix(limit)), footer: total, destination: .items, destinationItems: items, destinationTitle: "TV")
    }

    func movieCastSection(limit: Int) -> Section? {
        guard let credits = movie_credits else { return nil }

        let sorted = credits.cast.sorted(by: { $0.release_date ?? "" > $1.release_date ?? ""})
        let cast = Array(sorted.prefix(limit))

        guard cast.count > 0 else { return nil }

        let items = cast.map { $0.movieCastItem }

        var castTotal: String?
        if credits.cast.count > limit {
            castTotal = String.allCreditsText(credits.cast.count)
        }

        return Section(header: "movies", items: items, footer: castTotal, destination: .items, destinationItems: credits.cast.map { $0.movieCastItem }, destinationTitle: "Movies")
    }

    func tvCastSection(limit: Int) -> Section? {
        guard
            let c = tv_credits ,
            c.cast.count > 0 else { return nil }

        let items = c.cast
            .sorted { $0.episode_count ?? 0 > $1.episode_count ?? 0 }
            .map { $0.listItemTv }

        guard items.count > 0 else { return nil }
        var total: String?
        if items.count > limit {
            total = String.allCreditsText(items.count)
        }

        let prefix = Array(items.prefix(limit))

        return Section(header: "tv", items: prefix, footer: total, destination: .items, destinationItems: c.cast.map { $0.listItemTv }, destinationTitle: "TV")
    }

}

private extension Credit {

    var ageAtDeath: String? {
        let formatter = Tmdb.dateFormatter

        guard
            let bday = birthday,
            let bdayDate = formatter.date(from: bday) else { return nil }

        guard let dday = deathday,
            let ddayDate = formatter.date(from: dday) else { return nil }

        guard let age = bdayDate.yearDifferenceWithDate(ddayDate) else { return nil }

        return String(age)
    }
    
    var movieCastItem: Item {
        return Item(id: id, title: titleDisplay, subtitle: movieCastSubtitle, destination: .movie, color: ratingColor)
    }

    var movieCastSubtitle: String {
        var sub: [String] = []

        if let year = releaseYear {
            sub.append(year)
        }

        if
            let character = character,
            character.isEmpty == false {
            sub.append(character)
        }

        return sub.joined(separator: Tmdb.separator)
    }

    var movieCrewItem: Item {
        var sub: [String] = []
        if let year = releaseYear {
            sub.append(year)
        }
        if let j = job {
            sub.append(j)
        }
        return Item(id: id, title: titleDisplay, subtitle: sub.joined(separator: Tmdb.separator), destination: .movie, color: ratingColor)
    }

}

private extension String {
    var age: String? {
        let formatter = Tmdb.dateFormatter
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
