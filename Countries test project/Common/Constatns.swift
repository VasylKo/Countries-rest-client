//
//  Constatns.swift
//  Countries test project
//
//  Created by Vasiliy Kotsiuba on 09.06.2021.
//

import Foundation

enum Constatns {
    static let baseUrlString: String = "https://restcountries.eu/rest/v2"
    static let loadingDataDelaySeconds: Int = 0 // set for visible loading animation
    static let maxRequestRetryCount: Int = 3
    static let retryErrorAfterSeconds: Int = 20

    var baseUrl: URL {
        URL(string: Constatns.baseUrlString)!
    }
}
