//
//  Section+Search.swift
//
//  Created by Daniel on 5/9/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

// TODO: have tappable footers to show single list of results when more than what is displayed + later on allow paging
extension Section {
    static func searchSection(_ movie: MediaSearch?, _ tv: TvSearch?, _ people: PeopleSearch?, _ articles: [Article]?) -> [Section] {
        var sections: [Section] = []

        if let articles = articles {
            let items = articles.map { $0.listItem }
            if items.count > 0 {
                let section = Article.section(items)
                sections.append(section)
            }
        }

        if let section = movie?.section {
            sections.append(section)
        }

        if let section = tv?.section {
            sections.append(section)
        }

        if let section = people?.section {
            sections.append(section)
        }

        if sections.count == 0 {
            sections.append(Section.noResultsSection)
        }

        return sections
    }
}

private extension MediaSearch {
    var section: Section? {
        let items = results.map { $0.listItem }

        guard items.count > 0 else { return nil }

        let count = total_results

        return Section(header: "Movies (\(count))", items: items)
    }
}

private extension PeopleSearch {
    var section: Section? {
        let items = self.results.map { $0.listItemSearch }

        guard items.count > 0 else { return nil }

        let count = self.total_results

        return Section(header: "People (\(count))", items: items)
    }
}

private extension Section {
    static var noResultsSection: Section {
        let item = Item(title: "Nothing found for your search 😅")
        let section = Section(header: "Results", items: [item])

        return section
    }
}

private extension TvSearch {
    var section: Section? {
        let items = results.map { $0.listItem }

        guard items.count > 0 else { return nil }

        let count = total_results

        return Section(header: "TV (\(count))", items: items)
    }
}

private extension Credit {
    var listItemSearch: Item {
        var sub: [String] = []

        if let dept = known_for_department {
            sub.append(dept)
        }

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
