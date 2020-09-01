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

    private var tabBarIsHidden: Bool = false

    private var layoutConstraint: Constraint?

    private let animator: UIViewPropertyAnimator = .init(duration: 0.3, curve: .easeInOut)

    private lazy var gesture: UIPanGestureRecognizer = .init(target: self, action: #selector(pan(_:)))

    private var initialBarCenter = CGPoint()

    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(pipVC)
        view.addSubview(pipVC.view)
        view.bringSubviewToFront(tabBar)
        layoutConstraint = pipVC.view.snp.prepareConstraints {
            $0.top.equalTo(view)
        }.first
        layoutConstraint?.activate()

        pipVC.view.snp.makeConstraints {
            $0.leading.bottom.trailing.equalTo(view)
        }
        pipVC.didMove(toParent: self)
        pipVC.view.addGestureRecognizer(gesture)
        pipVC.view.alpha = 0

    }

    @objc
    func presentPIP() {
        layoutConstraint?.update(inset: 0)
        pipVC.view.transform = .init(translationX: 0, y: 150)

        animator.addAnimations {
            self.pipVC.view.transform = .identity
            self.pipVC.view.alpha = 1

            self.tabBar.transform = .init(translationX: 0, y: self.tabBar.bounds.height)
        }

        animator.addCompletion { animatingPosition in
            switch animatingPosition {
            case .end:
                self.tabBarIsHidden = true
            case .start:
                self.tabBarIsHidden = false
            default:
                ()
            }
        }

        animator.startAnimation()
    }

    func removePIP() {
        animator.addAnimations {
            self.pipVC.view.transform = .init(translationX: 0, y: 150)
            self.pipVC.view.alpha = 0

            self.tabBar.transform = .identity
        }

        animator.addCompletion { animatingPosition in
            switch animatingPosition {
            case .end:
                self.tabBarIsHidden = false
            case .start:
                self.tabBarIsHidden = true
            default:
                ()
            }
        }

        animator.startAnimation()
    }

    @objc
    func pan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: view)
        let velocity = gesture.velocity(in: view)
        switch gesture.state {
        case .began:
            initialBarCenter = location
            animator.pauseAnimation()
        case .changed:
            let offset: CGFloat
            if velocity.y >= 0 {
                animator.isReversed = false
                offset = max(location.y - initialBarCenter.y, 0)
            } else {
                if location.y - initialBarCenter.y > 0 {
                    animator.isReversed = true
                    offset = tabBar.bounds.height - (location.y - initialBarCenter.y)
                } else {
                    animator.isReversed = true
                    offset = tabBar.bounds.height
                }
            }
            animator.addAnimations {
                self.pipVC.view.transform = .init(translationX: 0, y: 150)
                self.pipVC.view.alpha = 0

                self.tabBar.transform = .identity
            }
            animator.fractionComplete = max(min(offset / tabBar.bounds.height, 1), 0)
        case .ended:
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        default:
            ()
        }
    }

}
