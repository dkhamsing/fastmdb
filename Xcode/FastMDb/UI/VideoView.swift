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
                .listStyle(InsetGroupedListStyle())
            }
        }
        .navigationBarTitle("Video Clips")
        .onAppear {
            self.fetchImages(self.items)
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
        Button(action: {
            self.video.url.map {
                UIApplication.shared.open($0)
            }
        }, label: {
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
        })
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

struct VideoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VideoView(items: testData)
        }
    }
}

let testData = [Item(id: nil, title: "Hamilton | Official Trailer | Disney+", subtitle: "YouTube · Trailer", url: URL.init(string: "https://www.youtube.com/watch/DSCKfXpAGHc"), destination: nil, destinationTitle: nil, sortedBy: nil, episode: nil, seasonNumber: nil, items: nil, image: nil, color: nil)]

/**FastMDb.Item(id: nil, title: Optional("Hamilton | Official Trailer | Disney+"), subtitle: Optional("YouTube · Trailer"), url: Optional(https://www.youtube.com/watch/DSCKfXpAGHc), destination: Optional(FastMDb.Destination.url), destinationTitle: nil, sortedBy: nil, episode: nil, seasonNumber: nil, items: nil, image: Optional(<UIImage:0x600000d45cb0 symbol(system: play.circle.fill) {20, 19} baseline=3.5,contentInsets={1, 1.5, 1, 1.5},alignmentRectInsets={-0.5, 0, -0.5, 0} config=<(null), traits=(UserInterfaceIdiom = Phone, DisplayScale = 2, DisplayGamut = P3, HorizontalSizeClass = Compact, VerticalSizeClass = Regular, UserInterfaceStyle = Dark, UserInterfaceLayoutDirection = LTR, PreferredContentSizeCategory = L, AccessibilityContrast = Normal)>>), color: nil), FastMDb.Item(id: nil, title: Optional("\"Alexander Hamilton\" Clip | Hamilton | Disney+"), subtitle: Optional("YouTube · Clip"), url: Optional(https://www.youtube.com/watch/hrGwCJQoeVo), destination: Optional(FastMDb.Destination.url), destinationTitle: nil, sortedBy: nil, episode: nil, seasonNumber: nil, items: nil, image: Optional(<UIImage:0x600000d45cb0 symbol(system: play.circle.fill) {20, 19} baseline=3.5,contentInsets={1, 1.5, 1, 1.5},alignmentRectInsets={-0.5, 0, -0.5, 0} config=<(null), traits=(UserInterfaceIdiom = Phone, DisplayScale = 2, DisplayGamut = P3, HorizontalSizeClass = Compact, VerticalSizeClass = Regular, UserInterfaceStyle = Dark, UserInterfaceLayoutDirection = LTR, PreferredContentSizeCategory = L, AccessibilityContrast = Normal)>>), color: nil),

 FastMDb.Item(id: nil, title: Optional("\"The Room Where It Happens\" Clip | Hamilton | Disney+"), subtitle: Optional("YouTube · Clip"), url: Optional(https://www.youtube.com/watch/BQjGGrKRL8o), destination: Optional(FastMDb.Destination.url), destinationTitle: nil, sortedBy: nil, episode: nil, seasonNumber: nil, items: nil, image: Optional(<UIImage:0x600000d45cb0 symbol(system: play.circle.fill) {20, 19} baseline=3.5,contentInsets={1, 1.5, 1, 1.5},alignmentRectInsets={-0.5, 0, -0.5, 0} config=<(null), traits=(UserInterfaceIdiom = Phone, DisplayScale = 2, DisplayGamut = P3, HorizontalSizeClass = Compact, VerticalSizeClass = Regular, UserInterfaceStyle = Dark, UserInterfaceLayoutDirection = LTR, PreferredContentSizeCategory = L, AccessibilityContrast = Normal)>>), color: nil), FastMDb.Item(id: nil, title: Optional("Hamilton | Streaming Exclusively July 3 | Disney+"), subtitle: Optional("YouTube · Teaser"), url: Optional(https://www.youtube.com/watch/5EI40a-Fc1k), destination: Optional(FastMDb.Destination.url), destinationTitle: nil, sortedBy: nil, episode: nil, seasonNumber: nil, items: nil, image: Optional(<UIImage:0x600000d45cb0 symbol(system: play.circle.fill) {20, 19} baseline=3.5,contentInsets={1, 1.5, 1, 1.5},alignmentRectInsets={-0.5, 0, -0.5, 0} config=<(null), traits=(UserInterfaceIdiom = Phone, DisplayScale = 2, DisplayGamut = P3, HorizontalSizeClass = Compact, VerticalSizeClass = Regular, UserInterfaceStyle = Dark, UserInterfaceLayoutDirection = LTR, PreferredContentSizeCategory = L, AccessibilityContrast = Normal)>>), color: nil), FastMDb.Item(id: nil, title: Optional("\"Satisfied\" Clip | Hamilton | Disney+"), subtitle: Optional("YouTube · Clip"), url: Optional(https://www.youtube.com/watch/asfLNbrSPv4), destination: Optional(FastMDb.Destination.url), destinationTitle: nil, sortedBy: nil, episode: nil, seasonNumber: nil, items: nil, image: Optional(<UIImage:0x600000d45cb0 symbol(system: play.circle.fill) {20, 19} baseline=3.5,contentInsets={1, 1.5, 1, 1.5},alignmentRectInsets={-0.5, 0, -0.5, 0} config=<(null), traits=(UserInterfaceIdiom = Phone, DisplayScale = 2, DisplayGamut = P3, HorizontalSizeClass = Compact, VerticalSizeClass = Regular, UserInterfaceStyle = Dark, UserInterfaceLayoutDirection = LTR, PreferredContentSizeCategory = L, AccessibilityContrast = Normal)>>), color: nil)]*/
