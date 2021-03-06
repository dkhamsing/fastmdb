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
    var episode: Episode?
    var seasonNumber: Int?
    var items: [Item]?
    var image: UIImage?

    var color: UIColor?
}

extension Item {
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
