//
//  PoemDetailViewController.swift
//  love-poemy
//
//  Created by 野中志保 on 2020/04/25.
//  Copyright © 2020 野中志保. All rights reserved.
//

import UIKit
import GoogleMobileAds
import FirebaseDynamicLinks

class PoemDetailViewController: UIViewController, UITableViewDelegate, GADInterstitialDelegate {
    
    private enum CellType:Int {
        case HeaderView = 0
        case OriginalText
        case Translation
        case Remark
        case Grammar
        case Word
        case DetailCellCount
    }
    
    var poem: [String: Any]?
    var poemId: Int = 0
    private var heartImageString: String = ""
    // 広告出すタイミングの基準となるpoemId。これより5離れると広告表示
    private var basisPoemId: Int!
    private var interstitial: GADInterstitial!
    private let lastPoemNumber = Bundle.main.object(forInfoDictionaryKey: "Last Poem Number") as! Int
    
    // 使用モデル一覧
    private let bookmarkManageModel = BookmarkManageModel()
    private let fetchFirestoreModel = FetchFirestoreModel()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var shareSNSButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareEachCell()
        setupButtonUI()
        decideFirstheartImage()
        // 広告関係
        basisPoemId = poemId
        interstitial = createAndLoadInterstitial()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    
    // MARK: - テーブルセルセットアップ
    private func prepareEachCell() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "DetailImageHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "HeaderViewCell")
        tableView.register(UINib(nibName: "DetailOriginalTextTableViewCell", bundle: nil), forCellReuseIdentifier: "originalTextCell")
        tableView.register(UINib(nibName: "DetailTranslationTableViewCell", bundle: nil), forCellReuseIdentifier: "translationCell")
        tableView.register(UINib(nibName: "DetailRemarkTableViewCell", bundle: nil), forCellReuseIdentifier: "remarkCell")
        tableView.register(UINib(nibName: "DetailGrammarTableViewCell", bundle: nil), forCellReuseIdentifier: "grammarCell")
        tableView.register(UINib(nibName: "DetailWordTableViewCell", bundle: nil), forCellReuseIdentifier: "wordCell")
        
        tableView.reloadData()
    }
    
    // MARK: - ボタン群
    private func setupButtonUI() {
        // お気に入りボタン
        heartButton.layer.borderColor = UIColor(named: "CustomBlack")?.cgColor
        // 前に戻るボタン
        prevButton.layer.borderColor = UIColor(named: "CustomBlack")?.cgColor
        // 次へ進むボタン
        nextButton.layer.borderColor = UIColor(named: "CustomBlack")?.cgColor
    }
    
    // userDefaultを調べてお気に入りボタンの初期画像をセット
    private func decideFirstheartImage() {
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
        let result = bookmarkManageModel.changeBookmark(poemId: poemId)
        switch result {
        case .removeBookmark:
            heartImageString = "heart_out"
        case .exceedMaxBookmark:
            let ExceedMaxBookmark = UIViewController.ErrorMassage.ExceedMaxBookmark
            takeError(message: ExceedMaxBookmark)
            heartImageString = "heart_out"
        case .saveBookmark:
            heartImageString = "heart_add"
        }
        let heartImage = UIImage(named: heartImageString)
        heartButton.setImage(heartImage, for: .normal)
    }
    
    // SNSシェアボタン
    @IBAction func tapShareSNSButton(_ sender: Any) {
        if poem != nil {
            // SNSシェア用の画像を変数に入れる
            let snsImageView = UIImageView()
            snsImageView.preparePhotoImage(poemId: poemId)
            let snsImage = snsImageView.image
            // SNSシェア用のテキストを変数に入れる
            let snsOriginalText = poem?["poem"] as! String
            let snsTranslationText = poem?["meaning"] as! String
            
            // ダイナミックリンクの生成
            guard let detail_url = NSURL(string: "https://lovepoemy.page.link/detail_view?\(poemId)") else {return}
            let dynamicLinksDomainURIPrefix = "https://lovepoemy.page.link/home"
            let linkBuilder = DynamicLinkComponents(link: detail_url as URL, domainURIPrefix: dynamicLinksDomainURIPrefix)
            linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.education.love-poemy")
            linkBuilder?.iOSParameters?.appStoreID = "151844667"
            guard let longDynamicLink = linkBuilder?.url else { return }
            
            let activityItems: [Any] = [snsImage!,
                                        snsOriginalText,
                                        "\n意味:",
                                        snsTranslationText,
                                        "#古今和歌集",
                                        "\(longDynamicLink)"]
            let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            // 余計な選択肢を削る
            activityVC.excludedActivityTypes = [
                UIActivity.ActivityType.print,
                UIActivity.ActivityType.saveToCameraRoll,
                UIActivity.ActivityType.assignToContact,
                UIActivity.ActivityType.addToReadingList,
            ]
            present(activityVC, animated: true, completion: nil)
        }
    }

    // 前に戻るボタン
    @IBAction func tapPrevButton(_ sender: Any) {
        poemId -= 1
        // poemIdが1の時押されたらreturn
        if poemId <= 0 {
            poemId += 1
            return
        }
        // ５首以上前に戻ったら広告表示
        presentInterstitial()
        callNeighborPoem(poemId: poemId)
    }
    
    // 次に進むボタン
    @IBAction func tapNextButton(_ sender: Any) {
        poemId += 1
        // poemIdが最大の時押されたらエラーメッセージ
        if poemId > lastPoemNumber {
            let MaxPoemCount = UIViewController.ErrorMassage.MaxPoemCount
            takeError(message: MaxPoemCount)
            poemId -= 1
            return
        }
        // ５首以上次に進んだら広告表示
        presentInterstitial()
        callNeighborPoem(poemId: poemId)
    }
    
    
    // MARK: -fetchDocuments
    // 前/次へ進むボタンのほか、ディープリンクを踏んだ時にも発火
    private func callNeighborPoem(poemId: Int) {
        self.title = poemId.description
        // 該当poemを一つ選びfetch。arrayとあるが一つのみ
        fetchFirestoreModel.fetchDocuments(numberArray: [poemId],
                                           completion: { (neighborPoem) in
            if let poem = neighborPoem {
                self.poem = poem[0]
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                    self.decideFirstheartImage()
                }
            } else {
                self.errorCallDocument()
            }
        })
    }
    
    // ディープリンク踏んだあと「戻る」を押すとホームに戻る
    @objc func backHome(sender: UIBarButtonItem) {
        if let tabbar = storyboard?.instantiateViewController(withIdentifier: "tabbar") as? TabbarViewController {
            tabbar.selectedIndex = 0
            dismiss(animated: true, completion: nil)
            navigationController?.setNavigationBarHidden(true, animated: false)
            show(tabbar, sender: nil)
        }
    }

    
    private func errorCallDocument() {
        // 通信エラー
        DispatchQueue.main.async {
            self.tableView.reloadData()
            let NetworkError = UIViewController.ErrorMassage.NetworkError
            self.takeError(message: NetworkError)
        }
    }
    
    // MARK: - 広告
    private func presentInterstitial() {
        if abs(basisPoemId - poemId) >= 5 && interstitial.isReady {
            interstitial.present(fromRootViewController: self)
            basisPoemId = poemId
        }
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

    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
    }
}

