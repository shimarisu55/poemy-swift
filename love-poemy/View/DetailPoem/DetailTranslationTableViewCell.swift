//
//  DetailTranslationTableViewCell.swift
//  love-poemy
//
//  Created by 野中志保 on 2020/04/29.
//  Copyright © 2020 野中志保. All rights reserved.
//

import UIKit

class DetailTranslationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dashView: UIView!
    @IBOutlet weak var meaning: UILabel!
    @IBOutlet weak var tag1: UILabel!
    @IBOutlet weak var tag2: UILabel!
    @IBOutlet weak var tag3: UILabel!
    @IBOutlet weak var tag4: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dashView.drawDashedLine(color: UIColor(named: "CustomBlack")!, lineWidth: 4, lineSize: 2, spaceSize: 2)
        meaning.text = ""
        tag1.text = ""
        tag2.text = ""
        tag3.text = ""
        tag4.text = ""
    }

    func prepareTranslation(poem:[String:Any]) {
        if let meaning = poem["meaning"] as? String {
            self.meaning.text = meaning
        }
        if let tag1 = poem["tag1"] as? String {
            self.tag1.text = tag1
        }
        if let tag2 = poem["tag2"] as? String {
            self.tag2.text = tag2
        }
        if let tag3 = poem["tag3"] as? String {
            self.tag3.text = tag3
        }
        if let tag4 = poem["tag4"] as? String {
            self.tag4.text = tag4
        }
    }
    
}
