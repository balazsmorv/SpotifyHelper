//
//  SpotifyHelper.swift
//  HeartBit
//
//  Created by Balázs Morvay on 2021. 02. 10..
//  Copyright © 2021. BitRaptors. All rights reserved.
//

import Foundation
import RxRelay
import RxSwift
import SpotifyiOS


public protocol SpotifyHelperProtocol {
    // MARK: - Input - App lifecycle

    func receiveDeepLink(url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool
    func disconnectRemote()
    func connectRemote()

    // MARK: - Input - User interaction

    func seekForward15seconds()
    func seekBackwards15seconds()

    func skipToNextTrack()
    func skipToPreviousTrack()

    func resumePlay()
    func pausePlay()

    func toggleShuffle()
    func toggleRepeatMode()

    func setPodcastSpeed(to: PodcastPlaybackSpeed)

    // MARK: - Configuration

    /// Set to the size you want the album covers to be downloaded
    func setAlbumImageSize(to size: CGSize)

    // MARK: - Output

    var errorOutput: PublishRelay<SpotifyError> { get }
    var imagePublisher: PublishSubject<UIImage?> { get }
    var spotifyStateOutput: SpotifyStateOutput { get }
}

class SpotifyHelper: NSObject, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate, SpotifyHelperProtocol {
    // MARK: - Properties

    // TODO: change these, when releasing!
    private let SpotifyClientID = "4f7e8f1175514131b4b2c899c0edb232"
    private let SpotifyRedirectURL = URL(string: "spotify-ios-quick-start://spotify-login-callback")!

    private var accessToken: String?

    private lazy var configuration = SPTConfiguration(
        clientID: SpotifyClientID,
        redirectURL: SpotifyRedirectURL
    )

    internal lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: self.configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        return appRemote
    }()

    /// If empty, it will resume playback of user’s last track or play a random track. If offline, one of the downloaded for offline tracks will play
    private let playURI = ""

    /// Observable that emit the spotify player states
    private let playerStateObservable = BehaviorRelay<SPTAppRemotePlayerState?>(value: nil)

    public var albumImageSize: CGSize = CGSize(width: 256, height: 256)

    override public init() {
        spotifyStateOutput =
            SpotifyStateOutput(
                trackObservable: playerStateObservable.map({ (remotePlayerState) -> SpotifyTrack? in
                    if let track = remotePlayerState?.track {
                        return SpotifyConverter.convertTrack(track)
                    } else { return nil }
                }),
                playbackPositionObservable: playerStateObservable.map({ (remotePlayerState) -> Int in
                    remotePlayerState?.playbackPosition ?? 0
                }),
                playbackSpeedObservable: playerStateObservable.map({ (remotePlayerState) -> PodcastPlaybackSpeed? in
                    if let speed = remotePlayerState?.playbackSpeed {
                        return SpotifyConverter.convertPlaybackSpeed(speed)
                    } else { return nil }
                }),
                isPausedObservable: playerStateObservable.map({ (remotePlayerState) -> Bool in
                    remotePlayerState?.isPaused ?? true
                }),
                playbackRestrictionsObservable: playerStateObservable.map({ (remotePlayerState) -> SpotifyPlaybackRestrictions? in
                    if let restrictions = remotePlayerState?.playbackRestrictions {
                        return SpotifyConverter.convertRestrictions(restrictions)
                    } else { return nil }
                }),
                playbackOptionsObservable: playerStateObservable.map({ (remotePlayerState) -> SpotifyPlayBackOptions? in
                    if let options = remotePlayerState?.playbackOptions {
                        return SpotifyConverter.convertPlaybackOptions(options)
                    } else { return nil }
                }),
                currentContextTitleObservable: playerStateObservable.map({ (remoteStatePlayer) -> String? in
                    remoteStatePlayer?.contextTitle
                }),
                contextURIObservable: playerStateObservable.map({ (remoteStatePlayer) -> URL? in
                    remoteStatePlayer?.contextURI
                })
            )

        super.init()
    }

    // MARK: - Output

    public var errorOutput = PublishRelay<SpotifyError>()

    public var imagePublisher = PublishSubject<UIImage?>()

    public var spotifyStateOutput: SpotifyStateOutput

    // MARK: - Input - user interaction

    public func seekForward15seconds() {
        appRemote.playerAPI?.seekForward15Seconds({ result, error in
            self.defaultHandler(result: result, error: error, processName: "Seek forward")
        })
    }

    public func seekBackwards15seconds() {
        appRemote.playerAPI?.seekBackward15Seconds({ result, error in
            self.defaultHandler(result: result, error: error, processName: "Seek backward")
        })
    }

    public func skipToNextTrack() {
        appRemote.playerAPI?.skip(toNext: { result, error in
            self.defaultHandler(result: result, error: error, processName: "Skip to next track")
        })
    }

    public func skipToPreviousTrack() {
        appRemote.playerAPI?.skip(toPrevious: { result, error in
            self.defaultHandler(result: result, error: error, processName: "Skip to previous track")
        })
    }

    public func resumePlay() {
        appRemote.playerAPI?.resume({ result, error in
            self.defaultHandler(result: result, error: error, processName: "Resuming")
        })
    }

    public func pausePlay() {
        appRemote.playerAPI?.pause({ result, error in
            self.defaultHandler(result: result, error: error, processName: "Pausing")
        })
    }

    public func toggleShuffle() {
        guard let currentState = playerStateObservable.value?.playbackOptions.isShuffling else { return }
        appRemote.playerAPI?.setShuffle(!currentState, callback: { result, error in
            self.defaultHandler(result: result, error: error, processName: "Shuffle setting")
        })
    }

