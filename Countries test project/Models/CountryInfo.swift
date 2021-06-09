//
//  CountryInfo.swift
//  Countries test project
//
//  Created by Vasiliy Kotsiuba on 11.06.2021.
//

struct CountryInfo: Decodable {
    var name: String
    var capital: String
    var population: Int
    var currencies: [Currency]
    var borders: [String]
}
