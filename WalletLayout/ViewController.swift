//
//  ViewController.swift
//  WalletLayout
//
//  Created by kidnapper on 2020/7/28.
//  Copyright © 2020 andrew. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    private lazy var collectionView: UICollectionView = {
        let flowLayout: WalletFlowLayout = WalletFlowLayout(delegate: self)
        let collectionView: UICollectionView = UICollectionView(frame: .zero,
                                                                collectionViewLayout: flowLayout)
        flowLayout.installGesture()
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
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(CryptoCardCell.self), for: indexPath)
        cell.contentView.backgroundColor = [UIColor.red, UIColor.blue, UIColor.yellow, UIColor.black, UIColor.brown][indexPath.item % 5]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.layer.zPosition = CGFloat(indexPath.item)
        if indexPath.item > 0 {
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOffset = .init(width: 1, height: 1)
            cell.layer.shadowPath = UIBezierPath(roundedRect: cell.layer.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 10, height: 10)).cgPath
            cell.layer.shadowRadius = 10
            cell.layer.shadowOpacity = 0.2
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
        return .init(top: 10, left: 15, bottom: 10, right: 15)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: WalletFlowLayout, offsetFromPreviousCardTop atIndexPath: IndexPath) -> CGFloat {
        return 50
    }

}
