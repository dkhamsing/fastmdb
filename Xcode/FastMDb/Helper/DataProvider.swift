//
//  DataProvider.swift
//
//  Created by Daniel on 5/9/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

class DataProvider {
    let group = DispatchGroup()
}

private extension DataProvider {
    func fetchItem<T:Codable>(url: URL?, type: T.Type, completion: @escaping (T?) -> Void) {
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

    func get(_ kind: Tmdb.MoviesType,
             completion: @escaping (MediaSearch?, TvSearch?, PeopleSearch?) -> Void) {

        let mapped = kind.tv
        if let url = Tmdb.tvURL(kind: mapped) {
            fetchItem(url: url, type: TvSearch.self) { (item) in
                self.tv = item
            }
        }

        if let url = Tmdb.moviesURL(kind: kind) {
            fetchItem(url: url, type: MediaSearch.self) { (item) in
                self.movie = item
            }
        }

        if
            kind == .popular,
            let url = Tmdb.peoplePopularURL {
            fetchItem(url: url, type: PeopleSearch.self) { (item) in
                self.people = item
            }
        }

        group.notify(queue: .main) {
            completion(self.movie, self.tv, self.people)
        }
    }
}

final class MovieDataProvider: DataProvider {
    func get(_ id: Int?, completion: @escaping (Media?) -> Void) {
        let url = Tmdb.movieURL(movieId: id)
        url?.apiGet { (result: Result<Media, NetError>) in
            guard case .success(let item) = result else { return }
            completion(item)
        }
    }
}

final class PersonDataProvider: DataProvider {
    func get(_ id: Int?, completion: @escaping (Credit?) -> Void) {
        let url = Tmdb.personURL(personId: id)
        url?.apiGet { (result: Result<Credit, NetError>) in
            guard case .success(let item) = result else { return }
            completion(item)
        }
    }
}

final class ProductionDataProvider: DataProvider {
    var movie: MediaSearch?
    var tv: TvSearch?

    func get(_ id: Int?,
             completion: @escaping (MediaSearch?, TvSearch?) -> Void) {
        fetchItem(url: Tmdb.moviesURL(productionId: id), type: MediaSearch.self) { (item) in
            self.movie = item
        }

        fetchItem(url: Tmdb.tvURL(productionId: id), type: TvSearch.self) { (item) in
            self.tv = item
        }

        group.notify(queue: .main) {
            completion(self.movie, self.tv)
        }
    }
}

final class TvDataProvider: DataProvider {
    func get(_ id: Int?, completion: @escaping (TV?) -> Void) {
        let url = Tmdb.tvURL(tvId: id)
        url?.apiGet { (result: Result<TV, NetError>) in
            guard case .success(let item) = result else { return }
            completion(item)
        }
    }
}

final class SearchDataProvider: DataProvider {
    var movieSearch: MediaSearch?
    var tvSearch: TvSearch?
    var peopleSearch: PeopleSearch?

    func get(_ query: String?, completion: @escaping (MediaSearch?, TvSearch?, PeopleSearch?) -> Void) {
        guard let query = query else { return }

        fetchItem(url: Tmdb.searchURL(type: .movie, query: query), type: MediaSearch.self) { (item) in
            self.movieSearch = item
        }

        fetchItem(url: Tmdb.searchURL(type: .tv, query: query), type: TvSearch.self) { (item) in
            self.tvSearch = item
        }

        fetchItem(url: Tmdb.searchURL(type: .person, query: query), type: PeopleSearch.self) { (item) in
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
