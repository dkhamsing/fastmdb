//
//  MainViewController+TableView.swift
//
//  Created by Daniel on 5/8/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit

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
        return s.items?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let section = dataSource[indexPath.section]
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
            controller.title = "Highest Grossing"
            controller.sortedBy = item.sortedBy
            navigationController?.pushViewController(controller, animated: true)
        case .music:
            guard let url = item.url else { return }

            let contentView = MusicView(url: url)
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

            let controller = VideosViewController()
            controller.items = item.items
            navigationController?.pushViewController(controller, animated: true)
        default:
            print("todo for \(item)")
        }
    }

}

// TODO: rewrite using SwiftUI
// TODO: move to own file
import LinkPresentation
class VideosViewController: UIViewController {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)

    var dataSource: UITableViewDiffableDataSource<VideoSection,VideoItem>!

    enum VideoSection: CaseIterable {
        case main
    }

    var items: [Item]? {
        didSet {
            guard
                let items = items,
                items.count > 0 else { return }

            fetchImages(items)

            let ds = makeDataSource()
            dataSource = ds
            tableView.dataSource = ds

            var snapshot = NSDiffableDataSourceSnapshot<VideoSection,VideoItem>()
            snapshot.appendSections([.main])
            snapshot.appendItems(items.map{$0.videoItem}, toSection: .main)
            dataSource.apply(snapshot, animatingDifferences: false)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Videos"
        setup()
    }

    func makeDataSource() -> UITableViewDiffableDataSource<VideoSection,VideoItem> {
        return UITableViewDiffableDataSource<VideoSection, VideoItem>(tableView: tableView) { (tableView, indexPath, videoItem) -> UITableViewCell? in
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "videoId")

            cell.textLabel?.text = videoItem.title
            cell.detailTextLabel?.text = videoItem.subtitle
            cell.imageView?.image = videoItem.image

            cell.detailTextLabel?.textColor = .secondaryLabel

            return cell
        }
    }

    // TODO: cache images
    func fetchImages(_ items: [Item]) {
        let group = DispatchGroup()
        var videoItems: [VideoItem] = []
        for item in items {
            if let url = item.url {
                group.enter()
                print(url)
                let provider = LPMetadataProvider()
                provider.startFetchingMetadata(for: url) { (metadata, error) in
                    if let metadata = metadata,
                        let imageProvider = metadata.imageProvider {
//                        print(metadata)
                        imageProvider.loadObject(ofClass: UIImage.self) { image, _ in
                            if let image = image as? UIImage {
//                                print("\(url.absoluteString): got image with size \(image.size)")
                                var vi = item.videoItem
                                vi.image = image
                                videoItems.append(vi)
                            }
                            group.leave()
                        }
                    }
                    else {
                        group.leave()
                    }
                }
            }
        }

        group.notify(queue: .main) {
//            print("we're finished with items \(videoItems)")

            var snapshot = NSDiffableDataSourceSnapshot<VideoSection,VideoItem>()
            snapshot.appendSections([.main])


            var sorted: [VideoItem] = []
            for item in items {
                let filtered = videoItems
                    .filter { $0.url?.absoluteString == item.url?.absoluteString }

                if let f = filtered.first {
                    sorted.append(f)
                }
                else {
                    sorted.append(item.videoItem)
                }
            }

            snapshot.appendItems(sorted, toSection: .main)
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }

    func setup() {
        tableView.delegate = self

        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tableView)
    }
}

extension VideosViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let snapshot = dataSource.snapshot()
        let items = snapshot.itemIdentifiers
        let item = items[indexPath.row]

        guard let url = item.url else { return }

        UIApplication.shared.open(url)
    }
}

struct VideoItem: Hashable {
    let title: String?
    let subtitle: String?
    var image: UIImage?
    var url: URL?
}

extension Item {
    var videoItem: VideoItem {
        return VideoItem(title: title, subtitle: subtitle, url: url)
    }
}

private class DestinationButton: UIButton {
    var section: Section?
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
        default:
            print("handle button not implemented for \(s)")
        }

    }

}




// TODO: move to own file
import SwiftUI
import Combine
struct MusicView: View {
    var url: URL?
    @ObservedObject private var api = iTunesApi()
    var body: some View {
            List(api.songs) { song in
                SongRow(song: song)
            }
            .navigationBarTitle("Music")
        .onAppear {
            guard let url = url else { return }
            api.searchSongs(url: url)
        }
    }
}

struct SongRow: View {
    var song: iTunes.Song

    var body: some View {
        Button(action: {
            UIApplication.shared.open(song.trackViewUrl)
        }, label: {
            VStack(alignment: .leading) {
                RemoteImage(url: song.artworkUrl100)
                    .frame(width: 100)
                Text(song.title)
            }
        })
        .buttonStyle(PlainButtonStyle())
    }
}

// TODO: group music by album
class iTunesApi: ObservableObject {
    @Published var songs: [iTunes.Song] = []
    private var stream: Set<AnyCancellable> = Set()

    func searchSongs(url: URL) {
        print(url.absoluteString)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        URLSession.shared.dataTaskPublisher(for: url)
            .map {$0.data}
            .decode(type: iTunes.Feed.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (completion) in
                print(completion)
            }) { (feed) in
                self.songs = feed.results
            }.store(in: &stream)
    }
}
