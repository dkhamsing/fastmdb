//
//  DataProvider.swift
//
//  Created by Daniel on 5/9/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation
import UIKit

class DataProvider {
    let group = DispatchGroup()
}

private extension DataProvider {

    func fetchArticles(url: URL?, completion: @escaping ([Article]?) -> Void) {
        guard let url = url else { return }

        group.enter()
        NewsApi.getArticles(url: url) { articles in
            completion(articles)
            self.group.leave()
        }
    }

    func fetchImage(url: URL?, completion: @escaping (UIImage?) -> Void) {
        guard
            let url = url,
            let data = try? Data(contentsOf: url) else {
            completion(nil)
            return
        }

        group.enter()
        let image = UIImage(data: data)
        completion(image)
        self.group.leave()
    }

    func fetchItem<T:Codable>(url: URL?,
                              decoder: JSONDecoder = JSONDecoder(),
                              completion: @escaping (T?) -> Void) {
        group.enter()
        url?.apiGet(decoder: decoder) { (result: Result<T,NetError>) in
            if case .success(let item) = result {
                completion(item)
            }
            else {
                print(result)
            }
            self.group.leave()
        }
    }

}

final class CollectionDataProvider: DataProvider {

    func get(_ collectionId: Int?, completion: @escaping ([Media]?, UIImage?) -> Void) {
        var movies: [Media] = []
        var image: UIImage?

        fetchItem(url: Tmdb.collectionURL(collectionId: collectionId)) { (item: MediaCollection?) in
            guard
                let collection = item,
                let list = item?.parts else { return }

            self.fetchImage(url: Tmdb.mediaPosterUrl(path: collection.backdrop_path, size: .large)) { i in
                image = i
            }

            let movieIds = list.map { $0.id }
            for id in movieIds {
                let url = Tmdb.movieURL(movieId: id, append: "credits")
                self.fetchItem(url: url) { (movie: Media?) in
                    if let mResult = movie {
                        movies.append(mResult)
                    }
                }
            }
        }

        group.notify(queue: .main) {
            let sorted = movies.sorted { $0.release_date ?? "" > $1.release_date ?? "" }
            completion(sorted,image)
        }
    }

}

final class ContentDataProvider: DataProvider {

    func get(_ kind: Tmdb.MoviesType, completion: @escaping (MediaSearch?, TvSearch?, PeopleSearch?, [Article]?) -> Void) {
        var movie: MediaSearch?
        var tv: TvSearch?
        var people: PeopleSearch?
        var articles: [Article]?

        if let url = Tmdb.tvURL(kind: kind.tv) {
            fetchItem(url: url) { (item: TvSearch?) in
                tv = item
            }
        }

        if let url = Tmdb.moviesURL(kind: kind) {
            fetchItem(url: url) { (item: MediaSearch?) in
                movie = item
            }
        }

        if
            kind == .popular,
            let url = Tmdb.peoplePopularURL {
            fetchItem(url: url) { (item: PeopleSearch?) in
                people = item
            }
        }

        if let url = NewsApi.urlForCategory(NewsCategory.entertainment.rawValue) {
            fetchArticles(url: url) { a in
                articles = a
            }
        }

        group.notify(queue: .main) {
            completion(movie, tv, people, articles)
        }
    }

}

final class ImageDataProvider: DataProvider {

    func get(_ url: URL?, completion: @escaping (UIImage?) -> Void) {
        fetchImage(url: url, completion: completion)
    }

}

final class MovieDataProvider: DataProvider {

    func get(_ id: Int?, completion: @escaping (Media?, [Article]?, UIImage?, [iTunes.Album]?) -> Void) {
        var movie: Media?
        var articles: [Article]?
        var image: UIImage?
        var albums: [iTunes.Album]?

        let url = Tmdb.movieURL(movieId: id)
        fetchItem(url: url) { (item: Media?) in
            movie = item

            if
                let name = item?.title,
                let url = NewsApi.urlForQuery("\(name) movie") {
                self.fetchArticles(url: url) { a in
                    articles = a
                }
            }

            let url = Tmdb.mediaPosterUrl(path: item?.poster_path, size: .large)
            self.fetchImage(url: url) { i in
                image = i
            }

            if let name = item?.title,
               let url = name.itunesMusicSearchUrl {
                self.fetchItem(url: url, decoder: iTunes.decoder) { (item: iTunes.Feed?) in
                    if
                        let count = item?.albums.count,
                        count > 0 {
                        albums = item?.albums
                    }
                }
            }
        }

        group.notify(queue: .main) {
            completion(movie, articles, image, albums)
        }
    }

}

final class PersonDataProvider: DataProvider {

    func get(_ id: Int?, completion: @escaping (Credit?, [Article]?, UIImage?) -> Void) {
        var credit: Credit?
        var articles: [Article]?
        var image: UIImage?

        let url = Tmdb.personURL(personId: id)
        fetchItem(url: url) { (item: Credit?) in
            credit = item

            if
                let name = item?.name,
                let url = NewsApi.urlForQuery(name) {
                self.fetchArticles(url: url) { a in
                    articles = a
                }
            }

            let url = Tmdb.castProfileUrl(path: item?.profile_path, size: .large)
            self.fetchImage(url: url) { i in
                image = i
            }
        }

        group.notify(queue: .main) {
            completion(credit, articles, image)
        }
    }
}

