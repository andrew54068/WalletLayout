//
//  TabView.swift
//  WalletLayout
//
//  Created by kidnapper on 2020/8/27.
//  Copyright © 2020 andrew. All rights reserved.
//

import UIKit
import SnapKit

enum TabInfoType: Equatable {
    case tokens
    case collectibles

    static let tokenListVC = TokenListViewController()
    static let collectionAssetVC = CollectionAssetViewController()

    var title: String {
        switch self {
        case .tokens:
            return "Tokens"
        case .collectibles:
            return "Collectibles"
        }
    }

    var vc: UIViewController {
        switch self {
        case .tokens:
            return Self.tokenListVC
        case .collectibles:
            return Self.collectionAssetVC
        }
    }
}

protocol TabViewDelegate: AnyObject {
    func tabSelected(tab: TabInfoType)
}

class TabView: UIView {

    private let tabTypes: [TabInfoType]
    private var buttons: [UIButton] = []

    weak var delegate: TabViewDelegate?

    var currentIndex: Int = 0

    private lazy var animator: UIViewPropertyAnimator = .init(duration: 0.3, curve: .easeInOut)

    private lazy var container: UIStackView = {
        let stack: UIStackView = .init()
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 16
        return stack
    }()

    private var indicator: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        view.layer.cornerRadius = 1
        view.clipsToBounds = true
        return view
    }()

    init(tabs: [TabInfoType]) {
        self.tabTypes = tabs
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        directionalLayoutMargins.leading = 16

        addSubview(container)
        container.snp.makeConstraints {
            $0.leading.equalTo(self.snp.leadingMargin)
            $0.top.bottom.trailing.equalTo(self)
        }
        tabTypes.enumerated().forEach {
            let button = UIButton()
            button.tag = $0
            button.setTitle($1.title, for: .normal)
            button.setImage(nil, for: .normal)
            button.setTitleColor(UIColor(red: 20 / 255, green: 20 / 255, blue: 20 / 255, alpha: 0.2), for: .normal)
            button.setTitleColor(UIColor(red: 20 / 255, green: 20 / 255, blue: 20 / 255, alpha: 1), for: .selected)
            button.addTarget(self, action: #selector(onClick(_:)), for: .touchUpInside)
            buttons.append(button)
            container.addArrangedSubview(button)
            container.setCustomSpacing(16, after: button)
        }

        let spacer = UIView()
        container.addArrangedSubview(spacer)

        addSubview(indicator)
        indicator.snp.makeConstraints {
            $0.leading.width.equalTo(buttons[0])
            $0.bottom.equalTo(self)
            $0.height.equalTo(4)
        }

        buttons[0].isSelected = true
    }

    @objc
    private func onClick(_ sender: UIButton) {
        selectIndex(index: sender.tag)
        animateIndicator(selectedTag: sender.tag)
    }

    private func animateIndicator(selectedTag: Int) {
//        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2,
//                                                       delay: 0,
//                                                       options: .curveEaseInOut,
//                                                       animations: {
//                                                        self.indicator.snp.remakeConstraints {
//                                                            $0.leading.width.equalTo(self.buttons[selectedTag])
//                                                            $0.bottom.equalTo(self)
//                                                            $0.height.equalTo(4)
//                                                        }
//                                                        self.layoutIfNeeded()
//        },
//                                                       completion: nil)

        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       usingSpringWithDamping: 0.75,
                       initialSpringVelocity: 0.1,
                       options: .curveEaseInOut,
                       animations: {
                        self.indicator.snp.remakeConstraints {
                            $0.leading.width.equalTo(self.buttons[selectedTag])
                            $0.bottom.equalTo(self)
                            $0.height.equalTo(4)
                        }
                        self.layoutIfNeeded()
        },
                       completion: nil)
    }

    func selectIndex(index: Int) {
        buttons.forEach { $0.isSelected = false }
        buttons[index].isSelected = true
        delegate?.tabSelected(tab: tabTypes[index])
        currentIndex = index
    }

    func updateIndicatorPosition(progress: CGFloat) {
        guard progress >= -1, progress <= 1 else {
            assertionFailure("progress should between -1, 1.")
            return
        }

        animate(from: currentIndex, progress: progress)

        animator.fractionComplete = abs(progress)
    }

    var animationAssigned: Bool = false

    private func animate(from index: Int, progress: CGFloat) {
        if progress > 0 {
            animator.addAnimations {
                self.indicator.snp.remakeConstraints {
                    let nextIndex = min(index + 1, self.buttons.count - 1)
                    $0.leading.width.equalTo(self.buttons[nextIndex])
                    $0.bottom.equalTo(self)
                    $0.height.equalTo(4)
                }
                // need to call setNeedsLayout to make sure indicator update correctly.
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
        } else if progress < 0 {
            animator.addAnimations {
                self.indicator.snp.remakeConstraints {
                    let nextIndex = max(index - 1, 0)
                    $0.leading.width.equalTo(self.buttons[nextIndex])
                    $0.bottom.equalTo(self)
                    $0.height.equalTo(4)
                }
                // need to call setNeedsLayout to make sure indicator update correctly.
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
        }
    }

    func indicatorStartDragging() {
        animator.isReversed = false
    }

    func indicatorEndDragging(progress: CGFloat) {
        guard progress >= -1, progress <= 1 else {
            assertionFailure("progress should between -1, 1.")
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            return
        }
        animate(from: currentIndex, progress: progress)

        animator.isReversed = abs(progress) < 0.5
        animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)

        var tempIndex = currentIndex
        if progress > 0.5 {
            tempIndex = min(tempIndex + 1, buttons.count - 1)
        }

        if progress < -0.5 {
            tempIndex = max(tempIndex - 1, 0)
        }
        selectIndex(index: tempIndex)

    }

}
