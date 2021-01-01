//
//  PortraitCollectionViewCell.swift
//  FastMDb
//
//  Created by Daniel on 12/24/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit

class PortraitCollectionViewCell: UICollectionViewCell {

    static let identifier = "PortraitCollectionViewCell"
    static let size: CGSize = CGSize(width: 90, height: 160)
    let ratingWidth: CGFloat = 14

    var imageView = UIImageView()
    var label = UILabel()
    var label2 = UILabel()
    var initials = UILabel()
    var ratingLabel = UILabel()

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
        ratingLabel.backgroundColor = .clear
    }

    func load(_ item: Item) {
        label.text = item.title
        label2.text = item.subtitle

        let size = PortraitCollectionViewCell.size
        imageView.load(urlString: item.imageUrl?.absoluteString, size: size, downloader: ImageDownloader.shared) {
            self.initials.isHidden = self.imageView.image != nil
        }

        initials.text = item.centerLabelText

        if let color = item.color {
            ratingLabel.backgroundColor = color
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

        ratingLabel.layer.cornerRadius = ratingWidth / 2
        ratingLabel.layer.masksToBounds = true

        [imageView, initials, label, label2, ratingLabel].forEach {
            contentView.addSubviewForAutoLayout($0)
        }

        let ratingInset: CGFloat = 4
        let height: CGFloat = 13
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            initials.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            initials.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),

            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 2),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.heightAnchor.constraint(equalToConstant: height),

            label2.topAnchor.constraint(equalTo: label.bottomAnchor),
            label2.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label2.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label2.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            label2.heightAnchor.constraint(equalToConstant: height),

            ratingLabel.topAnchor.constraint(equalTo: imageView.topAnchor, constant: ratingInset),
            imageView.trailingAnchor.constraint(equalTo: ratingLabel.trailingAnchor, constant: ratingInset),
            ratingLabel.widthAnchor.constraint(equalToConstant: ratingWidth),
            ratingLabel.heightAnchor.constraint(equalToConstant: ratingWidth),
        ])
    }

}
