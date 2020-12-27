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
    static let size: CGSize = CGSize(width: 90, height: 150)

    var imageView = UIImageView()
    var label = UILabel()
    var label2 = UILabel()
    var initials = UILabel()

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
        label2.text = item.subtitle

        let size = ImageCollectionViewCell.size
        imageView.load(urlString: item.imageUrl?.absoluteString, size: size, downloader: ImageDownloader.shared) {
            self.initials.isHidden = self.imageView.image != nil
        }

        guard let name = item.title?.split(separator: " "),
              let first = name.first
              else { return }

        initials.text = String(first.prefix(1))

        if name.indices.contains(1) {
            let last = name[1]
            if let text = initials.text {
                initials.text = text + String(last.prefix(1))
            }
        }
    }

    func setup() {
        imageView.backgroundColor = .systemGray5
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true

        label.font = .preferredFont(forTextStyle: .caption1)
        label.textAlignment = .center

        label2.font = .preferredFont(forTextStyle: .caption1)
        label2.textAlignment = .center
        label2.textColor = .secondaryLabel

        initials.font = .preferredFont(forTextStyle: .largeTitle)
        initials.textAlignment = .center
        initials.textColor = .systemGray

        [imageView, initials, label, label2].forEach {
            contentView.addSubviewForAutoLayout($0)
        }

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            initials.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            initials.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),

            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 2),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            label2.topAnchor.constraint(equalTo: label.bottomAnchor),
            label2.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label2.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label2.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

}
