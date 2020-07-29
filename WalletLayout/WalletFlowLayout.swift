//
//  WalletFlowLayout.swift
//  WalletLayout
//
//  Created by kidnapper on 2020/7/28.
//  Copyright © 2020 andrew. All rights reserved.
//

import UIKit

protocol WalletFlowLayoutDelegate: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: WalletFlowLayout, offsetFromPreviousCardTop atIndexPath: IndexPath) -> CGFloat
}

final class WalletFlowLayout: UICollectionViewLayout {

    private var attributes: [[UICollectionViewLayoutAttributes]] = []

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
        attributes = []

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
            for item in 0 ..< numberOfItem {
                let indexPath: IndexPath = .init(item: item, section: section)
                let itemSize: CGSize = layoutDelegate.collectionView?(collectionView, layout: self, sizeForItemAt: indexPath) ?? .zero

                // get offset from each card top, cause card are overlay by this attribute
                let cardsOffset: CGFloat = layoutDelegate.collectionView(collectionView, layout: self, offsetFromPreviousCardTop: indexPath)
                let attri: UICollectionViewLayoutAttributes = .init(forCellWith: indexPath)
                let cardFrame: CGRect = .init(x: currentCardFrame.minX,
                                              y: currentCardFrame.addingToY(cardsOffset).minY,
                                              width: itemSize.width,
                                              height: itemSize.height)
                attri.zIndex = item
                currentCardFrame = cardFrame
                attri.frame = cardFrame
                tempAttributes.append(attri)

                latestCardFrame = cardFrame
                contentHeight = cardFrame.maxY
            }
            contentHeight += currentSectionInsect.bottom
            lastSectionInset = currentSectionInsect
            attributes.append(tempAttributes)
        }

    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributes.flatMap { $0 }.filter { $0.frame.intersects(rect) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributes[indexPath.section][indexPath.item]
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
