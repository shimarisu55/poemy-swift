//
//  PoemListViewController.swift
//  love-poemy
//
//  Created by 野中志保 on 2020/04/25.
//  Copyright © 2020 野中志保. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import GoogleMobileAds

class PoemListViewController: UIViewController, UITableViewDelegate, ListCellDelegate, GADInterstitialDelegate {
    
    private var pluralPoems: [[String:Any]?] = []
    private var numArray: [Int] = []
    // リフレッシュボタンが何回押されたか測定する
    private var refreshTime = 0
    private var interstitial: GADInterstitial!
    private let lastPoemNumber = Bundle.main.object(forInfoDictionaryKey: "Last Poem Number") as! Int
    
    // 使用モデル一覧
    private let fetchFirestoreModel = FetchFirestoreModel()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        activityIndicator.hidesWhenStopped = true
        // アプリ表示
        tableInitialize()
        numArray = fetchFirestoreModel.callRandomNumber(last: lastPoemNumber)
        callDocuments()
        // 広告関係
        interstitial = createAndLoadInterstitial()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        // APIは呼ばない。お気に入り状態などの更新のみ。
        tableView.reloadData()
    }
    
//    // 開発用。userDefaultを初期化するときに使う
//    func removeUserDefaults() {
//        let appDomain = Bundle.main.bundleIdentifier
//        UserDefaults.standard.removePersistentDomain(forName: appDomain!)
//    }
    
    // MARK: -fetchDocuments
    private func callDocuments() {
        activityIndicator.startAnimating()
        pluralPoems = []
        fetchFirestoreModel.fetchDocuments(numberArray: numArray, completion: { [weak self] (pluralPoems) in
            guard let weakSelf = self else { return }
            if let newPoems = pluralPoems {
                weakSelf.pluralPoems = newPoems
                DispatchQueue.main.async {
                    weakSelf.tableView.reloadData()
                }
            } else {
                weakSelf.errorCallDocument()
            }
            weakSelf.activityIndicator.stopAnimating()
        })
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

    // MARK: - 上部のボタン設定
    @IBAction func searchButton(_ sender: Any) {
        let SearchModalVC = SearchModalViewController()
        // SearchModalVCで検索するidが決まったら、それを引数に検索を実行
        SearchModalVC.callBackSearchPoems = { (searchNumArray) in
            self.callBackSearch(searchNumArray: searchNumArray)
        }
        present(SearchModalVC, animated: true, completion: nil)
    }
    // 検索画面から戻ってきたときに実行する関数
    // 検索画面で選んだ歌番号で再検索
    public func callBackSearch(searchNumArray: [Int]) {
        numArray = []
        numArray = searchNumArray
        callDocuments()
    }
    
    // リフレッシュボタンが押されたら新たに10首選択され更新
    @IBAction func refreshButton(_ sender: Any) {
        refreshTime = refreshTime + 1
        // 3回更新かけたら広告表示
        if refreshTime >= 3 && interstitial.isReady {
            interstitial.present(fromRootViewController: self)
            refreshTime = 0
        }
        numArray = []
        numArray = fetchFirestoreModel.callRandomNumber(last: lastPoemNumber)
        callDocuments()
    }
    
    // MARK: - テーブルビューのリロード
    private func tableInitialize() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "PoemListTableViewCell", bundle: nil), forCellReuseIdentifier: "ListCell")
        tableView.register(UINib(nibName: "PoemListAdTableViewCell", bundle: nil), forCellReuseIdentifier: "AdCell")
    }
    
    // MARK: - 広告
    private func addBannerView() -> GADBannerView {
        let bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = fetchAdBannerID()
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        return bannerView
    }
    
    private func fetchAdBannerID() -> String {
        if let dict = Bundle.main.infoDictionary {
            let adUnitDic = dict["AdUnitIdDictionary"] as? [String:String]
            return adUnitDic?["AdBannerId"] ?? ""
        }
        return ""
    }
    
    // 五回以上リロードボタンを押したら発火
    public func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
    }

    private func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: fetchAdInterstitialID())
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    private func fetchAdInterstitialID() -> String {
        if let dict = Bundle.main.infoDictionary {
            let adUnitDic = dict["AdUnitIdDictionary"] as? [String:String]
            return adUnitDic?["AdInterstitialId"] ?? ""
        }
        return ""
    }
    
    // MARK: - ListTableViewCellDelegate
    /// ブックマーク×一覧画面でその店舗のセルを消去
    /// - Parameter shopId: セルの店舗id
    func removeBookmark(poemId: Int) {
        // 一覧画面ではブックマークが解除されても何もしないので空
    }
    
    /// 10件を超えてブックマークしようとするとアラートを出す。
    func exceedMaxBM() {
        let ExceedMaxBookmark = UIViewController.ErrorMassage.ExceedMaxBookmark
        takeError(message: ExceedMaxBookmark)
    }
}


extension PoemListViewController: UITableViewDataSource {
    // セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pluralPoems.count + 1
    }
    
    // セルの生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 最後のセルは広告セル
        if indexPath.row == pluralPoems.count {
            if let adCell = tableView.dequeueReusableCell(withIdentifier: "AdCell", for: indexPath) as? PoemListAdTableViewCell {
                adCell.selectionStyle = .none
                let bannerView = addBannerView()
                adCell.adView.addSubview(bannerView)
                return adCell
            }
        } else {
            if let listCell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as? PoemListTableViewCell {
                listCell.delegate = self
                if let eachPoem = pluralPoems[indexPath.row]  {
                    listCell.prepareListPoemCell(poem: eachPoem)
                }
                return listCell
            }
        }
         return UITableViewCell()
    }
    
    // セルがタップされたら
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard: UIStoryboard = self.storyboard!
        // 最後のセルは広告セル
        if indexPath.row == pluralPoems.count {
            return
        } else {
            if let detailView = storyboard.instantiateViewController(withIdentifier: "detailView") as? PoemDetailViewController {
                // 選んだセルのindexPath番号の店舗情報を詳細画面に渡す。
                if let eachPoem = pluralPoems[indexPath.row] {
                    detailView.poem = eachPoem
                    if let poemId = eachPoem["id"] as? Int {
                        detailView.poemId = poemId
                        detailView.title = poemId.description
                    }
                }
                // 一覧画面に戻ってきたときセルのハイライトが残る状態を防ぐ
                tableView.deselectRow(at: indexPath, animated: true)
                navigationController?.pushViewController(detailView, animated: true)
            }
        }
    }
}

