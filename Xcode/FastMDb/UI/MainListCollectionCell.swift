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

    var imagesHandler = ImagesHandler()
    var portraitHandler = CollectionHandler()
    var thumbnailHandler = CollectionThumbnailHandler()
    var squareHandler = CollectionSquareHandler()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    func update(display: Display, items: [Item]?) {
        switch display {
        case .portraitImage:
            collection.dataSource = portraitHandler
            collection.delegate = portraitHandler

            if let items = items {
                portraitHandler.items = items
                collection.reloadData()
            }

        case .thumbnailImage:
            collection.dataSource = thumbnailHandler
            collection.delegate = thumbnailHandler

            if let items = items {
                thumbnailHandler.items = items
                collection.reloadData()
            }

        case .squareImage:
            collection.dataSource = squareHandler
            collection.delegate = squareHandler

            if let items = items {
                squareHandler.items = items
                collection.reloadData()
            }

        case .images:

            collection.dataSource = imagesHandler
            collection.delegate = imagesHandler

            if let items = items {
                imagesHandler.items = items
                collection.reloadData()
            }

        case .text:
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
            ImagesCollectionViewCell.identifier
        ]
        collection = UICollectionView(frame: bounds, direction: .horizontal, identifiers: identifiers)
        collection.backgroundColor = .background
        collection.showsHorizontalScrollIndicator = false
        collection.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        contentView.addSubview(collection)
    }
}