    public func setPodcastSpeed(to speed: PodcastPlaybackSpeed) {
        switch speed {
        case let .fast(speed):
            appRemote.playerAPI?.setPodcastPlaybackSpeed(speed as! SPTAppRemotePodcastPlaybackSpeed, callback: { result, error in
                self.defaultHandler(result: result, error: error, processName: "Setting playback speed")
            })
        case let .normal(speed):
            appRemote.playerAPI?.setPodcastPlaybackSpeed(speed as! SPTAppRemotePodcastPlaybackSpeed, callback: { result, error in
                self.defaultHandler(result: result, error: error, processName: "Setting playback speed")
            })
        case let .slow(speed):
            appRemote.playerAPI?.setPodcastPlaybackSpeed(speed as! SPTAppRemotePodcastPlaybackSpeed, callback: { result, error in
                self.defaultHandler(result: result, error: error, processName: "Setting playback speed")
            })
        }
    }

    public func playTrackWithIdentifier(_ identifier: String) {
        appRemote.playerAPI?.play(identifier, callback: { result, error in
            self.defaultHandler(result: result, error: error, processName: "Playing \(identifier)")
        })
    }

    public func toggleRepeatMode() {
        guard let playerState = playerStateObservable.value else { return }
        let repeatMode: SPTAppRemotePlaybackOptionsRepeatMode = {
            switch playerState.playbackOptions.repeatMode {
            case .off: return .track
            case .track: return .context
            case .context: return .off
            default: return .off
            }
        }()

        appRemote.playerAPI?.setRepeatMode(repeatMode, callback: { result, error in
            self.defaultHandler(result: result, error: error, processName: "Repeat setting")
        })
    }

    // MARK: - Lifecycle funcs

    public func receiveDeepLink(url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        let parameters = appRemote.authorizationParameters(from: url)

        if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = access_token
            accessToken = access_token
        } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
            self.sendToErrorOutput(title: "Deep link error", description: error_description)
        }
        return true
    }

    public func disconnectRemote() {
        if appRemote.isConnected {
            appRemote.disconnect()
        }
    }

    public func connectRemote() {
        appRemote.connect()
    }

    // MARK: - App remote delegate funcs

    /// Invoke a request to subscribe to player state updates
    public func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        self.appRemote.playerAPI?.delegate = self
        self.appRemote.playerAPI?.subscribe(toPlayerState: { _, error in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
        })
    }

    public func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("SPOTIFY: disconnected")
        playerStateObservable.accept(nil)
        sendToErrorOutput(title: "Spotify disconnected", description: error?.localizedDescription ?? "")
    }

    public func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("SPOTIFY: failed")
        playerStateObservable.accept(nil)
        sendToErrorOutput(title: "Spotify failed to connect", description: error?.localizedDescription ?? "")
    }

    public func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        playerStateObservable.accept(playerState)
    }

    /// Initiate authorization and connect to Spotify.
    private func connect() {
        appRemote.authorizeAndPlayURI(playURI)
    }

    // MARK: - Other functions

    private func sendToErrorOutput(title: String, description: String) {
        errorOutput.accept(SpotifyError(errorTitle: title, errorMessage: description))
    }

    /// If any errors are received, it pushes to the error output, otherwise doesnt to anything
    private func defaultHandler(result: Any?, error: Error?, processName: String) {
        if let error = error {
            sendToErrorOutput(title: "\(processName) failed", description: error.localizedDescription)
        }
    }

    /// Downloads the album picture for the given track
    private func fetchAlbumArtForTrack(_ track: SPTAppRemoteTrack) -> Single<UIImage?> {
        return Single.create { [weak self] (single) -> Disposable in
            let disposable = Disposables.create()
            guard let strongSelf = self else { return disposable }

            strongSelf.appRemote.imageAPI?.fetchImage(forItem: track, with: strongSelf.albumImageSize, callback: { image, error in
                if let error = error {
                    single(.error(error))
                }

                if let image = image as? UIImage {
                    single(.success(image))
                }
            })

            return disposable
        }
    }

    public func setAlbumImageSize(to size: CGSize) {
        albumImageSize = size
    }
}

/// Composite class that contains the spotify player's state
public class SpotifyStateOutput {
    public let trackObservable: Observable<SpotifyTrack?>
    public let playbackPositionObservable: Observable<Int?>
    public let playbackSpeedObservable: Observable<PodcastPlaybackSpeed?>
    public let isPausedObservable: Observable<Bool?>
    public let playbackRestrictionsObservable: Observable<SpotifyPlaybackRestrictions?>
    public let playbackOptionsObservable: Observable<SpotifyPlayBackOptions?>

    /// The title of the currently playing context (e.g. the name of the playlist).
    public let currentContextTitleObservable: Observable<String?>

    public let contextURIObservable: Observable<URL?>

    public init(trackObservable: Observable<SpotifyTrack?>,
                playbackPositionObservable: Observable<Int?>,
                playbackSpeedObservable: Observable<PodcastPlaybackSpeed?>,
                isPausedObservable: Observable<Bool?>,
                playbackRestrictionsObservable: Observable<SpotifyPlaybackRestrictions?>,
                playbackOptionsObservable: Observable<SpotifyPlayBackOptions?>,
                currentContextTitleObservable: Observable<String?>,
                contextURIObservable: Observable<URL?>) {
        self.trackObservable = trackObservable
        self.playbackPositionObservable = playbackPositionObservable
        self.playbackSpeedObservable = playbackSpeedObservable
        self.isPausedObservable = isPausedObservable
        self.playbackRestrictionsObservable = playbackRestrictionsObservable
        self.playbackOptionsObservable = playbackOptionsObservable
        self.currentContextTitleObservable = currentContextTitleObservable
        self.contextURIObservable = contextURIObservable
    }
}
