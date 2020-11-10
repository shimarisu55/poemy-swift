//
//  SearchTagCollectionViewCell.swift
//  love-poemy
//
//  Created by 野中志保 on 2020/05/05.
//  Copyright © 2020 野中志保. All rights reserved.
//

import UIKit

class SearchTagCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textLabel.text = ""
        self.textLabel.textColor = .red
        // 枠線
        self.layer.borderColor = UIColor(named: "CustomPink")?.cgColor
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 5
    }

}
