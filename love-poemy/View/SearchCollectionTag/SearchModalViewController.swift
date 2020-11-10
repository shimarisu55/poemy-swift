//
//  SearchModalViewController.swift
//  love-poemy
//
//  Created by 野中志保 on 2020/06/07.
//  Copyright © 2020 野中志保. All rights reserved.
//

import UIKit

class SearchModalViewController: UIViewController {
    
    private enum Tag: Int {
        case Spring1 = 0
        case Spring2
        case Summer
        case Autumn1
        case Autumn2
        case Winter
        case Celebration
        case farewell
        case Count
    }
    
    var callBackSearchPoems: (([Int]) -> Void)?
    // 使用モデル一覧
    private let fetchFirestoreModel = FetchFirestoreModel()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var explanation: UILabel!
    @IBOutlet weak var webURLButton: UIButton!
    @IBOutlet weak var introSummary: UILabel!
    @IBOutlet weak var introSummaryButton: UIButton!
    @IBOutlet weak var collectionViewFlow: UICollectionViewFlowLayout!

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "SearchTagCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "tagTextCell")
    }
    
    override func viewDidLayoutSubviews() {
        super .viewDidLayoutSubviews()
        setCollectionItemSize()
    }
    
    // セルの大きさ
    private func setCollectionItemSize() {
        // セル同士の間隔(横)
        collectionViewFlow.minimumInteritemSpacing = 10
        // セル同士の間隔(縦)
        collectionViewFlow.minimumLineSpacing = 10
        let collectionWidth = collectionView.bounds.width
        let cellWidth = (collectionWidth - 50)/5
        collectionViewFlow.estimatedItemSize = CGSize(width: cellWidth, height: cellWidth)
    }
    
    // webボタン
    @IBAction func webURLButton(_ sender: Any) {
        if let url = NSURL(string: "http://www.milord-club.com/Kokin/index.htm") {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func introSummaryButton(_ sender: Any) {
        if let url = NSURL(string: "https://education-summary.com") {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    
    
}

// MARK: - コレクションビューdataSource
extension SearchModalViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Tag.Count.rawValue
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let tagTextCell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagTextCell", for: indexPath) as? SearchTagCollectionViewCell {
            switch indexPath.row {
            case Tag.Spring1.rawValue:
                tagTextCell.textLabel.text = "春上"
            case Tag.Spring2.rawValue:
                tagTextCell.textLabel.text = "春下"
            case Tag.Summer.rawValue:
                tagTextCell.textLabel.text = "夏"
            case Tag.Autumn1.rawValue:
                tagTextCell.textLabel.text = "秋上"
            case Tag.Autumn2.rawValue:
                tagTextCell.textLabel.text = "秋下"
            case Tag.Winter.rawValue:
                tagTextCell.textLabel.text = "冬"
            case Tag.Celebration.rawValue:
                tagTextCell.textLabel.text = "賀歌"
            case Tag.farewell.rawValue:
                tagTextCell.textLabel.text = "離別"
            default:
                tagTextCell.textLabel.text = "なし"
            }
            return tagTextCell
        }
        return UICollectionViewCell()
    }
}

// MARK: - セル選択時の処理
extension SearchModalViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var minPoemNumber: Int = 1
        var maxPoemNumber: Int = 200
        switch indexPath.row {
        case Tag.Spring1.rawValue:
            minPoemNumber = 1; maxPoemNumber = 68
        case Tag.Spring2.rawValue:
            minPoemNumber = 69; maxPoemNumber = 134
        case Tag.Summer.rawValue:
            minPoemNumber = 135; maxPoemNumber = 168
        case Tag.Autumn1.rawValue:
            minPoemNumber = 169; maxPoemNumber = 248
            let NoPoem = UIViewController.ErrorMassage.NoPoem
            takeError(message: NoPoem)
            return
        case Tag.Celebration.rawValue:
            minPoemNumber = 343; maxPoemNumber = 364
        case Tag.farewell.rawValue:
            minPoemNumber = 365; maxPoemNumber = 405
        default:
            let NoPoem = UIViewController.ErrorMassage.NoPoem
            takeError(message: NoPoem)
            return
        }
        // 指定の巻からランダムに10選び、変数に入れる
        let searchNumArray: [Int] = fetchFirestoreModel.callRandomNumber(first: minPoemNumber, last: maxPoemNumber)
        dismiss(animated: true) {
            // 戻ったらclosureを発火
            self.callBackSearchPoems?(searchNumArray)
        }
        
        collectionView.reloadItems(at: [indexPath])
    }
}

