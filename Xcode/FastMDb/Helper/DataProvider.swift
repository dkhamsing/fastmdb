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

final class WikiFxDataProvider: DataProvider {

    func get(_ name: String?, completion: @escaping (Bool, [String]) -> Void) {
        guard let url = name?.wikifxUrl else {
            comp { completion(false, []) }
            return
        }

        Log.log(#function + ": \(url.absoluteString)")

        let downloader = StringDownloader.shared
        downloader.load(url: url) { result1 in
            let string = String(result1)

            guard !string.isEmpty else {
                self.comp {
                    completion(false, [])
                }
                return
            }

            let result = string.slices(from: "vfx-studio", to: "/a")
//            print(result)

            var studios: [String] = []
            for sub in result {
                let str = String(sub)
                let res = str.slices(from: ">", to: "<")

                if let studio = res.first {
                    studios.append(
                        String(studio.replacingOccurrences(of: "amp;", with: ""))
                    )
                }
            }

            self.comp { completion(true, studios) }
        }
    }

    private func comp(task: @escaping () -> Void) {
        DispatchQueue.main.async {
            task()
        }
    }

}

private extension String {
    func ranges(of string: String, options: CompareOptions = .literal) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range)
            start = range.lowerBound < range.upperBound ? range.upperBound : index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }

    func slices(from: String, to: String) -> [Substring] {
        let pattern = "(?<=" + from + ").*?(?=" + to + ")"
        return ranges(of: pattern, options: .regularExpression)
            .map{ self[$0] }
    }
}


final class CollectionDataProvider: DataProvider {

    func get(_ collectionId: Int?, completion: @escaping (DataProviderModel) -> Void) {
        var movies: [Media] = []
        var dpm = DataProviderModel()

        fetchItem(url: Tmdb.Url.collection(collectionId: collectionId)) { (item: MediaCollection?) in
            guard let collection = item,
                  let list = item?.parts else { return }

            dpm.images = collection.images

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
            dpm.movies = movies.sorted { $0.release_date ?? "" > $1.release_date ?? "" }
            completion(dpm)
        }
    }

}

final class ContentDataProvider: DataProvider {

    func get(_ kind: Tmdb.Url.Kind.Movies, completion: @escaping (DataProviderModel) -> Void) {
        var dpm = DataProviderModel()

        if let kind = kind.tv,
           let url = Tmdb.Url.tv(kind: kind) {
            fetchItem(url: url) { (item: TvSearch?) in
                dpm.tvSearch = item
            }
        }

        if kind == .stream, let url = Tmdb.Url.watch() {
            fetchItem(url: url) { (item: ProviderSearch?)  in
                dpm.providers = item?.results
            }
        }

        if let url = Tmdb.Url.movies(kind: kind) {
            fetchItem(url: url) { (item: MediaSearch?) in
                dpm.mediaSearch = item
            }
        }

        if kind == .popular,
           let url = Tmdb.Url.people {
            fetchItem(url: url) { (item: PeopleSearch?) in
                dpm.peopleSearch = item
            }
        }

        if kind == .popular,
           let url = NewsApi.urlForCategory(NewsCategory.Entertainment.rawValue) {
            fetchArticles(url: url) { a in
                dpm.articles = a
            }
        }

        group.notify(queue: .main) {
            completion(dpm)
        }
    }

}

final class ImageDataProvider: DataProvider {

    func get(_ url: URL?, completion: @escaping (UIImage?) -> Void) {
        fetchImage(url: url, completion: completion)
    }

}

struct DataProviderModel {
    var movies: [Media]?
    var images: Images?

    var movie: Media?
    var articles: [Article]?
    var albums: [iTunes.Album]?
    var moreDirector: MoreDirector?

    var credit: Credit?
    var mediaSearch: MediaSearch?

    var tvSearch: TvSearch?

    var mediaSearch2: MediaSearch?

    var peopleSearch: PeopleSearch?
    var providers: [Provider]?

    var tv: TV?
}

struct MoreDirector {
    var name: String?
    var media: [Media]?
}

final class MovieDataProvider: DataProvider {

