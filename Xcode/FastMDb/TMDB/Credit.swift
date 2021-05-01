//
//  Credit.swift
//
//  Created by Daniel on 10/10/19.
//  Copyright © 2019 dkhamsing. All rights reserved.
//

import Foundation
import UIKit

struct Credit: Codable {
    var id: Int?
    var credit_id: String?

    var name: String?
    var original_name: String?

    var title: String?
    var original_title: String?

    var poster_path: String?
    var profile_path: String?

    var episode_count: Int?
    var first_air_date: String?

    var known_for_department: String?
    var known_for: [Media]?

    var movie_credits: Credits?
    var tv_credits: Credits?

    var vote_average: Double?
    var vote_count: Int?

    var biography: String?
    var birthday: String?
    var place_of_birth: String?
    var character: String?
    var deathday: String?
    var external_ids: ExternalIds?
    var genre_ids: [Int]?
    var original_language: String?
    var popularity: Double?
    var release_date: String?

    var images: Images?
    var tagged_images: ImageSearch?

    // Crew
    var job: String?

    // Aggregate Credits
    var roles: [Role]?
}

struct TaggedMedia: Codable {
    var media: Media
    var media_type: String
}

extension TaggedMedia {
    var destination: Destination? {
        switch media_type {
        case "movie":
            return .movie
        case "tv":
            return .tv
        default:
            print("not implemented yet for \(media_type)")
            return nil
        }
    }
}

struct Role: Codable {
    var character: String?
    var episode_count: Int?
}

extension Credit {

    var aggregatedRole: String? {
        guard let roles = roles else { return nil }

        let role = roles.first { (role) -> Bool in
            !(role.character ?? "").isEmpty
        }

        return role?.character
    }

    var aggregated: [String] {

        if roles?.count == 1,
           let first = roles?.first {
            var strings: [String] = []

            let name = first.character ?? ""
            if !name.isEmpty {
                strings.append(name)
            }

            if let count = first.episode_count,
               count > 0 {
                strings.append("\(count) episode\(count.pluralized)")
            }

            return strings
        } else if let roles = roles,
                  roles.count > 1 {
            let count = roles
                .map { $0.episode_count ?? 0 }
                .reduce(0, +)

            var role = "\(roles.count) roles"
            if let agRole = aggregatedRole {
                let oneLess = roles.count - 1
                role = "\(agRole) and \(oneLess) other role\(oneLess.pluralized)"
            }

            return [
                role,
                "\(count) episode\(count.pluralized)"
            ]
        }

        return []
    }

    var initials: String? {
        guard let name = name?.split(separator: " "),
              let first = name.first else { return nil }

        var text = String(first.prefix(1))

        if name.indices.contains(1) {
            let last = name[1]
            text = text + String(last.prefix(1))
        }

        return text
    }

    var taggedImageSection: ItemSection? {
        guard let results = tagged_images?.results,
              results.count > 0 else { return nil }

        let items: [Item] = results
            .filter { $0.media.backdrop_path ?? "" != "" }
            .map { item in
            let url = Tmdb.backdropImageUrl(path: item.media.backdrop_path, size: .original)
            let imageUrl = Tmdb.backdropImageUrl(path: item.media.backdrop_path, size: .medium)
            return Item(
                title: item.media.titleDisplay,
                metadata: Metadata(
                    id: item.media.id,
                    url: url,
                    destination: .safarivc,
                    imageUrl:imageUrl))
        }

        var unique: [Item] = []
        for item in items {
            if !unique.contains(item) {
                unique.append(item)
            }
        }

        return ItemSection(items: unique, metadata: Metadata(display: .thumbnailImage))
    }

    var listItemCast: Item {
        let url = Tmdb.castProfileUrl(path: profile_path, size: .medium)
        return Item(title: titleDisplay, subtitle: character,
                    metadata: Metadata(id: id, destination: .person, imageUrl: url, imageCenterText: initials))
    }

    var listItemCastAggregated: Item {
        var sub: [String] = []
        if let value = titleDisplay {
            sub.append(value)
        }
        sub.append(contentsOf: aggregated)

        let url = Tmdb.castProfileUrl(path: profile_path, size: .medium)
        return Item(title: name, metadata: Metadata(id: id, destination: .person, imageUrl: url, imageCenterText: initials, strings: sub))
    }

    var listItemCrew: Item {
        return Item(title: name, subtitle: job, metadata: Metadata(id: id, destination: .person))
    }

    var listItemTv: Item? {
        return listItemTv()
    }

    func listItemTv(isImage: Bool = false) -> Item? {
        var sub: [String] = []

        if first_air_date.yearDisplay != "" {
            sub.append(first_air_date.yearDisplay)
        }

        if
            let country = original_language,
            country != "en",
            let lang = Languages.List[country] {
            sub.append(lang)
        }

        if let c = character, c != "" {
            sub.append(c)
        }

        if let episodes = episode_count,
           episodes > 0 {
            let epString = "\(episodes) episode\(episodes > 1 ? "s" : "")"
            sub.append(epString)
        }

        var sub2 = sub
        if let value = titleDisplay {
            sub2.insert(value, at: 0)
        }

        var imageUrl: URL?
        if isImage {
            if let url = Tmdb.mediaPosterUrl(path: poster_path, size: .medium) {
                imageUrl = url
            } else {
                return nil
            }
        }

        return Item(title: titleDisplay, subtitle: sub.joined(separator: Tmdb.separator), color: ratingColor, 
                    metadata: Metadata(id: id, identifier: credit_id, destination: .tvCredit, imageUrl: imageUrl, strings: sub2)
        )
    }

    var ratingColor: UIColor? {
        guard
            let c = vote_count,
            c > Tmdb.voteThreshold else { return nil }

        return vote_average?.color
    }

    var releaseYear: String? {
        guard release_date.yearDisplay != "" else { return nil }

        return release_date.yearDisplay
    }

    var titleDisplay: String? {
        var t = "\(title ?? name ?? "")"
        if title != original_title {
            t.append(" (")
            t.append(original_title ?? "")
            t.append(")")
        }

        return t
    }

}
