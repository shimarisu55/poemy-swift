//
//  DetailWordTableViewCell.swift
//  love-poemy
//
//  Created by 野中志保 on 2020/05/26.
//  Copyright © 2020 野中志保. All rights reserved.
//

import UIKit

class DetailWordTableViewCell: UITableViewCell {

    @IBOutlet weak var dashView: UIView!
    @IBOutlet weak var sectionTitle: UILabel!
    @IBOutlet weak var wordText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dashView.drawDashedLine(color: UIColor(named: "CustomBlack")!, lineWidth: 4, lineSize: 2, spaceSize: 2)
        wordText.text = ""
    }

    
}
