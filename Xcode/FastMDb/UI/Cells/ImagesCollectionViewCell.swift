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
    static let size: CGSize = CGSize(width: 200, height: 150)

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
        imageView.load(urlString: item.imageUrl?.absoluteString, size: size, downloader: ImageDownloader.shared)
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

        if let display = display,
           display == .portraitImage {
            size.width = 100
        }

        return size
    }
}


class TagsCollectionViewCell: UICollectionViewCell {

    static let identifier = "TagsCollectionViewCell"
    static let size: CGSize = CGSize(width: 50, height: 40)
    static let font: UIFont = .preferredFont(forTextStyle: .caption1)

    var label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func load(_ item: Item) {
        label.text = item.title
    }

    func setup() {
        label.textAlignment = .center
        label.font = TagsCollectionViewCell.font
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.backgroundColor = .secondarySystemFill

        [label].forEach {
            contentView.addSubviewForAutoLayout($0)
        }

        let height = TagsCollectionViewCell.size.height - 10
        NSLayoutConstraint.activate([
            label.heightAnchor.constraint(equalToConstant: height),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

}

extension Item {
    var textSize: CGSize {
        let padding: CGFloat = 22
        var size = TagsCollectionViewCell.size
        let attributes: [NSAttributedString.Key: Any] = [.font: TagsCollectionViewCell.font]
        let attributed = NSAttributedString(string: title ?? "", attributes: attributes)
        size.width = attributed.size().width + padding

        return size
    }
}
