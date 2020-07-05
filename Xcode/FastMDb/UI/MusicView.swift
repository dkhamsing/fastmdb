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
    @State private var songs: [iTunes.Song] = []
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
                    List(songs) { song in
                        SongRow(song: song)
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
        }
        .navigationBarTitle("Music")
        .onAppear {
            guard let url = self.url else { return }
            self.searchSongs(url: url)
        }
    }

    // TODO: group music by album
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
                    self.songs = feed.results
                }

                self.isLoading = false
            }
        }.resume()
    }
}

struct SongRow: View {
    var song: iTunes.Song

    var body: some View {
        Button(action: {
            UIApplication.shared.open(self.song.trackViewUrl)
        }, label: {
            HStack {
                RemoteImage(url: song.artworkUrl100)
                    .frame(width: 100)
                VStack(alignment: .leading) {
                    Text(song.name ?? song.trackName ?? "")
                    Text("By " + song.artistName)
                        .font(.caption)
                    Text(song.releaseDisplay)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        })
        .buttonStyle(PlainButtonStyle())
    }
}
