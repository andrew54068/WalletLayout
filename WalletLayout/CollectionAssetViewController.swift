//
//  CollectionAssetViewController.swift
//  WalletLayout
//
//  Created by kidnapper on 2020/8/27.
//  Copyright © 2020 andrew. All rights reserved.
//

import UIKit

class CollectionAssetViewController: UIViewController {

    private let dataSource: [CollectionAsset] = [
        CollectionAsset(imageUrl: URL(string: "https://lh3.googleusercontent.com/PJvH9SkKtgJ_-O9p3tc1xc-L-TvLfAt2dPh-R8AAPGJxX8lAiF84CHMbj4dkhObNzVEraMYupcS_VOJE7zdMS9M=h260")!,
                        title: "Axie",
                        des: "Axie Infinity"),
        CollectionAsset(imageUrl: URL(string: "https://lh3.googleusercontent.com/BFINzWn3-uCc619oshZ8qfgaQse0zro98-KMkWb49OmHylRfXg0LNVQGfsDAM6EAWtU7FA-ZI1tDDssd0Nl6dNc=h260")!,
                        title: "BFH",
                        des: "Brave Frontier Heroes"),
        CollectionAsset(imageUrl: URL(string: "https://lh3.googleusercontent.com/XJHuGX3BOI_HRP8IEFiNGF_-7w148OILDAgYzZP9953L1eUoKK2Z3yBgGdW4XqAUM9aLIK89MRpzIcj35Z52aHtJ=h260")!,
                        title: "Bits and Pieces",
                        des: "Bits")
    ]

    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshCollection), for: .valueChanged)
        return control
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: UICollectionViewFlowLayout())
        let types: [UICollectionViewCell.Type] = [
            CollectionAssetCell.self
        ]
        types.forEach {
            collectionView.register($0, forCellWithReuseIdentifier: NSStringFromClass($0))
        }
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.refreshControl = refreshControl
        collectionView.backgroundColor = .systemGray
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

    @objc
    private func refreshCollection() {
        collectionView.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.refreshControl.endRefreshing()
            self.collectionView.isUserInteractionEnabled = true
            self.collectionView.reloadData()
        }
    }

}

extension CollectionAssetViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(CollectionAssetCell.self), for: indexPath) as! CollectionAssetCell
        cell.update(asset: dataSource[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 24 - 16 - 24) / 2,
                      height: (collectionView.bounds.width - 24 - 16 - 24) / 2 / 156 * 216)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 40, left: 15, bottom: 50, right: 15)
    }

}
