//
//  Extensions.swift
//
//  Created by Daniel on 5/5/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    func yearDifferenceWithDate(_ date: Date?) -> Int? {
        guard let date = date else { return nil }

        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .year, for: date) else { return nil }

        let components = calendar.dateComponents([.year], from: self, to: interval.end)

        return components.year
    }
}

extension Double {

    var color: UIColor {
        switch self {
        case 0...4:
            return UIColor.systemRed

        case 4...7:
            return UIColor.appYellow

        case 7...10:
            return UIColor.systemGreen

        default:
            return .clear
        }
    }

}

extension UIColor {
    static var appYellow: UIColor {
        return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
            if UITraitCollection.userInterfaceStyle == .dark {

                return UIColor(red: 0.952941, green: 0.776471, blue: 0.137255, alpha: 1)
            } else {
                return UIColor(red: 0.964706, green: 0.843137, blue: 0.262745, alpha: 1)
            }
        }
    }
}

//extension UIColor {
//
//    static func hexStringToUIColor (hex:String) -> UIColor {
//        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
//
//        if (cString.hasPrefix("#")) {
//            cString.remove(at: cString.startIndex)
//        }
//
//        if ((cString.count) != 6) {
//            return UIColor.gray
//        }
//
//        var rgbValue:UInt64 = 0
//        Scanner(string: cString).scanHexInt64(&rgbValue)
//
//        let c = UIColor(
//            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
//            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
//            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
//            alpha: CGFloat(1.0)
//        )
//
//        return c
//    }
//
//}

extension Int {
    var pluralized: String {
        return self == 1 ? "" : "s"
    }
}

extension String {

    static func allCreditsText(_ count: Int? = nil) -> String {
        if let count = count {
            return "See all \(count) credits"
        }

        return "Seel all credits"
    }
    
    var dateDisplay: String? {
        let formatter = Tmdb.dateFormatter

        guard let date = formatter.date(from: self) else { return nil }

        formatter.dateFormat = "MMM d, yyyy"

        return formatter.string(from: date)
    }

    var justWatchUrl: URL? {
        let baseUrl = "https://www.justwatch.com/us/search?q="
        let item = self.replacingOccurrences(of: " ", with: "+")

        return URL(string: "\(baseUrl)\(item)")
    }

    var wikipediaUrl: URL? {
        let baseUrl = "https://en.wikipedia.org/wiki"
        let item = self.replacingOccurrences(of: " ", with: "_")
        
        return URL(string: "\(baseUrl)/\(item)")
    }

}

extension Optional where Wrapped == String {

    var yearDisplay: String {
        guard
            let date = self,
            let index = date.firstIndex(of: "-") else { return "" }

        return String(date[..<index])
    }

}

/// Credits: https://www.avanderlee.com/swift/unique-values-removing-duplicates-array/
extension Sequence where Iterator.Element: Hashable {

    var unique: [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }

}
