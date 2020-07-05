//
//  ImageCache.swift
//
//  Created by Daniel on 7/4/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation
import UIKit

class ImageCache {
    var cache: NSCache<NSString, UIImage> = NSCache()

    func get(forKey: String) -> UIImage? {
        return cache.object(forKey: NSString(string: forKey))
    }

    func set(forKey: String, image: UIImage) {
        cache.setObject(image, forKey: NSString(string: forKey))
    }
}

extension ImageCache {
    private static var imageCache = ImageCache()

    static func getImageCache() -> ImageCache {
        return imageCache
    }
}
