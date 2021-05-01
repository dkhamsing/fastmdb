//
//  Link.swift
//  FastMDb
//
//  Created by Daniel on 5/1/21.
//  Copyright © 2021 dk. All rights reserved.
//

import UIKit

enum Link {

    case link,
         map,
         video

    var image: UIImage? {
        switch self {
        case .link:
            return UIImage(systemName: "link.circle.fill")
        case .map:
            return UIImage(systemName: "mappin.circle.fill")
        case .video:
            return UIImage(systemName: "play.circle.fill")
        }
    }

}
