//
//  MusicView.swift
//  FastMDb
//
//  Created by Daniel on 7/4/20.
//  Copyright © 2020 dk. All rights reserved.
//

import SwiftUI

struct MusicView: View {
    var url: URL?
    @State private var albums: [iTunes.Album] = []
    @State private var isLoading = true
    @State private var hasNoResults = false
    
    var body: some View {
        Group {
            if self.isLoading {
                ActivityIndicator(isAnimating: $isLoading)
            }
            else {
                if self.hasNoResults {
                    Text("No results 😅")
                }
                else {
                    List {
                        ForEach(albums) { album in
                            AlbumRow(album: album)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
        }
        .navigationBarTitle("Apple Music")
        .onAppear {
            guard let url = self.url else { return }
            self.searchSongs(url: url)
        }
    }
    
    func searchSongs(url: URL) {
        print(url.absoluteString)
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            
            if let feed = try? iTunes.decoder.decode(iTunes.Feed.self, from: data) {
                let results = feed.results
                
                if results.count == 0 {
                    self.hasNoResults = true
                }
                else {
                    //                    self.songs = feed.results
                    self.albums = feed.albums
                }
                
                self.isLoading = false
            }
        }.resume()
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
            VStack(alignment: .leading) {
                Text(album.name)
                Text(album.year)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

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

extension iTunes.Feed {
    var albums: [iTunes.Album] {
        let names = results.map { $0.collectionName }.unique
        
        var albums: [iTunes.Album] = []
        for n in names {
            let songs = results.filter { $0.collectionName == n }
            let song = songs.first
            let album = iTunes.Album(name: n, year: song?.releaseDisplay ?? "", artUrl: song?.artworkUrl100, songs: songs)
            albums.append(album)
        }
        
        return albums
    }
}