// MARK: -tableView
extension PoemDetailViewController: UITableViewDataSource {
    // セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CellType.DetailCellCount.rawValue
    }

    // セルの生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.row) {
        case CellType.HeaderView.rawValue:
            if let headerViewCell = tableView.dequeueReusableCell(withIdentifier: "HeaderViewCell", for: indexPath) as? DetailImageHeaderTableViewCell {
                headerViewCell.headerImage.preparePhotoImage(poemId: poemId)
                return headerViewCell
            }
        case CellType.OriginalText.rawValue:
            if let originalTextCell = tableView.dequeueReusableCell(withIdentifier: "originalTextCell", for: indexPath) as? DetailOriginalTextTableViewCell {
                if poem != nil {
                    originalTextCell.prepareOriginalText(poem:poem!)
                }
                return originalTextCell
            }
        case CellType.Translation.rawValue:
            if let translationCell = tableView.dequeueReusableCell(withIdentifier: "translationCell", for: indexPath) as? DetailTranslationTableViewCell {
                if poem != nil {
                    translationCell.prepareTranslation(poem:poem!)
                }
                return translationCell
            }
        case CellType.Remark.rawValue:
            if let remarkCell = tableView.dequeueReusableCell(withIdentifier: "remarkCell", for: indexPath) as? DetailRemarkTableViewCell {
                if poem != nil {
                    remarkCell.prepareRemark(poem:poem!)
                }
                return remarkCell
            }
        case CellType.Grammar.rawValue:
        if let grammarCell = tableView.dequeueReusableCell(withIdentifier: "grammarCell", for: indexPath) as? DetailGrammarTableViewCell {
            grammarCell.sectionTitle.text = "覚えよう！　文法"
            if let grammar = poem?["grammar"] as? String {
                grammarCell.grammarText.text = grammar
            }
            return grammarCell
        }
        case CellType.Word.rawValue:
        if let wordCell = tableView.dequeueReusableCell(withIdentifier: "wordCell", for: indexPath) as? DetailWordTableViewCell {
            wordCell.sectionTitle.text = "覚えよう！　単語"
            if let word = poem?["word"] as? String {
                wordCell.wordText.text = word
            }
            return wordCell
        }
        default:
            return UITableViewCell()
        }
        return UITableViewCell()
    }

    // フッター
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
}

