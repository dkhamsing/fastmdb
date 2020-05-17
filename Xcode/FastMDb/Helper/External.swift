//
//  External.swift
//
//  Created by Daniel on 5/11/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

struct Imdb {
    enum Kind: String {
        case person = "name"
        case title = "title"
    }

    static func url(id: String?, kind: Kind) -> URL? {
        guard let id = id else { return nil }

        return URL(string: "https://www.imdb.com/\(kind.rawValue)/\(id)")
    }
}

struct Instagram {
    static func url(_ id: String?) -> URL? {
        guard let id = id else { return nil }

        return URL(string: "https://www.instagram.com/\(id)")
    }
}

struct Map {
    static let urlBase = "http://maps.apple.com/?q="
}

struct Twitter {
    static func url(_ id: String?) -> URL? {
        guard let id = id else { return nil }

        return URL(string: "https://twitter.com/\(id)")
    }

    static func username(_ id: String?) -> String? {
        guard let id = id else { return nil }

        guard id.contains("@") == false else { return id }

        return "@\(id)"
    }
}

struct YouTube {
    static let urlBase = "https://www.youtube.com/watch"
}
