//
//  Network.swift
//
//  Created by Daniel on 5/14/20.
//  Copyright © 2020 dk. All rights reserved.
//

extension Tmdb {
    struct Network: Codable {
        var name: String?
        var id: Int
        var origin_country: String?
    }
}
