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

        private enum CodingKeys: String, CodingKey {
            case artistName, name, trackName, artworkUrl100, trackViewUrl, releaseDate
        }
    }
}

extension iTunes {
    static func songSearchUrl(_ query: String) -> URL? {
        let string = "https://itunes.apple.com/search?media=music&attribute=albumTerm&country=us&term=\(query.replacingOccurrences(of: " ", with: "+"))"
        let url = URL(string: string)

        return url
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

    var title: String {
        let string = (name ?? trackName ?? "") + " by " + artistName + " - \(releaseDisplay)"

        return string
    }
}