final class ProductionDataProvider: DataProvider {

    func get(_ id: Int?, completion: @escaping (MediaSearch?, TvSearch?) -> Void) {
        var movie: MediaSearch?
        var tv: TvSearch?

        fetchItem(url: Tmdb.moviesURL(productionId: id)) { (item: MediaSearch?) in
            movie = item
        }

        fetchItem(url: Tmdb.tvURL(productionId: id)) { (item: TvSearch?) in
            tv = item
        }

        group.notify(queue: .main) {
            completion(movie, tv)
        }
    }

}

final class SeasonDataProvider: DataProvider {

    func get(_ seasonItem: Item?, completion: @escaping (Season?, UIImage?) -> Void) {
        guard let item = seasonItem else { return }

        var season: Season?
        var image: UIImage?

        let url = Tmdb.tvURL(tvId: item.id, seasonNumber: item.seasonNumber)
        fetchItem(url: url) { (item: Season?) in
            season = item

            let imageUrl = Tmdb.mediaPosterUrl(path: item?.poster_path, size: .large)
            self.fetchImage(url: imageUrl) { i in
                image = i
            }
        }

        group.notify(queue: .main) {
            completion(season, image)
        }
    }
}

final class TvDataProvider: DataProvider {

    func get(_ id: Int?, completion: @escaping (TV?, UIImage?, [Article]?, [iTunes.Album]?) -> Void) {
        var tv: TV?
        var articles: [Article]?
        var image: UIImage?
        var albums: [iTunes.Album]?

        let url = Tmdb.tvURL(tvId: id)
        fetchItem(url: url) { (item: TV?) in
            tv = item

            if let url = Tmdb.mediaPosterUrl(path: item?.poster_path, size: .large) {
                self.fetchImage(url: url) { i in
                    image = i
                }
            }

            if
                let name = item?.name,
                let url = NewsApi.urlForQuery("\(name) tv") {
                self.fetchArticles(url: url) { a in
                    articles = a
                }
            }

            if let name = item?.name,
               let url = name.itunesMusicSearchUrl {
                self.fetchItem(url: url, decoder: iTunes.decoder) { (item: iTunes.Feed?) in
                    if
                        let count = item?.albums.count,
                        count > 0 {
                        albums = item?.albums
                    }
                }
            }
        }

        group.notify(queue: .main) {
            completion(tv, image, articles, albums)
        }
    }

}

final class SearchDataProvider: DataProvider {

    func get(_ query: String?, completion: @escaping (MediaSearch?, TvSearch?, PeopleSearch?, [Article]?) -> Void) {
        guard let query = query else { return }

        var movieSearch: MediaSearch?
        var tvSearch: TvSearch?
        var peopleSearch: PeopleSearch?
        var articles: [Article]?

        fetchItem(url: Tmdb.searchURL(type: .movie, query: query)) { (item: MediaSearch?) in
            movieSearch = item
        }

        fetchItem(url: Tmdb.searchURL(type: .tv, query: query)) { (item: TvSearch?) in
            tvSearch = item
        }

        fetchItem(url: Tmdb.searchURL(type: .person, query: query)) { (item: PeopleSearch?) in
            peopleSearch = item
        }

        fetchArticles(url: NewsApi.urlForQuery(query)) { a in
            articles = a
        }

        group.notify(queue: .main) {
            completion(movieSearch, tvSearch, peopleSearch, articles)
        }
    }

}

private extension iTunes.Feed {

    var albums: [iTunes.Album] {
        let names = results
            .filter { $0.primaryGenreName.lowercased().contains("soundtrack") }
            .map { $0.collectionName }.unique

        var albums: [iTunes.Album] = []
        for n in names {
            let songs = results.filter { $0.collectionName == n }
            let song = songs.first
            let album = iTunes.Album(name: n, year: song?.releaseDisplay ?? "", artUrl: song?.artworkUrl100, songs: songs)
            albums.append(album)
        }

        return albums
    }

}

extension URL {

    func apiGet<T: Codable>(decoder: JSONDecoder = JSONDecoder(), completion: @escaping (Result<T, NetError>) -> Void) {
        print("get: \(self.absoluteString)")

        let session = URLSession.shared
        session.dataTask(with: self) { data, _, error in
            if error != nil {
                DispatchQueue.main.async {
                    completion(.failure(.session))
                }

                return
            }

            guard let unwrapped = data else {
                DispatchQueue.main.async {
                    completion(.failure(.data))
                }

                return
            }

            guard let result = try? decoder.decode(T.self, from: unwrapped) else {
                DispatchQueue.main.async {
                    completion(.failure(.json))
                }
                return
            }

            DispatchQueue.main.async {
                completion(.success(result))
            }
        }.resume()
    }

}

enum NetError: Error {
    case data
    case json
    case session
}
