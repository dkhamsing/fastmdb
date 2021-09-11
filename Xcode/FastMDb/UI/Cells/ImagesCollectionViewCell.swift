//
//  ImagesCollectionViewCell.swift
//  FastMDb
//
//  Created by Daniel on 1/1/21.
//  Copyright © 2021 dk. All rights reserved.
//

import UIKit

class ImagesCollectionViewCell: UICollectionViewCell {

    static let identifier = "ImagesCollectionViewCell"
    static let size: CGSize = CGSize(width: 290, height: 230)
    static let portraitWidth: CGFloat = 140

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
        let size = item.imageSize
        imageView.load(urlString: item.metadata?.imageUrl?.absoluteString, size: size, downloader: ImageDownloader.shared)
    }

    func setup() {
        imageView.backgroundColor = .systemGray5
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
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

extension Item {
    var imageSize: CGSize {
        var size = ImagesCollectionViewCell.size

        switch metadata?.display {
        case .portraitImage:
            size.width = ImagesCollectionViewCell.portraitWidth
        default:
            break
        }

        return size
    }
}
