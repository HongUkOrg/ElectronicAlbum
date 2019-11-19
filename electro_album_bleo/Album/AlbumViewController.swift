//
//  AlbumViewController.swift
//  electro_album_bleo
//
//  Created by bleo on 14/11/2019.
//  Copyright © 2019 bleo. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import RxViewController
import SnapKit
import Then
import Alamofire
import RxAnimated
import RxReachability
import Reachability

class AlbumViewController: UIViewController, View {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    private let startSlideShowBtn = UIButton().then {
        
        $0.setTitle("start", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        $0.backgroundColor = UIColor(red: 60/255, green: 159/255, blue: 226/255, alpha: 1)
        $0.titleLabel?.textAlignment = .center
        $0.layer.cornerRadius = 15
        $0.clipsToBounds = true
        $0.isUserInteractionEnabled = true
        $0.isEnabled = true
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        $0.layer.shadowRadius = 8
        $0.layer.shadowOpacity = 0.5
    }
    
    private let albumImage = UIImageView().then {
        
        $0.image = UIImage(named: "album_default")
        $0.contentMode = .scaleAspectFit
    }
    
    private let stepper = UIStepper().then {
        $0.minimumValue = 1
        $0.maximumValue = 10
    }
    
    private let stepperLabel = UILabel().then {
        $0.text = "1"
        $0.textColor = .black
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        $0.numberOfLines = 1
        $0.adjustsFontSizeToFitWidth = true
        $0.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        $0.layer.cornerRadius = 20
    }
    
    private let networkStateLabel = UILabel().then {
        $0.text = "Network : disabled"
        $0.textColor = .black
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        $0.adjustsFontSizeToFitWidth = true
    }
    
    typealias Reactor = AlbumReactor
    
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
    
    func bind(reactor: AlbumReactor) {
        
        startSlideShowBtn.rx
            .tap
            .map { Reactor.Action.slideBtnClicked }
            .do(onNext: { (_) in
                print("startSlidkeBtn clicked!!")
            })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.btnText }
            .bind(to: startSlideShowBtn.rx.title())
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.btnImageColor }
            .observeOn(MainScheduler.asyncInstance)
            .bind(to: startSlideShowBtn.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isShowing }
            .distinctUntilChanged()
            .map { value in
                return value ? Reactor.Action.showAlbum : Reactor.Action.stopShowAlbum
        }
        .observeOn(MainScheduler.asyncInstance)
        .bind(to: reactor.action)
        .disposed(by: disposeBag)
        
        /// Getting Image and binding
        
        /*
         reactor.state
         .filter { $0.isShowing && $0.currentAlbumIndex >= 0 }
         .map { $0.albums[$0.currentAlbumIndex] }
         .map { $0.media.m }
         .distinctUntilChanged()
         .filter { $0 != nil }
         .map { URL(string: $0!)}
         .filter { $0 != nil }
         .map { $0! }
         .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
         .map { try Data(contentsOf: $0)}
         .map { UIImage(data: $0)}
         .observeOn(MainScheduler.asyncInstance)
         .bind(animated: albumImage.rx.animated.fade(duration: 0.5).image)
         .disposed(by: disposeBag)
         */
        
