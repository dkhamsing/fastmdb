//
//  MainViewController+TableView.swift
//
//  Created by Daniel on 5/8/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit
import SwiftUI

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

        switch s.display {
        case .table:
            return s.items?.count ?? 0
        case .collection:
            return 1
        }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let section = dataSource[indexPath.section]

        switch section.display {
        case .table:
            guard let items = section.items else { return UITableViewCell() }

            let item = items[indexPath.row]

            if let _ = item.color {
                let c = tableView.dequeueReusableCell(withIdentifier: CellType.color.rawValue, for: indexPath) as! MainListCell
                c.item = item
                return c
            }
            else {
                let c = tableView.dequeueReusableCell(withIdentifier: CellType.regular.rawValue, for: indexPath) as! MainListCell
                c.item = item
                return c
            }
        case .collection:
            let c = tableView.dequeueReusableCell(withIdentifier: MainListCollectionCell.identifier, for: indexPath) as! MainListCollectionCell

            if let items = section.items {
                c.handler.items = items
                c.handler.listener = self
                c.collection.reloadData()
            }
            
            return c 
        }

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = dataSource[indexPath.section]
        switch section.display {
        case .collection:
            return ImageCell.size.height
        case .table:
            return UITableView.automaticDimension
        }
    }

}

extension MainViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let s = dataSource[indexPath.section]
        if let items = s.items {
            let item = items[indexPath.row]
            if let _ = item.destination {
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

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = tableView.contentOffset.y + tableView.safeAreaInsets.top
        imageButton.alpha = (300 - value)/300
    }

}

private extension MainViewController {

    func loadDestination(_ item: Item) {
        guard let destination = item.destination else { return }

        switch destination {
        case .collection:
            let controller = MainViewController()
            controller.title = item.title
            controller.collectionId = item.id
            navigationController?.pushViewController(controller, animated: true)
        case .episode:
            let controller = MainViewController()
            controller.title = item.title
            controller.episode = item.episode
            navigationController?.pushViewController(controller, animated: true)
        case .genreMovie:
            let controller = MainViewController()
            controller.title = item.title
            controller.genreMovieId = item.id
            navigationController?.pushViewController(controller, animated: true)
        case .genreTv:
            let controller = MainViewController()
            controller.title = item.title
            controller.genreTvId = item.id
            navigationController?.pushViewController(controller, animated: true)
        case .items:
            let controller = MainViewController()
            controller.title = item.destinationTitle
            controller.items = item.items
            navigationController?.pushViewController(controller, animated: true)
        case .movie:
            // MARK: known issue that the rating in api list and api detail is sometimes different
            let controller = MainViewController()
            controller.title = item.title
            controller.movieId = item.id
            navigationController?.pushViewController(controller, animated: true)
        case .moviesSortedBy:
            // TODO: able to load more than one page of highest grossing
            let controller = MainViewController()

            var thisTitle = "Highest Grossing"

            if let releaseYear = item.releaseYear {
                thisTitle += " (\(releaseYear))"
            }

            controller.title = thisTitle
            controller.releaseYear = item.releaseYear
            controller.sortedBy = item.sortedBy
            navigationController?.pushViewController(controller, animated: true)
        case .music:
            guard let albums = item.albums else { return }

            let contentView = MusicView(albums: albums)
            let controller = UIHostingController(rootView: contentView)
            navigationController?.pushViewController(controller, animated: true)
        case .network:
            let controller = MainViewController()
            controller.title = item.title
            controller.networkId = item.id
            navigationController?.pushViewController(controller, animated: true)
        case .person:
            let controller = MainViewController()
            controller.title = item.title
            controller.personId = item.id
            navigationController?.pushViewController(controller, animated: true)
        case .production:
            let controller = MainViewController()
            controller.title = item.title
            controller.productionId = item.id
            navigationController?.pushViewController(controller, animated: true)
        case .season:
            let controller = MainViewController()
            controller.title = item.title
            controller.seasonItem = item
            navigationController?.pushViewController(controller, animated: true)
        case .tv:
            let controller = MainViewController()
            controller.title = item.title
            controller.tvId = item.id
            navigationController?.pushViewController(controller, animated: true)
        case .url:
            guard let url = item.url else { return }
            UIApplication.shared.open(url)
        case .videos:
            guard
                let items = item.items,
                items.count > 0 else { return }

            let contentView = VideoView(items: items)
            let controller = UIHostingController(rootView: contentView)
            navigationController?.pushViewController(controller, animated: true)

//            let controller = VideosViewController()
//            controller.items = item.items
//            navigationController?.pushViewController(controller, animated: true)
        default:
            print("todo for \(item)")
        }
    }

}

private class DestinationButton: UIButton {
    var section: ItemSection?
}

private extension MainViewController {

    @objc
    func handleFooterButton(_ button: DestinationButton) {

        guard
            let section = button.section,
            let s = section.destination else { return }

        switch s {
        case .items:
            let controller = MainViewController()
            controller.title = section.destinationTitle
            controller.items = section.destinationItems
            navigationController?.pushViewController(controller, animated: true)
        case .sections:
            let controller = MainViewController()
            controller.title = section.destinationTitle
            controller.sections = section.destinationSections
            navigationController?.pushViewController(controller, animated: true)
        case .moviesSortedBy:
            let controller = MainViewController()
            controller.title = "Highest Grossing"
            controller.sortedBy = "revenue.desc"
            navigationController?.pushViewController(controller, animated: true)
        default:
            print("handle button not implemented for \(s)")
        }

    }

}



protocol CollectionListener: class {

    func doTapItem(_ item: Item)

}


extension MainViewController: CollectionListener {
    func doTapItem(_ item: Item) {
        loadDestination(item)
    }
}
