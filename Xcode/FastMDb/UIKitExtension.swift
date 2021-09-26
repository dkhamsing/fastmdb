//
//  Extension.swift
//  FastMDb
//
//  Created by Daniel on 12/24/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit

extension Bundle {

    static var nameSpace: String? {
        guard let info = Bundle.main.infoDictionary,
              let projectName = info["CFBundleExecutable"] as? String else { return nil }

        let nameSpace = projectName.replacingOccurrences(of: "-", with: "_")

        return nameSpace
    }

}


extension UICollectionView {

    convenience init( frame: CGRect, direction: UICollectionView.ScrollDirection, identifiers: [String]) {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = direction
        layout.minimumLineSpacing = 0

        self.init(frame: frame, collectionViewLayout: layout)

        guard let nameSpace = Bundle.nameSpace else { return }

        for identifier in identifiers {
            if let anyClass: AnyClass = NSClassFromString("\(nameSpace).\(identifier)") {
                self.register(anyClass, forCellWithReuseIdentifier: identifier)
            }
        }
    }

}

extension UIView {

    func addSubviewForAutoLayout(_ view: UIView) {
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
    }

}
