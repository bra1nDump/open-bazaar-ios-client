//
//  ListingController.swift
//  openBazaarIOS
//
//  Created by KirillDubovitskiy on 4/13/19.
//  Copyright © 2019 Kirill Dubovitskiy. All rights reserved.
//

import UIKit
import Moya
import Eureka
import RichTextRow
import RxSwift

class ListingController: FormViewController {
    
    let listingHash: String
    let listingProvider = MoyaProvider<Listing>()
    
    let bag = DisposeBag()
    
    init(hash: String) {
        self.listingHash = hash
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listingProvider.rx.request(Listing.hash(hash: listingHash))
            .mapJSON()
            .observeOn(MainScheduler.instance)
            .asObservable()
            .bind { (json) in
                self.show(listingJson: json)
            }
            .disposed(by: bag)
    }
    
    func show(listingJson: Any) {
        guard let dict = listingJson as? [String:Any]
            , let listing = dict["listing"] as? [String:Any]
            , let metadata = listing["metadata"] as? [String:Any]
            , let item = listing["item"] as? [String:Any]
            , let title = item["title"] as? String
            , let description = item["description"] as? String
            , let price = item["price"] as? Int
            , let currency = metadata["pricingCurrency"] as? String
            , let images = item["images"] as? [[String:String]]
            , let image = images.first
            , let large = image["large"] else { return }
        
        form
            +++ Section()
                { section in
                var header = HeaderFooterView<UIImageView>(.class)
                header.onSetupView =
                    { (view, section) in
                        let urlString = "http://\(host):4002/ob/images/\(large)"
                        let url = URL(string: urlString)!
                        view.load(url: url
                            , callback: { (image) in
                            view.image = image
                        })
                    }
                header.height = {500}
                section.header = header
            }
            +++ Section("General")
            <<< LabelRow() {
                $0.title = "Title"
                $0.value = title
            }
            <<< LabelRow() {
                $0.title = "IPFS hash:\n \(listingHash)"
                $0.cell.textLabel?.numberOfLines = 0
            }
            +++ Section("Price")
            <<< LabelRow(){
                $0.title = currency
                $0.value = "\(price / 100)"
            }
            +++ Section("Details")
            <<< RichTextRow() {
                $0.value = description
                $0.baseCell.height = { 200 }
                //$0.cell.textLabel?.numberOfLines = 0
            }
    }
}
