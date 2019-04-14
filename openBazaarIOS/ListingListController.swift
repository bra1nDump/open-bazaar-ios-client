//
//  ViewController.swift
//  openBazaarIOS
//
//  Created by KirillDubovitskiy on 4/12/19.
//  Copyright © 2019 Kirill Dubovitskiy. All rights reserved.
//

import UIKit

import Moya
import RxSwift
import RxDataSources
import SnapKit

struct ListingModel {
    let title: String
    let smallThumbnail: String
    let hash: String
    let price: Int
}

let delta = 15

class ListingCell: UITableViewCell {
    
    let listingImage = UIImageView()
    let title = UILabel()
    let price = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(listingImage)
        self.contentView.addSubview(title)
        self.contentView.addSubview(price)
        
        //price.font = price.font.withSize(16)
        price.layer.cornerRadius = 1
        price.clipsToBounds = true
        //price.backgroundColor = UIColor(red: 53/250, green: 183/240, blue: 57/250, alpha: 1.0)
        
        listingImage.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(delta)
            maker.top.equalToSuperview().offset(delta)
            maker.bottom.equalToSuperview().offset(-delta)
            maker.height.equalTo(150)
            maker.width.equalTo(150)
        }
        
        title.font = UIFont.boldSystemFont(ofSize: 16.0)
        title.snp.makeConstraints { (maker) in
            maker.right.equalToSuperview().offset(-delta)
            maker.top.equalToSuperview().offset(delta)
            //maker.left.equalTo(listingImage.snp.right).offset(20)
        }
        
        price.snp.makeConstraints { (maker) in
            maker.right.equalToSuperview().offset(-delta)
            maker.top.equalTo(title.snp.bottom).offset(delta)
            //maker.left.equalTo(listingImage.snp.right).offset(20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }
}

class ListingListController: UITableViewController {
    
    let bag = DisposeBag()
    let listingListProvider = MoyaProvider<ListingList>()
    
    let peer: String
    
    var listings = Variable<[ListingModel]>([])
    
    var cache: [URL: UIImage] = [:]
    
    init(peer: String? = nil) {
        self.peer = peer ?? ""
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = .none
        self.view.backgroundColor = background
        
        self.tableView.register(ListingCell.self, forCellReuseIdentifier: "Cell")
        
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        
        listingListProvider.rx
            .request(.peer(id: peer))
            .mapJSON()
            .map({ (json) in
                let models = json as! [[String: Any]]
                return models.map({ (model) -> ListingModel in
                    let title = model["title"] as! String
                    let thumbnail = model["thumbnail"] as! [String: String]
                    let small = thumbnail["small"]!
                    let hash = model["hash"] as! String
                    let price = (model["price"] as! [String:Any])["amount"] as! Int
                    return ListingModel(title: title, smallThumbnail: small, hash: hash, price: price)
                })
            })
            .observeOn(MainScheduler.instance)
            .asObservable()
            .bind(to: listings)
            .disposed(by: bag)
            
        listings.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: "Cell")) {
                (index, model, cell) in
                let cell = cell as! ListingCell
                cell.title.text = model.title.lowercased()
                cell.price.text = "$ \(model.price / 100)"
                cell.backgroundColor = background
                let url = URL(string: "http://\(host):4002/ob/images/\(model.smallThumbnail)")!
                guard let image = self.cache[url] else {
                    cell.listingImage.layer.cornerRadius = 1
                    cell.listingImage.clipsToBounds = true
                    cell.listingImage.load(url: url
                        , callback: { (image) in
                            self.cache[url] = image
                            self.tableView.reloadData()
                    })
                    return
                }
                cell.listingImage.image = image
            }
            .disposed(by: bag)

        tableView.rx.itemSelected
            .bind { (indexPath) in
                let hash = self.listings.value[indexPath.row].hash
                self.navigationController!.pushViewController(ListingController(hash: hash), animated: true)
            }
            .disposed(by: bag)
    }
}

extension UIImageView {
    func load(url: URL, callback: @escaping (UIImage) -> Void ) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        callback(image)
                    }
                }
            }
        }
    }
}
