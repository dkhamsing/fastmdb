//
//  ItemSection.swift
//
//  Created by Daniel on 5/7/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

struct ItemSection {
    var header: String?
    var items: [Item]?
    var footer: String?

    var metadata: Metadata?
}

extension ItemSection {
    static func imagesSection(poster_path: String?,
                              images: Images?) -> ItemSection? {
        var items: [Item] = []

        if !(poster_path ?? "").isEmpty {
            let url = Tmdb.mediaPosterUrl(path: poster_path, size: .xxl)
            let imageUrl = Tmdb.mediaPosterUrl(path: poster_path, size: .large)
            let posterItem = Item(metadata: Metadata(url: url, destination: .safarivc, imageUrl: imageUrl, display: .portraitImage))
            items.append(posterItem)
        }

        if let it = images?.backdropItems {
            items.append(contentsOf: it)
        }

        guard items.count > 0 else { return nil }

        return ItemSection(items: items, metadata: Metadata(display: .images))
    }
}
