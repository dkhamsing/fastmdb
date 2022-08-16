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

    // Display 10272 as 10,272
    static var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0

        return formatter
    }

    struct Vote {
        var voteCount: Int
        var voteAverage: Double?
        var threshold: Int = Constant.voteThreshold

        var ratingDisplay: String? {
            guard let voteAverage = voteAverage,
                  voteCount > threshold else { return nil }

            return "\(String(format: "%.2f", voteAverage))/10"
        }

        var voteDisplay: String? {
            guard voteCount > threshold else { return nil }

            let number = NSNumber(value: voteCount)
            guard let formattedValue = Constant.numberFormatter.string(from: number) else { return nil }

            return "\(formattedValue) votes"
        }
    }

}
