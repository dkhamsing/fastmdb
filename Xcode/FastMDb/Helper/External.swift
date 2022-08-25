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

    static func awardsUrl(id: String?, kind: Kind) -> URL? {
        guard var path = path(id: id, kind: kind) else { return nil }

        path += "/awards"
        return URL(string: path)
    }

    static func companyUrl(id: String?, kind: Kind) -> URL? {
        guard var path = path(id: id, kind: kind) else { return nil }

        path += "/companycredits"
        return URL(string: path)
    }

    static func soundtrackUrl(id: String?, kind: Kind) -> URL? {
        guard var path = path(id: id, kind: kind) else { return nil }

        path += "/soundtrack"
        return URL(string: path)
    }

    static func url(id: String?, kind: Kind) -> URL? {
        guard let path = path(id: id, kind: kind) else { return nil }

        return URL(string: path)
    }
}

private extension Imdb {
    static func path(id: String?, kind: Kind) -> String? {
        guard let id = id else { return nil }

        return "https://www.imdb.com/\(kind.rawValue)/\(id)"
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
