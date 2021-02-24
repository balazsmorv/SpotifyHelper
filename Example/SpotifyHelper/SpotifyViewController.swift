//
//  SpotifyViewController.swift
//  HeartBit
//
//  Created by Balázs Morvay on 2021. 02. 11..
//  Copyright © 2021. BitRaptors. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import StoreKit
import SpotifyHelper
import RxGesture



public class SpotifyViewController: UIViewController {
    
    // MARK: - Properties
    
    private let screenHeight = UIScreen.main.bounds.height
    
    private let spotifyHelper = SpotifyHelperFactory.instance
    
    private let disposeBag = DisposeBag()
    
    private var isPlaying: Bool = false
    
    private var parentVC: UIViewController?
    
    // MARK: - Constants and personalization
    
    let defaultAlbumCoverImage: UIImage = UIImage(named: "easteregg")!
    
    let playingImage: UIImage = UIImage(named: "play")!
    let stoppedImage: UIImage = UIImage(named: "pause")!
    
    let skipBackImage: UIImage = UIImage(named: "back")!
    let skipForwardImage: UIImage = UIImage(named: "next")!
    
    /// The tint color for the back, forward, play/pause buttons
    let buttonTintColor: UIColor = .blue
    
    let openSpotifyButtonTintColor: UIColor = .green
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var faderView: UIView!
    
    @IBOutlet weak var bottomSheetView: UIView!
    
    @IBOutlet weak var albumImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    @IBOutlet weak var previousTrackButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextTrackButton: UIButton!
    
    
    @IBOutlet weak var openSpotifyButton: UIButton!
    
    
    // MARK: - Lifecycle
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        animateIn()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        
        animateOut()
        
        spotifyHelper.setAlbumImageSize(to: CGSize(width: albumImageView.bounds.width * 2,
                                                   height: albumImageView.bounds.height * 2))
        
        self.previousTrackButton.tintColor = self.buttonTintColor
        self.playPauseButton.tintColor = self.buttonTintColor
        self.nextTrackButton.tintColor = self.buttonTintColor
        
        spotifyHelper.connectRemote()
        
        setSubscriptions()
        setActions()
    }
    
    
    // MARK: - Other funcs
    
    public func setParentVC(vc: UIViewController) {
        self.parentVC = vc
    }
    
    private func animateIn() {
        UIView.animate(withDuration: 0.2, animations: {
            self.faderView.alpha = 0.4
        }) { (_) in
            self.animateBottomSheetIn()
        }
    }
    
    private func animateOut(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.2, animations: {
            self.faderView.alpha = 0.0
        }, completion: { _ in
            self.animateBottomSheetOut(completion: completion)
        })
    }
    
    
    private func animateBottomSheetIn() {
        UIView.animate(withDuration: 0.2,
                       delay: 0.1,
                       options: [.curveEaseOut]) {
            self.bottomSheetView.transform = .identity
            self.bottomSheetView.alpha = 1.0
        }
    }
    
    private func animateBottomSheetOut(completion: (() -> Void)?) {
        UIView.animate(withDuration: 0.1, delay: 0.1, options: [.curveEaseIn], animations: {
            self.bottomSheetView.transform = CGAffineTransform(translationX: 0,
                                                               y: self.screenHeight)
        }) { (_) in
            if let completion = completion {
                completion()
            }
        }
    }

    
    /// Updates the UI from the SpotifyHelper's output observables
    private func setSubscriptions() {
        
        // Any errors are bound to the current page
        spotifyHelper.errorOutput.subscribe { (error) in
            print("Error output: \(error)")
        } onError: { (_) in
            
        } onCompleted: {
            
        } onDisposed: {
            
        }.disposed(by: disposeBag)

        
        
        // Bind the album covers to the image view. If no album cover exists, put a default image
        spotifyHelper.albumImageObservable.map { (image) -> UIImage in
            return image ?? self.defaultAlbumCoverImage
        }.bind(to: self.albumImageView.rx.image)
        .disposed(by: disposeBag)
        
        
        spotifyHelper.spotifyStateOutput.isPausedObservable.map { (optionaBool) -> Bool in
            optionaBool ?? true
        }.subscribe(onNext: { (paused) in
            if paused {
                self.playPauseButton.setImage(self.playingImage, for: .normal)
            } else {
                self.playPauseButton.setImage(self.stoppedImage, for: .normal)
            }
        }).disposed(by: disposeBag)
        
        
        // We need to save if the music is currently playing to determine on the next play/pause button tap what to do
        spotifyHelper.spotifyStateOutput.isPausedObservable.subscribe(onNext: { (paused) in
            self.isPlaying = !(paused ?? true)
        }).disposed(by: disposeBag)

        
        spotifyHelper.spotifyStateOutput.trackObservable.subscribe(onNext: { (track) in
            self.titleLabel.text = track?.name
            self.artistLabel.text = track?.artist.name
        }).disposed(by: disposeBag)
        
        
        // Disable certain controls if the users account is restricted
        spotifyHelper.spotifyStateOutput.playbackRestrictionsObservable.subscribe(onNext: { (restrictions) in
            
            if restrictions?.canSkipNext != .some(true) {
                self.nextTrackButton.isEnabled = false
            } else {
                self.nextTrackButton.isEnabled = true
            }
            
            if restrictions?.canSkipPrevious != .some(true) {
                self.previousTrackButton.isEnabled = false
            } else {
                self.previousTrackButton.isEnabled = true
            }
            
        }).disposed(by: disposeBag)
        
    }
    
    /// Sets the actions for the tappable buttons
    private func setActions() {
        
        self.playPauseButton.rx.tap.subscribe(onNext: { (_) in
            self.isPlaying ? self.spotifyHelper.pausePlay() : self.spotifyHelper.resumePlay()
        }).disposed(by: disposeBag)
        
        self.previousTrackButton.rx.tap.subscribe(onNext: { (_) in
            self.spotifyHelper.skipToPreviousTrack()
        }).disposed(by: disposeBag)
        
        self.nextTrackButton.rx.tap.subscribe(onNext: { _ in
            self.spotifyHelper.skipToNextTrack()
        }).disposed(by: disposeBag)
        
        self.openSpotifyButton.rx.tap.subscribe(onNext: { (_) in
            self.spotifyHelper.openSpotifyApp()
        }).disposed(by: disposeBag)
        
        // Dismiss itself when the fader view is tapped
        self.faderView.rx.tapGesture().subscribe(onNext: { (gesture) in
            guard gesture.state == .ended else { return }
            self.animateOut {
                self.parentVC?.dismiss(animated: true, completion: nil)
            }
        }).disposed(by: disposeBag)


    }
    
    
    

}


// MARK: SKStoreProductViewControllerDelegate
extension SpotifyViewController: SKStoreProductViewControllerDelegate {
    private func showAppStoreInstall() {
        if TARGET_OS_SIMULATOR != 0 {
            print("Only testable on physical device")
        } else {
            let loadingView = UIActivityIndicatorView(frame: view.bounds)
            view.addSubview(loadingView)
            loadingView.startAnimating()
            loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
            let storeProductViewController = SKStoreProductViewController()
            storeProductViewController.delegate = self
            storeProductViewController.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: spotifyHelper.spotifyItunesID], completionBlock: { (success, error) in
                loadingView.removeFromSuperview()
                if let error = error {
                    print(error)
                } else {
                    self.present(storeProductViewController, animated: true, completion: nil)
                }
            })
        }
    }

    public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}
