//
//  EditCryptoCardCell.swift
//  WalletLayout
//
//  Created by kidnapper on 2020/8/6.
//  Copyright © 2020 andrew. All rights reserved.
//

import UIKit

private struct UX {
    static let cardInset: UIEdgeInsets = .init(top: 20, left: 17, bottom: 20, right: 0)
    static let editButtonInset: UIEdgeInsets = .init(top: 53, left: 32, bottom: 53, right: 32)
}

class EditCryptoCardCell: UICollectionViewCell {

    enum Style {
        case normal
        case dragDisable
        case disable
    }

    private var cardView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .systemTeal
        view.layer.cornerRadius = 13
        view.clipsToBounds = true
        return view
    }()

    private var editButton: UIButton = {
        let button: UIButton = UIButton()
        button.setImage(UIImage(named: "icReorder"), for: .normal)
//        button.backgroundColor = .white
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(cardView)
        contentView.addSubview(editButton)

        cardView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview().inset(UX.cardInset)
        }

        editButton.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 20, height: 20))
            $0.leading.equalTo(cardView.snp.trailing).offset(UX.editButtonInset.left)
            $0.top.trailing.equalToSuperview().inset(UX.editButtonInset)
        }
    }

    func canDrag(by point: CGPoint) -> Bool {
        editButton.frame.contains(point)
    }

    func updateStyle(style: Style) {
        switch style {
        case .normal:
            editButton.backgroundColor = .clear
        case .disable:
            editButton.backgroundColor = .black
        case .dragDisable:
            editButton.backgroundColor = .red
        }
    }

}
