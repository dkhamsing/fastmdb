//
//  Section+Production.swift
//  FastMDb
//
//  Created by Daniel on 5/14/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

extension MediaSearch {

    var productionSections: [Section]? {
        var sections: [Section] = []

        if let section = upcoming {
            sections.append(section)
        }

        if let section = released {
            sections.append(section)
        }

        return sections
    }

}

private extension MediaSearch {

    var upcomingMovies: [Media] {
        let upcoming = results
            .filter {
                let noReleaseDate = $0.release_date == nil || $0.release_date == ""

                var releaseDateInFuture = false
                if let inFuture = $0.release_date?.inFuture,
                    inFuture == true {
                    releaseDateInFuture = true
                }

                return releaseDateInFuture || noReleaseDate
        }
        .sorted { $0.release_date ?? "" > $1.release_date ?? "" }

        return upcoming
    }

    var upcoming: Section? {
        let u = upcomingMovies

        guard u.count > 0 else { return nil }

        return Section(header: "movies upcoming", items: u.map { $0.listItem})
    }

    var released: Section? {
        let titles = upcomingMovies.compactMap { $0.title }

        let released = results
            .filter { titles.contains($0.title ?? "") == false }
            .sorted { $0.release_date ?? "" > $1.release_date ?? "" }

        return Section(header: "movies released", items: released.map { $0.listItem})
    }

}

extension TvSearch {

    var productionSections: [Section]? {
        let s = TV.networkSections(results)
        return s
    }

}
