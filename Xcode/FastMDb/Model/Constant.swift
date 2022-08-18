//
//  Constant.swift
//  FastMDb
//
//  Created by Daniel on 9/26/21.
//  Copyright © 2021 dk. All rights reserved.
//

import Foundation
import UIKit

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
        var count: Int
        var average: Double?
        var threshold: Int = Constant.voteThreshold

        var ratingDisplay: String? {
            guard let voteAverage = average,
                  count > threshold else { return nil }

            return "\(String(format: "%.1f", voteAverage))/10"
        }

        var ratingDisplayAttributed: NSAttributedString? {
            guard let voteAverage = average,
                  count > threshold else { return nil }

            let attributed = NSMutableAttributedString(string: (String(format: "%.1f", voteAverage)))
            let attr: NSAttributedString = NSAttributedString(string: "/10",
                                                              attributes: [.foregroundColor : UIColor.secondaryLabel])
            attributed.append(attr)

            return attributed
        }

        var voteDisplay: String? {
            guard count > threshold else { return nil }

            let number = NSNumber(value: count)
            guard let formattedValue = Constant.numberFormatter.string(from: number) else { return nil }

            return "\(formattedValue) votes"
        }
    }

}
