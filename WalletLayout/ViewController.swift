//
//  ViewController.swift
//  WalletLayout
//
//  Created by kidnapper on 2020/7/28.
//  Copyright © 2020 andrew. All rights reserved.
//

import UIKit
import SnapKit

private struct UX {
    static let cardOffset: CGFloat = 41
}

class ViewController: UIViewController {

    private lazy var collectionView: UICollectionView = {
        let flowLayout: WalletFlowLayout = WalletFlowLayout(delegate: self)
        let collectionView: UICollectionView = UICollectionView(frame: .zero,
                                                                collectionViewLayout: flowLayout)
//        flowLayout.installGesture()
        let types: [UICollectionViewCell.Type] = [
            CryptoCardCell.self
        ]
        types.forEach {
            collectionView.register($0, forCellWithReuseIdentifier: NSStringFromClass($0))
        }
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

    }

}

extension ViewController: UICollectionViewDataSource, WalletFlowLayoutDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(CryptoCardCell.self), for: indexPath)
        cell.contentView.backgroundColor = [UIColor.red, UIColor.blue, UIColor.yellow, UIColor.black, UIColor.brown][indexPath.item % 5]
//        cell.contentView.backgroundColor = .white
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.layer.zPosition = CGFloat(indexPath.item)
        if indexPath.item > 0 {
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOffset = .init(width: 0, height: -1)
            cell.layer.shadowPath = UIBezierPath(roundedRect: cell.layer.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 10, height: 10)).cgPath
            cell.layer.shadowRadius = 0.5
            cell.layer.shadowOpacity = 0.15
        }

        let numberOfItems = self.collectionView(collectionView, numberOfItemsInSection: indexPath.section)
        if indexPath.item == max(numberOfItems - 1, 0) {
            (cell as? CryptoCardCell)?.addAdditionalShadowLayer()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 30,
                      height: (collectionView.bounds.width - 30) / 16 * 10)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 50, left: 15, bottom: 50, right: 15)
    }

    // MARK: - WalletFlowLayoutDelegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: WalletFlowLayout, offsetFromPreviousCardTopAt indexPath: IndexPath) -> CGFloat {
        if indexPath.item == 0 {
            return 0
        }
        return UX.cardOffset
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: WalletFlowLayout, distanceToVisualTop: CGFloat, at indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.shadowOpacity = Float(0.15 * min(distanceToVisualTop, UX.cardOffset) / UX.cardOffset)
    }

}
