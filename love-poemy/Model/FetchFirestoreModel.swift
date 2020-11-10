//
//  FetchFirestoreModel.swift
//  love-poemy
//
//  Created by 野中志保 on 2020/04/25.
//  Copyright © 2020 野中志保. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class FetchFirestoreModel {
    
    private let db = Firestore.firestore()
    private var numberArray: [Int] = []
    
    // 使用モデル
    private let bookmarkManageModel = BookmarkManageModel()
    
    /// 初期値のランダム10首を呼ぶ
    func fetchDocuments(numberArray: [Int], completion: @escaping ([[String: Any]?]?) -> Swift.Void) {
        db.collection("poems")
            .whereField("id", in: numberArray)
            .getDocuments() { (querySnapshot, err) in
            if err != nil {
                completion(nil)
            } else {
                guard let documents = querySnapshot?.documents else {
                    return }
               
                let pluralPoems = documents.map({ (querySnapshot) -> [String: Any] in
                    querySnapshot.data()
                })
                completion(pluralPoems)
            }
        }
    }
    
    /// ランダムで10首選んで返す
    func callRandomNumber(first:Int = 1, last:Int) -> [Int] {
        var numArray: [Int] = []
        var total: Int = 0
        while total < 10 {
            let number = Int.random(in: first...last)
            if (numArray.contains(number) == false) {
                if (number <= 168 || 343 <= number) {
                    numArray.append(number)
                    total += 1
                }
            }
        }
        return numArray
    }
    
    /// お気に入りを最大10首選んで返す
    func callFavNumber() -> [Int] {
        let numArray: [Int] = bookmarkManageModel.loadHeartPoemIds() ?? []
        return numArray
    }
    
}
