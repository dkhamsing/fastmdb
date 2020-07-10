//
//  iTunes.swift
//
//  Created by Daniel on 7/4/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

struct iTunes {
    struct Response: Codable {
        var feed: Feed
    }

    struct Feed: Codable {
        var results: [Song]
    }

    struct Song: Codable, Identifiable {
        let id = UUID()

        var artistName: String
        var artworkUrl100: URL

        // feed
        var name: String?

        // search
        var trackName: String?

        var trackViewUrl: URL
        var releaseDate: Date
        var collectionName: String
        var primaryGenreName: String

        private enum CodingKeys: String, CodingKey {
            case artistName, name, trackName, artworkUrl100, trackViewUrl, releaseDate, collectionName, primaryGenreName
        }
    }
}

extension iTunes {
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return decoder
    }

    static func songSearchUrl(_ query: String) -> URL? {
        let url = searchUrl(query: query, limit: 50, media: "music", attribute: "albumTerm")
        return url
    }

    static func searchUrl(query: String, country: String = "us", limit: Int = 100, media: String?, attribute: String?) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "itunes.apple.com"
        components.path = "/search"

        var queryItems = [
            URLQueryItem(name: "term", value: query),
            URLQueryItem(name: "country", value: country),
            URLQueryItem(name: "limit", value: "\(limit)"),
        ]

        if let attribute = attribute {
            queryItems.append(
                URLQueryItem(name: "attribute", value: attribute)
            )
        }

        if let media = media {
            queryItems.append(
                URLQueryItem(name: "media", value: media)
            )
        }

        components.queryItems = queryItems

        return components.url
    }

//    static var topSongsUrl: URL? {
//        let string = "https://rss.itunes.apple.com/api/v1/us/apple-music/top-songs/all/100/explicit.json"
//        let url = URL(string: string)
//
//        return url
//    }
}

extension iTunes.Song {
    var releaseDisplay: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy"

        return df.string(from: releaseDate)
    }

//    var title: String {
//        let string = (name ?? trackName ?? "") + " by " + artistName + " - \(releaseDisplay)"
//
//        return string
//    }
}
