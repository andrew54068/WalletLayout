//
//  ViewController.swift
//  WalletLayout
//
//  Created by kidnapper on 2020/7/28.
//  Copyright © 2020 andrew. All rights reserved.
//

import UIKit
import SnapKit

struct CardModel {
    var movable: Bool
    let cardTitle: String
    let color: UIColor
}

class ViewController: UIViewController {

    private lazy var purchaseButton: UIButton = {
        let button: UIButton = .init(frame: CGRect(x: 0, y: 0, width: 125, height: 30))
        button.setImage(UIImage(named: "icBuy20"), for: .normal)
        button.setTitle("PURCHASE", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(purchaseOnClick(_:)), for: .touchUpInside)
        button.backgroundColor = .init(red: 19 / 255, green: 54 / 255, blue: 191 / 255, alpha: 1)
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        button.setInsetBetween(4)
        return button
    }()

    private lazy var purchaseButtonItem: UIBarButtonItem = {
        let item: UIBarButtonItem = .init(customView: purchaseButton)
        return item
    }()

    private lazy var settingButtonItem: UIBarButtonItem = {
        let item: UIBarButtonItem = .init(image: UIImage(named: "ic22Gear"),
                                          style: .plain,
                                          target: self,
                                          action: #selector(editCardOrder))
        item.tintColor = .black
        return item
    }()

    private let tabs: [TabInfoType] = [.tokens, .collectibles]

    private lazy var tabView: TabView = {
        let tabview: TabView = TabView(tabs: tabs)
        tabview.delegate = self
        return tabview
    }()

    private let pageController: UIPageViewController = UIPageViewController(transitionStyle: .scroll,
                                                                            navigationOrientation: .horizontal,
                                                                            options: nil)

    private let tokenListViewController = TokenListViewController()
    private let collectionAssetViewController = CollectionAssetViewController()

    private var isDragging: Bool = false
    private var offsetBeforeDrag: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setUpNavigationBar()
        setupScrollView()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        // to make tabView animate
        view.layoutIfNeeded()
    }

    private func setupUI() {
        view.backgroundColor = .white

        view.addSubview(tabView)
        tabView.snp.makeConstraints {
            $0.leading.top.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(42)
        }

        pageController.setViewControllers([tokenListViewController],
                                          direction: .forward,
                                          animated: true,
                                          completion: nil)

        pageController.delegate = self
        pageController.dataSource = self

        addChild(pageController)
        view.addSubview(pageController.view)
        pageController.view.snp.makeConstraints {
            $0.top.equalTo(tabView.snp.bottom)
            $0.leading.bottom.trailing.equalTo(view)
        }

        pageController.didMove(toParent: self)
    }

    private func setUpNavigationBar() {
        navigationItem.setLeftBarButton(purchaseButtonItem, animated: true)
        navigationItem.setRightBarButton(settingButtonItem, animated: true)
    }

    private func setupScrollView() {
        // Disable PageViewController's ScrollView bounce
        let scrollView = pageController.view.subviews.compactMap { $0 as? UIScrollView }.first
//        scrollView?.bounces = false
        scrollView?.delegate = self
    }

    @objc
    private func purchaseOnClick(_ sender: UIButton) {
        let alert = UIAlertController(title: "test", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    @objc
    private func editCardOrder(_ sender: UIBarButtonItem) {

    }

}

extension ViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController is TokenListViewController {
            return nil
        } else if viewController is CollectionAssetViewController {
            return tokenListViewController
        } else {
            return nil
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController is TokenListViewController {
            return collectionAssetViewController
        } else if viewController is CollectionAssetViewController {
            return nil
        } else {
            return nil
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else { return }
        if pageViewController.viewControllers?.first?.view == tokenListViewController {
            tabView.selectIndex(index: 0)
        } else if pageViewController.viewControllers?.first?.view == collectionAssetViewController {
            tabView.selectIndex(index: 1)
        }
    }

}

extension ViewController: UIScrollViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        offsetBeforeDrag = scrollView.contentOffset.x
        isDragging = true
        tabView.indicatorStartDragging()
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        isDragging = false
        let progress = max(min((targetContentOffset.pointee.x - offsetBeforeDrag) / scrollView.bounds.width, 1), -1)
        tabView.indicatorEndDragging(progress: progress)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isDragging {
            let progress = max(min((scrollView.contentOffset.x - offsetBeforeDrag) / scrollView.bounds.width, 1), -1)
            tabView.updateIndicatorPosition(progress: progress)
        }
    }

}

extension ViewController: TabViewDelegate {

    func tabSelected(tab: TabInfoType) {
        switch tab {
        case .tokens:
            pageController.setViewControllers([tokenListViewController],
                                              direction: .reverse,
                                              animated: true,
                                              completion: nil)
        case .collectibles:
            pageController.setViewControllers([collectionAssetViewController],
                                              direction: .forward,
                                              animated: true,
                                              completion: nil)
        }
    }

}
