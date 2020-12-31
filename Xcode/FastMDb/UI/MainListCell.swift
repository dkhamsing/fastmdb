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
        detailTextLabel?.textColor = .seconday
    }
}

private extension UIColor {
    static var seconday: UIColor {
        return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
            if UITraitCollection.userInterfaceStyle == .dark {
                return .white
            } else {
                return .secondaryLabel
            }
        }
    }
}
