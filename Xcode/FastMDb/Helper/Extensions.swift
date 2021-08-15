//
//  Extensions.swift
//
//  Created by Daniel on 5/5/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation
import UIKit

extension Article {

    static func newsSection(_ articles: [Article]?, limit: Int = 2) -> ItemSection? {
        guard
            let articles = articles,
            articles.count > 0 else { return nil }

        let items = articles.map { $0.listItem(hasTimeAgo: true) }
        let latest = Array(items.prefix(limit))

        var footer: String?
        if items.count > limit {
            footer = "See all news"
        }

        let sec = sectionsGroupedByTime(articles)

        return ItemSection(header: "news", items: latest, footer: footer,
                           metadata: Metadata(destination: .sections, destinationTitle: "News", sections: sec))
    }

}

private extension Article {

    static func sectionsGroupedByTime(_ articles: [Article]?) -> [ItemSection] {
        let sorted = articles?.sorted { $0.publishedAt ?? Date() > $1.publishedAt ?? Date() }
        guard let headers = sorted?.compactMap({ $0.relativeTimeAgo }) else { return [] }

        var sec: [ItemSection] = []
        for header in headers.unique {
            let items = articles?.filter { $0.relativeTimeAgo == header }.map { $0.listItem() }
            sec.append(
                ItemSection(header: header, items: items)
            )
        }

        return sec
    }

    func listItem(hasTimeAgo: Bool = false) -> Item {
        var strings: [String] = []
        if hasTimeAgo,
           let ago = publishedAt?.shortTimeAgoSinceDate {
            strings.append(ago)
        }
        strings.append(contentsOf: sub)

        var met: Metadata?
        if let string = url,
           let url = URL(string: string) {
            met = Metadata(url: url, destination: .url)
        }

        let item = Item(title: titleDisplay, subtitle: strings.joined(separator: Tmdb.separator),
                        metadata: met)

        return item
    }

    var relativeTimeAgo: String? {
        guard let p = publishedAt else { return nil }

        let rdf = RelativeDateTimeFormatter()
        return rdf.localizedString(for: p, relativeTo: Date())
    }

    var sub: [String] {
        var sub: [String] = []
        if let source = source?.name {
            sub.append(source)
        }
        if let desc = descriptionOrContent {
            sub.append(desc)
        }

        return sub
    }

    var titleDisplay: String? {
        return title?
            .filterOutStringAfter(" | ")?
            .filterOutStringAfter(" - ")
    }
}

private extension String {

    func filterOutStringAfter(_ string: String) -> String? {
        let handleDupe = filterOutDuplicateCredits(string)

        let components = handleDupe?.components(separatedBy: string)

        guard components?.count == 2 else { return handleDupe }

        return components?.first
    }

    func filterOutDuplicateCredits(_ string: String) -> String? {
        let components = self.components(separatedBy: string)

        if
            components.count == 3,
            components[1] == components[2] {
            return components.first
        }

        return self
    }

}

extension Date {

    var shortTimeAgoSinceDate: String {
        // From Time
        let fromDate = self

        // To Time
        let toDate = Date()

        // Estimation
        // Year
        if let interval = Calendar.current.dateComponents([.year], from: fromDate, to: toDate).year, interval > 0  {

            return "\(interval)y"
        }

        // Month
        if let interval = Calendar.current.dateComponents([.month], from: fromDate, to: toDate).month, interval > 0  {

            return "\(interval)mo"
        }

        // Day
        if let interval = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day, interval > 0  {

            return "\(interval)d"
        }

        // Hours
        if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: toDate).hour, interval > 0 {

            return "\(interval)h"
        }

        // Minute
        if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: toDate).minute, interval > 0 {

            return "\(interval)m"
        }

        return "a moment ago"
    }

    func yearDifferenceWithDate(_ date: Date?) -> Int? {
        guard let date = date else { return nil }

        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .day, for: date) else { return nil }

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

extension Int {
    var pluralized: String {
        return self == 1 ? "" : "s"
    }
}

extension NewsApi {
    static func getArticles(url: URL?, completion: @escaping ([Article]?) -> Void) {
        url?.get(completion: { (result: Result<Headline, ApiError>) in
            switch result {
            case .success(let headline):
                completion(headline.articles)
            case .failure(_):
                completion(nil)
            }
        })
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

extension String {

    static func allCreditsText(_ count: Int? = nil) -> String {
        if let count = count {
            return "See all \(count) credits"
        }

        return "Seel all credits"
    }

    var boxOfficeMojoUrl: URL? {
        let baseUrl = "https://www.boxofficemojo.com/search/?q="
        guard let item = self.addingPercentEncoding else { return nil }

        return URL(string: "\(baseUrl)\(item)")
    }

    var date: Date? {
        let formatter = Tmdb.dateFormatter

        return formatter.date(from: self)
    }
    
    var dateDisplay: String? {
        let formatter = Tmdb.dateFormatter

        guard let date = self.date  else { return nil }

        formatter.dateFormat = "MMM d, yyyy"

        return formatter.string(from: date)
    }

    var inFuture: Bool {
        guard let date = self.date else { return false }

        let interval = date.timeIntervalSince(Date())

        return interval > 0
    }

    var validStatus: String? {
        switch self {
        case
        "Canceled",
        "In Production",
        "Planned",
        "Post Production",
        "Rumored":
            return self
        default:
//            print("status = \(self)")
            break
        }
        return nil
    }

    static func googleSearchUrlWithQuery(_ query: String) -> URL? {
        let baseUrl = "https://www.google.com/search?q="
        guard let item = query.addingPercentEncoding else { return nil }

        return URL(string: "\(baseUrl)\(item)")
    }

    var googleSearchAwardsUrl: URL? {
        return String.googleSearchUrlWithQuery("\(self) awards nominations")
    }

    var googleSearchMusicUrl: URL? { 
        return String.googleSearchUrlWithQuery("music \(self)")
    }

    var googleSearchWatchUrl: URL? {
        return String.googleSearchUrlWithQuery("watch \(self)")
    }

    var itunesMusicSearchUrl: URL? {
        return iTunes.songSearchUrl(self)
    }

    var letterboxdUrl: URL? {
        let baseUrl = "https://letterboxd.com/search/"
        guard let item = self.addingPercentEncoding else { return nil }

        return URL(string: "\(baseUrl)\(item)")
    }

    var rottenTomatoestUrl: URL? {
        let baseUrl = "https://www.rottentomatoes.com/search?search="
        guard let item = self.addingPercentEncoding else { return nil }

        return URL(string: "\(baseUrl)\(item)")
    }

    var wikipediaUrl: URL? {
        let baseUrl = "https://en.wikipedia.org/wiki"
        guard let item = self.replacingOccurrences(of: " ", with: "_").addingPercentEncoding else { return nil }
        
        return URL(string: "\(baseUrl)/\(item)")
    }

}

private extension String {

    var addingPercentEncoding: String? {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    }
    
}

/// Credits: https://www.avanderlee.com/swift/unique-values-removing-duplicates-array/
extension Sequence where Iterator.Element: Hashable {

    var unique: [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }

}

extension UIColor {

    static var background: UIColor {
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return .black
            } else {
                return .secondarySystemBackground
            }
        }
    }

    static var cellBackground: UIColor {
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return .systemFill
            } else {
                return .white
            }
        }
    }

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

extension URL {

    var urlToSourceLogo: URL? {
        guard let host = self.host else { return nil }

        return URL(string: "https://logo.clearbit.com/\(host)?greyscale=true")
    }

}
