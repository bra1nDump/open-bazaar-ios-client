//
//  CreateListingController.swift
//  openBazaarIOS
//
//  Created by KirillDubovitskiy on 4/14/19.
//  Copyright © 2019 Kirill Dubovitskiy. All rights reserved.
//

import UIKit
import Eureka
import ImageRow
import Moya
import RxSwift

class CreateListingController: FormViewController {
    let bag = DisposeBag()
    
    let imageProvider = MoyaProvider<Image>()
    let provider = MoyaProvider<Listing>()

    override func viewDidLoad() {
        super.viewDidLoad()

        form
            +++ Section("Item")
            <<< TextRow("title") {
                $0.placeholder = "title"
            }
            <<< IntRow("price") {
                $0.title = "price"
            }
            <<< ImageRow("image") {
                $0.title = "Product image"
                $0.sourceTypes = [.PhotoLibrary, .SavedPhotosAlbum, .Camera]
                $0.clearAction = .yes(style: .default)
            }
            <<< ButtonRow() {
                $0.title = "Publish"
            }
            .onCellSelection({ (_, _) in
                guard let price = self.form.rowBy(tag: "price")?.baseValue as? Int
                    , let title = self.form.rowBy(tag: "title")?.baseValue as? String
                    , let imageRow = self.form.rowBy(tag: "image") as? ImageRow
                    , let image = imageRow.value
                    else { return }
                
                self.imageProvider.rx.request(.upload(image: image))
                    .asObservable()
                    .mapJSON()
                    .flatMap({ (res) -> PrimitiveSequence<SingleTrait, Response> in
                        print(res)
                        let json = (res as! [[String:Any]]).first!
                        let filename = json["filename"] as! String
                        let hashes = json["hashes"] as! [String:String]
                        let imageHashes = [
                            "tiny",
                            "small",
                            "medium",
                            "large",
                            "original"
                            ].map { hashes[$0]! }
                        return self.provider.rx.request(.create(data: createListing(price: price, title: title, filename: filename, imageHashes: imageHashes)))
                    })
                    .bind(onNext: { (response) in
                        let alert = UIAlertController(title: "Success", message: "\(title) has being created!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Kek", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    })
                    .disposed(by: self.bag)
            })
    }
}
