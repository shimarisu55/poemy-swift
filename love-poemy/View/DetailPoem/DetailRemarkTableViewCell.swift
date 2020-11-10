//
//  DetailAppliciationTableViewCell.swift
//  love-poemy
//
//  Created by 野中志保 on 2020/04/29.
//  Copyright © 2020 野中志保. All rights reserved.
//

import UIKit

class DetailRemarkTableViewCell: UITableViewCell {

    @IBOutlet weak var remark: UILabel!
    @IBOutlet weak var dashView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        dashView.drawDashedLine(color: UIColor(named: "CustomBlack")!, lineWidth: 4, lineSize: 2, spaceSize: 2)
        self.remark.text = ""
    }

    func prepareRemark(poem:[String:Any]) {
        if let remark = poem["remark"] as? String {
            self.remark.text = remark
        }
    }
    
}
