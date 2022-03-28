//
//  ViewController.swift
//
//  Created by Daniel on 5/8/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit
//import SafariServices // TODO: swap out safari controller with custom image controller

// TODO: lists pagination
// TODO: error handling

class MainViewController: UIViewController {

    var collectionId: Int? {
        didSet {
            updateCollection(collectionId)
        }
    }

    var genreTvId: Int? {
        didSet {
            updateGenreTv(genreTvId)
        }
    }

    var genreMovieId: Int? {
        didSet {
            updateGenreMovie(genreMovieId)
        }
    }

    var items: [Item]? {
        didSet {
            updateItems(items)
        }
    }

    var movieId: Int? {
        didSet {
            updateMovie(movieId)
        }
    }

    var networkId: Int? {
        didSet {
            updateNetwork(networkId)
        }
    }

    var personId: Int? {
        didSet {
            updatePerson(personId)
        }
    }

    var productionId: Int? {
        didSet {
            updateProduction(productionId)
        }
    }

    var seasonItem: Item? {
        didSet {
            updateSeason(seasonItem)
        }
    }

    var sections: [ItemSection]? {
        didSet {
            updateSections(sections)
        }
    }

    var releaseYear: String?

    var sortedBy: Tmdb.Url.Kind.Sort? {
        didSet {
            updateSortedByMovies(sortedBy,
                           releaseYear,
                           voteCountGreaterThanOrEqual: voteCountGreaterThanOrEqual)
        }
    }

    var tvId: Int? {
        didSet {
            updateTv(tvId)
        }
    }

    var voteCountGreaterThanOrEqual: Int?

    // Data
    var screen: ScreenType = .landing
    var dataSource: [ItemSection] = []
    var search = TableSearch()
    var startSearch = false

    // UI
    let spinner = UIActivityIndicatorView(style: .large)
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    var searchResultsButtons = StackButtons()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        setup()
        config()
        
        if screen == .landing {
            loadContent(.popular)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if startSearch {
            navigationItem.searchController?.searchBar.becomeFirstResponder()
        }
    }

    deinit {
        print("deinit \(self)")
    }

}

private extension MainViewController {

