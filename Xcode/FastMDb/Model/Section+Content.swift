//
//  Section+Content.swift
//  FastMDb
//
//  Created by Daniel on 5/18/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

extension ItemSection {

    static func contentSections(kind: Tmdb.MoviesType, movie: MediaSearch?, tv: TvSearch?, people: PeopleSearch?, articles: [Article]?) -> [ItemSection] {
        var sections: [ItemSection] = []

        if let s = Article.newsSection(articles, limit: 3) {
            sections.append(s)
        }

        if let s = movieSections(movie: movie, kind: kind) {
            sections.append(contentsOf: s)
        }

        if let s = tvSections(tv: tv, kind: kind) {
            sections.append(contentsOf: s)
        }

        if let people = people {
            let items = people.results.map { $0.listItemPopular }
            let section = ItemSection(header: "people\(Tmdb.separator)\(kind.title)", items: items)
            sections.append(section)
        }

        return sections
    }

}

private extension ItemSection {

    static func movieSections(movie: MediaSearch?, kind: Tmdb.MoviesType) -> [ItemSection]? {
        guard let movie = movie else { return nil }

        var sections: [ItemSection] = []

        let english = movie.results.filter { $0.original_language == "en" }.map { $0.listItem }
        if english.count > 0 {
            let section = ItemSection(header: "movies\(Tmdb.separator)English\(Tmdb.separator)\(kind.title)", items: english)
            sections.append(section)
        }

        let notEnglish = movie.results.filter { $0.original_language != "en" }.map { $0.listItem }
        if notEnglish.count > 0 {
            let section = ItemSection(header: "movies\(Tmdb.separator)Not English\(Tmdb.separator)\(kind.title)", items: notEnglish)
            sections.append(section)
        }

        guard sections.count > 0 else { return nil }

        return sections
    }

    static func tvSections(tv: TvSearch?, kind: Tmdb.MoviesType) -> [ItemSection]? {
        guard let tv = tv else { return nil }

        var sections: [ItemSection] = []

        let english = tv.results.filter { $0.original_language == "en" }.map { $0.listItem }

        if english.count > 0 {
            let section = ItemSection(header: "tv\(Tmdb.separator)English\(Tmdb.separator)\(kind.tv.title)", items: english)
            sections.append(section)
        }

        let notEnglish = tv.results.filter { $0.original_language != "en" }.map { $0.listItem }
        if notEnglish.count > 0 {
            let section = ItemSection(header: "tv\(Tmdb.separator)Not English\(Tmdb.separator)\(kind.tv.title)", items: notEnglish)
            sections.append(section)
        }

        guard sections.count > 0 else { return nil }

        return sections
    }

}

private extension Credit {

    var listItemPopular: Item {
        var sub: [String] = []

        if
            let known = known_for,
            known.count > 0 {
            let movies = Array(known.prefix(3))
                .map { $0.titleDisplay ?? "" }
                .filter { $0.isEmpty == false }

            if movies.count > 0 {
                sub.append(movies.joined(separator: ", "))
            }
        }

        return Item(id: id, title: name, subtitle: sub.joined(separator: ": "), destination: .person)
    }

}

