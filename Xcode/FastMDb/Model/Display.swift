//
//  Display.swift
//  FastMDb
//
//  Created by Daniel on 4/30/21.
//  Copyright © 2021 dk. All rights reserved.
//

enum Display {
    case

    // table cell
    text(_ value: Cell = .table(.plain)),

    // table cell with image right
    textImage(_ value: Cell = .table(.image(.plain))),

    // collection cell with text label
    tags(_ value: Cell = .collection(.plain)),

    // collection cell with image
    images(_ value: Cell = .collection(.image(.plain))),

    // collection cell with portrait image
    portraitImage(_ value: Cell = .collection(.image(.portrait))),

    // collection cell with thumbnail image
    thumbnailImage(_ value: Cell = .collection(.image(.thumbnail))),

    // collectionn cell with square image
    squareImage(_ value: Cell = .collection(.image(.square)))
}


enum Cell {
    case table(_ value: CellType),
         collection(_ value: CellType)
}

enum CellType {
    case plain,
         image(_ value: ImageType = .plain)

    var identifier: String {
        switch self {
        case .plain: return "plain"
        case .image: return "image"
        }
    }
}

enum ImageType {
    case plain, portrait, thumbnail, square
}
