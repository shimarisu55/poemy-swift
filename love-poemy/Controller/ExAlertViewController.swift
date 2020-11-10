//
//  UIViewController+Alert.swift
//  love-poemy
//
//  Created by 野中志保 on 2020/04/29.
//  Copyright © 2020 野中志保. All rights reserved.
//

import Foundation
import UIKit

// どのUIViewControllerでもアラートが出せるように拡張
extension UIViewController {

    enum ErrorMassage: String {
        case ExceedMaxBookmark = "保存できる件数は最大10件です"
        case MaxPoemCount = "配信している歌はこれが最後です"
        case NoPoem = "まだ用意していません。配信を待ってください"
        case NetworkError = "通信エラーです"
    }

    /// エラーパターンを受け取り、エラーメッセージつきのアラートを返す。
    /// - Parameter message: 上のenumで設定したエラーパターン
    func takeError(message: ErrorMassage) {
        let alert = UIAlertController(title: nil, message: message.rawValue, preferredStyle: .actionSheet)
        let dissolveAlert = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(dissolveAlert)
        present(alert, animated: true)
    }
}
