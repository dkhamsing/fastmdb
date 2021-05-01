//
//  Section+Search.swift
//
//  Created by Daniel on 5/9/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

// TODO: have tappable footers to show single list of results when more than what is displayed + later on allow paging
extension ItemSection {
    static func searchSection(_ movie: MediaSearch?, _ tv: TvSearch?, _ people: PeopleSearch?, _ articles: [Article]?) -> [ItemSection] {
        var sections: [ItemSection] = []

        if let section = Article.newsSection(articles) {
            sections.append(section)
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
            sections.append(ItemSection.noResultsSection)
        }

        return sections
    }
}

private extension MediaSearch {
    var section: ItemSection? {
        let items = results.map { $0.listItem }

        guard items.count > 0 else { return nil }

        let count = total_results

        return ItemSection(header: "Movies (\(count))", items: items)
    }
}

private extension PeopleSearch {
    var section: ItemSection? {
        let items = self.results.map { $0.listItemSearch }

        guard items.count > 0 else { return nil }

        let count = self.total_results

        return ItemSection(header: "People (\(count))", items: items)
    }
}

private extension ItemSection {
    static var noResultsSection: ItemSection {
        let item = Item(title: "Nothing found for your search 😅")
        let section = ItemSection(header: "Results", items: [item])

        return section
    }
}

private extension TvSearch {
    var section: ItemSection? {
        let items = results.map { $0.listItem }

        guard items.count > 0 else { return nil }

        let count = total_results

        return ItemSection(header: "TV (\(count))", items: items)
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

        return Item(title: name, subtitle: sub.joined(separator: ": "), metadata: Metadata(id: id, destination: .person))
    }
}