    func get(_ id: Int?, completion: @escaping (DataProviderModel) -> Void) {
        var dpm = DataProviderModel()

        let url = Tmdb.Url.movie(movieId: id)
        fetchItem(url: url) { (item: Media?) in
            dpm.movie = item

            let jobs = [CrewJob.Director.rawValue]
                let job =
            item?.credits?.crew.filter { item in
                    var condition: Bool = false
                    for job in jobs {
                        condition = condition || item.job == job
                    }
                    return condition
                }

            if job?.count ?? 0 > 0,
               let moreUrl = Tmdb.Url.movies(
                sortedBy: .byRevenue,
                personId: job?.first?.id) {
                self.fetchItem(url: moreUrl) { (res: MediaSearch?) in
                    let med = res?.results
                        .filter { $0.id != id ?? 0 }
                        .filter { $0.release_date ?? "" != "" }
                        .filter { $0.poster_path ?? "" != "" }

                    if med?.count ?? 0 > 0 {
                        dpm.moreDirector = MoreDirector(
                            name: job?.first?.name, media: med
                        )
                    }
                }
            }

            if let name = item?.title,
               let url = NewsApi.urlForQuery("\(name) movie") {
                self.fetchArticles(url: url) { a in
                    dpm.articles = a
                }
            }

            if let name = item?.title,
               let url = name.itunesMusicSearchUrl {
                self.fetchItem(url: url, decoder: iTunes.decoder) { (item: iTunes.Feed?) in
                    if
                        let count = item?.albums.count,
                        count > 0 {
                        dpm.albums = item?.albums
                    }
                }
            }
        }

        group.notify(queue: .main) {
            completion(dpm)
        }
    }

}

final class PersonDataProvider: DataProvider {

    func get(_ id: Int?, completion: @escaping (DataProviderModel) -> Void) {
        var dpm = DataProviderModel()

        let url = Tmdb.Url.person(personId: id)
        fetchItem(url: url) { (item: Credit?) in
            dpm.credit = item

            if let name = item?.name,
                let url = NewsApi.urlForQuery(name) {
                self.fetchArticles(url: url) { a in
                    dpm.articles = a
                }
            }
        }

        fetchItem(url: Tmdb.Url.movies(sortedBy: .byRevenue, personId: id)) { (item: MediaSearch?) in
            dpm.mediaSearch = item
        }

        group.notify(queue: .main) {
            completion(dpm)
        }
    }
}

final class ProductionDataProvider: DataProvider {

    func get(_ id: Int?, completion: @escaping (DataProviderModel) -> Void) {
        var dpm = DataProviderModel()

        fetchItem(url: Tmdb.Url.movies(productionId: id)) { (item: MediaSearch?) in
            dpm.mediaSearch = item
        }

        fetchItem(url: Tmdb.Url.tv(productionId: id)) { (item: TvSearch?) in
            dpm.tvSearch = item
        }

        fetchItem(url: Tmdb.Url.movies(sortedBy: .byRevenue, productionId: id)) { (item: MediaSearch?) in
            dpm.mediaSearch2 = item
        }

        group.notify(queue: .main) {
            completion(dpm)
        }
    }

}

final class ProviderDataProvider: DataProvider {

    func get(_ id: Int?, completion: @escaping (DataProviderModel) -> Void) {
        var dpm = DataProviderModel()

        fetchItem(url: Tmdb.Url.discover(kind: .movie, providerId: id)) { (item: MediaSearch?) in
            dpm.mediaSearch = item
        }

        fetchItem(url: Tmdb.Url.discover(kind: .tv, providerId: id)) { (item: TvSearch?) in
            dpm.tvSearch = item
        }

        group.notify(queue: .main) {
            completion(dpm)
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

    func get(_ query: String?, completion: @escaping (DataProviderModel) -> Void) {
        var dpm = DataProviderModel()

        guard let query = query else {
            completion(dpm)
            return
        }

        fetchItem(url: Tmdb.Url.searchMulti(query)) { (item: MultiSearch?) in
            dpm.peopleSearch = item?.people
            dpm.mediaSearch = item?.movie
            dpm.tvSearch = item?.tv
        }

        fetchArticles(url: NewsApi.urlForQuery(query)) { a in
            dpm.articles = a
        }

        group.notify(queue: .main) {
            completion(dpm)
        }
    }

}

final class TvDataProvider: DataProvider {

    func get(_ id: Int?, completion: @escaping (DataProviderModel) -> Void) {
        var dpm = DataProviderModel()

        let url = Tmdb.Url.tv(tvId: id)
        fetchItem(url: url) { (item: TV?) in
            dpm.tv = item

            if let name = item?.name,
               let url = NewsApi.urlForQuery("\(name) tv") {
                self.fetchArticles(url: url) { a in
                    dpm.articles = a
                }
            }

            if let name = item?.name,
               let url = name.itunesMusicSearchUrl {
                self.fetchItem(url: url, decoder: iTunes.decoder) { (item: iTunes.Feed?) in
                    if
                        let count = item?.albums.count,
                        count > 0 {
                        dpm.albums = item?.albums
                    }
                }
            }
        }

        group.notify(queue: .main) {
            completion(dpm)
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
