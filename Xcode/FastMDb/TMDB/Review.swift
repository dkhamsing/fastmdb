//
//  Review.swift
//  FastMDb
//
//  Created by Daniel on 12/24/20.
//  Copyright © 2020 dk. All rights reserved.
//

struct Review: Codable {
    var author, content: String
    var author_details: Author
}

struct Author: Codable {
    var rating: Double?
}
