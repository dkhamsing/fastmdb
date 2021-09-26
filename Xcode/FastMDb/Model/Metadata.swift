//
//  Metadata.swift
//  FastMDb
//
//  Created by Daniel on 4/30/21.
//  Copyright © 2021 dk. All rights reserved.
//

import UIKit

struct Metadata {
    var id: Int?
    var identifier: String?

    var url: URL?

    var destination: Destination?

    var destinationTitle: String?

    var sortedBy: Tmdb.Url.Kind.Sort?
    var releaseYear: String?

    var episode: Episode?
    var seasonNumber: Int?

    var items: [Item]?
    var sections: [ItemSection]?

    var albums: [iTunes.Album]?

    var imageUrl: URL?
    var imageCenterText: String?

    var display: Display?

    var strings: [String]?

    var imageCornerRadius: CGFloat = SquareCollectionViewCell.size.width / 2

    var link: Link?
}
