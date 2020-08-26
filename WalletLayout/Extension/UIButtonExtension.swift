//
//  UIButtonExtension.swift
//  WalletLayout
//
//  Created by kidnapper on 2020/8/14.
//  Copyright © 2020 andrew. All rights reserved.
//

import UIKit
import SnapKit
import BonMot

extension UIButton {
    func setInsetBetween(_ value: CGFloat) {
        contentEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: value)
        titleEdgeInsets = .init(top: 0, left: value, bottom: 0, right: -value)
    }
}

extension UIFont {

    enum WeightStyle: String {
        case thin = "Thin"
        case extraLight = "ExtraLight"
        case light = "Light"
        case medium = "Medium"
        case semiBold = "SemiBold"
        case regular = "Regular"
        case bold = "Bold"
        case extraBold = "ExtraBold"
        case black = "Black"
    }

    enum BO {

        private static var fontName: String {
            return "WorkSans"
        }

        static func font(ofSize size: CGFloat, weight: WeightStyle = .regular) -> UIFont {
            return UIFont(name: "\(fontName)-\(weight.rawValue)", size: size) ?? UIFont.systemFont(ofSize: size)
        }

        static func italicFont(ofSize size: CGFloat, weight: WeightStyle = .regular) -> UIFont {
            return UIFont(name: "\(fontName)-\(weight.rawValue)Italic", size: size) ?? UIFont.italicSystemFont(ofSize: size)
        }

        static let titleBig = font(ofSize: 24, weight: .bold)
        static let title = font(ofSize: 20, weight: .bold)
        static let desc = font(ofSize: 14)
        static let note = font(ofSize: 12)
        static let error = font(ofSize: 12)

        static let tutorialDesc = font(ofSize: 16)
        static let tutorialButton = font(ofSize: 20, weight: .semiBold)

        static let descMinLineHeight = 22.4
    }
}

extension UIButton {

    enum BO {

        // swiftlint:disable:next nesting
        struct UX {
            static let font = UIFont.BO.font(ofSize: 14, weight: .semiBold)
            static let pureFont = UIFont.BO.font(ofSize: 14)
            static let height: CGFloat = 44
            static let borderWidth: CGFloat = 1
            static let borderContentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
            static let cornerRadius: CGFloat = 6
            static let kern: CGFloat = 1.25
        }

        static func make(
            style: Style,
            title: String? = nil,
            height: CGFloat = UX.height,
            cornerRadius: CGFloat = UX.cornerRadius,
            uppercased: Bool? = nil
        ) -> UIButton {
            /// handle uppercased
            var title = title
            if let uppercased = uppercased {
                if uppercased {
                    title = title?.uppercased()
                }
            } else {
                switch style {
                case .primary, .cancel, .fill:
                    title = title?.uppercased()
                case .pure, .border:
                    break
                }
            }

            let button = BOButton()
//            button.setTitleColor(style.textColor, for: .normal)
//            button.setTitleColor(style.textColor?.withAlphaComponent(style.disabledAlpha), for: .disabled)
//            button.normalBackgroundColor = style.backgroundColor
//            button.disabledBackgroundColor = style.backgroundColor?.withAlphaComponent(style.disabledAlpha)
            button.normalBorderColor = style.borderColor
            button.disabledBorderColor = style.borderColor?.withAlphaComponent(style.disabledAlpha)

            update(button: button,
                   style: style,
                   title: title,
                   cornerRadius: cornerRadius)

            button.snp.makeConstraints {
                $0.height.equalTo(height)
            }
            return button
        }

        internal static func update(
            button: UIButton,
            style: Style,
            title: String? = nil,
            cornerRadius: CGFloat = UX.cornerRadius
        ) {
//            switch style {
//            case .primary, .cancel:
//                button.titleLabel?.font = UX.font
//                button.setAttributedTitle(title?.styled(with: StringStyle([.tracking(.point(UX.kern)), .color(style.textColor ?? .white)])), for: .normal)
//                button.layer.cornerRadius = cornerRadius
//            case .pure:
//                button.titleLabel?.font = UX.pureFont
//                button.setAttributedTitle(title?.styled(with: StringStyle([.color(style.textColor ?? .white)])), for: .normal)
//            case .border:
//                button.titleLabel?.font = UX.pureFont
//                button.setAttributedTitle(title?.styled(with: StringStyle([.color(style.textColor ?? .white)])), for: .normal)
//                button.layer.borderWidth = UX.borderWidth
//                button.contentEdgeInsets = UX.borderContentEdgeInsets
//                button.layer.cornerRadius = cornerRadius
//            case .fill:
//                button.titleLabel?.font = UX.font
//                button.setAttributedTitle(title?.styled(with: StringStyle([.tracking(.point(UX.kern)), .color(style.textColor ?? .white)])), for: .normal)
//            }
        }

    }

    func update(
        style: UIButton.BO.Style,
        title: String? = nil,
        cornerRadius: CGFloat = BO.UX.cornerRadius
    ) {
        BO.update(button: self,
                  style: style,
                  title: title,
                  cornerRadius: cornerRadius)
    }

}

extension UIButton.BO {

    enum Style {
        case primary
        case pure
        case cancel
        case border
        case fill

//        var textColor: UIColor? {
//            switch self {
//            case .primary:
//                return R.color.buttonPrimaryText()
//            case .pure:
//                return R.color.buttonPure()
//            case .cancel:
//                return R.color.buttonCancelText()
//            case .border:
//                return R.color.buttonPure()
//            case .fill:
//                return R.color.buttonFillText()
//            }
//        }

//        var backgroundColor: UIColor? {
//            switch self {
//            case .primary:
//                return R.color.buttonPrimary()
//            case .pure:
//                return nil
//            case .cancel:
//                return R.color.buttonCancel()
//            case .border:
//                return nil
//            case .fill:
//                return R.color.buttonFill()
//            }
//        }

        var disabledAlpha: CGFloat {
            switch self {
            case .primary:
                return 0.3
            case .pure:
                return 0.3
            case .cancel:
                return 0.05
            case .border:
                return 0.4
            case .fill:
                return 0.3
            }
        }

        var borderColor: UIColor? {
            switch self {
            case .primary:
                return nil
            case .pure:
                return nil
            case .cancel:
                return nil
            case .border:
                return nil
            case .fill:
                return nil
            }
        }
    }
}

private class BOButton: UIButton {

    fileprivate var normalBackgroundColor: UIColor? {
        didSet {
            if isEnabled {
                backgroundColor = normalBackgroundColor
            }
        }
    }

    fileprivate var disabledBackgroundColor: UIColor? {
        didSet {
            if !isEnabled {
                backgroundColor = disabledBackgroundColor
            }
        }
    }

    fileprivate var normalBorderColor: UIColor? {
        didSet {
            if isEnabled {
                layer.borderColor = normalBorderColor?.cgColor
            }
        }
    }

    fileprivate var disabledBorderColor: UIColor? {
       didSet {
           if !isEnabled {
               layer.borderColor = disabledBorderColor?.cgColor
           }
       }
   }

    override var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? normalBackgroundColor : disabledBackgroundColor
            layer.borderColor = isEnabled ? normalBorderColor?.cgColor : disabledBorderColor?.cgColor
        }
    }
}
