//
//  MusicView.swift
//  FastMDb
//
//  Created by Daniel on 7/4/20.
//  Copyright © 2020 dk. All rights reserved.
//

import SwiftUI

struct MusicView: View {
    var albums: [iTunes.Album]
    
    var body: some View {
        List {
            ForEach(albums) { album in
                AlbumRow(album: album)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Apple Music")
    }
}

struct AlbumRow: View {
    var album: iTunes.Album
    
    var body: some View {
        Section(header: AlbumHeader(album:album)) {
            ForEach(album.songs) { song in
                SongRow(song: song)
            }
        }
    }
}

struct AlbumHeader: View {
    var album: iTunes.Album
    
    var body: some View {
        HStack {
            RemoteImage(url: album.artUrl)
                .frame(width: 100, height: 100)
                .cornerRadius(8)
                .padding(.bottom, 5)
            VStack(alignment: .leading) {
                Text(album.name)
                Text(album.year)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// TODO: display disclosure indicator (>)
struct SongRow: View {
    var song: iTunes.Song
    
    var body: some View {
        Button(action: {
            UIApplication.shared.open(self.song.trackViewUrl)
        }, label: {
            VStack(alignment: .leading) {
                Text(song.name ?? song.trackName ?? "")
                Text("By " + song.artistName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        })
        .buttonStyle(PlainButtonStyle())
    }
}

extension iTunes {
    struct Album: Identifiable {
        let id = UUID()
        
        var name: String
        var year: String
        var artUrl: URL?
        var songs: [Song] = []
    }
}

//struct MusicView_Previews: PreviewProvider {
//    static let url = URL(string: "https://itunes.apple.com/search?media=music&attribute=albumTerm&country=us&limit=10&term=Hamilton")!
//    static let url2 = URL(string: "https://itunes.apple.com/search?media=music&attribute=albumTerm&country=us&limit=50&term=aladdin")!
//    static let urlNoResults = URL(string: "https://itunes.apple.com/search?media=music&attribute=albumTerm&country=us&limit=50&term=master+commander")!
//
//    static var previews: some View {
//        Group {
//            NavigationView {
//                MusicView(url: url)
//                    .preferredColorScheme(.dark)
//            }
//            NavigationView {
//                MusicView(url: url2)
//            }
//            NavigationView {
//                MusicView(url: urlNoResults)
//            }
//        }
//    }
//}
