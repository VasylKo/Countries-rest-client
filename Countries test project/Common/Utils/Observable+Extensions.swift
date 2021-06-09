//
//  Observable+Extensions.swift
//  Countries test project
//
//  Created by Vasiliy Kotsiuba on 11.06.2021.
//

import RxSwift
import RxCocoa

extension ObservableType {
    func asDriverOnErrorJustComplete() -> Driver<Element> {
        return asDriver { error in
            return Driver.empty()
        }
    }
}
