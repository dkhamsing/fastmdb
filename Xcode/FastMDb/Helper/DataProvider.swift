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

    static func get<T: Codable>(_ url: URL?, completion: @escaping (Result<T, Error>) -> Void) {
        url?.apiGet(completion: completion)
    }

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
        url?.apiGet(decoder: decoder) { (result: Result<T,Error>) in
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

    func get(_ collectionId: Int?, completion: @escaping ([Media]?, Images?) -> Void) {
        var movies: [Media] = []
        var images: Images?

        fetchItem(url: Tmdb.Url.collection(collectionId: collectionId)) { (item: MediaCollection?) in
            guard let collection = item,
                  let list = item?.parts else { return }

            images = collection.images

            let movieIds = list.map { $0.id }
            for id in movieIds {
                let url = Tmdb.Url.movie(movieId: id, append: "credits")
                self.fetchItem(url: url) { (movie: Media?) in
                    if let mResult = movie {
                        movies.append(mResult)
                    }
                }
            }
        }

        group.notify(queue: .main) {
            let sorted = movies.sorted { $0.release_date ?? "" > $1.release_date ?? "" }
            completion(sorted, images)
        }
    }

}

final class ContentDataProvider: DataProvider {

    func get(_ kind: Tmdb.Url.Kind.Movies, completion: @escaping (MediaSearch?, TvSearch?, PeopleSearch?, [Article]?) -> Void) {
        var movie: MediaSearch?
        var tv: TvSearch?
        var people: PeopleSearch?
        var articles: [Article]?

        if let kind = kind.tv,
           let url = Tmdb.Url.tv(kind: kind) {
            fetchItem(url: url) { (item: TvSearch?) in
                tv = item
            }
        }

        if let url = Tmdb.Url.movies(kind: kind) {
            fetchItem(url: url) { (item: MediaSearch?) in
                movie = item
            }
        }

        if kind == .popular,
           let url = Tmdb.Url.people {
            fetchItem(url: url) { (item: PeopleSearch?) in
                people = item
            }
        }

        if kind == .popular,
           let url = NewsApi.urlForCategory(NewsCategory.Entertainment.rawValue) {
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
        var albums: [iTunes.Album]?

        let url = Tmdb.Url.movie(movieId: id)
        fetchItem(url: url) { (item: Media?) in
            movie = item

            if let name = item?.title,
               let url = NewsApi.urlForQuery("\(name) movie") {
                self.fetchArticles(url: url) { a in
                    articles = a
                }
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
            completion(movie, articles, nil, albums)
        }
    }

}

final class PersonDataProvider: DataProvider {

    func get(_ id: Int?, completion: @escaping (Credit?, [Article]?, MediaSearch?) -> Void) {
        var credit: Credit?
        var articles: [Article]?
        var highGross: MediaSearch?

        let url = Tmdb.Url.person(personId: id)
        fetchItem(url: url) { (item: Credit?) in
            credit = item

            if let name = item?.name,
                let url = NewsApi.urlForQuery(name) {
                self.fetchArticles(url: url) { a in
                    articles = a
                }
            }
        }

        fetchItem(url: Tmdb.Url.movies(sortedBy: .byRevenue, personId: id)) { (item: MediaSearch?) in
            highGross = item
        }

        group.notify(queue: .main) {
            completion(credit, articles, highGross)
        }
    }
}

final class ProductionDataProvider: DataProvider {

    func get(_ id: Int?, completion: @escaping (MediaSearch?, TvSearch?, MediaSearch?) -> Void) {
        var movie: MediaSearch?
        var tv: TvSearch?
        var highGross: MediaSearch?

        fetchItem(url: Tmdb.Url.movies(productionId: id)) { (item: MediaSearch?) in
            movie = item
        }

        fetchItem(url: Tmdb.Url.tv(productionId: id)) { (item: TvSearch?) in
            tv = item
        }

        fetchItem(url: Tmdb.Url.movies(sortedBy: .byRevenue, productionId: id)) { (item: MediaSearch?) in
            highGross = item
        }

        group.notify(queue: .main) {
            completion(movie, tv, highGross)
        }
    }

}

final class SeasonDataProvider: DataProvider {

    func get(_ seasonItem: Item?, completion: @escaping (Season?, UIImage?) -> Void) {
        guard let item = seasonItem,
              let number = item.metadata?.seasonNumber else { return }

        var season: Season?

        let url = Tmdb.Url.tv(tvId: item.metadata?.id, seasonNumber: number)
        fetchItem(url: url) { (item: Season?) in
            season = item
        }

        group.notify(queue: .main) {
            completion(season, nil)
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

        fetchItem(url: Tmdb.Url.searchMulti(query)) { (item: MultiSearch?) in
            peopleSearch = item?.people
            movieSearch = item?.movie
            tvSearch = item?.tv
        }

        fetchArticles(url: NewsApi.urlForQuery(query)) { a in
            articles = a
        }

        group.notify(queue: .main) {
            completion(movieSearch, tvSearch, peopleSearch, articles)
        }
    }

}

final class TvDataProvider: DataProvider {

    func get(_ id: Int?, completion: @escaping (TV?, UIImage?, [Article]?, [iTunes.Album]?) -> Void) {
        var tv: TV?
        var articles: [Article]?
        var albums: [iTunes.Album]?

        let url = Tmdb.Url.tv(tvId: id)
        fetchItem(url: url) { (item: TV?) in
            tv = item

            if let name = item?.name,
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
            completion(tv, nil, articles, albums)
        }
    }

}

private extension URL {

    func apiGet<T: Codable>(decoder: JSONDecoder = JSONDecoder(),
                            queue: DispatchQueue = DispatchQueue.main,
                            completion: @escaping (Result<T, Error>) -> Void) {
        Log.log(#function + ": \(self.absoluteString)")

        let session = URLSession.shared
        session.dataTask(with: self) { data, _, error in
            if let error = error {
                queue.async {
                    completion(.failure(error))
                }
                return
            }

            guard let unwrapped = data else {
                queue.async {
                    completion(.failure(NetError.data))
                }
                return
            }

            guard let result = try? decoder.decode(T.self, from: unwrapped) else {
                queue.async {
                    completion(.failure(NetError.json))
                }
                return
            }

            queue.async {
                completion(.success(result))
            }
        }.resume()
    }

}

private enum NetError: Error {
    case data
    case json    
}

private struct Log {
    static func log(_ value: String) {
        print(value)
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

private extension NewsApi {

    static func getArticles(url: URL?, completion: @escaping ([Article]?) -> Void) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        url?.apiGet(decoder: decoder) { (result: Result<Headline, Error>) in
            switch result {
            case .success(let headline):
                completion(headline.articles)
            case .failure(let error):
                Log.log(error.localizedDescription)
                completion(nil)
            }
        }
    }

}
