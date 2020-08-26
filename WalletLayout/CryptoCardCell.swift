//
//  CryptoCardCell.swift
//  WalletLayout
//
//  Created by kidnapper on 2020/7/28.
//  Copyright © 2020 andrew. All rights reserved.
//

import UIKit
import SnapKit

private struct UX {
    static let contentViewMargin: UIEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 20)
    static let labelTopInset: CGFloat = 20
    static let iconLeadingInset: CGFloat = 20
    static let estimateValueOffset: CGFloat = 4

    static let cryptoIconSize: CGSize = .init(width: 22, height: 22)
    static let cryptoNameFont: UIFont = UIFont.BO.font(ofSize: 14, weight: .semiBold)
    static let balanceFont: UIFont = UIFont.BO.font(ofSize: 14, weight: .semiBold)
    static let balanceUnitFont: UIFont = UIFont.BO.font(ofSize: 14, weight: .semiBold)
    static let addressColor: UIColor = UIColor.white.withAlphaComponent(0.5)
    static let addressFont: UIFont = UIFont.BO.font(ofSize: 10, weight: .regular)
    static let estimateFiatFont: UIFont = UIFont.BO.font(ofSize: 10, weight: .regular)
}

class CryptoCardCell: UICollectionViewCell {

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let cryptoIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private var crptoNameLabel: UILabel = {
        let label: UILabel = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = UX.cryptoNameFont
        label.numberOfLines = 1
        return label
    }()

    private var balanceLabel: UILabel = {
        let label: UILabel = UILabel()
        label.textColor = .white
        label.textAlignment = .right
        label.font = UX.balanceFont
        return label
    }()

    private var balanceUnitLabel: UILabel = {
        let label: UILabel = UILabel()
        label.textColor = .white
        label.textAlignment = .right
        label.font = UX.balanceUnitFont
        return label
    }()

    private var estimateFiatValueLabel: UILabel = {
        let label: UILabel = UILabel()
        label.textColor = .white
        label.textAlignment = .right
        label.font = UX.estimateFiatFont
        return label
    }()

    private var addressLabel: UILabel = {
        let label: UILabel = UILabel()
        label.textColor = UX.addressColor
        label.textAlignment = .left
        label.font = UX.addressFont
        label.numberOfLines = 0
        return label
    }()

    private let additionShadowLayer: CALayer = .init()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        contentView.layoutMargins = UX.contentViewMargin
    }

    private func setupUI() {
        [backgroundImageView,
         cryptoIconView,
         crptoNameLabel,
         balanceLabel,
         balanceUnitLabel,
         estimateFiatValueLabel,
         addressLabel].forEach {
            contentView.addSubview($0)
        }

        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        cryptoIconView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(UX.contentViewMargin)
            $0.leading.equalToSuperview().inset(UX.iconLeadingInset)
            $0.size.equalTo(UX.cryptoIconSize)
        }
        crptoNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(UX.labelTopInset)
            $0.leading.equalTo(cryptoIconView.snp.trailing).offset(9)
        }
        balanceLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(UX.labelTopInset)
        }
        balanceUnitLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(UX.labelTopInset)
            $0.trailing.equalToSuperview().inset(UX.contentViewMargin)
            $0.leading.equalTo(balanceLabel.snp.trailing).offset(4)
        }
        balanceUnitLabel.setContentHuggingPriority(.required, for: .horizontal)
        balanceUnitLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        estimateFiatValueLabel.snp.makeConstraints {
            $0.top.equalTo(balanceUnitLabel.snp.bottom).offset(UX.estimateValueOffset)
            $0.trailing.equalTo(balanceUnitLabel)
        }

        addressLabel.snp.makeConstraints {
            $0.leading.bottom.equalToSuperview().inset(UX.contentViewMargin)
        }
    }

    func addAdditionalShadowLayer() {
        additionShadowLayer.shadowColor = UIColor.black.cgColor
        additionShadowLayer.shadowOffset = .init(width: 0, height: 10)
        additionShadowLayer.shadowPath = UIBezierPath(roundedRect: layer.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 10, height: 10)).cgPath
        additionShadowLayer.shadowRadius = 5
        additionShadowLayer.shadowOpacity = 0.1
        layer.insertSublayer(additionShadowLayer, at: 0)
    }

    func setup() {
//        backgroundImageView.image = UIImage(named: <#T##String#>)
        cryptoIconView.image = UIImage(named: "icWallet22Blocto")
        crptoNameLabel.text = "Blocto"
        balanceLabel.text = "1000"
        balanceUnitLabel.text = "Points"
        estimateFiatValueLabel.text = "≈ 173.3033 USD"
        addressLabel.text = "thierry@portto.io"
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        additionShadowLayer.removeFromSuperlayer()
    }

}
