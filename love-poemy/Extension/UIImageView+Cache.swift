//
//  UIImageView+Cache.swift
//  love-poemy
//
//  Created by 野中志保 on 2020/05/24.
//  Copyright © 2020 野中志保. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage

extension UIImageView {
    static let imageCache = NSCache<AnyObject, AnyObject>()
    
    /// キャッシュ確認後、fireStorageから画像をダウンロードしてセット
    func preparePhotoImage(poemId: Int) {
        self.image = UIImage(named: "noImage")
        
        // キャッシュの確認
        if let cachedImage = UIImageView.imageCache.object(forKey: poemId as AnyObject) as? UIImage {
            // キャッシュの画像を設定
            self.image = cachedImage
            return
        }
        // キャッシュがなければfireStorageからダウンロード
        let storage = Storage.storage()
        // poemIdを渡し、imageを返す
        let pathReference = storage.reference(withPath: "photoImage/\(poemId).jpg")
        pathReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
          if let error = error {
            self.image = UIImage(named: "noImage")
            print(error)
          } else {
            if let downloadImage = UIImage(data: data!) {
                UIImageView.imageCache.setObject(downloadImage, forKey: poemId as AnyObject)
                self.image = downloadImage
            }
          }
        }
    }
}
