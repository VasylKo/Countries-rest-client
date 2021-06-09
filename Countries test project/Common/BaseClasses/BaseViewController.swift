//
//  BaseViewController.swift
//  Countries test project
//
//  Created by Vasiliy Kotsiuba on 10.06.2021.
//

import UIKit
import RxSwift

class BaseViewController: UIViewController {
    let logger: LoggerService = ServiceLayer.shared.loggerService
    let disposeBag: DisposeBag = .init()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        logger.debug(from: self)
    }

    deinit {
        logger.debug(from: self)
    }
}

