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

    var collectionId: Int? {
        didSet {
            updateCollection(collectionId)
        }
    }

    var episode: Episode? {
        didSet {
            updateEpisode(episode)
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

    var sortedBy: String? {
        didSet {
            updateSortedBy(sortedBy)
        }
    }

    var tvId: Int? {
        didSet {
            updateTv(tvId)
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

        dataSource.sections = []
        updateUI()

        let provider = ContentDataProvider()
        provider.get(kind) { (movie, tv, people, articles) in
            self.dataSource.sections = Section.contentSections(kind: kind, movie: movie, tv: tv, people: people, articles: articles)
            self.updateUI()
        }
    }

    func updateUI(_ image: UIImage? = nil, _ buttonUrl: URL? = nil) {
        updateTableHeaderHeader(image: image, buttonUrl: buttonUrl)
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

    func updateTableHeaderHeader(image: UIImage?, buttonUrl: URL?) {
           // TODO: show banner instead? looks better on ipad
           guard let image = image else { return }

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

           imageButton.url = buttonUrl
       }

}

private extension MainViewController {

    func updateCollection(_ collectionId: Int?) {
        dataSource = DataSource(screen: .list)
        spinner.startAnimating()

        let url = Tmdb.collectionURL(collectionId: collectionId)
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

    func updateEpisode(_ episode: Episode?) {
        dataSource = DataSource(screen: .detail)
        spinner.startAnimating()

        let url = Tmdb.stillImageUrl(path: episode?.still_path, size: .original)
        self.getImage(url: url) { (image) in
            guard let episode = episode else { return }

            self.dataSource.sections = episode.episodeSections
            let buttonUrl = Tmdb.stillImageUrl(path: episode.still_path, size: .original)
            self.updateUI(image, buttonUrl)
        }
    }

    func updateGenreTv(_ genreTvId: Int?) {
        dataSource = DataSource(screen: .list)
        spinner.startAnimating()

        let url = Tmdb.tvURL(genreId: genreTvId)
        url?.apiGet { (result: Result<TvSearch, NetError>) in
            guard case .success(let search) = result else { return }

            let items = search.results.map { $0.listItem }
            self.dataSource.sections = [ Section(items: items) ]
            self.updateUI()
        }
    }

    func updateGenreMovie(_ genreMovieId: Int?) {
        dataSource = DataSource(screen: .list)
        spinner.startAnimating()

        let url = Tmdb.moviesURL(genreId: genreMovieId)
        url?.apiGet { (result: Result<MediaSearch, NetError>) in
            guard case .success(let search) = result else { return }

            let items = search.results.map { $0.listItem }
            self.dataSource.sections = [ Section(items: items) ]
            self.updateUI()
        }
    }

    func updateItems(_ items: [Item]?) {
        let section = Section(items: items)
        let sections = [section]
        dataSource = DataSource(screen: .list, sections: sections)
        updateUI()
    }

    func updateMovie(_ movieId: Int?, limit: Int = Credit.numberOfEntries) {
        dataSource = DataSource(screen: .detail)
        spinner.startAnimating()

        let provider = MovieDataProvider()
        provider.get(movieId) { (movie, articles, image) in
            guard let movie = movie else { return }

            self.dataSource.sections = movie.sections(articles: articles, limit: limit)
            let buttonUrl = Tmdb.mediaPosterUrl(path: movie.poster_path, size: .xxl)
            self.updateUI(image, buttonUrl)
        }
    }

    func updateNetwork(_ networkId: Int?) {
        dataSource = DataSource(screen: .list)
        spinner.startAnimating()

        let url = Tmdb.tvURL(networkId: networkId)
        url?.apiGet { (result: Result<TvSearch, NetError>) in
            guard case .success(let search) = result else { return }

            let items = search.results.map { $0.listItem }
            self.dataSource.sections = [ Section(items: items) ]
            self.updateUI()
        }
    }

    func updatePerson(_ personId: Int?, limit: Int = Credit.numberOfEntries) {
        dataSource = DataSource(screen: .detail)
        spinner.startAnimating()

        let provider = PersonDataProvider()
        provider.get(personId) { (credit, articles, image) in
            guard let credit = credit else { return }

            self.dataSource.sections = Section.personSections(credit: credit, articles: articles, limit: limit)
            let buttonUrl = Tmdb.castProfileUrl(path: credit.profile_path, size: .large)
            self.updateUI(image, buttonUrl)
        }
    }

    func updateProduction(_ productionId: Int?) {
        dataSource = DataSource(screen: .list)
        spinner.startAnimating()

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
        dataSource = DataSource(screen: .detail)
        spinner.startAnimating()

        let provider = SeasonDataProvider()
        provider.get(seasonItem) { (season, image) in
            self.dataSource.sections = Section.seasonSections(season)
            let buttonUrl = Tmdb.mediaPosterUrl(path: season?.poster_path, size: .xxl)
            self.updateUI(image, buttonUrl)
        }
    }

    func updateSortedBy(_ sortedBy: String?) {
        dataSource = DataSource(screen: .list)
        spinner.startAnimating()

        let url = Tmdb.moviesURL(sortedBy: sortedBy)
        url?.apiGet { (result: Result<MediaSearch, NetError>) in
            guard case .success(let search) = result else { return }

            let items = search.results.map { $0.listItem }
            self.dataSource.sections = [ Section(items: items) ]
            self.updateUI()
        }
    }

    func updateTv(_ id: Int?, limit: Int = Credit.numberOfEntries) {
        dataSource = DataSource(screen: .detail)
        spinner.startAnimating()

        let provider = TvDataProvider()
        provider.get(id) { (tv, image, articles) in
            guard let tv = tv else { return }

            self.dataSource.sections = tv.tvSections(articles)
            let buttonUrl = Tmdb.mediaPosterUrl(path: tv.poster_path, size: .xxl)
            self.updateUI(image, buttonUrl)
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
