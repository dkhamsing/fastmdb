//
//  SquareCollectionViewCell.swift
//  FastMDb
//
//  Created by Daniel on 12/31/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit

class SquareCollectionViewCell: UICollectionViewCell {

    static let identifier = "SquareCollectionViewCell"
    static let size: CGSize = CGSize(width: 44, height: 44)

    var imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = nil
    }

    func load(_ item: Item) {
        let size = SquareCollectionViewCell.size
        if let corner = item.metadata?.imageCornerRadius {
            imageView.layer.cornerRadius = corner
        }
        imageView.load(urlString: item.metadata?.imageUrl?.absoluteString, size: size, downloader: ImageDownloader.shared)
    }

    func setup() {
        imageView.backgroundColor = .systemGray5
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true

        [imageView].forEach {
            contentView.addSubviewForAutoLayout($0)
        }

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

}
