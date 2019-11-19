//
//  AppDelegate.swift
//  electro_album_bleo
//
//  Created by bleo on 13/11/2019.
//  Copyright © 2019 bleo. All rights reserved.
//

import UIKit
import RxFlow
import RxSwift
import Moya
import Then
import Reachability

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private let coordinator = FlowCoordinator()
    private let disposeBag = DisposeBag()
    
    private var bleoFlow: BleoFlow!
    private var bleoServices: BleoServices!
    
    var reachablity: Reachability?
    
    /** Moya Debug Mode
     
    private let apiService: BleoAPIServiceType = BleoAPIService(
        provider: MoyaProvider<BleoAPIEndPoint>(
            plugins: [NetworkLoggerPlugin(
                configuration: NetworkLoggerPlugin.Configuration(logOptions: .verbose))]))
    */
    
    private let apiService: BleoAPIServiceType = BleoAPIService(provider: MoyaProvider<BleoAPIEndPoint>())
    
    private let temp = UIButton().then {
        $0.setTitle("temp", for: .normal)
        $0.setTitleColor(.blue, for: .normal)
        $0.titleLabel?.textAlignment = .center
        $0.layer.cornerRadius = 4
        $0.frame = CGRect(x: 100, y: 100, width: 100, height: 80)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.addSubview(temp)
        
        reachablity = Reachability()
        try? reachablity?.startNotifier()
        
        self.bleoServices = BleoServices(apiService: apiService)
        self.bleoFlow = BleoFlow(initWindow: window!, andServices: self.bleoServices)
        
        coordinator.rx.didNavigate.subscribe(onNext: { (flow, step) in
            print("did navigate to flow = \(flow), step = \(step)")
        }).disposed(by: disposeBag)
        
        coordinator.coordinate(flow: bleoFlow, with: OneStepper(withSingleStep: BleoNavigateStep.splash))
        
        return true
    }
    
    /*
// MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    */
}
