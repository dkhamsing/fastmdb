//
//  VideoView.swift
//  FastMDb
//
//  Created by Daniel on 7/4/20.
//  Copyright © 2020 dk. All rights reserved.
//

import SwiftUI
import LinkPresentation

// TODO: show spinner
struct VideoView: View {
    var items: [Item]
    @State var videoItems: [VideoItem] = []
    @State var isLoading = true

    var body: some View {
        Group {
            if self.isLoading {
                ActivityIndicator(isAnimating: $isLoading)
            }
            else {
                List(videoItems) { video in
                    VideoRow(video: video)
                }
            }
        }
        .navigationBarTitle("Video Clips")
        .onAppear {
            fetchImages(items)
        }
    }

    // TODO: cache images
    func fetchImages(_ items: [Item]) {
        let group = DispatchGroup()
        var videoItems: [VideoItem] = []
        for item in items {
            if let url = item.url {
                group.enter()
                print(url)
                let provider = LPMetadataProvider()
                provider.startFetchingMetadata(for: url) { (metadata, error) in
                    if let metadata = metadata,
                        let imageProvider = metadata.imageProvider {
                        imageProvider.loadObject(ofClass: UIImage.self) { image, _ in
                            if let image = image as? UIImage {
//                                print("\(url.absoluteString): got image with size \(image.size)")
                                var vi = item.videoItem
                                vi.image = image
                                videoItems.append(vi)
                            }
                            group.leave()
                        }
                    }
                    else {
                        group.leave()
                    }
                }
            }
        }

        group.notify(queue: .main) {
            var sorted: [VideoItem] = []
            for item in items {
                let filtered = videoItems
                    .filter { $0.url?.absoluteString == item.url?.absoluteString }

                if let f = filtered.first {
                    sorted.append(f)
                }
                else {
                    sorted.append(item.videoItem)
                }
            }

            self.videoItems = sorted
            self.isLoading = false
        }
    }
}

struct VideoRow: View {
    var video: VideoItem

    var body: some View {
        Button {
            video.url.map {
                UIApplication.shared.open($0)
            }
        } label: {
            HStack {
                video.image.map {
                    Image(uiImage: $0)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100)
                }
                VStack(alignment: .leading) {
                    Text(video.title)
                    video.subtitle.map {
                        Text($0)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct VideoItem: Identifiable {
    let id = UUID()

    let title: String
    let subtitle: String?
    var image: UIImage?
    var url: URL?
}

extension Item {
    var videoItem: VideoItem {
        return VideoItem(title: title ?? "", subtitle: subtitle, url: url)
    }
}
