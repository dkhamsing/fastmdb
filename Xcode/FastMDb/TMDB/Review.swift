//
//  Review.swift
//  FastMDb
//
//  Created by Daniel on 12/24/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

struct Review: Codable {
    var author, content: String
    var author_details: Author
}

struct Author: Codable {
    var rating: Double?
}

extension Review {
    var listItem: Item {
        var sub: [String] = []

        if let rating = author_details.rating {
            sub.append("\(rating)/10")
        }

        sub.append(author)

        return Item(title: content, subtitle: sub.joined(separator: Tmdb.separator))
    }
}
