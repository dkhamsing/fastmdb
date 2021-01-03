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
    static let size: CGSize = CGSize(width: 90, height: 174)
    static let height: CGFloat = 13
    let ratingWidth: CGFloat = 14

    var imageView = UIImageView()
    var label = UILabel()
    var label2 = UILabel()
    var label3 = UILabel()
    var initials = UILabel()
    var ratingLabel = UILabel()
    var label3HeightConstraint: NSLayoutConstraint!

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
        if let strings = item.strings {
            label3HeightConstraint.constant = PortraitCollectionViewCell.height

            label.text = strings.first

            if strings.indices.contains(1) {
                label2.text = strings[1]
            }

            if strings.indices.contains(2) {
                label3.text = strings[2]
                contentView.layoutIfNeeded()
            }
        } else {
            label.text = item.title
            label2.text = item.subtitle
        }

        let size = PortraitCollectionViewCell.size
        imageView.load(urlString: item.imageUrl?.absoluteString, size: size, downloader: ImageDownloader.shared) {
            self.initials.isHidden = self.imageView.image != nil
        }

        initials.text = item.imageCenterText

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

        label3.font = .preferredFont(forTextStyle: .caption1)
        label3.textAlignment = .center
        label3.textColor = .secondaryLabel

        initials.font = .preferredFont(forTextStyle: .largeTitle)
        initials.textAlignment = .center
        initials.textColor = .systemGray

        ratingLabel.layer.cornerRadius = ratingWidth / 2
        ratingLabel.layer.masksToBounds = true

        [imageView, initials, label, label2, label3, ratingLabel].forEach {
            contentView.addSubviewForAutoLayout($0)
        }

        let ratingInset: CGFloat = 4
        let height = PortraitCollectionViewCell.height
        label3HeightConstraint = label3.heightAnchor.constraint(equalToConstant: 0)
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
            label2.heightAnchor.constraint(equalToConstant: height),

            label3.topAnchor.constraint(equalTo: label2.bottomAnchor),
            label3.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label3.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label3.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            label3HeightConstraint,

            ratingLabel.topAnchor.constraint(equalTo: imageView.topAnchor, constant: ratingInset),
            imageView.trailingAnchor.constraint(equalTo: ratingLabel.trailingAnchor, constant: ratingInset),
            ratingLabel.widthAnchor.constraint(equalToConstant: ratingWidth),
            ratingLabel.heightAnchor.constraint(equalToConstant: ratingWidth),
        ])
    }

}
