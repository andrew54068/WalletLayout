//
//  TabBarViewController.swift
//  WalletLayout
//
//  Created by kidnapper on 2020/8/12.
//  Copyright © 2020 andrew. All rights reserved.
//

import UIKit
import SnapKit

class TabBarViewController: UITabBarController {

    let pipVC: PIPViewController = .init()

    let customTabBar: UIView = .init()


    private var tabBarIsHidden: Bool = false

    private var layoutConstraint: Constraint?

    private lazy var gesture: UIPanGestureRecognizer = .init(target: self, action: #selector(pan(_:)))

    override func viewDidLoad() {
        super.viewDidLoad()
//        tabBar.isHidden = true

//        addChild(pipVC)
//        view.addSubview(pipVC.view)
//        view.bringSubviewToFront(tabBar)
//        layoutConstraint = pipVC.view.snp.prepareConstraints {
//            $0.top.equalTo(view)
//        }.first
//        layoutConstraint?.activate()
//
//        pipVC.view.snp.makeConstraints {
//            $0.leading.bottom.trailing.equalTo(view)
//        }
//        pipVC.didMove(toParent: self)
//        pipVC.view.addGestureRecognizer(gesture)
//        pipVC.view.alpha = 0
//
//        view.addSubview(customTabBar)
//        customTabBar.backgroundColor = .red
//        customTabBar.snp.makeConstraints {
//            $0.bottom.width.centerX.equalToSuperview()
//            $0.height.equalTo(tabBar.snp.height)
//        }

    }

    @objc
    func presentPIP() {
        DispatchQueue.main.async {
            self.hideTabBar()
        }
        layoutConstraint?.update(inset: 0)
        pipVC.view.transform = .init(translationX: 0, y: 150)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.pipVC.view.transform = .identity
            self.pipVC.view.alpha = 1
        }, completion: { finished in

        })
    }

    private func hideTabBar() {

        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            if self.tabBarIsHidden {
                //                self.tabBar.frame = self.oringialTabBarFrame

                self.customTabBar.transform = .identity
            } else {
                //                self.tabBar.frame = self.oringialTabBarFrame.offsetBy(dx: 0, dy: self.tabBar.bounds.height)

                self.customTabBar.transform = .init(translationX: 0, y: self.customTabBar.bounds.height)
            }
        }, completion: { finished in
            if finished {
                self.tabBarIsHidden.toggle()
            }
        })

    }

    func removePIP() {
//        willMove(toParent: nil)
//        pipVC.view.removeFromSuperview()
//        pipVC.removeFromParent()
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.pipVC.view.transform = .init(translationX: 0, y: 150)
            self.pipVC.view.alpha = 0
        }, completion: { finished in

        })
        showTabBar()
    }

    func showTabBar() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.tabBar.transform = .identity
        }, completion: { finished in
            if finished {
                self.tabBarIsHidden = false
            }
        })
    }


    var initialBarCenter = CGPoint()
    var initialPIPViewY: CGFloat = .init()

    lazy var initialBrowserFrame = self.pipVC.view.frame
    lazy var oringialTabBarFrame: CGRect = self.tabBar.frame

    @objc
    func pan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: view)
        switch gesture.state {
        case .began:
            initialBarCenter = location
            oringialTabBarFrame = pipVC.view.frame
            initialPIPViewY = layoutConstraint?.layoutConstraints.first?.constant ?? 0
        case .changed:
            let diff = location.y - initialBarCenter.y
//            tabBar.frame = oringialTabBarFrame.offsetBy(dx: 0,
//                                                        dy: tabBar.bounds.height - min(max(diff, 0), tabBar.bounds.height))
//            pipVC.view.frame = .init(x: 0,
//                                     y: location.y,
//                                     width: initialBrowserFrame.width,
//                                     height: initialBrowserFrame.height - location.y)

            layoutConstraint?.update(offset: max(initialPIPViewY + diff, 0))
            customTabBar.transform = .init(translationX: 0,
                                           y: tabBar.bounds.height - min(max(diff, 0), tabBar.bounds.height))
        default:
            ()
        }
    }

}

extension TabBarViewController {

    func setTabBarHidden(_ hidden: Bool, animated: Bool = true, duration: TimeInterval = 0.3) {
        if animated {
//            let factor: CGFloat = hidden ? 1 : -1
//            let y = tabBar.frame.origin.y + (tabBar.frame.size.height * factor)
            UIView.animate(withDuration: duration, animations: {
//                self.tabBar.translatesAutoresizingMaskIntoConstraints = false
//                self.tabBar.centerYAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
                self.tabBar.frame = CGRect(x: self.tabBar.frame.origin.x,
                                           y: 500,
                                           width: self.tabBar.frame.width,
                                           height: self.tabBar.frame.height)
//                self.tabBar.snp.remakeConstraints {
//                    $0.top.equalTo(self.view.snp.bottom)
//                    $0.centerX.equalTo(self.view.snp.centerX)
//                }
                self.tabBar.layoutIfNeeded()
            })
            return
        }
        self.tabBarController?.tabBar.isHidden = hidden
    }

}
