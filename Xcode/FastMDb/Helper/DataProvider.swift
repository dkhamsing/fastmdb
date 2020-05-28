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
        self.group.enter()
        if
            let url = url,
            let data = try? Data(contentsOf: url)  {
            let image = UIImage(data: data)
            completion(image)
            self.group.leave()
        }
        else {
            completion(nil)
            self.group.leave()
        }
    }

    func fetchItem<T:Codable>(url: URL?, completion: @escaping (T?) -> Void) {
        group.enter()
        url?.apiGet { (result: Result<T,NetError>) in

            if case .success(let item) = result {
                completion(item)
            }
            self.group.leave()
        }
    }
}

final class ContentDataProvider: DataProvider {
    var movie: MediaSearch?
    var tv: TvSearch?
    var people: PeopleSearch?
    var articles: [Article]?

    func get(_ kind: Tmdb.MoviesType,
             completion: @escaping (MediaSearch?, TvSearch?, PeopleSearch?, [Article]?) -> Void) {

        let mapped = kind.tv
        if let url = Tmdb.tvURL(kind: mapped) {
            fetchItem(url: url) { (item: TvSearch?) in
                self.tv = item
            }
        }

        if let url = Tmdb.moviesURL(kind: kind) {
            fetchItem(url: url) { (item: MediaSearch?) in
                self.movie = item
            }
        }

        if
            kind == .popular,
            let url = Tmdb.peoplePopularURL {
            fetchItem(url: url) { (item: PeopleSearch?) in
                self.people = item
            }
        }

        if let url = NewsApi.urlForCategory(NewsCategory.entertainment.rawValue) {
            fetchArticles(url: url) { (articles) in
                self.articles = articles
            }
        }

        group.notify(queue: .main) {
            completion(self.movie, self.tv, self.people, self.articles)
        }
    }
}

final class MovieDataProvider: DataProvider {
    var movie: Media?
    var articles: [Article]?
    var image: UIImage?

    func get(_ id: Int?, completion: @escaping (Media?, [Article]?, UIImage?) -> Void) {
        let url = Tmdb.movieURL(movieId: id)
        fetchItem(url: url) { (item: Media?) in
            self.movie = item

            if
                let name = item?.title,
                let url = NewsApi.urlForQuery("\(name) movie") {
                self.fetchArticles(url: url) { (articles) in
                    self.articles = articles
                }
            }

            let url = Tmdb.mediaPosterUrl(path: item?.poster_path, size: .large)
            self.fetchImage(url: url) { (image) in
                self.image = image
            }
        }

        group.notify(queue: .main) {
            completion(self.movie, self.articles, self.image)
        }
    }
}

final class PersonDataProvider: DataProvider {
    var credit: Credit?
    var articles: [Article]?
    var image: UIImage?

    func get(_ id: Int?, completion: @escaping (Credit?, [Article]?, UIImage?) -> Void) {
        let url = Tmdb.personURL(personId: id)

        fetchItem(url: url) { (item: Credit?) in
            self.credit = item

            if
                let name = item?.name,
                let url = NewsApi.urlForQuery(name) {
                self.fetchArticles(url: url) { (articles) in
                    self.articles = articles
                }
            }

            let url = Tmdb.castProfileUrl(path: item?.profile_path, size: .large)
            self.fetchImage(url: url) { (image) in
                self.image = image
            }
        }

        group.notify(queue: .main) {
            completion(self.credit, self.articles, self.image)
        }
    }
}

final class ProductionDataProvider: DataProvider {
    var movie: MediaSearch?
    var tv: TvSearch?

    func get(_ id: Int?,
             completion: @escaping (MediaSearch?, TvSearch?) -> Void) {
        fetchItem(url: Tmdb.moviesURL(productionId: id)) { (item: MediaSearch?) in
            self.movie = item
        }

        fetchItem(url: Tmdb.tvURL(productionId: id)) { (item: TvSearch?) in
            self.tv = item
        }

        group.notify(queue: .main) {
            completion(self.movie, self.tv)
        }
    }
}

final class SeasonDataProvider: DataProvider {
    var season: Season?
    var image: UIImage?

    func get(_ seasonItem: Item?, completion: @escaping (Season?, UIImage?) -> Void) {
        guard let item = seasonItem else { return }

        let url = Tmdb.tvURL(tvId: item.id, seasonNumber: item.seasonNumber)
        fetchItem(url: url) { (item: Season?) in
            self.season = item

            let imageUrl = Tmdb.mediaPosterUrl(path: item?.poster_path, size: .large)
            self.fetchImage(url: imageUrl) { (image) in
                self.image = image
            }
        }

        group.notify(queue: .main) {
            completion(self.season, self.image)
        }
    }
}

final class TvDataProvider: DataProvider {
    var tv: TV?
    var articles: [Article]?
    var image: UIImage?
    
    func get(_ id: Int?, completion: @escaping (TV?, UIImage?, [Article]?) -> Void) {
        let url = Tmdb.tvURL(tvId: id)
        fetchItem(url: url) { (item: TV?) in
            self.tv = item

            if let url = Tmdb.mediaPosterUrl(path: item?.poster_path, size: .large) {
                self.fetchImage(url: url) { (image) in
                    self.image = image
                }
            }

            if
                let name = item?.name,
                let url = NewsApi.urlForQuery("\(name) tv") {
                self.fetchArticles(url: url) { (articles) in
                    self.articles = articles
                }
            }
        }

        group.notify(queue: .main) {
            completion(self.tv, self.image, self.articles)
        }
    }
}

final class SearchDataProvider: DataProvider {
    var movieSearch: MediaSearch?
    var tvSearch: TvSearch?
    var peopleSearch: PeopleSearch?

    func get(_ query: String?, completion: @escaping (MediaSearch?, TvSearch?, PeopleSearch?) -> Void) {
        guard let query = query else { return }

        fetchItem(url: Tmdb.searchURL(type: .movie, query: query)) { (item: MediaSearch?) in
            self.movieSearch = item
        }

        fetchItem(url: Tmdb.searchURL(type: .tv, query: query)) { (item: TvSearch?) in
            self.tvSearch = item
        }

        fetchItem(url: Tmdb.searchURL(type: .person, query: query)) { (item: PeopleSearch?) in
            self.peopleSearch = item
        }

        group.notify(queue: .main) {
            completion(self.movieSearch, self.tvSearch, self.peopleSearch)
        }
    }
}

extension URL {

    func apiGet<T: Codable>(completion: @escaping (Result<T, NetError>) -> Void) {
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

            guard let result = try? JSONDecoder().decode(T.self, from: unwrapped) else {
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
