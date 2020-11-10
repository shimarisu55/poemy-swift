//
//  PoemListTableViewCell.swift
//  love-poemy
//
//  Created by 野中志保 on 2020/04/25.
//  Copyright © 2020 野中志保. All rights reserved.
//

import UIKit
import Firebase

protocol ListCellDelegate: AnyObject {
    func exceedMaxBM()
    func removeBookmark(poemId: Int)
}

class PoemListTableViewCell: UITableViewCell {
    
    var poemId: Int = 0
    weak var delegate: ListCellDelegate?
    
    // 使用モデル一覧
    private let bookmarkManageModel = BookmarkManageModel()

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var tag1: UILabel!
    @IBOutlet weak var tag2: UILabel!
    @IBOutlet weak var tag3: UILabel!
    @IBOutlet weak var tag4: UILabel!
    @IBOutlet weak var heartButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        numberLabel.text = ""
        titleLabel.text = ""
        tag1.text = ""
        tag2.text = ""
        tag3.text = ""
        tag4.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func prepareListPoemCell(poem: [String: Any]) {
        if let poemId = poem["id"] as? Int {
            self.poemId = poemId
            numberLabel.text = poemId.description + ". "
        }
        if let beginning = poem["beginning"] as? String {
            titleLabel.text = beginning + "..."
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
        // 画像のダウンロード
        photoImageView.preparePhotoImage(poemId: poemId)
        // お気に入りボタンのセット
        decideFirstheartImage()
        heartButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    // MARK: - お気に入りボタン
    // userDefaultを調べてお気に入りボタンの初期画像をセット
    private func decideFirstheartImage() {
        var heartImageString: String = ""
        let result = bookmarkManageModel.decideheartImage(poemId: poemId)
        switch result {
        case .savedBookmark:
            heartImageString = "heart_add"
        case .noSavedBookmark:
            heartImageString = "heart_out"
        }
        let heartImage = UIImage(named: heartImageString)
        heartButton.setImage(heartImage, for: .normal)
    }
    
    @IBAction func heartButton(_ sender: Any) {
        var heartImageString: String = ""
        let result = bookmarkManageModel.changeBookmark(poemId: poemId)
        switch result {
        case .removeBookmark:
            guard let delegate = delegate else { return }
            delegate.removeBookmark(poemId: poemId)
            heartImageString = "heart_out"
        case .exceedMaxBookmark:
            guard let delegate = delegate else { return }
            delegate.exceedMaxBM()
            heartImageString = "heart_out"
        case .saveBookmark:
            heartImageString = "heart_add"
        }
        let heartImage = UIImage(named: heartImageString)
        heartButton.setImage(heartImage, for: .normal)
    }
    
    
}
