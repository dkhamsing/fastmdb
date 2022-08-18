//
//  Item.swift
//  FastMDb
//
//  Created by Daniel on 5/17/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation
import UIKit

struct Item {
    var attributedTitle: NSAttributedString?
    var title: String?
    var subtitle: String?
    var color: UIColor?

    var metadata: Metadata?
}

extension Item: Equatable {
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.metadata?.id ?? 0 == rhs.metadata?.id ?? 0
    }
}

extension Item {
    static func imageItem(url: URL?, imageUrl: URL?) -> Item {
        let metadata = Metadata(url: url, destination: .safarivc, imageUrl: imageUrl)
        return Item(metadata: metadata)
    }
}

