//
//  MainListCell.swift
//
//  Created by Daniel on 5/6/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit

class MainListCell: UITableViewCell {

    var item: Item? {
        didSet {
            textLabel?.text = item?.title
            detailTextLabel?.text = item?.subtitle
            accessoryType = item?.destination == nil ? .none : .disclosureIndicator
            imageView?.image = item?.image

            if let c = item?.color {
                backgroundColor = c
            }
            else {
                backgroundColor = .white
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

        textLabel?.text = nil
        detailTextLabel?.text = nil
        imageView?.image = nil
    }

}

private extension MainListCell {
    func setup() {
        imageView?.tintColor = .secondaryLabel
        textLabel?.numberOfLines = 0

        detailTextLabel?.numberOfLines = 0
        detailTextLabel?.textColor = .secondaryLabel
    }
}

class MainListCollectionCell: UITableViewCell {
    static let identifier = "MainListCollectionCell"

    var collection: UICollectionView!
    var handler = CollectionHandler()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

private extension MainListCollectionCell {
    func setup() {
//        contentView.backgroundColor = .clear

        collection = UICollectionView(frame: bounds, direction: .horizontal, identifiers: [ImageCell.identifier])
        collection.backgroundColor = .secondarySystemBackground
        collection.dataSource = handler
        collection.delegate = handler
        collection.showsHorizontalScrollIndicator = false
        collection.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        contentView.addSubview(collection)
    }
}

class ImageCell: UICollectionViewCell {
    static let identifier = "ImageCell"
    static let height: CGFloat = 100

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

extension UIView {
    func addSubviewForAutoLayout(_ view: UIView) {
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension UICollectionView {
    convenience init( frame: CGRect, direction: UICollectionView.ScrollDirection, identifiers: [String]) {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = direction
        layout.minimumLineSpacing = 0

        self.init(frame: frame, collectionViewLayout: layout)

        guard let nameSpace = Bundle.nameSpace else { return }

        for identifier in identifiers {
            if let anyClass: AnyClass = NSClassFromString("\(nameSpace).\(identifier)") {
                self.register(anyClass, forCellWithReuseIdentifier: identifier)
            }
        }
    }

}

extension Bundle {

    static var nameSpace: String? {
        guard let info = Bundle.main.infoDictionary,
              let projectName = info["CFBundleExecutable"] as? String else { return nil }

        let nameSpace = projectName.replacingOccurrences(of: "-", with: "_")

        return nameSpace
    }

}

class CollectionHandler: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    var items: [Item] = []

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let c = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as! ImageCell

        let item = items[indexPath.row]

        let size = CGSize(width: 70, height: ImageCell.height)
        c.imageView.load(urlString: item.imageUrl?.absoluteString, size: size, downloader: ImageDownloader.shared)

        return c
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: 70, height: ImageCell.height)
        return size
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("todo")
//        let item = items[indexPath.row]
    }

}
