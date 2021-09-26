//
//  Constant.swift
//  FastMDb
//
//  Created by Daniel on 9/26/21.
//  Copyright © 2021 dk. All rights reserved.
//

import Foundation

struct Constant {

    static let separator = " · "
    static let voteThreshold = 10

    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        return formatter
    }

}
