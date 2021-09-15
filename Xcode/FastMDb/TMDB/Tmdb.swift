//
//  Tmdb.swift
//
//  Created by Daniel on 5/5/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit

private extension Tmdb {

    struct Constant {
        static let apiKey = "<GET API KEY>"
        static let host = "api.themoviedb.org"
        static let imageBaseUrl = "https://image.tmdb.org/t/p/"
    }

}

struct Tmdb {

    static func collectionURL(collectionId: Int?) -> URL? {
        guard let collectionId = collectionId else { return nil }

        var urlComponents = baseComponents
        urlComponents.path = "\(Path.collection)/\(collectionId)"

        let appendQueryItem = URLQueryItem(name: "append_to_response", value: "images")
        urlComponents.queryItems = [ Tmdb.keyQueryItem, appendQueryItem ]

        return urlComponents.url
    }

    static func creditURL(creditId: String?) -> URL? {
        guard let creditId = creditId else { return nil }

        var urlComponents = baseComponents
        urlComponents.path = "\(Path.credit)/\(creditId)"
        urlComponents.queryItems = [ Tmdb.keyQueryItem ]

        return urlComponents.url
    }

    static func searchURL(type: SearchType, query: String) -> URL? {
        var urlComponents = baseComponents
        urlComponents.path = "\(Path.search)\(type.rawValue)"
        
        let genreQueryItem = URLQueryItem(name: "query", value: query)
        urlComponents.queryItems = [ Tmdb.keyQueryItem, genreQueryItem ]
        
        return urlComponents.url
    }

    static func moviesURL(genreId: Int?) -> URL? {
        guard let genreId = genreId else { return nil }

        var urlComponents = baseComponents
        urlComponents.path = Path.discover

        let genreQueryItem = URLQueryItem(name: "with_genres", value: String(genreId))
        urlComponents.queryItems = [ Tmdb.keyQueryItem, genreQueryItem ]

        return urlComponents.url
    }

    static func moviesURL(productionId: Int?) -> URL? {
        guard let genreId = productionId else { return nil }

        var urlComponents = baseComponents
        urlComponents.path = Path.discover

        let genreQueryItem = URLQueryItem(name: "with_companies", value: String(genreId))
        urlComponents.queryItems = [ Tmdb.keyQueryItem, genreQueryItem ]

        return urlComponents.url
    }

    static func moviesURL(sortedBy: String?,
                          releaseYear: String? = nil) -> URL? {
        guard let sortedBy = sortedBy else { return nil }

        var urlComponents = baseComponents
        urlComponents.path = Path.discover

        let genreQueryItem = URLQueryItem(name: "sort_by", value: sortedBy)

        var qi = [ Tmdb.keyQueryItem, genreQueryItem ]

        if let releaseYear = releaseYear {
            qi.append(
                URLQueryItem(name: "primary_release_year", value: releaseYear)
            )
        }

        urlComponents.queryItems = qi

        return urlComponents.url
    }

    static func tvURL(id: Int?, episode: Episode?) -> URL? {
        guard let episode = episode,
              let episodeId = id,
              let seasonNumber = episode.season_number,
              let episodeNumber = episode.episode_number
              else { return nil }

        var urlComponents = baseComponents
        urlComponents.path = Path.tv + "/\(episodeId)/season/\(seasonNumber)/episode/\(episodeNumber)/images"

        return urlComponents.url
    }

    static func tvURL(genreId: Int?) -> URL? {
        guard let genreId = genreId else { return nil }

        var urlComponents = baseComponents
        urlComponents.path = Path.tvDiscover

        let genreQueryItem = URLQueryItem(name: "with_genres", value: String(genreId))
        urlComponents.queryItems = [ Tmdb.keyQueryItem, genreQueryItem ]

        return urlComponents.url
    }

    static func tvURL(networkId: Int?) -> URL? {
        guard let networkId = networkId else { return nil }

        var urlComponents = baseComponents
        urlComponents.path = Path.tvDiscover

        let genreQueryItem = URLQueryItem(name: "with_networks", value: String(networkId))
        urlComponents.queryItems = [ Tmdb.keyQueryItem, genreQueryItem ]

        return urlComponents.url
    }