        reactor.state
            .map { $0.albumIamgeUrl }
            .distinctUntilChanged()
            .filter { $0 != "" }
            .map { Reactor.Action.updateImage($0) }
            .observeOn(MainScheduler.asyncInstance)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.currentAlbumImage }
            .observeOn(MainScheduler.asyncInstance)
            .bind(to: albumImage.rx.image)
            .disposed(by: disposeBag)
        
        /// Binding Stepper, Interval
        
        stepper.rx
            .value
            .changed
            .map { Int($0) }
            .map { Reactor.Action.stepperChanged($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.interval }
            .map { String($0)}
            .bind(to: stepperLabel.rx.text)
            .disposed(by: disposeBag)
        
        /// Binding Reachability
        
        Reachability.rx.isReachable
            .do(onNext: { (v) in
                print("reachable!! \(v)") })
            .map { Reactor.Action.getNetworkState($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.reachablity }
            .map { (value) in
                return value ? "Network : enabled" : "Network : disabled" }
            .bind(to: networkStateLabel.rx.text)
            .disposed(by: disposeBag)
        
        self.rx
            .viewDidLoad
            .take(1)
            .map { Reactor.Action.updateInitalState }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        /// Oriendtation
        
        NotificationCenter.default.rx.notification(UIDevice.orientationDidChangeNotification)
            .observeOn(MainScheduler.instance)
            .map { (_) in Reactor.Action.orientationChanged }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.orientation }
            .distinctUntilChanged()
            .skip(1)
            .subscribe(onNext: { (orientation) in
                switch orientation.rawValue {
                case 1:
                    self.remakePortraitContraints()
                case 3, 4:
                    self.remakeLandscapeConstrains()
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        //king fisher
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("AlbumViewController :: viewDidLoad")
        view.backgroundColor = .white
        
        view.addSubview(startSlideShowBtn)
        view.addSubview(stepper)
        view.addSubview(stepperLabel)
        view.addSubview(albumImage)
        view.addSubview(networkStateLabel)
        
        remakePortraitContraints()
        
    }
    
    private func remakePortraitContraints() {
        startSlideShowBtn.snp.remakeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60)
            $0.height.equalTo(50)
            $0.leading.equalToSuperview().offset(40)
            $0.trailing.equalToSuperview().offset(-40)
        }
        
        stepper.snp.remakeConstraints {
            $0.trailing.equalTo(startSlideShowBtn.snp.trailing)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-140)
            $0.leading.equalTo(stepperLabel.snp.trailing).offset(20)
        }
        
        stepperLabel.snp.remakeConstraints {
            $0.trailing.equalTo(stepper.snp.leading).offset(-20)
            $0.leading.equalTo(startSlideShowBtn.snp.leading)
            $0.centerY.equalTo(stepper.snp.centerY)
            $0.height.equalTo(stepper.snp.height)
            $0.bottom.equalTo(stepper.snp.bottom)
        }
        
        albumImage.snp.remakeConstraints {
            $0.leading.equalToSuperview().offset(40)
            $0.trailing.equalToSuperview().offset(-40)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(80)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-200)
            
        }
        
        networkStateLabel.snp.remakeConstraints {
            $0.height.equalTo(30)
            $0.leading.equalToSuperview().offset(40)
            $0.top.equalToSuperview().offset(60)
        }
    }
    
    private func remakeLandscapeConstrains() {
        
        albumImage.snp.remakeConstraints {
            $0.left.equalToSuperview().offset(50)
            $0.right.equalTo(view.snp.centerX).offset(-10)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(80)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-40)
            
        }
        
        startSlideShowBtn.snp.remakeConstraints {
            $0.bottom.equalTo(albumImage.snp.bottom)
            $0.height.equalTo(50)
            $0.leading.equalTo(view.snp.centerX).offset(10)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-60)
        }
        
        stepper.snp.remakeConstraints {
            $0.trailing.equalTo(startSlideShowBtn.snp.trailing)
            $0.centerY.equalTo(startSlideShowBtn.snp.top).offset(-50)
            $0.leading.equalTo(stepperLabel.snp.trailing).offset(20)
        }
        
        stepperLabel.snp.remakeConstraints {
            $0.trailing.equalTo(stepper.snp.leading).offset(-20)
            $0.leading.equalTo(startSlideShowBtn.snp.leading)
            $0.centerY.equalTo(stepper.snp.centerY)
            $0.height.equalTo(stepper.snp.height)
            $0.bottom.equalTo(stepper.snp.bottom)
        }
        
        networkStateLabel.snp.remakeConstraints {
            $0.height.equalTo(20)
            $0.trailing.equalToSuperview().offset(-60)
            $0.top.equalToSuperview().offset(60)
        }
    }
}
