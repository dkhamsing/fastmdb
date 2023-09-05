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
            guard count > 0 else {
                return NSAttributedString(string: "Unrated")
            }

            guard let voteAverage = average
//                  count > threshold
            else { return nil }

            let font = UIFont.preferredFont(forTextStyle: .title1)
            let attributed = NSMutableAttributedString(string: (String(format: "%.1f", voteAverage)),
                                                       attributes: [.font: font])
            attributed.append(
                NSAttributedString(string: "/10",
                                   attributes: [.foregroundColor: UIColor.secondaryLabel,
                                                .font: font])
            )

            return attributed
        }

        var voteDisplay: String? {
            guard count > 0 else { return nil }
//            guard count > threshold else { return nil }

            let number = NSNumber(value: count)
            guard let formattedValue = Constant.numberFormatter.string(from: number) else { return nil }

            return "\(formattedValue) vote" + (count == 1 ? "" : "s")
        }
    }

}
