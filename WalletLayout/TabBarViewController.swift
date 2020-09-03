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

    private var browserToTopLayoutConstraint: Constraint?
    private var browserToBottomLayoutConstraint: Constraint?
    private var browserHeightLayoutConstraint: Constraint?

    private lazy var browserViewController: BrowserViewController = {
        let vc: BrowserViewController = .init()
        vc.delegate = self

        self.addChild(vc)
        self.view.addSubview(vc.view)
        self.view.bringSubviewToFront(tabBar)
        self.browserToTopLayoutConstraint = vc.view.snp.prepareConstraints {
            $0.top.equalTo(view)
        }.first
        self.browserToTopLayoutConstraint?.activate()

        self.browserToBottomLayoutConstraint = vc.view.snp.prepareConstraints {
            $0.bottom.equalTo(view)
        }.first
        self.browserToBottomLayoutConstraint?.activate()

        vc.view.snp.makeConstraints {
            $0.leading.trailing.equalTo(view)
        }

        vc.didMove(toParent: self)
        vc.view.addGestureRecognizer(gesture)
        vc.view.alpha = 0

        // https://stackoverflow.com/a/53339022/7332815
        self.viewControllers?.removeAll(where: { $0 is BrowserViewController })
        return vc
    }()

    private var tabBarIsHidden: Bool = false

    private let animator: UIViewPropertyAnimator = .init(duration: 0.3, curve: .easeInOut)

    private var isInteractionAnimationAssigned: Bool = false

    private lazy var gesture: UIPanGestureRecognizer = .init(target: self, action: #selector(pan(_:)))

    private var initialBarCenter = CGPoint()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @objc
    func presentBrowser() {
        browserViewController.view.transform = .init(translationX: 0, y: 150)
        browserViewController.view.layoutIfNeeded()

        animator.addAnimations {
            self.layoutChangeToFull()
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

    func changeBrowserToPIP() {
        animator.addAnimations {
            self.layoutChangeToPIP()
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
            self.view.layoutIfNeeded()
            self.browserViewController.view.layoutIfNeeded()
        }

        animator.startAnimation()
    }

    private func layoutChangeToFull() {
        browserHeightLayoutConstraint?.deactivate()
        browserToTopLayoutConstraint?.update(inset: 0)
        browserToBottomLayoutConstraint?.update(inset: 0)
        browserToTopLayoutConstraint?.activate()

        browserViewController.view.transform = .identity
        browserViewController.view.alpha = 1

        view.setNeedsLayout()
        view.layoutIfNeeded()
        tabBar.transform = .init(translationX: 0, y: tabBar.bounds.height)
    }

    private func layoutChangeToPIP() {
        browserToTopLayoutConstraint?.deactivate()
        browserHeightLayoutConstraint?.deactivate()
        browserHeightLayoutConstraint = browserViewController.view.snp.prepareConstraints {
            $0.height.equalTo(56)
        }.first
        browserHeightLayoutConstraint?.activate()
        browserToBottomLayoutConstraint?.update(inset: tabBar.bounds.height)

        tabBar.transform = .identity

        view.setNeedsLayout()
        view.layoutIfNeeded()
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
            if !isInteractionAnimationAssigned {
                animator.addAnimations {
                    self.layoutChangeToPIP()
                    self.isInteractionAnimationAssigned = true
                }
                animator.addCompletion { _ in
                    self.isInteractionAnimationAssigned = false
                }
            }
            animator.fractionComplete = max(min(offset / tabBar.bounds.height, 1), 0)
        case .ended:
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        default:
            ()
        }
    }

}

extension TabBarViewController: BrowserViewControllerDelegate {

    func browser(_ browserViewController: BrowserViewController, statusChangedTo status: BrowserStatus) {
        switch status {
        case .pip:
            changeBrowserToPIP()
        default:
            ()
        }
    }

}
