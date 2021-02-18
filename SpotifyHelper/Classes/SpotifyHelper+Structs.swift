//
//  SpotifyHelper+Structs.swift
//  HeartBit
//
//  Created by Balázs Morvay on 2021. 02. 10..
//  Copyright © 2021. BitRaptors. All rights reserved.
//

import Foundation


public struct SpotifyError {
    let errorTitle: String
    let errorMessage: String
}



/// All information stored about a spotify track
public struct SpotifyTrack {
    let album: SpotifyAlbum
    let artist: SpotifyArtist
    let duration: Int
    
    /// True, if the track is a: -podcast, -video, -other audio episode
    let isEpisode: Bool
    
    let isPodcast: Bool
    let isSaved: Bool
    let name: String
    let uri: String
}



public struct SpotifyAlbum {
    let name: String
    let uri: String
}



public struct SpotifyArtist {
    let name: String
    let uri: String
}



public struct SpotifyPlaybackRestrictions {
    let canSkipNext: Bool
    let canSkipPrevious: Bool
    let canRepeatTrack: Bool
    let canRepeatContext: Bool
    let canToggleShuffle: Bool
    let canSeek: Bool
}



public struct SpotifyPlayBackOptions {
    let isShuffling: Bool
    let repeatMode: SpotifyRepeatMode
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
