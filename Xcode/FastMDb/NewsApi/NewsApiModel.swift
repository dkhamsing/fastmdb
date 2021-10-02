//
//  NewsApiModel.swift
//
//  Created by Daniel on 4/23/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

struct Headline: Codable {

    var articles: [Article]

}

struct Article: Codable {

    var author: String?
    var title: String?
    var description: String?
    var content: String?
    var url: String?
    var urlToImage: String?
    var publishedAt: Date?
    var source: Source?

}

extension Article: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }

}

extension Article: Equatable {

    static func == (lhs: Article, rhs: Article) -> Bool {
        return lhs.title == rhs.title
    }
}

struct Source: Codable {

    var name: String?

}

extension Article {

    var descriptionOrContent: String? {
        return description ?? content
    }

    var identifier: String? {
        return url
    }

    var urlToSourceLogo: String {
        guard let url = url,
              let u = URL(string: url),
              let host = u.host else { return "" }

        return "https://logo.clearbit.com/\(host)"
    }

    var safeTitle: String {
        return title ?? ""
    }

    var safeTitleNoSource: String {
        let tns = safeTitle

        let list = tns.components(separatedBy: " - ")
        return list.first ?? ""
    }

    var safeDescription: String {
        return descriptionOrContent ?? ""
    }

}

enum NewsCategory: String, CaseIterable, Codable {

    case General
    case Business
    case Entertainment
    case Health
    case Science
    case Sports
    case Technology

}
