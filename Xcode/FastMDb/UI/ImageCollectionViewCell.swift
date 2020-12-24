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
    static let size: CGSize = CGSize(width: 100, height: 140)

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

    func setup() {
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true

        contentView.addSubviewForAutoLayout(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

}
