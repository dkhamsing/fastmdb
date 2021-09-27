//
//  MainListCollectionCell.swift
//  FastMDb
//
//  Created by Daniel on 12/24/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit

class MainListCollectionCell: UITableViewCell {
    static let identifier = "MainListCollectionCell"

    var collection: UICollectionView!

    var tagsHandler = CollectionTagHandler()
    var imagesHandler = CollectionImagesHandler()
    var portraitHandler = CollectionPortraitHandler()
    var thumbnailHandler = CollectionThumbnailHandler()
    var squareHandler = CollectionSquareHandler()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    func load(display: Display, items: [Item]?) {

        guard let items = items else { return }

        switch display {
        case .tags:
            collection.dataSource = tagsHandler
            collection.delegate = tagsHandler
            tagsHandler.items = items
            collection.reloadData()
        case .portraitImage:
            collection.dataSource = portraitHandler
            collection.delegate = portraitHandler
            portraitHandler.items = items
            collection.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
            collection.reloadData()
        case .thumbnailImage:
            collection.dataSource = thumbnailHandler
            collection.delegate = thumbnailHandler
            thumbnailHandler.items = items
            collection.reloadData()
        case .squareImage:
            collection.dataSource = squareHandler
            collection.delegate = squareHandler
            squareHandler.items = items
            collection.reloadData()
        case .images:
            collection.dataSource = imagesHandler
            collection.delegate = imagesHandler
            imagesHandler.items = items
            collection.reloadData()
        case .text, .textImage:
            break
        }

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

private extension MainListCollectionCell {
    func setup() {
        let identifiers = [
            PortraitCollectionViewCell.identifier,
            ThumbnailCollectionViewCell.identifier,
            SquareCollectionViewCell.identifier,
            ImagesCollectionViewCell.identifier,
            TagsCollectionViewCell.identifier
        ]
        collection = UICollectionView(frame: bounds, direction: .horizontal, identifiers: identifiers)
        collection.backgroundColor = .background
        collection.showsHorizontalScrollIndicator = false
        collection.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        contentView.addSubview(collection)
    }
}
