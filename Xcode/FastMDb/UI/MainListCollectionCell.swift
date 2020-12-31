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
    var portraitHandler = CollectionHandler()
    var thumbnailHandler = CollectionThumbnailHandler()

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

        default:
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
            ImageCollectionViewCell.identifier,
            ThumbnailCollectionViewCell.identifier
        ]
        collection = UICollectionView(frame: bounds, direction: .horizontal, identifiers: identifiers)
        collection.backgroundColor = .background
        collection.showsHorizontalScrollIndicator = false
        collection.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        contentView.addSubview(collection)
    }
}

private extension UIColor {
    static var background: UIColor {
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return .black
            } else {
                return .secondarySystemBackground
            }
        }
    }
}
