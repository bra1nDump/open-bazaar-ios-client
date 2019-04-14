//
//  MainController.swift
//  openBazaarIOS
//
//  Created by KirillDubovitskiy on 4/13/19.
//  Copyright © 2019 Kirill Dubovitskiy. All rights reserved.
//

import UIKit

class MainController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewControllers = [
            ListingListController(peer: "QmPFvqyMp13EQHP94AZhFWQWQtmUQteeCoS75wEfyKu2Wb")
            , CreateListingController()
            , ProfileController()
            ].map {
                return UINavigationController(rootViewController: $0)
            }
    }
}
