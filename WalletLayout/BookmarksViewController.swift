//
//  BookmarksViewController.swift
//  WalletLayout
//
//  Created by kidnapper on 2020/8/31.
//  Copyright © 2020 andrew. All rights reserved.
//

import UIKit
import SnapKit

class BookmarksViewController: UIViewController {

    private var button: UIButton = {
        let button: UIButton = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.setTitle("pip", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(button)
        button.addTarget(self, action: #selector(showPIP(_:)), for: .touchUpInside)
        button.snp.makeConstraints {
            $0.center.equalTo(view)
        }
    }

    @objc
    func showPIP(_ sender: UIButton) {
        (tabBarController as! TabBarViewController).presentBrowser()
    }

}
