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
    var handler = CollectionHandler()
    var handler2 = CollectionThumbnailHandler()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    func update(display: Display) {
        switch display {
        case .collection:
            collection.dataSource = handler
            collection.delegate = handler
        case .thumbnail:
            collection.dataSource = handler2
            collection.delegate = handler2
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
