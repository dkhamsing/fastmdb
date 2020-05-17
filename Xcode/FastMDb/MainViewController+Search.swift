//
//  MainViewController+Search.swift
//
//  Created by Daniel on 5/8/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit

struct TableSearch {
    var query: String?
    var savedDataSource: DataSource?
    var savedHeader: UIView?
}

extension MainViewController: UISearchControllerDelegate {

    func didDismissSearchController(_ searchController: UISearchController) {
        guard let saved = search.savedDataSource else { return }

        guard saved.sections.count > 0 else { return }

        self.dataSource = saved
        self.tableView.tableHeaderView = search.savedHeader
        self.tableView.reloadData()
    }

}

extension MainViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        guard
            let text = searchController.searchBar.text,
            text.count > 2 else { return }

        if dataSource.screen != .search {
            search.savedDataSource = dataSource
            search.savedHeader = tableView.tableHeaderView
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
        dataSource.sections = []
        tableView.reloadData()
        tableView.tableHeaderView = nil

        spinner.startAnimating()

        let provider = SearchDataProvider()
        provider.get(query) { (movie, tv, people) in
            // TODO: show summary in bottom buttons?: movies (3), tv(5), people (2)

            let sections = Section.searchSection(movie, tv, people)
            let dataSource = DataSource(screen: .search, sections: sections)
            self.dataSource = dataSource

            self.spinner.stopAnimating()

            self.tableView.reloadData()

            if self.dataSource.screen == .detail {
                self.title = "Search"
            }
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
