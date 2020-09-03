//
//  SecViewController.swift
//  WalletLayout
//
//  Created by kidnapper on 2020/8/12.
//  Copyright © 2020 andrew. All rights reserved.
//

import UIKit

class SecViewController: UIViewController {

    private lazy var barButtonItem: UIBarButtonItem = .init(title: "show PIP", style: .plain, target: self, action: #selector(showPIP))

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.setRightBarButton(barButtonItem, animated: true)
    }

    @objc
    func showPIP() {
        (tabBarController as? TabBarViewController)?.presentBrowser()
    }

}
