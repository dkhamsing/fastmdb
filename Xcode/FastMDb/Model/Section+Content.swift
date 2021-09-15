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

        if let people = people {
            let items = people.results.map { $0.listItemPopular }
            let section = ItemSection(header: "people\(Tmdb.separator)\(kind.title)", items: items,
                                      metadata: Metadata(display: .portraitImage()))
            sections.append(section)
        }

        if let s = movieSections(movie: movie, kind: kind) {
            sections.append(contentsOf: s)
        }

        if let s = tvSections(tv: tv, kind: kind) {
            sections.append(contentsOf: s)
        }

        return sections
    }

}

private extension ItemSection {

    static func movieSections(movie: MediaSearch?, kind: Tmdb.MoviesType) -> [ItemSection]? {
        guard let movie = movie else { return nil }

        var sections: [ItemSection] = []

        var results = movie.results

        let voteLimit = 5000

        switch kind {
        case .top_rated:
            results = results.filter { $0.vote_count > voteLimit }
        case .upcoming:
            results = results.sorted { $0.release_date ?? "" > $1.release_date ?? "" }
        default:
            break
        }

        let english: [Item] = results
            .filter { $0.original_language == "en" }
            .map { item in
                switch kind {
                case .top_rated:
                    return item.listItemWithVotes
                case .upcoming:
                    return item.listItemUpcoming
                default:
                    return item.listItemTextImage
                }
        }
        if english.count > 0 {
            let section = ItemSection(header: "movies\(Tmdb.separator)English\(Tmdb.separator)\(kind.title)", items: english, metadata: Metadata(display: .textImage()))
            sections.append(section)
        }

        let notEnglish = results.filter { $0.original_language != "en" }.map { kind == .top_rated ? $0.listItemWithVotes : $0.listItem }
        if notEnglish.count > 0 {
            let section = ItemSection(header: "movies\(Tmdb.separator)Not English\(Tmdb.separator)\(kind.title)", items: notEnglish)
            sections.append(section)
        }

        if kind == .top_rated {
            let lessVotes = movie.results.filter { $0.vote_count < (voteLimit + 1) }.map { $0.listItemWithVotes }
            if !lessVotes.isEmpty {
                let section = ItemSection(header: "movies\(Tmdb.separator)also top rated", items: lessVotes)
                sections.append(section)
            }
        }

        guard sections.count > 0 else { return nil }

        return sections
    }

    static func tvSections(tv: TvSearch?, kind: Tmdb.MoviesType) -> [ItemSection]? {
        guard let tv = tv else { return nil }

        var sections: [ItemSection] = []

        var results = tv.results

        let voteLimit = 1000

        if kind == .top_rated {
            results = results.filter { $0.vote_count > voteLimit }
        }

        let english = results.filter { $0.original_language == "en" }.map { kind == .top_rated ? $0.listItemWithVotes : $0.listItem }

        if english.count > 0 {
            let section = ItemSection(header: "tv\(Tmdb.separator)English\(Tmdb.separator)\(kind.tv?.title ?? "")", items: english)
            sections.append(section)
        }

        let notEnglish = results.filter { $0.original_language != "en" }.map { kind == .top_rated ? $0.listItemWithVotes : $0.listItem }
        if notEnglish.count > 0 {
            let section = ItemSection(header: "tv\(Tmdb.separator)Not English\(Tmdb.separator)\(kind.tv?.title ?? "")", items: notEnglish)
            sections.append(section)
        }

        if kind == .top_rated {
            let lessVotes = tv.results.filter { $0.vote_count < (voteLimit + 1) }.map { $0.listItemWithVotes }
            if !lessVotes.isEmpty {
                let section = ItemSection(header: "tv\(Tmdb.separator)also top rated", items: lessVotes)
                sections.append(section)
            }
        }

        guard sections.count > 0 else { return nil }

        return sections
    }

}
