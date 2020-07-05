//
//  MainViewController+Search.swift
//
//  Created by Daniel on 5/8/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit

struct TableSearch {

    var query: String?
    var savedDataSource: [ItemSection]?
    var savedHeader: UIView?
    var savedTitle: String?
    
}

extension MainViewController: UISearchControllerDelegate {

    func didDismissSearchController(_ searchController: UISearchController) {
        guard let saved = search.savedDataSource else { return }

        guard saved.count > 0 else { return }

        dataSource = saved
        tableView.tableHeaderView = search.savedHeader
        title = search.savedTitle

        tableView.reloadData()

        searchResultsButtons.isHidden = true
        tableView.contentInset = .zero
    }

}

extension MainViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        guard
            let text = searchController.searchBar.text,
            text.count > 2 else { return }

        if screen != .search {
            search.savedDataSource = dataSource
            search.savedHeader = tableView.tableHeaderView
            search.savedTitle = title
        }

        search.query = text

        /// Credits: https://stackoverflow.com/questions/24330056/how-to-throttle-search-based-on-typing-speed-in-ios-uisearchbar
        /// to limit network activity, reload half a second after last key press.
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(loadSearch), object: nil)
        perform(#selector(loadSearch), with: nil, afterDelay: 0.5)
    }

}

private extension MainViewController {

    @objc
    func loadSearch() {
        guard let query = search.query else { return }

        dataSource = []
        tableView.reloadData()
        tableView.tableHeaderView = nil

        spinner.startAnimating()

        let provider = SearchDataProvider()
        provider.get(query) { (movie, tv, people, articles) in
            let section = ItemSection.searchSection(movie, tv, people, articles)
            let u = Updater(dataSource: section)
            self.updateScreen(u)

            self.screen = .search

            let buttonConfigs = [
                StackButtonConfiguration(label: "News", value: articles?.count, kind: .news, showCount: false),
                StackButtonConfiguration(label: "Movies", value: movie?.total_results, kind: .movie),
                StackButtonConfiguration(label: "TV", value: tv?.total_results, kind: .tv),
                StackButtonConfiguration(label: "People", value: people?.total_results, kind: .people)
            ]
            self.searchResultsButtons.update(buttonConfigs)

            self.searchResultsButtons.isHidden = false
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: StackButtons.height, right: 0)
        }
    }

}

extension MainViewController {

    func activateSearch() {
        if let searchbar = self.navigationItem.searchController?.searchBar {
            searchbar.becomeFirstResponder()
        } else {
            startSearch = true
        }
    }

}

extension MainViewController: SelectKind {

    func didselectKind(_ kind: SearchKind) {
        let headers = dataSource.compactMap { $0.header }
        let s = sectionIndex(headers: headers, kind: kind)
        let ip = IndexPath(item: 0, section: s)
        tableView.scrollToRow(at: ip, at: .top, animated: true)
    }

}

private extension MainViewController {

    func sectionIndex(headers: [String], kind: SearchKind) -> Int {
        switch kind {
        case .movie:
            return sectionIndex(headers: headers, string: "movie")
        case .people:
            return sectionIndex(headers: headers, string: "people")
        case .tv:
            return sectionIndex(headers: headers, string: "tv")
        default:
            return 0
        }
    }

    func sectionIndex(headers: [String], string: String) -> Int {
        var s = 0
        for (index,value) in headers.enumerated() {
            if value.lowercased().contains(string) {
                s = index
            }
        }

        return s
    }

}
