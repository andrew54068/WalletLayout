//
//  PIPViewController.swift
//  WalletLayout
//
//  Created by kidnapper on 2020/8/10.
//  Copyright © 2020 andrew. All rights reserved.
//

import UIKit

class PIPViewController: UIViewController {

    private lazy var showButton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.setTitle("show bar", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(showTabBar), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .brown
        view.addSubview(showButton)
        showButton.translatesAutoresizingMaskIntoConstraints = false
        showButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        showButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        view.autoresizesSubviews = false
    }

    @objc
    func showTabBar() {
        (tabBarController as? TabBarViewController)?.removePIP()
    }

}
