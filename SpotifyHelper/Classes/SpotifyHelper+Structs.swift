//
//  SpotifyHelper+Structs.swift
//  HeartBit
//
//  Created by Balázs Morvay on 2021. 02. 10..
//  Copyright © 2021. BitRaptors. All rights reserved.
//

import Foundation

public struct SpotifyError {
    public let errorTitle: String
    public let errorMessage: String
}

/// All information stored about a spotify track
public struct SpotifyTrack {
    public let album: SpotifyAlbum
    public let artist: SpotifyArtist
    public let duration: Int

    /// True, if the track is a: -podcast, -video, -other audio episode
    public let isEpisode: Bool

    public let isPodcast: Bool
    public let isSaved: Bool
    public let name: String
    public let uri: String
}

public struct SpotifyAlbum {
    public let name: String
    public let uri: String
}

public struct SpotifyArtist {
    public let name: String
    public let uri: String
}

public struct SpotifyPlaybackRestrictions {
    public let canSkipNext: Bool
    public let canSkipPrevious: Bool
    public let canRepeatTrack: Bool
    public let canRepeatContext: Bool
    public let canToggleShuffle: Bool
    public let canSeek: Bool
}

public struct SpotifyPlayBackOptions {
    public let isShuffling: Bool
    public let repeatMode: SpotifyRepeatMode
}

public enum PodcastPlaybackSpeed {
    case slow(speed: NSNumber = 0.5)
    case normal(speed: NSNumber = 1.0)
    case fast(speed: NSNumber = 2.0)
}

public enum SpotifyRepeatMode {
    /// No repeat
    case off
    /// The current track over and over again
    case track
    /// The current context (i.e. playlist, album etc.) over and over again
    case context
}


public enum SpotifyLogLevel {
    case debug
    case error
    case info
    case none
}
