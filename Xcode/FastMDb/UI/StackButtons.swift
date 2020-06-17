//
//  StackButtons.swift
//  FastMDb
//
//  Created by Daniel on 6/14/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit

protocol SelectKind: class {
    func didselectKind(_ kind: SearchKind)
}

class StackButtons: UIView {

    weak var delegate: SelectKind?
    static let height: CGFloat = 90
    private var stack = UIStackView()

    func setup(_ views: [UIView]) {
        stack.removeFromSuperview()

        stack = UIStackView(arrangedSubviews: views)
        stack.distribution = .fillProportionally
        stack.spacing = 10
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: stack.spacing, left: stack.spacing, bottom: stack.spacing, right: stack.spacing)

        stack.frame = self.bounds
        stack.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(stack)
    }

    @objc func buttonTapped(_ sender: KindButton) {
        guard let kind = sender.kind else { return }
        delegate?.didselectKind(kind)
    }

}

extension StackButtons {

    func update(_ list: [StackButtonConfiguration]) {
        let views = list.compactMap { $0.kindButton }
        guard views.count > 1 else {
            setup([])
            return
        }
        
        views.forEach {
            $0.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        }

        setup(views)
    }

}

struct StackButtonConfiguration {

    var label = ""
    var value: Int?
    var kind: SearchKind
    var showCount: Bool = true

}

private extension StackButtonConfiguration {

    var kindButton: KindButton? {
        guard
            let v = value,
            v > 0 else { return nil }

        let button = KindButton()
        var string = label
        if showCount {
            string.append(contentsOf: " (\(v))")
        }
        button.setTitle(string, for: .normal)

        button.titleLabel?.font = .preferredFont(forTextStyle: .caption1)
        button.kind = kind

        button.backgroundColor = .systemTeal
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true

        return button
    }

}

class KindButton: UIButton {
    var kind: SearchKind?
}

enum SearchKind {
    case news, movie, tv, people
}
