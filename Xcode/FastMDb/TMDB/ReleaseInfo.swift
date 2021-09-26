//
//  ReleaseInfo.swift
//  FastMDb
//
//  Created by Daniel on 9/26/21.
//  Copyright © 2021 dk. All rights reserved.
//

struct ReleaseInfo: Codable {
    var iso_3166_1: String
    var release_dates: [Release]
}
