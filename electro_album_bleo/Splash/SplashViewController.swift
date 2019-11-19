//
//  SplashViewController.swift
//  electro_album_bleo
//
//  Created by bleo on 13/11/2019.
//  Copyright © 2019 bleo. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import RxViewController
import SnapKit
// RxViewController 를 importing 하지 않았음에도 호출할 수 있는 이유!?

final class SplashViewController: UIViewController, View {

    typealias Reactor = SplashReactor
    var disposeBag: DisposeBag = DisposeBag()
    
    private let launchLabel = UILabel().then {
        $0.text = "Flickr Albums"
        $0.textColor = .black
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        $0.adjustsFontSizeToFitWidth = true
    }
    
    func bind(reactor: SplashReactor) {
        self.rx
            .viewDidAppear
            .asObservable()
            .take(1)
            .do(onNext: { _ in
                print("SplashViewController :: viewDidAppear")
            })
            .observeOn(MainScheduler.asyncInstance)
            .map { _ in return Reactor.Action.didViewAppearCompleted }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(reactor: Reactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("SplashViewController :: viewDidLoad")
        view.backgroundColor = .white
        view.addSubview(launchLabel)
        launchLabel.snp.remakeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
    }
    
}
