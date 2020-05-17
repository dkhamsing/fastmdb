//
//  ExternalIds.swift
//
//  Created by Daniel on 5/11/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

struct ExternalIds: Codable {
    var imdb_id: String?
    var instagram_id: String?
    var twitter_id: String?
}

extension ExternalIds {
    var validInstagramId: String? {
        guard
            let id = instagram_id,
            id != "" else { return nil }

        return id
    }

    var validImdbId: String? {
        guard
            let id = imdb_id,
            id != "" else { return nil }
        
        return id
    }

    var validTwitterId: String? {
        guard
            let id = twitter_id,
            id != "" else { return nil }

        return id
    }
}
