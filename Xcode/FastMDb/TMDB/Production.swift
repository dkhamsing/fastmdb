//
//  Production.swift
//
//  Created by Daniel on 5/14/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

struct Production: Codable {
    var id: Int
    var name: String
}

extension Production {
    var listItem: Item {
        return Item(id: id, title: name, destination: .production)
    }
}

struct ProductionCountry: Codable {
    var name: String
}
