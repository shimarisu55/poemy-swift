//
//  TabbarViewController.swift
//  love-poemy
//
//  Created by 野中志保 on 2020/04/26.
//  Copyright © 2020 野中志保. All rights reserved.
//

import UIKit

class TabbarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().barTintColor = UIColor(named: "CustomBlack")
        UITabBar.appearance().tintColor = UIColor(named: "CustomYellow")
    }

}
