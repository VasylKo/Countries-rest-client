//
//  CountriesTarget.swift
//  Countries test project
//
//  Created by Vasiliy Kotsiuba on 09.06.2021.
//

import Foundation
import Moya

enum CountriesTarget {
    case all
    case country(String)
}

extension CountriesTarget: TargetType, CachePolicyGettableType {
    var baseURL: URL {
        guard let url = URL(string: Constatns.baseUrlString) else {
            fatalError("Bad base url")
        }

        return url
    }

    var path: String {
        switch self {
            case .all:
                return "/all"
            case .country(let name):
                return "/name/\(name)"
        }
    }

    var method: Moya.Method  {
        return .get
    }

    var sampleData: Data {
        return Data()
    }

    var task: Task {
        switch self {
            case .all:
                return .requestParameters(parameters: ["fields" : ["name", "population"]], encoding: URLEncoding.default)
            case .country:
                return .requestParameters(parameters: ["fields" : ["name", "capital", "currencies", "population"]], encoding: URLEncoding.default)
        }
    }

    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }

    var cachePolicy: URLRequest.CachePolicy? {
            .reloadIgnoringLocalCacheData
        }
}