    static func tvURL(productionId: Int?) -> URL? {
        guard let networkId = productionId else { return nil }

        var urlComponents = baseComponents
        urlComponents.path = Path.tvDiscover

        let genreQueryItem = URLQueryItem(name: "with_companies", value: String(networkId))
        urlComponents.queryItems = [ Tmdb.keyQueryItem, genreQueryItem ]

        return urlComponents.url
    }

    static func tvURL(original_language: String, voteCountGreaterThanOrEqual: Int, sortBy: String) -> URL? {
        var urlComponents = baseComponents
        urlComponents.path = "\(Path.tvDiscover)"

        let qi1 = URLQueryItem(name: "sort_by", value: sortBy)
        let qi2 = URLQueryItem(name: "with_original_language", value: original_language)
        let qi3 = URLQueryItem(name: "vote_count.gte", value: String(voteCountGreaterThanOrEqual))
        urlComponents.queryItems = [ Tmdb.keyQueryItem, qi1, qi2, qi3 ]

        return urlComponents.url
    }

    static func movieURL(movieId: Int?, append: String = "credits,videos,external_ids,recommendations,similar,reviews,release_dates,watch/providers,images") -> URL? {
        guard let movieId = movieId else { return nil }

        var urlComponents = baseComponents
        urlComponents.path = "\(Path.movie)/\(movieId)"

        let appendQueryItem = URLQueryItem(name: "append_to_response", value: append)
        urlComponents.queryItems = [ Tmdb.keyQueryItem, appendQueryItem ]

        return urlComponents.url
    }

    static func personURL(personId: Int?) -> URL? {
        guard let personId = personId else { return nil }

        var urlComponents = baseComponents
        urlComponents.path = "\(Path.person)/\(personId)"

        let appendQueryItem = URLQueryItem(name: "append_to_response", value: "movie_credits,tv_credits,external_ids,tagged_images,images")
        urlComponents.queryItems = [ Tmdb.keyQueryItem, appendQueryItem ]

        return urlComponents.url
    }

    static func tvURL(tvId: Int?) -> URL? {
        guard let tvId = tvId else { return nil }

        var urlComponents = baseComponents
        urlComponents.path = "\(Path.tv)/\(tvId)"

        let appendQueryItem = URLQueryItem(name: "append_to_response", value: "aggregate_credits,credits,external_ids,recommendations,similar,videos,content_ratings,watch/providers,images")
        urlComponents.queryItems = [ Tmdb.keyQueryItem, appendQueryItem ]

        return urlComponents.url
    }

    static func tvURL(tvId: Int?, seasonNumber: Int?) -> URL? {
        guard
            let tvId = tvId,
            let seasonNumber = seasonNumber else { return nil }

        var urlComponents = baseComponents
        urlComponents.path = "\(Path.tv)/\(tvId)/season/\(seasonNumber)"

        let appendQueryItem = URLQueryItem(name: "append_to_response", value: "credits,images")
        urlComponents.queryItems = [ Tmdb.keyQueryItem, appendQueryItem ]

        return urlComponents.url
    }

    static let webBase = "https://www.themoviedb.org/"

    enum Web: String {
        case movie, person, tv

        func detail(_ id: Int?) -> URL? {
            guard let id = id else { return nil }

            let string = Tmdb.webBase + self.rawValue + "/\(id)"
            return URL(string: string)
//            switch self {
//            default:
//                return
//            }
        }

    }

}

extension Tmdb {

    static func backdropImageUrl(path: String?, size: BackdropSize) -> URL? {
        guard
            let path = path,
            let url = URL(string: "\(Constant.imageBaseUrl)\(size.rawValue)\(path)") else { return nil }

        return url
    }

    static func stillImageUrl(path: String?, size: StillSize) -> URL? {
        guard
            let path = path,
            let url = URL(string: "\(Constant.imageBaseUrl)\(size.rawValue)\(path)") else { return nil }

        return url
    }

    static func castProfileUrl(path: String?, size: ProfileSize) -> URL? {
        guard
            let path = path,
            let url = URL(string: "\(Constant.imageBaseUrl)\(size.rawValue)\(path)") else { return nil }

        return url
    }

    static func mediaPosterUrl(path: String?, size: PosterSize) -> URL? {
        guard
            let path = path,
            let url = URL(string: "\(Constant.imageBaseUrl)\(size.rawValue)\(path)") else { return nil }

        return url
    }

