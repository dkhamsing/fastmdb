//
//  Credits.swift
//
//  Created by Daniel on 10/10/19.
//  Copyright © 2019 dkhamsing. All rights reserved.
//

import Foundation

struct Credits: Codable {
    var cast: [Credit]
    var crew: [Credit]
}

extension Credits {

    func jobSection(_ jobs: [String], _ header: String) -> ItemSection? {
        let job = crew.filter { item in
            var condition: Bool = false
            for job in jobs {
                condition = condition || item.job == job
            }
            return condition
        }
        guard job.count > 0 else { return nil }

        let items = job.map { $0.listItemCrew }
        return ItemSection(header: header, items: items)
    }
    
}
