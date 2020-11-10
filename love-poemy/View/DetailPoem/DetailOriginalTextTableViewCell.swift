//
//  DetailOriginalTextTableViewCell.swift
//  love-poemy
//
//  Created by 野中志保 on 2020/04/29.
//  Copyright © 2020 野中志保. All rights reserved.
//

import UIKit

class DetailOriginalTextTableViewCell: UITableViewCell {

    
    @IBOutlet weak var sectionTitle: UILabel!
    @IBOutlet weak var dashView: UIView!
    @IBOutlet weak var foreword: UILabel!
    @IBOutlet weak var originalPoem: UILabel!
    @IBOutlet weak var author: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dashView.drawDashedLine(color: UIColor(named: "CustomBlack")!, lineWidth: 4, lineSize: 2, spaceSize: 2)
        sectionTitle.text = "原文"
        foreword.text = ""
        originalPoem.text = ""
        author.text = "詠み人知らず"
    }
    
    func prepareOriginalText(poem:[String:Any]) {
        if let foreword = poem["foreword"] as? String {
            self.foreword.text = foreword
        }
        if let originalPoem = poem["poem"] as? String {
            self.originalPoem.text = originalPoem
        }
        if let author = poem["author"] as? String {
            self.author.text = author
        }
    }
}




