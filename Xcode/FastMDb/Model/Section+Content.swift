//
//  Section+Content.swift
//  FastMDb
//
//  Created by Daniel on 5/18/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

extension Section {

    static func contentSections(kind: Tmdb.MoviesType, movie: MediaSearch?, tv: TvSearch?, people: PeopleSearch?, articles: [Article]?) -> [Section] {
        var sections: [Section] = []

        if let articles = articles {
            let items = articles.map { $0.listItem }
            let section = Article.section(items)
            sections.append(section)
        }

        if let movie = movie {
            let s = movieSections(movie: movie, kind: kind)
            sections.append(contentsOf: s)
        }

        if let tv = tv {
            let items = tv.results.map { $0.listItem }
            let section = Section(header: "tv\(Tmdb.separator)\(kind.tv.title)", items: items)
            sections.append(section)
        }

        if let people = people {
            let items = people.results.map { $0.listItemPopular }
            let section = Section(header: "people\(Tmdb.separator)\(kind.title)", items: items)
            sections.append(section)
        }

        return sections
    }

}

private extension Section {

    static func movieSections(movie: MediaSearch, kind: Tmdb.MoviesType) -> [Section] {
        var sections: [Section] = []
        
        let english = movie.results.filter { $0.original_language == "en" }.map { $0.listItem }
        if english.count > 0 {
            let section = Section(header: "movies\(Tmdb.separator)English\(Tmdb.separator)\(kind.title)", items: english)
            sections.append(section)
        }
        
        let notEnglish = movie.results.filter { $0.original_language != "en" }.map { $0.listItem }
        if notEnglish.count > 0 {
            let section = Section(header: "movies\(Tmdb.separator)Not English\(Tmdb.separator)\(kind.title)", items: notEnglish)
            sections.append(section)
        }

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

