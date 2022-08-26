//
//  MainViewController+TableView.swift
//
//  Created by Daniel on 5/8/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit
import SwiftUI
import SafariServices

extension MainViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let s = dataSource[section]
        return s.header
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let s = dataSource[section]
        let display = s.metadata?.display ?? .text()

        switch display {
        case .text, .textImage:
            return s.items?.count ?? 0
        case .portraitImage, .thumbnailImage, .squareImage, .images, .tags:
            return 1
        }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let section = dataSource[indexPath.section]
        let display = section.metadata?.display ?? .text()

        switch display {

        // table
        case .text:
            guard let items = section.items else { return UITableViewCell() }
            let item = items[indexPath.row]
            let c = tableView.dequeueReusableCell(withIdentifier: CellType.plain.identifier, for: indexPath) as! MainListCell
            c.item = item
            return c
        case .textImage:
            guard let items = section.items else { return UITableViewCell() }
            let item = items[indexPath.row]
            let c = tableView.dequeueReusableCell(withIdentifier: CellType.image().identifier, for: indexPath) as! MainListCellImage
            c.item = item
            return c

        // collection
        case .tags, .images, .portraitImage, .thumbnailImage, .squareImage:
            let c = tableView.dequeueReusableCell(withIdentifier: MainListCollectionCell.identifier, for: indexPath) as! MainListCollectionCell
            c.load(display: display, items: section.items)
            c.tagsHandler.listener = self
            c.imagesHandler.listener = self
            c.portraitHandler.listener = self
            c.thumbnailHandler.listener = self
            c.squareHandler.listener = self
            return c
        }

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = dataSource[indexPath.section]
        let display = section.metadata?.display ?? .text()
        
        switch display {
        case .tags:
            return TagsCollectionViewCell.size.height
        case .images:
            return ImagesCollectionViewCell.size.height
        case .squareImage:
            return SquareCollectionViewCell.size.height
        case .portraitImage:
            return PortraitCollectionViewCell.size.height
        case .thumbnailImage:
            return ThumbnailCollectionViewCell.size.height
        case .text, .textImage:
            return UITableView.automaticDimension
        }
    }

}

extension MainViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let s = dataSource[indexPath.section]
        if let items = s.items {
            let item = items[indexPath.row]
            if let _ = item.metadata?.destination {
                return true
            }
        }

        return false
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let buttonSection = dataSource[section]

        guard let title = buttonSection.footer else { return nil }

        var frame = view.bounds
        frame.size.height = 30
        let button = DestinationButton(frame: frame)

        button.section = buttonSection
        button.autoresizingMask = [.flexibleWidth]
        button.addTarget(self, action: #selector(handleFooterButton), for: .touchUpInside)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .caption1)
        button.setTitleColor(.secondaryLabel, for: .normal)

        return button
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigationItem.searchController?.searchBar.resignFirstResponder()

        let s = dataSource[indexPath.section]
        guard let items = s.items else { return }
        let item = items[indexPath.row]

        loadDestination(item)
    }

}

extension MainViewController: CollectionListener {

    func doTapItem(_ item: Item) {
        loadDestination(item)
    }

}

private extension MainViewController {

