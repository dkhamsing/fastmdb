//
//  Tmdb.swift
//
//  Created by Daniel on 5/5/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

struct Tmdb {

    static let language = "en"

    struct Constant {
        static let host = "api.themoviedb.org"
        static let imageBaseUrl = "https://image.tmdb.org/t/p/"
    }

}

private extension Tmdb {

    static let apiKey = "<GET TMDB API KEY>"

    enum Path {
        static let collection = "/3/collection"
        static let credit = "/3/credit"
        static let discover = "/3/discover/movie"
        static let movie = "/3/movie"
        static let person = "/3/person"
        static let search = "/3/search/"
        static let searchMulti = "/3/search/multi"
        static let tv = "/3/tv"
        static let tvDiscover = "/3/discover/tv"
        static let watch = "/3/watch/providers/movie"
    }

    static var baseComponents: URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.themoviedb.org"
        urlComponents.queryItems = [ Tmdb.keyQueryItem, languageQueryItem ]

        return urlComponents
    }

    static var keyQueryItem: URLQueryItem {
        return URLQueryItem(name: "api_key", value: apiKey)
    }

    static var languageQueryItem: URLQueryItem {
        return URLQueryItem(name: "language", value: language)
    }

}

// MARK: URL

extension Tmdb {

    struct Url {

        static let baseImage = "https://image.tmdb.org/t/p/"
        static let baseWeb = "https://www.themoviedb.org/"

        static func collection(collectionId: Int?) -> URL? {
            guard let collectionId = collectionId else { return nil }

            var urlComponents = baseComponents
            urlComponents.path = "\(Path.collection)/\(collectionId)"

            let appendQueryItem = URLQueryItem(name: QueryName.append.rawValue, value: "images")
            urlComponents.queryItems?.append(appendQueryItem)

            return urlComponents.url
        }

        static func credit(creditId: String?) -> URL? {
            guard let creditId = creditId else { return nil }

            var urlComponents = baseComponents
            urlComponents.path = "\(Path.credit)/\(creditId)"

            return urlComponents.url
        }

        static func search(type: Kind.Search, query: String) -> URL? {
            var urlComponents = baseComponents
            urlComponents.path = "\(Path.search)\(type.rawValue)"

            let genreQueryItem = URLQueryItem(name: QueryName.query.rawValue, value: query)
            urlComponents.queryItems?.append(genreQueryItem)

            return urlComponents.url
        }

        static func searchMulti(_ query: String) -> URL? {
            var urlComponents = baseComponents
            urlComponents.path = Path.searchMulti

            let genreQueryItem = URLQueryItem(name: QueryName.query.rawValue, value: query)
            urlComponents.queryItems?.append(genreQueryItem)

            return urlComponents.url
        }

        static func watch() -> URL? {
            var urlComponents = baseComponents
            urlComponents.path = Path.watch
            let genreQueryItem = URLQueryItem(name: "watch_region", value: "US")
            urlComponents.queryItems?.append(genreQueryItem)
            return urlComponents.url
        }

        static func movie(movieId: Int?, append: String = "credits,videos,external_ids,recommendations,similar,reviews,release_dates,watch/providers,images") -> URL? {
            guard let movieId = movieId else { return nil }

            var urlComponents = baseComponents
            urlComponents.path = "\(Path.movie)/\(movieId)"

            let appendQueryItem = URLQueryItem(name: QueryName.append.rawValue, value: append)
            urlComponents.queryItems?.append(appendQueryItem)

            return urlComponents.url
        }

        static func movies(kind: Kind.Movies) -> URL? {
            guard kind != .stream else { return nil }
            var urlComponents = baseComponents
            urlComponents.path = "\(Path.movie)/\(kind.rawValue)"

            return urlComponents.url
        }

        static func movies(genreId: Int?) -> URL? {
            guard let genreId = genreId else { return nil }

            var urlComponents = baseComponents
            urlComponents.path = Path.discover

            let genreQueryItem = URLQueryItem(name: QueryName.genre.rawValue, value: String(genreId))
            urlComponents.queryItems?.append(genreQueryItem)

            return urlComponents.url
        }

        static func movies(productionId: Int?) -> URL? {
            guard let genreId = productionId else { return nil }

            var urlComponents = baseComponents
            urlComponents.path = Path.discover

            let genreQueryItem = URLQueryItem(name: QueryName.company.rawValue, value: String(genreId))
            urlComponents.queryItems?.append(genreQueryItem)

            return urlComponents.url
        }

        enum DiscoverKind { case movie, tv}

        static func discover(
            kind: DiscoverKind,
            providerId: Int?) -> URL? {
            guard let providerId = providerId else { return nil }

            var urlComponents = baseComponents

                switch kind {
                case .movie: urlComponents.path = Path.discover
                case .tv: urlComponents.path = Path.tvDiscover
                }


            urlComponents.queryItems?.append(
                URLQueryItem(name: QueryName.sort.rawValue, value: "popularity")
            )

            urlComponents.queryItems?.append(
                URLQueryItem(name: "watch_region", value: "US")
            )

            urlComponents.queryItems?.append(
                URLQueryItem(name: "with_watch_providers", value: String(providerId))
            )

            return urlComponents.url
        }



