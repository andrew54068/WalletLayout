//
//  TestTableViewCell.swift
//  WalletLayout
//
//  Created by kidnapper on 2020/8/6.
//  Copyright © 2020 andrew. All rights reserved.
//

import UIKit

class TestTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func setupUI() {
        contentView.backgroundColor = .systemGray
        textLabel?.text = "123"
        detailTextLabel?.text = "432"
        showsReorderControl = true
        shouldIndentWhileEditing = true
    }

}
