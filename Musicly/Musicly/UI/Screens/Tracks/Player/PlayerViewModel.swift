//
//  PlayerViewModel.swift
//  Musicly
//
//  Created by Christopher Webb-Orenstein on 4/23/17.
//  Copyright © 2017 Christopher Webb-Orenstein. All rights reserved.
//

import UIKit

struct PlayerViewModel {
    var thumbs: Thumbs {
        didSet {
            thumbsUpImage = thumbs == .up ? #imageLiteral(resourceName: "thumbsupiconorange") : #imageLiteral(resourceName: "thumbsupblue")
            thumbsDownImage = thumbs == .down ? #imageLiteral(resourceName: "thumbsdownorange") : #imageLiteral(resourceName: "thumbsdownblue")
        }
    }
    var currentPlayTimeColor: UIColor = .orange
    var totalPlayTimeColor: UIColor
    var progress: Float
    var playState: FileState {
        didSet {
            currentPlayTimeColor = playState == .done ? .white : .orange
            totalPlayTimeColor = playState == .done ? .orange : .white
            print(playState)
        }
    }
    var trackName: String
    var albumArt: UIImage
    var thumbsUpImage: UIImage
    var thumbsDownImage: UIImage
    var time: Int
    var totalTime: Int
    var totalTimeString: String
    var artworkUrl: String
    init(track: Track, playState: FileState) {
        self.playState = playState
        self.currentPlayTimeColor = .orange
        self.totalPlayTimeColor = .white
        self.time = 0
        self.progress = 0
        self.totalTimeString = ""
        self.totalTime = 0
        self.thumbs = .none
        self.thumbsDownImage = UIImage()
        self.thumbsUpImage = UIImage()
        self.albumArt = UIImage()
        self.artworkUrl = track.artworkUrl
        self.trackName = track.trackName
    }
}