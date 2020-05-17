//
//  ViewController.swift
//
//  Created by Daniel on 5/8/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit
import SafariServices // TODO: swap out safari controller with custom image controller

// TODO: lists pagination
// TODO: error handling

enum ScreenType {
    case landing, list, detail, search
}

enum CellType: String {
    case regular, color
}

struct DataSource {
    var screen: ScreenType
    var kind: Tmdb.MoviesType?
    var sections: [Section] = []
}

class MainViewController: UIViewController {

    // List
    var collectionId: Int? {
        didSet {
            dataSource = DataSource(screen: .list)

            let url = Tmdb.collectionURL(collectionId: collectionId)

            spinner.startAnimating()

            url?.apiGet { (result: Result<MediaCollection, NetError>) in

                guard
                    case .success(let collection) = result,
                    let list = collection.parts?
                        .sorted(by: { $0.release_date ?? "" > $1.release_date ?? "" })
                        .map({ $0.listItem }) else { return }

                // TODO: look up director in separate requests

                let url = Tmdb.mediaPosterUrl(path: collection.backdrop_path, size: .large)
                self.getImage(url: url) { (image) in
                    self.dataSource.sections = [ Section(items: list) ]
                    self.updateUI(image)
                }
                
            }

        }
    }

    var genreTvId: Int? {
        didSet {
            dataSource = DataSource(screen: .list)

            let url = Tmdb.tvURL(genreId: genreTvId)

            spinner.startAnimating()

            url?.apiGet { (result: Result<TvSearch, NetError>) in
                guard case .success(let search) = result else { return }

                let items = search.results.map { $0.listItem }
                self.dataSource.sections = [ Section(items: items) ]
                self.updateUI()
            }
        }
    }

    var genreMovieId: Int? {
        didSet {
            dataSource = DataSource(screen: .list)

            let url = Tmdb.moviesURL(genreId: genreMovieId)

            spinner.startAnimating()

            url?.apiGet { (result: Result<MediaSearch, NetError>) in
                guard case .success(let search) = result else { return }

                let items = search.results.map { $0.listItem }
                self.dataSource.sections = [ Section(items: items) ]
                self.updateUI()
            }
        }
    }

    var networkId: Int? {
        didSet {
            dataSource = DataSource(screen: .list)

            let url = Tmdb.tvURL(networkId: networkId)

            spinner.startAnimating()

            url?.apiGet { (result: Result<TvSearch, NetError>) in
                guard case .success(let search) = result else { return }

                let items = search.results.map { $0.listItem }
                self.dataSource.sections = [ Section(items: items) ]
                self.updateUI()
            }
        }
    }

    var productionId: Int? {
        didSet {
            dataSource = DataSource(screen: .list)
            spinner.startAnimating()
            updateProduction(productionId)
        }
    }

    var items: [Item]? {
        didSet {
            let section = Section(items: items)
            let sections = [section]
            dataSource = DataSource(screen: .list, sections: sections)
            self.updateUI()
        }
    }

    var sortedBy: String? {
        didSet {
            dataSource = DataSource(screen: .list)

            let url = Tmdb.moviesURL(sortedBy: sortedBy)

            spinner.startAnimating()

            url?.apiGet { (result: Result<MediaSearch, NetError>) in
                guard case .success(let search) = result else { return }

                let items = search.results.map { $0.listItem }
                self.dataSource.sections = [ Section(items: items) ]
                self.updateUI()
            }
        }
    }

    // Detail
    var movieId: Int? {
        didSet {
            dataSource = DataSource(screen: .detail)
            spinner.startAnimating()
            updateMovie(movieId)
        }
    }

    var personId: Int? {
        didSet {
            dataSource = DataSource(screen: .detail)
            spinner.startAnimating()
            updatePerson(personId)
        }
    }

    var tvId: Int? {
        didSet {
            dataSource = DataSource(screen: .detail)
            spinner.startAnimating()
            updateTv(tvId)
        }
    }

    var episode: Episode? {
        didSet {
            dataSource = DataSource(screen: .detail)
            updateEpisode(episode)
        }
    }

