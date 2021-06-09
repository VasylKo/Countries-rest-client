//
//  AppDelegate.swift
//  Countries test project
//
//  Created by Vasiliy Kotsiuba on 09.06.2021.
//

import UIKit
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var applicationCoordinator: ApplicationCoordinator!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        applicationCoordinator = ApplicationCoordinator()
        window = applicationCoordinator.window
        applicationCoordinator.start()

        return true
    }
}

