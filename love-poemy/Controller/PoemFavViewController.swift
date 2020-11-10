//
//  PoemFavViewController.swift
//  love-poemy
//
//  Created by 野中志保 on 2020/04/25.
//  Copyright © 2020 野中志保. All rights reserved.
//

import UIKit

class PoemFavViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,  ListCellDelegate {

    private var pluralPoems: [[String:Any]?] = []
    private var sortedFavPoemIdArray: [Int] = []
    
    // 使用モデル一覧
    private let fetchFirestoreModel = FetchFirestoreModel()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableInitialize()
        activityIndicator.hidesWhenStopped = true
        callDocuments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        callDocuments()
    }
    
    // MARK: -fetchDocuments
    private func callDocuments() {
        activityIndicator.startAnimating()
        let favNumArray = fetchFirestoreModel.callFavNumber()
        if favNumArray != [] {
            fetchFirestoreModel.fetchDocuments(numberArray: favNumArray, completion: { (pluralPoems) in
                if let newPoems = pluralPoems {
                    self.pluralPoems = newPoems
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else {
                    self.errorCallDocument()
                }
            })
        }
        self.activityIndicator.stopAnimating()
    }
    
    private func errorCallDocument() {
        // 通信エラー
        DispatchQueue.main.async {
            self.tableView.reloadData()
            let NetworkError = UIViewController.ErrorMassage.NetworkError
            self.takeError(message: NetworkError)
            // フッターの最後のセルの位置を調整する
            if self.pluralPoems.count > 0 {
                let indexPath = NSIndexPath(row: (self.pluralPoems.count - 1), section: 0)
                self.tableView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
            }
        }
    }
    
    
    // MARK: - テーブルビューのリロード
    private func tableInitialize() {
        tableView.register(UINib(nibName: "PoemListTableViewCell", bundle: nil), forCellReuseIdentifier: "ListCell")
    }
    
    // セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pluralPoems.count
    }
    
    // セルの生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let listCell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as? PoemListTableViewCell {
            listCell.delegate = self
            if let eachPoem = pluralPoems[indexPath.row] {
                listCell.prepareListPoemCell(poem: eachPoem)
            }
            return listCell
        }
        return UITableViewCell()
    }
    
    // セルがタップされたら
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard: UIStoryboard = self.storyboard!
        if let detailView = storyboard.instantiateViewController(withIdentifier: "detailView") as? PoemDetailViewController {
            // 選んだセルのindexPath番号の店舗情報を詳細画面に渡す。
            if let eachPoem = pluralPoems[indexPath.row] {
                detailView.poem = eachPoem
                if let poemId = eachPoem["id"] as? Int {
                    detailView.poemId = poemId
                }
            }
            // 一覧画面に戻ってきたときセルのハイライトが残る状態を防ぐ
            tableView.deselectRow(at: indexPath, animated: true)
            navigationController?.pushViewController(detailView, animated: true)
        }
    }
    
    
    // MARK: - セルのデリゲート設定
    /// 各セルのお気に入りボタンが押されてブックマークが解消されたらセルを消す
    /// - Parameter shopId: ブックマーク解消した店舗のid
    func removeBookmark(poemId: Int) {
        var rowNumber: Int = 0
        // 消去するrowNumberが何番目かを調べる
        for i in 0..<pluralPoems.count {
            if let eachPoemId = pluralPoems[i]?["id"] as? Int {
                if eachPoemId == poemId {
                    rowNumber = i
                    break
                }
            }
        }
        let indexPath = NSIndexPath(row: rowNumber, section: 0) as IndexPath
        tableView.beginUpdates()
        pluralPoems.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.endUpdates()
    }

    func exceedMaxBM() {
        // ブックマーク×一覧画面で11件以上ブックマーク登録することはないので空
    }



}