    func loadDestination(_ item: Item) {
        guard let destination = item.metadata?.destination else { return }

        switch destination {
        case .collection:
            let controller = MainViewController()
            controller.title = item.title
            controller.collectionId = item.metadata?.id
            navigationController?.pushViewController(controller, animated: true)
        case .episode:
            let controller = MainViewController()
            controller.title = item.title
            controller.updateEpisode(tvId: item.metadata?.id, episode: item.metadata?.episode)
            navigationController?.pushViewController(controller, animated: true)
        case .genreMovie:
            let controller = MainViewController()
            controller.title = item.title
            controller.genreMovieId = item.metadata?.id
            navigationController?.pushViewController(controller, animated: true)
        case .genreTv:
            let controller = MainViewController()
            controller.title = item.title
            controller.genreTvId = item.metadata?.id
            navigationController?.pushViewController(controller, animated: true)
        case .items:
            let controller = MainViewController()
            controller.title = item.metadata?.destinationTitle
            controller.items = item.metadata?.items
            navigationController?.pushViewController(controller, animated: true)
        case .movie:
            // MARK: known issue that the rating in api list and api detail is sometimes different
            let controller = MainViewController()
            controller.title = item.title
            controller.movieId = item.metadata?.id
            navigationController?.pushViewController(controller, animated: true)
        case .moviesSortedBy:
            // TODO: able to load more than one page of highest grossing
            let controller = MainViewController()

            if let sorted = item.metadata?.sortedBy {
                switch sorted {
                case .byVote:
                    controller.voteCountGreaterThanOrEqual = 1000
                    controller.title = Tmdb.Url.Kind.Movies.top_rated_movies.title
                case .byRevenue:
                    controller.title = Tmdb.Url.Kind.Movies.highest_grossing.title
                }
            }

            controller.releaseYear = item.metadata?.releaseYear
            controller.sortedBy = item.metadata?.sortedBy
            navigationController?.pushViewController(controller, animated: true)
        case .music:
            guard let albums = item.metadata?.albums else { return }

            let contentView = MusicView(albums: albums)
            let controller = UIHostingController(rootView: contentView)
            navigationController?.pushViewController(controller, animated: true)
        case .network:
            let controller = MainViewController()
            controller.title = item.title
            controller.networkId = item.metadata?.id
            navigationController?.pushViewController(controller, animated: true)
        case .person:
            let controller = MainViewController()
            controller.title = item.title
            controller.personId = item.metadata?.id
            navigationController?.pushViewController(controller, animated: true)
        case .production:
            let controller = MainViewController()
            controller.title = item.title
            controller.productionId = item.metadata?.id
            navigationController?.pushViewController(controller, animated: true)
        case .safarivc:
            guard let url = item.metadata?.url else { return }
            let sfvc = SFSafariViewController(url: url)
            sfvc.modalPresentationStyle = .formSheet
            present(sfvc, animated: true, completion: nil)
        case .season:
            let controller = MainViewController()
            controller.title = item.title
            controller.seasonItem = item
            navigationController?.pushViewController(controller, animated: true)
        case .sections:
            let controller = MainViewController()
            controller.title = item.metadata?.destinationTitle
            controller.sections = item.metadata?.sections
            navigationController?.pushViewController(controller, animated: true)
        case .tv:
            let controller = MainViewController()
            controller.title = item.title
            controller.tvId = item.metadata?.id
            navigationController?.pushViewController(controller, animated: true)
        case .tvCredit:
            let controller = MainViewController()
            controller.updateCredit(id: item.metadata?.id, creditId: item.metadata?.identifier)
            navigationController?.pushViewController(controller, animated: true)
        case .url:
            guard let url = item.metadata?.url else { return }
            UIApplication.shared.open(url)
        case .videos:
            guard
                let items = item.metadata?.items,
                items.count > 0 else { return }

            let contentView = VideoView(items: items)
            let controller = UIHostingController(rootView: contentView)
            navigationController?.pushViewController(controller, animated: true)
        default:
            print("todo for \(item)")
        }
    }

}

private extension MainViewController {

    @objc
    func handleFooterButton(_ button: DestinationButton) {

        guard
            let section = button.section,
            let s = section.metadata?.destination else { return }

        switch s {
        case .best:
            let controller = MainViewController()
            controller.loadContent(.top_rated)
            controller.screen = .list
            navigationController?.pushViewController(controller, animated: true)
        case .items:
            let controller = MainViewController()
            controller.title = section.metadata?.destinationTitle
            controller.items = section.metadata?.items
            navigationController?.pushViewController(controller, animated: true)
        case .sections:
            let controller = MainViewController()
            controller.title = section.metadata?.destinationTitle
            controller.sections = section.metadata?.sections
            navigationController?.pushViewController(controller, animated: true)
        case .moviesSortedBy:
            let controller = MainViewController()
            controller.title = section.metadata?.sortedBy?.display
            controller.voteCountGreaterThanOrEqual = 1000
            controller.sortedBy = section.metadata?.sortedBy
            navigationController?.pushViewController(controller, animated: true)
        default:
            print("handle button not implemented for \(s)")
        }

    }

}

private class DestinationButton: UIButton {

    var section: ItemSection?

}
