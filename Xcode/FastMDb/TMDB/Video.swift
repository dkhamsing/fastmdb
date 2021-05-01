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
        return Item(title: name, subtitle: sub.joined(separator: Tmdb.separator),
                    metadata: Metadata(url: url, destination: .url, link: .video))
    }

    var url: URL? {
        switch site.lowercased() {
        case "youtube":
            let baseUrl = YouTube.urlBase
            let url = URL(string: "\(baseUrl)/\(key)")

            return url
        case "vimeo":
            let baseUrl = "https://vimeo.com/"
            let url = URL(string: "\(baseUrl)/\(key)")

            return url
        default:
            return nil
        }
    }
}