    static func logoUrl(path: String?, size: LogoSize) -> URL? {
        guard
            let path = path,
            let url = URL(string: "\(Constant.imageBaseUrl)\(size.rawValue)\(path)") else { return nil }

        return url
    }

}

enum PosterSize: String {
    case tiny = "w92"
    case small = "w154"
    case medium = "w185"
    case large = "w342"
    case xl = "w500"
    case xxl = "w780"
}

enum ProfileSize: String {
    case small = "w45"
    case medium = "w185"
    case large = "h632"
}

enum StillSize: String {
    case small = "w92"
    case medium = "w185"
    case large = "w300"
    case original = "original"
}

enum BackdropSize: String {
    case small = "w300"
    case medium = "w780"
    case large = "w1280"
    case original = "original"
}

enum LogoSize: String {
    case tiny = "w45",
         small = "w92",
         medium = "w154",
         large = "w185",
         xl = "w300",
         xxl = "w500",
         original = "original"
}

extension Tmdb {

    enum TvType: String, CaseIterable {
        case
        popular,
        top_rated,
        airing_today,
        on_the_air

        var title: String {
            switch self {
            case .popular:
                return self.rawValue.capitalizingFirstLetter

            case .airing_today:
                return "Airing Today"

            case .on_the_air:
                return "Upcoming"

            case .top_rated:
                return "Top Rated"
            }
        }
    }

    enum MoviesType: String, CaseIterable {
        case
        popular,
        highest_grossing,
        top_rated,
        now_playing,
        upcoming

        var title: String {
            switch self {
            case .popular, .upcoming:
                return self.rawValue.capitalizingFirstLetter

            case .now_playing:
                return "Now Playing"

            case .highest_grossing:
                return "Highest Grossing"

            case .top_rated:
                return "Top Rated"
            }
        }

        var systemImage: UIImage? {
            var string: String = ""
            switch self {
            case .popular:
                string = "star"
            case .now_playing:
                string = "play"
            case .highest_grossing:
                string = "dollarsign.circle"
            case .top_rated:
                string = "hand.thumbsup"
            case .upcoming:
                string = "calendar"
            }

            return UIImage(systemName: string)
        }

        var tv: TvType? {
            switch self {
            case .popular:
                return .popular
            case .top_rated:
                return .top_rated
            case .now_playing:
                return .airing_today
            case .upcoming:
                return .on_the_air
            case .highest_grossing:
                return nil
            }
        }
    }

    static func moviesURL(kind: MoviesType) -> URL? {
        var urlComponents = baseComponents
        urlComponents.path = "\(Path.movie)/\(kind.rawValue)"

        return urlComponents.url
    }

    static var peoplePopularURL: URL? {
        var urlComponents = baseComponents
        urlComponents.path = "\(Path.person)/popular"

        return urlComponents.url
    }

    static func tvURL(kind: TvType) -> URL? {
        if kind == .top_rated {
            return tvURL(original_language: "en", voteCountGreaterThanOrEqual: 1000, sortBy: Tmdb.Sort.byVote.rawValue)
        }

        var urlComponents = baseComponents
        urlComponents.path = "\(Path.tv)/\(kind.rawValue)"

        return urlComponents.url
    }

}

extension Tmdb {
    enum SearchType: String {
        case movie, person, tv
    }

    enum Sort: String {
        case byRevenue = "revenue.desc"
        case byVote = "vote_average.desc"
    }    

    static let separator = " · "

    static let voteThreshold = 10

    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        return formatter
    }
}

private extension Tmdb {

    enum Path {
        static let collection = "/3/collection"
        static let credit = "/3/credit"
        static let discover = "/3/discover/movie"
        static let movie = "/3/movie"
        static let person = "/3/person"
        static let search = "/3/search/"
        static let tv = "/3/tv"
        static let tvDiscover = "/3/discover/tv"
    }

    static var baseComponents: URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = Constant.host
        urlComponents.queryItems = [ Tmdb.keyQueryItem ]

        return urlComponents
    }

    static var keyQueryItem: URLQueryItem {
        return URLQueryItem(name: "api_key", value: Constant.apiKey)
    }

}

private extension String {

    var capitalizingFirstLetter: String {
        return prefix(1).capitalized + dropFirst()
    }

}
