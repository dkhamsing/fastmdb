//
//  RemoteImage.swift
//
//  Created by Daniel on 7/4/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit
import SwiftUI

class ImageModel: ObservableObject {
    @Published var image: UIImage? = nil

    private var imageCache = ImageCache.getImageCache()

    init(url: URL?) {
        loadImage(url: url)
    }

    func loadImage(url: URL?) {
        if let image = getImageFromCache(url: url) {
            self.image = image
            return
        }

        getImageFromUrl(url: url) { image in
            if let image = image {
                self.imageCache.set(forKey: url?.absoluteString ?? "", image: image)
            }

            DispatchQueue.main.async {
                self.image = image
            }
        }
    }

    func getImageFromCache(url: URL?) -> UIImage? {
        guard let url = url else { return nil }

        guard let cacheImage = imageCache.get(forKey: url.absoluteString) else { return nil }

        print("cache hit")

        return cacheImage
    }

    func getImageFromUrl(url: URL?, completion: @escaping (UIImage?) ->Void) {
        guard let url = url else { return }

        print(url.absoluteString)

        DispatchQueue.global().async {
            guard let data = try? Data(contentsOf: url) else { return }

            let image = UIImage(data: data)
            completion(image)
        }
    }
}

struct RemoteImage: View {
    @ObservedObject var imageModel: ImageModel

    init(url: URL?) {
        imageModel = ImageModel(url: url)
    }

    var body: some View {
        imageModel.image.map {
            Image(uiImage: $0)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
}
