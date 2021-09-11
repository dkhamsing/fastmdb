//
//  MainListCellImage.swift
//  MainListCellImage
//
//  Created by Daniel on 9/11/21.
//  Copyright © 2021 dk. All rights reserved.
//

import UIKit

class MainListCellImage: UITableViewCell {

    static let height: CGFloat = 75

    var label1: UILabel!
    var label2: UILabel!
    var iv: UIImageView!

    var item: Item? {
        didSet {
            label1.text = item?.title
            label2.text = item?.subtitle
            accessoryType = item?.metadata?.destination == nil ? .none : .disclosureIndicator

            iv.load(urlString: item?.metadata?.imageUrl?.absoluteString, downloader: ImageDownloader.shared)

            if let c = item?.color {
                backgroundColor = c
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iv.image = nil
        iv.tag = -1
    }

}

private extension MainListCellImage {

    func setup() {
        let innerView = UIView()
        contentView.addSubviewForAutoLayout(innerView)
        NSLayoutConstraint.activate([
            innerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            innerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            innerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            innerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])

        iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.layer.masksToBounds = true
        innerView.addSubviewForAutoLayout(iv)
        NSLayoutConstraint.activate([
            iv.heightAnchor.constraint(equalToConstant: MainListCellImage.height - 30),
            iv.widthAnchor.constraint(equalToConstant: 65),
            iv.trailingAnchor.constraint(equalTo: innerView.trailingAnchor),
            iv.centerYAnchor.constraint(equalTo: innerView.centerYAnchor)
        ])

        label1 = UILabel()
        label1.numberOfLines = 0
        label1.font = .preferredFont(forTextStyle: .body)
        innerView.addSubviewForAutoLayout(label1)
        NSLayoutConstraint.activate([
            label1.topAnchor.constraint(equalTo: innerView.topAnchor),
            label1.leadingAnchor.constraint(equalTo: innerView.leadingAnchor),
            label1.trailingAnchor.constraint(equalTo: iv.leadingAnchor, constant: -10),
        ])

        label2 = UILabel()
        label2.numberOfLines = 0
        label2.textColor = .secondaryLabel
        label2.font = .preferredFont(forTextStyle: .caption1)
        innerView.addSubviewForAutoLayout(label2)
        NSLayoutConstraint.activate([
            label2.topAnchor.constraint(equalTo: label1.bottomAnchor, constant: 2),
            label2.bottomAnchor.constraint(equalTo: innerView.bottomAnchor),
            label2.trailingAnchor.constraint(equalTo: iv.leadingAnchor, constant: -10),
            label2.leadingAnchor.constraint(equalTo: innerView.leadingAnchor),
        ])
    }

}
