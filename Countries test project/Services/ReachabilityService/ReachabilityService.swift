//
//  ReachabilityService.swift
//  RxExample
//
//  Created by Vodovozov Gleb on 10/22/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift

protocol ReachabilityService {
    var reachability: Observable<ReachabilityStatus> { get }
}
