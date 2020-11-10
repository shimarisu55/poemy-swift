//
//  BookmarkManageModel.swift
//  love-poemy
//
//  Created by 野中志保 on 2020/04/29.
//  Copyright © 2020 野中志保. All rights reserved.
//

import Foundation
import UIKit

// お気に入りのロードや保存を管理する
protocol HeartProtocol {
    func loadHeartPoemIds() -> [Int]?
    func saveHeartPoemIds(heartPoemId: [Int])
}

class BookmarkManageModel: HeartProtocol {
    
    // お気に入りのロードや保存を司る。
    private let userDefaults = UserDefaults.standard
    private static let BOOKMARK_KEY: String = "heartPoemId"
    func loadHeartPoemIds() -> [Int]? {
        return userDefaults.array(forKey: BookmarkManageModel.BOOKMARK_KEY) as? [Int]
    }
    func saveHeartPoemIds(heartPoemId: [Int]) {
        return userDefaults.set(heartPoemId, forKey: BookmarkManageModel.BOOKMARK_KEY)
    }
    
    // お気に入りボタンの初期画像
    enum FirstheartButton {
        case savedBookmark
        case noSavedBookmark
    }
    
    func decideheartImage(poemId: Int) -> FirstheartButton {
        if let heartPoemId = loadHeartPoemIds() {
            // もしuserDefaultに店舗が登録されていたら
            if heartPoemId.firstIndex(of: poemId) != nil {
                // ハートをfillに
                return FirstheartButton.savedBookmark
            } else {
                return FirstheartButton.noSavedBookmark
            }
        } else {
            // userDefaultになにもなかった場合、初期画像セット
            return FirstheartButton.noSavedBookmark
        }
    }
    
    // お気に入りボタンを押した時の結果
    enum heartButtonResult {
        case removeBookmark
        case exceedMaxBookmark
        case saveBookmark
    }
    
    func changeBookmark(poemId: Int) -> heartButtonResult {
        if var heartPoemId = loadHeartPoemIds() {
            // もしuserDefaultに店舗が登録されていたら
            if let poemDetailId = heartPoemId.firstIndex(of: poemId) {
                // ハートが白になり、ブックマーク解除される。店舗idの配列を保存
                heartPoemId.remove(at: poemDetailId)
                saveHeartPoemIds(heartPoemId: heartPoemId)
                return heartButtonResult.removeBookmark
            } else if heartPoemId.count >= 10 {
                // もし通常×一覧画面で100件以上ブックマークしようとしたらアラートが出る
                return heartButtonResult.exceedMaxBookmark
            } else {
                // ハートがfillになり、ブックマーク追加される。店舗idの配列を保存
                heartPoemId.append(poemId)
                saveHeartPoemIds(heartPoemId: heartPoemId)
                return heartButtonResult.saveBookmark
            }
        } else {
            // userDefaultになにもなかった場合
            var heartPoemId: [Int] = []
            heartPoemId.append(poemId)
            saveHeartPoemIds(heartPoemId: heartPoemId)
            return heartButtonResult.saveBookmark
        }
    }
}
