//
//  WalletFlowLayout.swift
//  WalletLayout
//
//  Created by kidnapper on 2020/7/28.
//  Copyright © 2020 andrew. All rights reserved.
//

import UIKit

protocol WalletFlowLayoutDelegate: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: WalletFlowLayout, offsetFromPreviousCardTopAt indexPath: IndexPath) -> CGFloat
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: WalletFlowLayout, distanceToVisualTop: CGFloat, at indexPath: IndexPath)
}

final class WalletFlowLayout: UICollectionViewLayout {

    private var attributes: [[UICollectionViewLayoutAttributes]] = []
    private var originalAttributes: [[UICollectionViewLayoutAttributes]] = []
    private var displayFrames: [[CGRect]] = []

    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let gestureRecognizer: UIPanGestureRecognizer = .init(target: self, action: #selector(self.movingCard(_:)))
        gestureRecognizer.delegate = self
        return gestureRecognizer
    }()

    private var contentExceedCollectionBounds: Bool = false

    private weak var layoutDelegate: WalletFlowLayoutDelegate?

    private var contentHeight: CGFloat = 0

    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    init(delegate: WalletFlowLayoutDelegate) {
        layoutDelegate = delegate
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepare() {
        super.prepare()

        contentExceedCollectionBounds = false

        attributes.removeAll()
        displayFrames.removeAll()

        guard let collectionView: UICollectionView = collectionView else { return }

        //  handle gesture
        removeGesture()

        guard let layoutDelegate: WalletFlowLayoutDelegate = layoutDelegate else { return }

        var latestCardFrame: CGRect = .zero
        var lastSectionInset: UIEdgeInsets = .zero

        var cardOffsetCount: CGFloat = 0

        for section in 0 ..< collectionView.numberOfSections {
            guard let numberOfItem = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: section) else { return }
            let currentSectionInsect: UIEdgeInsets = layoutDelegate.collectionView?(collectionView, layout: self, insetForSectionAt: section) ?? .zero

            cardOffsetCount += currentSectionInsect.top

            var currentCardFrame: CGRect = latestCardFrame
            if section != 0 {
                currentCardFrame = currentCardFrame.addingToY(lastSectionInset.bottom)
            }
            currentCardFrame = currentCardFrame.addingToX(currentSectionInsect.left)
            currentCardFrame = currentCardFrame.addingToY(currentSectionInsect.top)

            var tempAttributes: [UICollectionViewLayoutAttributes] = []
            var tempOriginalAttributes: [UICollectionViewLayoutAttributes] = []
            var tempFrames: [CGRect] = []
            for item in 0 ..< numberOfItem {
                let indexPath: IndexPath = .init(item: item, section: section)
                let itemSize: CGSize = layoutDelegate.collectionView?(collectionView, layout: self, sizeForItemAt: indexPath) ?? .zero

                // get offset from each card top, cause card are overlay by this attribute
                let cardsOffset: CGFloat
                if item == 0 {
                    cardsOffset = 0
                } else {
                    cardsOffset = layoutDelegate.collectionView(collectionView, layout: self, offsetFromPreviousCardTopAt: indexPath)
                }

                cardOffsetCount += cardsOffset

                let attri: UICollectionViewLayoutAttributes = .init(forCellWith: indexPath)

                let currentVisualTopY = collectionView.contentInset.top + collectionView.contentOffset.y + currentSectionInsect.top
                
                let cardFrame: CGRect = .init(x: currentCardFrame.minX,
                                              y: currentCardFrame.addingToY(cardsOffset).minY,
                                              width: itemSize.width,
                                              height: itemSize.height)

                let shiftedFrame: CGRect = .init(x: currentCardFrame.minX,
                                                 y: max(currentCardFrame.addingToY(cardsOffset).minY, currentVisualTopY),
                                                 width: itemSize.width,
                                                 height: itemSize.height)

                let distanceToVisualTop: CGFloat = shiftedFrame.minY - currentVisualTopY

                layoutDelegate.collectionView(collectionView, layout: self, distanceToVisualTop: distanceToVisualTop, at: indexPath)

                attri.zIndex = item
                currentCardFrame = cardFrame
                attri.frame = shiftedFrame
                tempAttributes.append(attri)
                tempOriginalAttributes.append(attri)
                tempFrames.append(cardFrame)

                latestCardFrame = cardFrame
                contentHeight = cardFrame.maxY

            }
            cardOffsetCount += currentSectionInsect.bottom
            contentHeight += currentSectionInsect.bottom
            lastSectionInset = currentSectionInsect
            attributes.append(tempAttributes)
            originalAttributes.append(tempOriginalAttributes)
            displayFrames.append(tempFrames)

        }
        if collectionView.contentInset.top + cardOffsetCount + latestCardFrame.height < collectionView.bounds.height {
            installGesture()
            contentExceedCollectionBounds = false
        } else {
            contentExceedCollectionBounds = true
        }

    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView: UICollectionView = collectionView else { return nil }
        guard let layoutDelegate: WalletFlowLayoutDelegate = layoutDelegate else { return nil }
        return attributes.flatMap { $0 }.filter {
            shouldDisplay(collectionView: collectionView, layoutDelegate: layoutDelegate, attribute: $0)
        }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributes[indexPath.section][indexPath.item]
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return contentExceedCollectionBounds
    }

