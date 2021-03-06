//
//  Video.swift
//
//  Created by Daniel on 5/14/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

struct Video: Codable {
    var key: String
    var name: String
    var site: String
    var type: String
}

extension Video {
    var listItem: Item {
        let sub = [site, type]
        return Item(title: name, subtitle: sub.joined(separator: Tmdb.separator), url: url, destination: .url, image: Item.videoImage)
    }

    var url: URL? {
        guard site.lowercased() == "youtube" else { return nil }

        let baseUrl = YouTube.urlBase
        let url = URL(string: "\(baseUrl)/\(key)")

        return url
    }
}
