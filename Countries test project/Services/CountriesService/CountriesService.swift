//
//  CountriesService.swift
//  Countries test project
//
//  Created by Vasiliy Kotsiuba on 10.06.2021.
//

import RxSwift


protocol CountriesService {
    func allContries() -> Observable<[Country]>
    func country(name: String) -> Observable<[CountryInfo]>
}