    private func shouldDisplay(collectionView: UICollectionView, layoutDelegate: WalletFlowLayoutDelegate, attribute: UICollectionViewLayoutAttributes) -> Bool {

        let currentSectionInsect: UIEdgeInsets = layoutDelegate.collectionView?(collectionView,
                                                                                layout: self,
                                                                                insetForSectionAt: attribute.indexPath.section) ?? .zero

        let cardsOffset: CGFloat = layoutDelegate.collectionView(collectionView,
                                                                 layout: self,
                                                                 offsetFromPreviousCardTopAt: attribute.indexPath)

        let originalFrameY: CGFloat = CGFloat(attribute.indexPath.item) * cardsOffset + currentSectionInsect.top + collectionView.contentInset.top

        let shiftedFrameY: CGFloat = attribute.frame.minY

        let numberOfItem = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: attribute.indexPath.section) ?? 0

        let buffer: CGFloat
        if attribute.indexPath.item == numberOfItem - 1 {
            buffer = 0
        } else {
            let cardsNextOffset: CGFloat = layoutDelegate.collectionView(collectionView,
                                                                         layout: self,
                                                                         offsetFromPreviousCardTopAt: IndexPath(item: attribute.indexPath.item + 1,
                                                                                                                section: attribute.indexPath.section))
            buffer = cardsNextOffset
        }

        return shiftedFrameY - originalFrameY < cardsOffset + buffer
    }

    func installGesture() {
        self.collectionView?.addGestureRecognizer(panGestureRecognizer)
    }

    func removeGesture() {
        self.collectionView?.removeGestureRecognizer(panGestureRecognizer)
    }

    @objc
    private func movingCard(_ gesture: UIPanGestureRecognizer) {
        guard let collectionView = collectionView else { return }

        let translation: CGPoint = gesture.translation(in: collectionView)

        let section: Int = 0

        if !contentExceedCollectionBounds, translation.y > 0 {
            return
        }
        guard let numberOfItem: Int = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: section) else { return }
        for item in 0 ..< numberOfItem {

            let offset: CGFloat = translation.y

            guard let cell = collectionView.cellForItem(at: IndexPath(item: item, section: section)) else { continue }

            guard cell.frame.origin.y >= originalAttributes[section][0].frame.minY else { continue }

            cell.frame.origin.y = max(originalAttributes[section][item].frame.minY + offset, originalAttributes[section][0].frame.minY)

            if gesture.state == .ended {
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 3,
                               initialSpringVelocity: 1,
                               options: .curveEaseInOut,
                               animations: {
                                cell.frame = self.originalAttributes[section][item].frame
                })
            }
        }
    }
    
}

extension WalletFlowLayout: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if panGestureRecognizer === gestureRecognizer,
            !contentExceedCollectionBounds {
            return panGestureRecognizer.translation(in: collectionView).y > 0
        }
        return true
    }

}

extension CGRect {

    func addingToX(_ offset: CGFloat) -> CGRect {
        return .init(x: minX + offset, y: minY, width: width, height: height)
    }

    func addingToY(_ offset: CGFloat) -> CGRect {
        return .init(x: minX, y: minY + offset, width: width, height: height)
    }

}