    var seasonItem: Item? {
        didSet {
            dataSource = DataSource(screen: .detail)
            updateSeason(seasonItem)
        }
    }

    // Data
    var dataSource = DataSource(screen: .landing, kind: .popular)
    var search = TableSearch()
    var startSearch = false

    // UI
    fileprivate var imageButton = ImageButton()
    let spinner = UIActivityIndicatorView(style: .large)
    let tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        setup()
        config()
        loadContent(dataSource.kind)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if startSearch {
            navigationItem.searchController?.searchBar.becomeFirstResponder()
        }
    }

    deinit {
        print("deinit")
    }

}

private extension MainViewController {

    func setup() {
        tableView.register(MainListCell.self, forCellReuseIdentifier: CellType.regular.rawValue)
        tableView.register(MainListCell.self, forCellReuseIdentifier: CellType.color.rawValue)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.separatorInset = .zero

        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.delegate = self
        navigationItem.searchController = search

        navigationController?.navigationBar.tintColor = .systemTeal

        let interaction = UIContextMenuInteraction(delegate: self)
        imageButton.addInteraction(interaction)
        // TODO: change bounds of image button, right now width is full
    }

    func config() {
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tableView)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        if dataSource.screen == .landing {
            let image = UIImage(systemName: "shuffle")
            let barButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleBarButton))
            navigationItem.rightBarButtonItem = barButtonItem
        }
        else {
            let image = UIImage(systemName: "house")
            let barButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(goHome))
            navigationItem.rightBarButtonItem = barButtonItem
        }
    }

}

extension MainViewController {
    func loadContent(_ kind: Tmdb.MoviesType?) {

        guard let kind = kind else { return }

        spinner.startAnimating()

        dataSource.kind = kind
        title = kind.title

        self.dataSource.sections = []
        self.updateUI()

        let provider = ContentDataProvider()
        provider.get(kind) { (movie, tv, people) in
            self.dataSource.sections = Section.contentSections(kind: kind, movie: movie, tv: tv, people: people)
            self.updateUI()
        }
    }

    func updateUI(_ image: UIImage? = nil) {
        // TODO: show banner instead? looks better on ipad
        if let image = image {
            let h = header
            var frame = h.frame

            let ratio: CGFloat = image.size.height / image.size.width

            if ratio > 1 {
                let fixedHeight: CGFloat = h.frame.height
                frame.size.width = fixedHeight / ratio
                frame.size.height = fixedHeight
            } else {
                let fixed: CGFloat = h.frame.width
                frame.size.width = fixed
                frame.size.height = fixed * ratio
            }

            h.frame = frame

            tableView.tableHeaderView = h

            imageButton.setImage(image, for: .normal)
        }

        spinner.stopAnimating()

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

    @objc
    func handleBarButton() {
        if let kind = dataSource.kind {
            let list = Tmdb.MoviesType.allCases.filter { $0.rawValue != kind.rawValue }
            let random = list.randomElement() ?? .popular

            loadContent(random)
        }
    }

    @objc func imageTap(sender: ImageButton) {
        guard let url = sender.url else { return }

        let sfvc = SFSafariViewController(url: url)
        sfvc.modalPresentationStyle = .formSheet
        present(sfvc, animated: true, completion: nil)
    }

}

private extension MainViewController {

    var header: UIView {
        let headerView = UIView()

        var frame = view.bounds
        frame.size.height = 300
        headerView.frame = frame

        imageButton.imageView?.contentMode = .scaleAspectFit
        imageButton.addTarget(self, action: #selector(imageTap), for: .touchUpInside)

        headerView.addSubview(imageButton)
        imageButton.translatesAutoresizingMaskIntoConstraints = false

        let inset: CGFloat = 20
        NSLayoutConstraint.activate([
            imageButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: inset),
            imageButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: inset),
            imageButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -inset),
            imageButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -inset),
        ])

        return headerView
    }

    func getImage(url: URL?, completion: @escaping (UIImage?) -> Void) {
        guard let url = url else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }

        DispatchQueue.global().async {
            guard let data = try? Data(contentsOf: url) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            let image = UIImage(data: data)

            DispatchQueue.main.async {
                completion(image)
            }
        }
    }

}

