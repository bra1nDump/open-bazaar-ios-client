//
//  Image.swift
//  openBazaarIOS
//
//  Created by KirillDubovitskiy on 4/12/19.
//  Copyright © 2019 Kirill Dubovitskiy. All rights reserved.
//

import Moya

let local = true
let host = local ? "localhost" : "192.168.99.100"

enum ListingList {
    case peer(id: String)
}

enum Listing {
    case hash(hash: String)
    case create(data: String)
}

enum Image {
    case upload(image: UIImage)
}

extension ListingList: TargetType {
    var path: String {
        switch self {
        case .peer(let id):
            return "/\(id)"
        }
    }
    
    var method: Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String : String]? {
        return [:]
    }
    
    var baseURL: URL { return URL(string: "http://\(host):4002/ob/listings")! }
}


extension Listing: TargetType {
    var baseURL: URL {
        return URL(string: "http://\(host):4002/ob/listing")!
    }
    
    var path: String {
        switch self {
        case .hash(let hash):
            return "/ipfs/\(hash)"
        case .create(_):
            return ""
        }
    }
    
    var method: Method {
        switch self {
        case .hash(_):
            return .get
        case .create(_):
            return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .hash(_):
            return .requestPlain
        case .create(let str):
            return Task.requestData(str.data(using: String.Encoding.utf8)!)
        }
    }

    var headers: [String : String]? {
        return [:]
    }
}

extension Image: TargetType {
    var baseURL: URL {
        return URL(string: "http://\(host):4002/ob/images")!
    }
    
    var path: String {
        return ""
    }
    
    var method: Method { return .post }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .upload(let image):
            let data = image.pngData()!.base64EncodedString()
            return Task.requestData(createImage(imageString: data).data(using: String.Encoding.utf8)!)
        }
    }
    
    var headers: [String : String]? {
        return [:]
    }
    
}

func createImage(imageString: String) -> String {
return """
[{
\"filename\": \"image.png\",
\"image\": \"\(imageString)\"
}]
"""
}

func createListing(price: Int, title: String, filename: String, imageHashes: [String]) -> String {
    return """
{
    \"slug\": \"vintage-dress-service-no-options\",
    \"metadata\": {
    \"contractType\": \"SERVICE\",
    \"format\": \"FIXED_PRICE\",
    \"expiry\": \"2037-12-31T05:00:00.000Z\",
    \"pricingCurrency\": \"USD\",
    \"acceptedCurrencies\": [
    \"BTC\",
    \"BCH\",
    \"ZEC\",
    \"LTC\"
    ]
},
\"item\": {
\"title\": \"\(title)\",
\"description\": \"This is a listing example.\",
\"processingTime\": \"3 days\",
\"price\": \(price * 100),
\"tags\": [
\"vintage dress\"
],
    \"images\": [{
    \"filename\": \"\(filename)\",
    \"tiny\": \"\(imageHashes[0])\",
    \"small\": \"\(imageHashes[1])\",
    \"medium\": \"\(imageHashes[2])\",
    \"large\": \"\(imageHashes[3])\",
    \"original\": \"\(imageHashes[4])\"
    }],
\"categories\": [
\"👚 Apparel & Accessories\"
],
\"condition\": \"New\",
\"options\": [],
\"skus\": [],
\"nsfw\": false
},
\"shippingOptions\": [],
\"taxes\": [],
\"coupons\": [],
\"moderators\": [],
\"termsAndConditions\": \"Terms and conditions.\",
\"refundPolicy\": \"Refund policy.\"
}
"""
}
