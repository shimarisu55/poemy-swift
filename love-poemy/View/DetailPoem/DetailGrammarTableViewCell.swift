//
//  DetailGrammarTableViewCell.swift
//  love-poemy
//
//  Created by 野中志保 on 2020/04/29.
//  Copyright © 2020 野中志保. All rights reserved.
//

import UIKit

class DetailGrammarTableViewCell: UITableViewCell {

    @IBOutlet weak var dashView: UIView!
    @IBOutlet weak var sectionTitle: UILabel!
    @IBOutlet weak var grammarText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dashView.drawDashedLine(color: UIColor(named: "CustomBlack")!, lineWidth: 4, lineSize: 2, spaceSize: 2)
        grammarText.text = ""
    }

}
