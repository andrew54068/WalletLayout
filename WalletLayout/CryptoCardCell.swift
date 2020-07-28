//
//  CryptoCardCell.swift
//  WalletLayout
//
//  Created by kidnapper on 2020/7/28.
//  Copyright © 2020 andrew. All rights reserved.
//

import UIKit
import SnapKit

class CryptoCardCell: UICollectionViewCell {

    private var balanceLabel: UILabel = {
        let label: UILabel = UILabel()
        label.textColor = .blue
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        contentView.layer.cornerRadius = 10
    }

    private func setupUI() {
        contentView.backgroundColor = .gray

        addSubview(balanceLabel)
        balanceLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(10)
        }
    }

}
