//
//  WalletController.swift
//  openBazaarIOS
//
//  Created by KirillDubovitskiy on 4/13/19.
//  Copyright © 2019 Kirill Dubovitskiy. All rights reserved.
//

import UIKit
import Eureka

class ProfileController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        form
            +++ Section() { section in
                var header = HeaderFooterView<UIImageView>(.class)
                header.onSetupView =
                    { (view, section) in
                        header.onSetupView = { (view, _) in
                            view.image = UIImage(named: "fsharp")!
                        }
                }
                header.height = {400}
                section.header = header
            }
            <<< ButtonRow() { button in
                button.title = "Wallet"
                }
            <<< ButtonRow() { button in
                button.title = "My store"
                button.value = "Void functions"
            }.onCellSelection({ (_, _) in
                self.navigationController!.pushViewController(ListingListController(), animated: false)
            })
    }
}
