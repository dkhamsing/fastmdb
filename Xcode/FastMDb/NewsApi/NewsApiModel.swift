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
    var url: URL?
    var urlToImage: String?
    var publishedAt: Date?
    var source: Source?
}

struct Source: Codable {
    var name: String?
}

extension Article {
    var identifier: String? {
        return url?.absoluteString ?? urlToImage
    }

    var urlToSourceLogo: String {
        guard let host = url?.host else { return "" }

        return "https://logo.clearbit.com/\(host)"
    }

    var validDescription: String? {
        let d = descriptionOrContent
        guard d != "" else { return nil }

        return d
    }
}

private extension Article {
    var descriptionOrContent: String? {
        return description ?? content
    }
}

enum NewsCategory: String, CaseIterable, Codable {
    case general
    case business
    case entertainment
    case health
    case science
    case sports
    case technology
}
