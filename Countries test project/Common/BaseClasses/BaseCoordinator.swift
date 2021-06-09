//
//  BaseFlow.swift
//  Countries test project
//
//  Created by Vasiliy Kotsiuba on 10.06.2021.
//

import UIKit
import RxSwift

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    func startFlow()
    func finishFlow(_ result: Result<FlowSuccess, FlowError>)
}

enum FlowSuccess: Error {
    case completed
    case cancelled
}

enum FlowError: Error {
    case unexpectedDeinit
}

class BaseCoordinator: Coordinator {
    let logger: LoggerService = ServiceLayer.shared.loggerService
    let disposeBag: DisposeBag = .init()
    var navigationController: UINavigationController

    private var completion: (Result<FlowSuccess, FlowError>) -> Void
    private var finished = false
    
    init(navigationController: UINavigationController, completion: @escaping (Result<FlowSuccess, FlowError>) -> Void) {
        self.completion = completion
        self.navigationController = navigationController
    }

    func startFlow() {
        logger.debug(from: self)
    }

    func finishFlow(_ result: Result<FlowSuccess, FlowError>) {
        logger.debug(from: self)
        finished = true
        completion(result)
    }

    deinit {
        logger.debug(from: self)
        if !finished {
            finishFlow(.failure(.unexpectedDeinit))
        }
    }
}