private extension MainViewController {

    func updateEpisode(_ episode: Episode?) {
        spinner.startAnimating()

        let buttonUrl = Tmdb.stillImageUrl(path: episode?.still_path, size: .original)
        self.imageButton.url = buttonUrl

        let url = Tmdb.stillImageUrl(path: episode?.still_path, size: .original)
        self.getImage(url: url) { (image) in
            guard let episode = episode else { return }
            
            self.dataSource.sections = episode.episodeSections
            self.updateUI(image)
        }
    }

    func updateMovie(_ movieId: Int?, limit: Int = Credit.numberOfEntries) {
        let provider = MovieDataProvider()
        provider.get(movieId) { (movie) in
            guard let movie = movie else { return }

            self.dataSource.sections = movie.sections(limit: limit)

            let buttonUrl = Tmdb.mediaPosterUrl(path: movie.poster_path, size: .xxl)
            self.imageButton.url = buttonUrl

            let url = Tmdb.mediaPosterUrl(path: movie.poster_path, size: .large)
            self.getImage(url: url) { (image) in
                self.updateUI(image)
            }
        }
    }

    func updatePerson(_ personId: Int?, limit: Int = Credit.numberOfEntries) {
        let provider = PersonDataProvider()
        provider.get(personId) { (credit) in
            guard let credit = credit else { return }

            self.dataSource.sections = Section.personSections(credit: credit, limit: limit)

            let buttonUrl = Tmdb.castProfileUrl(path: credit.profile_path, size: .large)
            self.imageButton.url = buttonUrl

            let url = Tmdb.castProfileUrl(path: credit.profile_path, size: .large)
            self.getImage(url: url) { (image) in
                self.updateUI(image)
            }
        }
    }

    func updateProduction(_ productionId: Int?) {
        let provider = ProductionDataProvider()
        provider.get(productionId) { (movie, tv) in
            var sections: [Section] = []

            if let section = movie?.productionSection {
                sections.append(section)
            }

            if let section = tv?.productionSection {
                sections.append(section)
            }

            self.dataSource.sections = sections
            self.updateUI()
        }
    }

    func updateSeason(_ seasonItem: Item?) {
        spinner.startAnimating()

        guard let item = seasonItem else { return }

        let url = Tmdb.tvURL(tvId: item.id, seasonNumber: item.seasonNumber)
        url?.apiGet { (result: Result<Season, NetError>) in
            guard case .success(let season) = result else { return }

            self.dataSource.sections = Section.seasonSections(season)

            let buttonUrl = Tmdb.mediaPosterUrl(path: season.poster_path, size: .xxl)
            self.imageButton.url = buttonUrl

            let url = Tmdb.mediaPosterUrl(path: season.poster_path, size: .large)

            self.getImage(url: url) { (image) in
                self.updateUI(image)
            }
        }
    }

    func updateTv(_ id: Int?, limit: Int = Credit.numberOfEntries) {
        let provider = TvDataProvider()
        provider.get(id) { (tv) in
            guard let tv = tv else { return }

            self.dataSource.sections = tv.tvSections

            let buttonUrl = Tmdb.mediaPosterUrl(path: tv.poster_path, size: .xxl)
            self.imageButton.url = buttonUrl

            let url = Tmdb.mediaPosterUrl(path: tv.poster_path, size: .large)

            self.getImage(url: url) { (image) in
                self.updateUI(image)
            }
        }
    }

}

extension MainViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let _ = imageButton.url else { return nil }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: sfvc, actionProvider: nil)
    }

    private func sfvc() -> UIViewController? {
        guard let url = imageButton.url else { return nil }

        let sfvc = SFSafariViewController(url: url)
        sfvc.modalPresentationStyle = .formSheet

        return sfvc
    }
}

private extension Credit {
    static let numberOfEntries = 10
}

private class ImageButton: UIButton {
    var url: URL?
}
