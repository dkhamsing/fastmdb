//
//  Section+Content.swift
//  FastMDb
//
//  Created by Daniel on 5/18/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

extension Section {

    static func contentSections(kind: Tmdb.MoviesType, movie: MediaSearch?, tv: TvSearch?, people: PeopleSearch?) -> [Section] {
        var sections: [Section] = []

        if let movie = movie {
            let items = movie.results.map { $0.listItem }
            let section = Section(header: "movies\(Tmdb.separator)\(kind.title)", items: items)
            sections.append(section)
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