        static func movies(sortedBy: Kind.Sort,
                           releaseYear: String? = nil,
                           productionId: Int? = nil,
                           personId: Int? = nil,
                           voteCountGreaterThanOrEqual: Int? = nil) -> URL? {

            var urlComponents = baseComponents
            urlComponents.path = Path.discover

            let genreQueryItem = URLQueryItem(name: QueryName.sort.rawValue, value: sortedBy.rawValue)
            urlComponents.queryItems?.append(genreQueryItem)

            if let releaseYear = releaseYear {
                urlComponents.queryItems?.append(
                    URLQueryItem(name: "primary_release_year", value: releaseYear)
                )
            }

            if let personId = personId {
                urlComponents.queryItems?.append(
                    URLQueryItem(name: "with_people", value: String(personId))
                )
            }

            if let productionId = productionId {
                urlComponents.queryItems?.append(
                    URLQueryItem(name: QueryName.company.rawValue, value: String(productionId))
                )
            }

            if let vote = voteCountGreaterThanOrEqual {
                urlComponents.queryItems?.append(
                    URLQueryItem(name: "vote_count.gte" , value: String(vote))
                )
            }

            return urlComponents.url
        }

        static var people: URL? {
            var urlComponents = baseComponents
            urlComponents.path = "\(Path.person)/popular"

            return urlComponents.url
        }

        static func person(personId: Int?) -> URL? {
            guard let personId = personId else { return nil }

            var urlComponents = baseComponents
            urlComponents.path = "\(Path.person)/\(personId)"

            let appendQueryItem = URLQueryItem(name: QueryName.append.rawValue, value: "movie_credits,tv_credits,external_ids,tagged_images,images")
            urlComponents.queryItems?.append(appendQueryItem)

            return urlComponents.url
        }

        static func tv(id: Int?, episode: Episode?) -> URL? {
            guard let episode = episode,
                  let episodeId = id,
                  let seasonNumber = episode.season_number,
                  let episodeNumber = episode.episode_number else { return nil }

            var urlComponents = baseComponents
            urlComponents.path = Path.tv + "/\(episodeId)/season/\(seasonNumber)/episode/\(episodeNumber)/images"

            return urlComponents.url
        }

        static func tv(genreId: Int?) -> URL? {
            guard let genreId = genreId else { return nil }

            var urlComponents = baseComponents
            urlComponents.path = Path.tvDiscover

            let genreQueryItem = URLQueryItem(name: QueryName.genre.rawValue, value: String(genreId))
            urlComponents.queryItems?.append(genreQueryItem)

            return urlComponents.url
        }

        static func tv(networkId: Int?) -> URL? {
            guard let networkId = networkId else { return nil }

            var urlComponents = baseComponents
            urlComponents.path = Path.tvDiscover

            let genreQueryItem = URLQueryItem(name: "with_networks", value: String(networkId))
            urlComponents.queryItems?.append(genreQueryItem)

            return urlComponents.url
        }

        static func tv(productionId: Int?) -> URL? {
            guard let networkId = productionId else { return nil }

            var urlComponents = baseComponents
            urlComponents.path = Path.tvDiscover

            let genreQueryItem = URLQueryItem(name: QueryName.company.rawValue, value: String(networkId))
            urlComponents.queryItems?.append(genreQueryItem)

            return urlComponents.url
        }

        static func tv(original_language: String,
                       voteCountGreaterThanOrEqual: Int,
                       sortBy: String,
                       year: String? = nil) -> URL? {
            var urlComponents = baseComponents
            urlComponents.path = "\(Path.tvDiscover)"

            let qi1 = URLQueryItem(name: QueryName.sort.rawValue, value: sortBy)
            let qi2 = URLQueryItem(name: "with_original_language", value: original_language)
            let qi3 = URLQueryItem(name: "vote_count.gte", value: String(voteCountGreaterThanOrEqual))
            urlComponents.queryItems?.append(qi1)
            urlComponents.queryItems?.append(qi2)
            urlComponents.queryItems?.append(qi3)

            if let year = year {
                urlComponents.queryItems?.append(
                    URLQueryItem(name: "first_air_date_year", value: year)
                )
            }

            return urlComponents.url
        }

        static func tv(tvId: Int?) -> URL? {
            guard let tvId = tvId else { return nil }

            var urlComponents = baseComponents
            urlComponents.path = "\(Path.tv)/\(tvId)"

            let appendQueryItem = URLQueryItem(name: QueryName.append.rawValue, value: "aggregate_credits,credits,external_ids,recommendations,similar,videos,content_ratings,watch/providers,images")
            urlComponents.queryItems?.append(appendQueryItem)

            return urlComponents.url
        }

