//
//  BrowserViewController.swift
//  WalletLayout
//
//  Created by kidnapper on 2020/8/10.
//  Copyright © 2020 andrew. All rights reserved.
//

import UIKit

protocol BrowserViewControllerDelegate: AnyObject {
    func browser(_ browserViewController: BrowserViewController, statusChangedTo status: BrowserStatus)
}

enum BrowserStatus {
    case fullScreen
    case pip
    case hide
    case dismiss
}

class BrowserViewController: UIViewController {

    weak var delegate: BrowserViewControllerDelegate?

    private lazy var showButton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.setTitle("show bar", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(changeToPIP), for: .touchUpInside)
        return button
    }()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        edgesForExtendedLayout = []
        extendedLayoutIncludesOpaqueBars = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
    private func changeToPIP(_ sender: UIButton) {
        delegate?.browser(self, statusChangedTo: .pip)
    }

}
