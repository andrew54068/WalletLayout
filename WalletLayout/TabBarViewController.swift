//
//  TabBarViewController.swift
//  WalletLayout
//
//  Created by kidnapper on 2020/8/12.
//  Copyright © 2020 andrew. All rights reserved.
//

import UIKit
import SnapKit

class PIPWindow: UIWindow {

    lazy var pipVC: PIPViewController = .init()

    init() {
        super.init(frame: UIScreen.main.bounds)
        backgroundColor = nil
        windowLevel = UIWindow.Level(UIWindow.Level.alert.rawValue - 1)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return frame.contains(point)
    }

    func presentPIP() {
        rootViewController = pipVC
        isHidden = false
    }

    func dismiss() {
        rootViewController = nil
        isHidden = true
    }
}

class TabBarViewController: UITabBarController {

    private lazy var window: PIPWindow = .init()

    private var tabBarIsHidden: Bool = false

    private var layoutConstraint: Constraint?

    private let animator: UIViewPropertyAnimator = .init(duration: 0.3, curve: .easeInOut)

    private lazy var gesture: UIPanGestureRecognizer = .init(target: self, action: #selector(pan(_:)))

    private var initialBarCenter = CGPoint()

    override func viewDidLoad() {
        super.viewDidLoad()
        window.addGestureRecognizer(gesture)
    }

    @objc
    func presentPIP() {
        window.presentPIP()
        window.frame = .init(x: 0, y: 0, width: 300, height: 300)
        window.transform = .init(translationX: 0, y: 150)

        animator.addAnimations {
            self.window.transform = .identity
            self.window.alpha = 1

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
        window.dismiss()

        animator.addAnimations {
            self.window.transform = .init(translationX: 0, y: 150)
            self.window.alpha = 0

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
                self.window.transform = .init(translationX: 0, y: 150)
                self.window.alpha = 0

                self.tabBar.transform = .identity
            }
            animator.fractionComplete = max(min(offset / tabBar.bounds.height, 1), 0)
        case .ended:
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
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        default:
            ()
        }
    }

}
