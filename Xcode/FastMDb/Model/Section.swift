//
//  Section.swift
//
//  Created by Daniel on 5/7/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

struct Section {
    var header: String?
    var items: [Item]?
    var footer: String?

    var destination: Destination?
    var destinationItems: [Item]?
    var destinationSections: [Section]?
    var destinationTitle: String?
}
