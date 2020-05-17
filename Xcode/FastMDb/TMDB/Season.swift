//
//  Season.swift
//
//  Created by Daniel on 5/14/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

struct Season: Codable {
    var id: Int

    var air_date: String?
    var credits: Credits?
    var episode_count: Int?
    var episodes: [Episode]?
    var name: String
    var overview: String?
    var poster_path: String?
    var season_number: Int 
}
