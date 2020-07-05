//
//  Section+Network.swift
//  FastMDb
//
//  Created by Daniel on 6/15/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

extension TV {

    static func networkSections(_ list: [TV]) -> [ItemSection] {
        var sections: [ItemSection] = []

        if let section = tvUpcomingSection(list) {
            sections.append(section)
        }

        if let s = tvYearSections(list) {
            sections.append(contentsOf: s)
        }

        return sections
    }

}

private extension TV {

    static func tvUpcomingSection(_ list: [TV]) -> ItemSection? {
        let upcoming = list
            .filter {
                let noRelease = $0.first_air_date ?? "" == ""
                let inFuture = $0.first_air_date?.inFuture == true

                return noRelease || inFuture
        }
        .sorted { $0.first_air_date ?? "" > $1.first_air_date ?? "" }
        .map { $0.listItem }
        guard upcoming.count > 0 else { return nil }

        return ItemSection(header: "tv upcoming", items:upcoming)
    }

    static func tvYearSections(_ list: [TV]) -> [ItemSection]? {
        var sections: [ItemSection] = []

        let currentByYear = list
            .filter { $0.first_air_date ?? "" != "" }
            .filter { $0.first_air_date?.inFuture == false }
            .sorted { $0.first_air_date ?? "" > $1.first_air_date ?? "" }

        let years = currentByYear.map { $0.first_air_date.yearDisplay }.unique
        for year in years {
            if let section = tvSection(list: currentByYear, year: year) {
                sections.append(section)
            }
        }

        guard sections.count > 0 else { return nil }

        return sections
    }

}

private extension TV {

    static func tvSection(list: [TV], year: String) -> ItemSection? {
        let sublist = list.filter { $0.first_air_date.yearDisplay == year }
        let items = sublist.map { $0.listItemWithoutYear }

        guard items.count > 0 else { return nil }

        return ItemSection(header: year, items: items)
    }

}
