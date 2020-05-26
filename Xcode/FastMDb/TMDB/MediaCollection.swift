//
//  MediaCollection.swift
//
//  Created by Daniel on 5/6/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

struct MediaCollection: Codable {
    var id: Int

    var backdrop_path: String?
    var name: String
    var overview: String?
    var parts: [Media]?
//    var poster_path: String?
}
