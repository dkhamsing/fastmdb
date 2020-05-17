//
//  Section+Production.swift
//  FastMDb
//
//  Created by Daniel on 5/14/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

extension MediaSearch {
    var productionSection: Section? {
        let items = results
            .sorted { $0.release_date ?? "" > $1.release_date ?? "" }
            .map { $0.listItem }

        guard items.count > 0 else { return nil }

        return Section(header: "movies", items: items)
    }
}

extension TvSearch {
    var productionSection: Section? {
        let items = results.map { $0.listItem }

        guard items.count > 0 else { return nil }

        return Section(header: "tv", items: items)
    }
}
