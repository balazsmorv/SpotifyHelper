//
//  SpotifyHelper+Converters.swift
//  HeartBit
//
//  Created by Balázs Morvay on 2021. 02. 10..
//  Copyright © 2021. BitRaptors. All rights reserved.
//

import Foundation
import RxRelay
import RxSwift
import SpotifyiOS

/// Converter class for converting SpotifySDK classes into classes that do not need the SDK
public class SpotifyConverter {
    public static func convertTrack(_ track: SPTAppRemoteTrack) -> SpotifyTrack {
        SpotifyTrack(album: convertAlbum(track.album),
                     artist: convertArtist(track.artist),
                     duration: Int(track.duration),
                     isEpisode: track.isEpisode,
                     isPodcast: track.isPodcast,
                     isSaved: track.isSaved,
                     name: track.name,
                     uri: track.uri)
    }

    public static func convertAlbum(_ album: SPTAppRemoteAlbum) -> SpotifyAlbum {
        SpotifyAlbum(name: album.name, uri: album.uri)
    }

    public static func convertArtist(_ artist: SPTAppRemoteArtist) -> SpotifyArtist {
        SpotifyArtist(name: artist.name, uri: artist.uri)
    }

    public static func convertPlaybackSpeed(_ speed: Float) -> PodcastPlaybackSpeed {
        if speed == 0.5 { return .slow(speed: 0.5) }
        if speed == 1.0 { return .normal(speed: 1.0) }
        if speed == 2.0 { return .fast(speed: 2.0) }
        return .normal(speed: 1.0)
    }

    public static func convertRestrictions(_ restrictions: SPTAppRemotePlaybackRestrictions) -> SpotifyPlaybackRestrictions {
        SpotifyPlaybackRestrictions(canSkipNext: restrictions.canSkipNext,
                                    canSkipPrevious: restrictions.canSkipPrevious,
                                    canRepeatTrack: restrictions.canRepeatTrack,
                                    canRepeatContext: restrictions.canRepeatContext,
                                    canToggleShuffle: restrictions.canToggleShuffle,
                                    canSeek: restrictions.canSeek)
    }

    public static func convertPlaybackOptions(_ options: SPTAppRemotePlaybackOptions) -> SpotifyPlayBackOptions {
        let repeatMode: SpotifyRepeatMode = {
            switch options.repeatMode {
            case .off:
                return .off
            case .track:
                return .track
            case .context:
                return .context
            @unknown default:
                fatalError("Oooops")
            }
        }()

        return SpotifyPlayBackOptions(isShuffling: options.isShuffling,
                                      repeatMode: repeatMode)
    }
}
