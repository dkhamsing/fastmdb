//
//  ImageCollectionViewCell.swift
//  FastMDb
//
//  Created by Daniel on 12/24/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    static let identifier = "ImageCollectionViewCell"
    static let size: CGSize = CGSize(width: 90, height: 140)

    var imageView = UIImageView()
    var label = UILabel()

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
        label.text = item.title

        let size = ImageCollectionViewCell.size
        imageView.load(urlString: item.imageUrl?.absoluteString, size: size, downloader: ImageDownloader.shared)
    }

    func setup() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true

        label.font = .preferredFont(forTextStyle: .caption1)
        label.textAlignment = .center
        label.textColor = .secondaryLabel

        [imageView, label].forEach {
            contentView.addSubviewForAutoLayout($0)
        }

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 2),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

}
