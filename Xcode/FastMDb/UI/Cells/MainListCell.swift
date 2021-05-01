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
            accessoryType = item?.metadata?.destination == nil ? .none : .disclosureIndicator
            imageView?.image = item?.metadata?.link?.image

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

}

private extension MainListCell {
    func setup() {
        imageView?.tintColor = .secondaryLabel
        textLabel?.numberOfLines = 0

        detailTextLabel?.numberOfLines = 0
        detailTextLabel?.textColor = .secondary
    }
}

private extension UIColor {
    static var secondary: UIColor {
        return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
            if UITraitCollection.userInterfaceStyle == .dark {
                return .white
            } else {
                return .secondaryLabel
            }
        }
    }
}
