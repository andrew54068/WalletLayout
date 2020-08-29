//
//  CollectionAssetCell.swift
//  WalletLayout
//
//  Created by kidnapper on 2020/8/27.
//  Copyright © 2020 andrew. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

private struct UX {
    static let margin: UIEdgeInsets = .init(top: 0, left: 11.5, bottom: 12, right: 13.5)
}

final class CollectionAssetCell: UICollectionViewCell {

    private let contentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private var titleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.textColor = .init(red: 20 / 255, green: 20 / 255, blue: 20 / 255, alpha: 1)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()

    private var desLabel: UILabel = {
        let label: UILabel = UILabel()
        label.textColor = .init(red: 127 / 255, green: 127 / 255, blue: 127 / 255, alpha: 1)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        [
            contentImageView,
            titleLabel,
            desLabel
            ].forEach {
                contentView.addSubview($0)
        }

        contentView.backgroundColor = .white
        contentView.layoutMargins = UX.margin

        contentImageView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(contentView)
            $0.width.equalTo(contentImageView.snp.height)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(contentImageView.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(contentView.layoutMargins)
        }

        desLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.top).offset(4)
            $0.leading.equalTo(titleLabel)
            $0.bottom.equalTo(contentView.layoutMargins)
        }

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = .init(width: 0, height: 5)
        layer.shadowPath = UIBezierPath(roundedRect: contentView.layer.bounds,
                                        byRoundingCorners: .allCorners,
                                        cornerRadii: CGSize(width: 10, height: 10)).cgPath
        layer.shadowRadius = 7.5
        layer.shadowOpacity = 0.05

    }

    func update(asset: CollectionAsset) {
        contentImageView.kf.setImage(with: asset.imageUrl)
        titleLabel.text = asset.title
        desLabel.text = asset.des
    }

}

struct CollectionAsset {
    let imageUrl: URL
    let title: String
    let des: String
}
