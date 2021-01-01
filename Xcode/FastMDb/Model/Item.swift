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
    var id: Int?
    var title: String?
    var subtitle: String?
    var url: URL?
    var destination: Destination?
    var destinationTitle: String?

    var sortedBy: String?
    var releaseYear: String?

    var episode: Episode?
    var seasonNumber: Int?
    var items: [Item]?
    var image: UIImage?

    var color: UIColor?

    var albums: [iTunes.Album]?

    var imageUrl: URL?

    var imageCenterText: String?
}

extension Item: Equatable {
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Item {
    static func ImageItem(
        url: URL?,
        imageUrl: URL?) -> Item {
        return Item(url: url,
                    destination: .safarivc,
                    imageUrl: imageUrl)
    }

    static var linkImage: UIImage? {
        return UIImage(systemName: "link.circle.fill")
    }

    static var mapImage: UIImage? {
        return UIImage(systemName: "mappin.circle.fill")
    }

    static var videoImage: UIImage? {
        return UIImage(systemName: "play.circle.fill")
    }
}