    func setup() {
        navigationController?.navigationBar.tintColor = .systemTeal

        // table
        tableView.register(MainListCell.self, forCellReuseIdentifier: CellType.plain.identifier)
        tableView.register(MainListCell.self, forCellReuseIdentifier: CellType.plain.identifier)
        tableView.register(MainListCellImage.self, forCellReuseIdentifier: CellType.image().identifier)

        tableView.register(MainListCollectionCell.self, forCellReuseIdentifier: MainListCollectionCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.separatorInset = .zero

        // search
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.delegate = self
        navigationItem.searchController = search

        // search results button
        searchResultsButtons.isHidden = true
        searchResultsButtons.delegate = self
    }

    func config() {
        view.backgroundColor = .background
        
        view.addSubviewForAutoLayout(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        let button = barButtonItem(screen)
        navigationItem.rightBarButtonItem = button

        searchResultsButtons.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchResultsButtons)
        NSLayoutConstraint.activate([
            searchResultsButtons.heightAnchor.constraint(equalToConstant: StackButtons.height), // TODO: this height changes depending on device, should be fixed
            searchResultsButtons.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            searchResultsButtons.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
    }

}

extension MainViewController {

    func loadContent(_ kind: Tmdb.Url.Kind.Movies?) {
        guard let kind = kind else { return }

        title = kind.title

        spinner.startAnimating()

        screen = .landing

        let updater = Updater(dataSource: [])
        updateScreen(updater)

        let dc = Calendar.current.dateComponents([.year], from: Date())
        if let year = dc.year {
            releaseYear = String(year)
        }

        switch kind {
        case .highest_grossing:
            voteCountGreaterThanOrEqual = nil
            sortedBy = .byRevenue
        case .top_rated_movies:
            voteCountGreaterThanOrEqual = 1000
            sortedBy = .byVote
        case .top_rated_tv:
            updateSortedByTv(.byVote, releaseYear, voteCountGreaterThanOrEqual: 700)
        default:
            let provider = ContentDataProvider()
            provider.get(kind) { (movie, tv, people, articles) in
                let sections = ItemSection.contentSections(kind: kind, movie: movie, tv: tv, people: people, articles: articles)
                let updater = Updater(dataSource: sections)
                self.updateScreen(updater)
            }
        }
    }

    func updateCredit(id: Int?, creditId: String?) {
        screen = .list
        spinner.startAnimating()

        let url = Tmdb.Url.credit(creditId: creditId)
        DataProvider.get(url) { (result: Result<CreditResult, Error>) in
            guard case.success(let cr) = result else { return }

            if let job = cr.job {
                self.title = job + " Credits"
            } else {
                self.title = "Credits"
            }

            let sections = cr.sections(id: id)
            let u = Updater(dataSource: sections)
            self.updateScreen(u)
        }
    }

    func updateEpisode(tvId: Int?, episode: Episode?) {
        screen = .list
        spinner.startAnimating()

        let url = Tmdb.Url.tv(id: tvId, episode: episode)
        DataProvider.get(url) { (result: Result<Images, Error>) in
            switch result {
            case .success(let images): 
                var sections: [ItemSection] = []

                if let section = images.stillsSection {
                    sections.append(section)
                }

                if let section = episode?.episodeSections {
                    sections.append(contentsOf: section)
                }

                let u = Updater(dataSource: sections)
                self.updateScreen(u)
            case .failure(_):
                self.updateScreen(nil)
            }
        }
    }

    func updateScreen(_ updater: Updater?) {
        spinner.stopAnimating()

        if let ds = updater?.dataSource {
            dataSource = ds
        }

        tableView.reloadData()
    }

}

private extension MainViewController {

    @objc
    func goHome() {
        navigationController?.popToRootViewController(animated: true)

        // TODO: seeing assert warning

        /**
         steps
         launch app
         tap on movie
         tap on box office
         tap on movie
         tap on box office
         tap on movie
         tap on home

         2020-05-10 21:09:14.775267-0700 FastMDb[78921:13778251] [Assert] Unexpected configuration of navigation stack. viewControllers = (
         "<FastMDb.MainViewController: 0x7f821b81ea00>"
         ), stack.items = (
         "<UINavigationItem: 0x7f821a40d8a0> title='Popular' rightBarButtonItems=0x600003520750 searchController=0x7f821b848e00 hidesSearchBarWhenScrolling",
         "<UINavigationItem: 0x7f821a62f3e0> title='Ad Astra' rightBarButtonItems=0x600003521260 searchController=0x7f821b02b200 hidesSearchBarWhenScrolling",
         "<UINavigationItem: 0x7f821a5433c0> title='Highest Grossing' rightBarButtonItems=0x60000352d1b0 searchController=0x7f821c016400 hidesSearchBarWhenScrolling",
         "<UINavigationItem: 0x7f821a63f730> title='Titanic' rightBarButtonItems=0x600003527270 searchController=0x7f821b019e00 hidesSearchBarWhenScrolling",
         "<UINavigationItem: 0x7f821a72a570> title='Highest Grossing' rightBarButtonItems=0x60000352d5c0 searchController=0x7f821c02ca00 hidesSearchBarWhenScrolling"
         )*/
    }

    func barButtonItem(_ screen: ScreenType) -> UIBarButtonItem {
        if screen == .landing {
            let image = UIImage(systemName: "ellipsis")
            return UIBarButtonItem(title: nil, image: image, primaryAction: nil, menu: barMenu)
        }
        else {
            let image = UIImage(systemName: "house")
            return  UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(goHome))
        }
    }

    var barMenu: UIMenu {
        let menuActions = Tmdb.Url.Kind.Movies.allCases.map { (kind) -> UIAction in
            return UIAction(title: kind.title, image: kind.systemImage) { (_) in
                self.loadContent(kind)
            }
        }

        return UIMenu(title: "", children: menuActions)
    }

}

private extension MainViewController {

    func numberedItem(_ it: [Item]) -> [Item] {
        var items: [Item] = []
        for (index, element) in it.enumerated() {
            var mElemented = element
            mElemented.title = "\(index + 1). " + (element.title ?? "")
            items.append(mElemented)
        }

        return items
    }

    func updateCollection(_ collectionId: Int?) {
        screen = .list
        spinner.startAnimating()

        let provider = CollectionDataProvider()
        provider.get(collectionId) { (movies, image) in
            guard let movies = movies else { return }

            var sections: [ItemSection] = []

            if let imageSection = image?.backdropsSection {
                sections.append(imageSection)
            }

            var metItems: [Item] = []
            metItems.append(
                Item(title: String(movies.count), subtitle: "Number of Movies")
            )

            let totalRevenue = movies.compactMap { $0.revenue }.reduce(0, +)
            if totalRevenue > 0 {
                metItems.append(
                    Item(title: totalRevenue.display, subtitle: "Total Revenue")
                )
            }

            sections.append(
                ItemSection(items: metItems)
            )

            let items = movies.map { $0.listItemCollection }
            sections.append(
                ItemSection(items: items,
                            metadata: Metadata(display: .textImage()))
            )

            let u = Updater(dataSource: sections)
            self.updateScreen(u)
        }
    }

    func updateGenreMovie(_ genreMovieId: Int?) {
        screen = .list
        spinner.startAnimating()

        let url = Tmdb.Url.movies(genreId: genreMovieId)
        DataProvider.get(url) { (result: Result<MediaSearch, Error>) in
            guard case .success(let search) = result else { return }

            let items = search.results.map { $0.listItem }
            let sections = [ ItemSection(items: items) ]
            let u = Updater(dataSource: sections)
            self.updateScreen(u)
        }
    }

    func updateGenreTv(_ genreTvId: Int?) {
        screen = .list
        spinner.startAnimating()

        let url = Tmdb.Url.tv(genreId: genreTvId)
        DataProvider.get(url) { (result: Result<TvSearch, Error>) in
            guard case .success(let search) = result else { return }

            let items = search.results.map { $0.listItem }
            let sections = [ ItemSection(items: items) ]
            let u = Updater(dataSource: sections)
            self.updateScreen(u)
        }
    }

    func updateItems(_ items: [Item]?) {
        screen = .list

        let section = ItemSection(items: items)
        let sections = [section]
        let u = Updater(dataSource: sections)
        updateScreen(u)
    }

    func updateMovie(_ movieId: Int?, limit: Int = Credit.numberOfEntries) {
        screen = .list
        spinner.startAnimating()

        let provider = MovieDataProvider()
        provider.get(movieId) { (movie, articles, image, albums) in
            guard let movie = movie else { return }

            let sections = movie.sections(articles: articles, albums: albums, limit: limit)
            let u = Updater(dataSource:sections)
            self.updateScreen(u)
        }
    }

    func updateNetwork(_ networkId: Int?) {
        screen = .list
        spinner.startAnimating()

        let url = Tmdb.Url.tv(networkId: networkId)
        DataProvider.get(url) { (result: Result<TvSearch, Error>) in
            guard case .success(let search) = result else { return }

            let sections = TV.networkSections(search.results)
            let u = Updater(dataSource: sections)
            self.updateScreen(u)
        }
    }

    func updatePerson(_ personId: Int?, limit: Int = Credit.numberOfEntries) {
        screen = .list
        spinner.startAnimating()

        let provider = PersonDataProvider()
        provider.get(personId) { (credit, articles, highGross) in
            guard let credit = credit else { return }

            let sections = ItemSection.personSections(credit: credit,
                                                      articles: articles,
                                                      highGross: highGross,
                                                      limit: limit)
            let u = Updater(dataSource: sections)
            self.updateScreen(u)
        }
    }

    func updateProduction(_ productionId: Int?) {
        screen = .list
        spinner.startAnimating()

        let provider = ProductionDataProvider()
        provider.get(productionId) { (movie, tv, highGross) in
            var sections: [ItemSection] = []

            if let s = highGross?.highestGrossingSections {
                sections.append(contentsOf: s)
            }

            if let s = movie?.productionSections {
                sections.append(contentsOf: s)
            }

            if let s = tv?.productionSections {
                sections.append(contentsOf: s)
            }

            let u = Updater(dataSource: sections)
            self.updateScreen(u)
        }
    }

    func updateSeason(_ seasonItem: Item?) {
        screen = .list
        spinner.startAnimating()

        let provider = SeasonDataProvider()
        provider.get(seasonItem) { (season, image) in
            let sections = ItemSection.seasonSections(tvId: seasonItem?.metadata?.id, season: season)
            let u = Updater(dataSource: sections)
            self.updateScreen(u)
        }
    }

    func updateSortedByMovies(_ sortedBy: Tmdb.Url.Kind.Sort?,
                        _ releaseYear: String?,
                        voteCountGreaterThanOrEqual: Int? = nil) {
        guard let sortedBy = sortedBy else { return }

        screen = .list
        spinner.startAnimating()

        let url = Tmdb.Url.movies(sortedBy: sortedBy,
                                  releaseYear: releaseYear,
                                  voteCountGreaterThanOrEqual: voteCountGreaterThanOrEqual)
        DataProvider.get(url) { (result: Result<MediaSearch, Error>) in
            guard case .success(let search) = result else { return }

            let list: [Item]
            let metadata: Metadata
            if sortedBy == .byVote {
                list = search.results.map { $0.listItemWithVotes }
                metadata = Metadata(destination: .best, display: .textImage())
            } else {
                list = search.results.map { $0.listItemTextImage }
                metadata = Metadata(destination: .moviesSortedBy,
                                   sortedBy: sortedBy,
                                   display: .textImage())
            }
            let numbered = self.numberedItem(list)

            var footer: String?
            if let _ = releaseYear {
                footer = "See all time"
            }
            let sections = [ ItemSection(header: releaseYear ?? "all time",
                                         items: numbered,
                                         footer: footer,
                                         metadata: metadata) ]
            let u = Updater(dataSource: sections)
            self.updateScreen(u)
        }
    }

    func updateSortedByTv(_ sortedBy: Tmdb.Url.Kind.Sort?,
                          _ releaseYear: String?,
                          voteCountGreaterThanOrEqual: Int? = nil) {
          guard let sortedBy = sortedBy,
                let voteCountGreaterThanOrEqual = voteCountGreaterThanOrEqual else { return }

        let url = Tmdb.Url.tv(original_language: Tmdb.language, voteCountGreaterThanOrEqual: voteCountGreaterThanOrEqual, sortBy: sortedBy.rawValue, year: releaseYear)
        DataProvider.get(url) { (result: Result<TvSearch, Error>) in
            guard case .success(let search) = result else { return }

            let list = search.results.map { $0.listItemWithVotes }
            let numbered = self.numberedItem(list)

            var footer: String?
            if let _ = releaseYear {
                footer = "See all time"
            }
            let sections = [ ItemSection(header: releaseYear ?? "all time",
                                         items: numbered,
                                         footer: footer,
                                         metadata: Metadata(destination: .best)) ]
            let u = Updater(dataSource: sections)
            self.updateScreen(u)
        }
    }

    func updateSections(_ sections: [ItemSection]?) {
        screen = .list

        let u = Updater(dataSource: sections)
        updateScreen(u)
    }

    func updateTv(_ id: Int?, limit: Int = Credit.numberOfEntries) {
        screen = .list
        spinner.startAnimating()

        let provider = TvDataProvider()
        provider.get(id) { (tv, image, articles, albums) in
            guard let tv = tv else { return }

            let sections = tv.sections(articles: articles, albums: albums)
            let u = Updater(dataSource: sections)
            self.updateScreen(u)
        }
    }

}

private extension Credit {

    static let numberOfEntries = 10

}

extension MediaSearch {

    var highestGrossingSections: [ItemSection]? {
        let items = results
            .filter { $0.released }
            .map { $0.listItemImage }
        guard items.count > 0 else { return nil }

        return [
            ItemSection(header: Tmdb.Url.Kind.Movies.highest_grossing.title,
                        items: items,
                        metadata: Metadata(display: .portraitImage(.collection(.image(.portrait)))))
        ]
    }

}

enum ScreenType {

    case landing, list, search

}

struct Updater {

    var dataSource: [ItemSection]?
    
}
