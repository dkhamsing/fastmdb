//
//  Section+Content.swift
//  FastMDb
//
//  Created by Daniel on 5/18/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

extension ItemSection {

    static func contentSections(kind: Tmdb.Url.Kind.Movies, movie: MediaSearch?, tv: TvSearch?, people: PeopleSearch?, articles: [Article]?, providers: [Provider]?) -> [ItemSection] {
        var sections: [ItemSection] = []

        if let s = Article.newsSection(articles, limit: 3) {
            sections.append(s)
        }

        if let people = people {
            let items = people.results.map { $0.listItemPopular }
            let section = ItemSection(header: "people\(Constant.separator)\(kind.title)", items: items,
                                      metadata: Metadata(display: .portraitImage()))
            sections.append(section)
        }

        if let s = movieSections(movie: movie, kind: kind) {
            sections.append(contentsOf: s)
        }

        if let s = tvSections(tv: tv, kind: kind) {
            sections.append(contentsOf: s)
        }

        if let s = providerSections(providers) {
            sections.append(contentsOf: s)
        }

        return sections
    }

}

private extension ItemSection {

    static func movieSections(movie: MediaSearch?, kind: Tmdb.Url.Kind.Movies) -> [ItemSection]? {
        guard let movie = movie else { return nil }

        var sections: [ItemSection] = []

        var results = movie.results

        let voteLimit = 5000

        switch kind {
        case .top_rated:
            results = results.filter { $0.vote_count ?? 0 > voteLimit }
        case .upcoming:
            results = results.sorted { $0.release_date ?? "" > $1.release_date ?? "" }
        default:
            break
        }

        let language: [Item] = results
            .filter { $0.original_language == Tmdb.language }
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

        let languageDisplay = Languages.List[Tmdb.language] ?? ""
        if language.count > 0 {
            let section = ItemSection(header: "movies\(Constant.separator)\(languageDisplay)\(Constant.separator)\(kind.title)", items: language, metadata: Metadata(display: .textImage()))
            sections.append(section)
        }

        let notLanguage = results.filter { $0.original_language != Tmdb.language }.map { kind == .top_rated ? $0.listItemWithVotes : $0.listItem }
        if notLanguage.count > 0 {
            let section = ItemSection(header: "movies\(Constant.separator)Not \(languageDisplay)\(Constant.separator)\(kind.title)", items: notLanguage)
            sections.append(section)
        }

        if kind == .top_rated {
            let lessVotes = movie.results.filter { $0.vote_count ?? 0 < (voteLimit + 1) }.map { $0.listItemWithVotes }
            if !lessVotes.isEmpty {
                let section = ItemSection(header: "movies\(Constant.separator)also top rated", items: lessVotes)
                sections.append(section)
            }
        }

        guard sections.count > 0 else { return nil }

        return sections
    }

    static func providerSections(_ providers: [Provider]?) -> [ItemSection]? {
        guard let providers = providers else { return nil }

        var sections: [ItemSection] = []
        let items = providers.compactMap { $0.listItem }
        sections.append(
            ItemSection(header: "Stream", items: items)
        )
        return sections
    }

    static func tvSections(tv: TvSearch?, kind: Tmdb.Url.Kind.Movies) -> [ItemSection]? {
        guard let tv = tv else { return nil }

        var sections: [ItemSection] = []

        var results = tv.results

        let voteLimit = 1000

        if kind == .top_rated {
            results = results.filter { $0.vote_count > voteLimit }
        }

        let language = results.filter { $0.original_language == Tmdb.language }.map { kind == .top_rated ? $0.listItemWithVotes : $0.listItem }

        let languageDisplay = Languages.List[Tmdb.language] ?? ""
        if language.count > 0 {
            let section = ItemSection(header: "tv\(Constant.separator)\(languageDisplay)\(Constant.separator)\(kind.tv?.title ?? "")", items: language)
            sections.append(section)
        }

        let notLanguage = results.filter { $0.original_language != Tmdb.language }.map { kind == .top_rated ? $0.listItemWithVotes : $0.listItem }
        if notLanguage.count > 0 {
            let section = ItemSection(header: "tv\(Constant.separator)Not \(languageDisplay)\(Constant.separator)\(kind.tv?.title ?? "")", items: notLanguage)
            sections.append(section)
        }

        if kind == .top_rated {
            let lessVotes = tv.results.filter { $0.vote_count < (voteLimit + 1) }.map { $0.listItemWithVotes }
            if !lessVotes.isEmpty {
                let section = ItemSection(header: "tv\(Constant.separator)also top rated", items: lessVotes)
                sections.append(section)
            }
        }

        guard sections.count > 0 else { return nil }

        return sections
    }

}
extension Provider {
    var listItem: Item? {
        if WatchSearch.providersNotInterested.contains(provider_name.lowercased()) { return nil }

        if provider_name.lowercased().contains("amazon channel") ||
            provider_name.lowercased().contains("apple tv channel") ||
            provider_name.lowercased().contains("roku premium")  {
            return nil
        }

        return .init(title: provider_name,
                     metadata: .init(id: provider_id, destination: .provider, destinationTitle: provider_name)
        )
    }
}