        static func tv(tvId: Int?, seasonNumber: Int?) -> URL? {
            guard
                let tvId = tvId,
                let seasonNumber = seasonNumber else { return nil }

            var urlComponents = baseComponents
            urlComponents.path = "\(Path.tv)/\(tvId)/season/\(seasonNumber)"

            let appendQueryItem = URLQueryItem(name: QueryName.append.rawValue, value: "credits,images")
            urlComponents.queryItems?.append(appendQueryItem)

            return urlComponents.url
        }

        static func tv(kind: Kind.Tv) -> URL? {
            if kind == .top_rated {
                return tv(original_language: Tmdb.language, voteCountGreaterThanOrEqual: 1000, sortBy: Tmdb.Url.Kind.Sort.byVote.rawValue)
            }

            var urlComponents = baseComponents
            urlComponents.path = "\(Path.tv)/\(kind.rawValue)"

            return urlComponents.url
        }

        struct Image {

            static func backdrop(path: String?, size: Size.Backdrop) -> URL? {
                guard let path = path,
                      let url = URL(string: "\(baseImage)\(size.rawValue)\(path)") else { return nil }

                return url
            }

            static func castProfile(path: String?, size: Size.Profile) -> URL? {
                guard let path = path,
                      let url = URL(string: "\(baseImage)\(size.rawValue)\(path)") else { return nil }

                return url
            }

            static func mediaPoster(path: String?, size: Size.Poster) -> URL? {
                guard let path = path,
                      let url = URL(string: "\(baseImage)\(size.rawValue)\(path)") else { return nil }

                return url
            }

            static func logo(path: String?, size: Size.Logo) -> URL? {
                guard let path = path,
                      let url = URL(string: "\(baseImage)\(size.rawValue)\(path)") else { return nil }

                return url
            }

            static func still(path: String?, size: Size.Still) -> URL? {
                guard let path = path,
                      let url = URL(string: "\(baseImage)\(size.rawValue)\(path)") else { return nil }

                return url
            }

            struct Size {

                enum Backdrop: String {
                    case small = "w300"
                    case medium = "w780"
                    case large = "w1280"
                    case original = "original"
                }

                enum Logo: String {
                    case tiny = "w45",
                         small = "w92",
                         medium = "w154",
                         large = "w185",
                         xl = "w300",
                         xxl = "w500",
                         original = "original"
                }

                enum Poster: String {
                    case tiny = "w92"
                    case small = "w154"
                    case medium = "w185"
                    case large = "w342"
                    case xl = "w500"
                    case xxl = "w780"
                }

                enum Profile: String {
                    case small = "w45"
                    case medium = "w185"
                    case large = "h632"
                }

                enum Still: String {
                    case small = "w92"
                    case medium = "w185"
                    case large = "w300"
                    case original = "original"
                }

            }

        }

        struct Kind {

            enum Movies: String, CaseIterable {
                case popular,
                     highest_grossing,
                     top_rated_movies,
                     top_rated_tv,
                     top_rated,
                     now_playing,
                     upcoming,
                     stream

                var title: String {
                    switch self {
                    case .popular:
                        return "Popular"
                    case .upcoming:
                        return "Upcoming"
                    case .now_playing:
                        return "Now Playing"
                    case .highest_grossing:
                        return "Highest Grossing"
                    case .top_rated:
                        return "Best"
                    case .top_rated_movies:
                        return "Top Rated Movies"
                    case .top_rated_tv:
                        return "Top Rated TV"
                    case .stream:
                        return "Stream"
                    }
                }

                var tv: Tv? {
                    switch self {
                    case .popular:
                        return .popular
                    case .top_rated:
                        return .top_rated
                    case .now_playing:
                        return .airing_today
                    case .upcoming:
                        return .on_the_air
                    case .highest_grossing, .top_rated_tv, .top_rated_movies, .stream:
                        return nil
                    }
                }
            }

            enum Search: String {
                case movie, person, tv
            }

            enum Sort: String {
                case byRevenue = "revenue.desc"
                case byVote = "vote_average.desc"

                var display: String {
                    switch self {
                    case .byRevenue: return Kind.Movies.highest_grossing.title
                    case .byVote: return Kind.Movies.top_rated.title
                    }
                }
            }

            enum Tv: String, CaseIterable {
                case popular,
                     top_rated,
                     airing_today,
                     on_the_air

                var title: String {
                    switch self {
                    case .popular:
                        return "Popular"
                    case .airing_today:
                        return "Airing Today"
                    case .on_the_air:
                        return "Upcoming"
                    case .top_rated:
                        return "Top Rated"
                    }
                }
            }

        }

        enum QueryName: String {
            case append = "append_to_response"
            case company = "with_companies"
            case genre = "with_genres"
            case query = "query"
            case sort = "sort_by"
        }

        enum Web: String {
            case movie, person, tv

            func detailURL(_ id: Int?) -> URL? {
                guard let id = id else { return nil }

                let string = baseWeb + self.rawValue + "/\(id)"
                return URL(string: string)
            }
        }

    }

}
