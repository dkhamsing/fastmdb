//
//  RemoteImage.swift
//
//  Created by Daniel on 7/4/20.
//  Copyright © 2020 dk. All rights reserved.
//

import SwiftUI

struct RemoteImage: View {
    @ObservedObject var remoteData: RemoteData

    init(url: URL) {
        remoteData = RemoteData(url: url)
    }

    var body: some View {
        Image(uiImage: UIImage(data: self.remoteData.data) ?? UIImage())
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

class RemoteData: ObservableObject {
    @Published var data = Data()

    init(url: URL) {
        DispatchQueue.global().async {
            guard let data = try? Data(contentsOf: url) else { return }

            DispatchQueue.main.async {
                self.data = data
            }
        }
    }
}
