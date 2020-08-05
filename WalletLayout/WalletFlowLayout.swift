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
    private var displayFrames: [[CGRect]] = []

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
        attributes.removeAll()
        displayFrames.removeAll()

        guard let collectionView: UICollectionView = collectionView else { return }

        guard let layoutDelegate: WalletFlowLayoutDelegate = layoutDelegate else { return }

        var latestCardFrame: CGRect = .zero
        var lastSectionInset: UIEdgeInsets = .zero

        for section in 0 ..< collectionView.numberOfSections {
            guard let numberOfItem = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: section) else { return }
            let currentSectionInsect: UIEdgeInsets = layoutDelegate.collectionView?(collectionView, layout: self, insetForSectionAt: section) ?? .zero

            var currentCardFrame: CGRect = latestCardFrame
            if section != 0 {
                currentCardFrame = currentCardFrame.addingToY(lastSectionInset.bottom)
            }
            currentCardFrame = currentCardFrame.addingToX(currentSectionInsect.left)
            currentCardFrame = currentCardFrame.addingToY(currentSectionInsect.top)

            var tempAttributes: [UICollectionViewLayoutAttributes] = []
            var tempFrames: [CGRect] = []
            for item in 0 ..< numberOfItem {
                let indexPath: IndexPath = .init(item: item, section: section)
                let itemSize: CGSize = layoutDelegate.collectionView?(collectionView, layout: self, sizeForItemAt: indexPath) ?? .zero

                // get offset from each card top, cause card are overlay by this attribute
                let cardsOffset: CGFloat = layoutDelegate.collectionView(collectionView, layout: self, offsetFromPreviousCardTopAt: indexPath)
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
                tempFrames.append(cardFrame)

                latestCardFrame = cardFrame
                contentHeight = cardFrame.maxY
            }
            contentHeight += currentSectionInsect.bottom
            lastSectionInset = currentSectionInsect
            attributes.append(tempAttributes)
            displayFrames.append(tempFrames)
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
        return true
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

        let buffer: CGFloat = 41

        return shiftedFrameY - originalFrameY < cardsOffset + buffer
    }

    func installGesture() {
//        let panGestureRecognizer: UIPanGestureRecognizer = .init(target: self, action: #selector(movingCard(_:)))
//        panGestureRecognizer.delegate = self
//        self.collectionView?.addGestureRecognizer(panGestureRecognizer)
    }

//    @objc
//    private func movingCard(_ gesture: UIPanGestureRecognizer) {
//        guard let collectionView = collectionView else { return }
//
//        let translation: CGPoint = gesture.translation(in: collectionView)
//        let velocity: CGPoint = gesture.velocity(in: collectionView)
//
//        let section: Int = 0
//
//        guard let numberOfItem: Int = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: section) else { return }
//        for item in 1 ..< numberOfItem {
//
//            let offset: CGFloat
//            if velocity.y >= 0 {
//                offset = (CGFloat(item) * sqrt(abs(translation.y)) * 2)
//            } else {
//                offset = (CGFloat(item) * -sqrt(abs(translation.y)) * 2)
//            }
//
//            let finalOffset: CGFloat = offset
//
//            collectionView.cellForItem(at: IndexPath(item: item, section: section))?.frame.origin.y = max (originalAttributes[section][item].frame.minY + finalOffset, originalAttributes[section][0].frame.minY)
//
//            if gesture.state == .ended {
//                UIView.animate(withDuration: 0.3,
//                               delay: 0,
//                               usingSpringWithDamping: 3,
//                               initialSpringVelocity: 1,
//                               options: .curveEaseInOut,
//                               animations: {
//                                collectionView.cellForItem(at: IndexPath(item: item, section: section))?.frame = self.originalAttributes[section][item].frame
//                })
//            }
//        }
//    }
    
}

extension WalletFlowLayout: UIGestureRecognizerDelegate {

}

extension CGRect {

    func addingToX(_ offset: CGFloat) -> CGRect {
        return .init(x: minX + offset, y: minY, width: width, height: height)
    }

    func addingToY(_ offset: CGFloat) -> CGRect {
        return .init(x: minX, y: minY + offset, width: width, height: height)
    }

}
