//
//  SpotifyHelperFactory.swift
//  SpotifyHelper
//
//  Created by Balázs Morvay on 2021. 02. 24..
//  Copyright © 2021. CocoaPods. All rights reserved.
//

import Foundation
import SpotifyHelper

public class SpotifyHelperFactory {
    public static let instance = SpotifyHelper(spotifyClientID: "7bdeb474b09149bd92c907de7d2a052e", redirectURL: URL(string: "spotify-ios-hb-test://callback")!)
    private init() {}
}
