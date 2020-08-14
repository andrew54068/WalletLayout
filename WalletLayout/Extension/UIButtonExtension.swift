//
//  UIButtonExtension.swift
//  WalletLayout
//
//  Created by kidnapper on 2020/8/14.
//  Copyright © 2020 andrew. All rights reserved.
//

import UIKit

extension UIButton {
    func setInsetBetween(_ value: CGFloat) {
        contentEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: value)
        titleEdgeInsets = .init(top: 0, left: value, bottom: 0, right: -value)
    }
}
