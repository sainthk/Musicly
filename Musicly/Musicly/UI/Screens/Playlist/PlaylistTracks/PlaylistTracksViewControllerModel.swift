//
//  PlaylistTracksViewControllerModel.swift
//  Musicly
//
//  Created by Christopher Webb-Orenstein on 5/5/17.
//  Copyright © 2017 Christopher Webb-Orenstein. All rights reserved.
//

import UIKit

class PlaylistTracksViewControllerModel {
    
    var playlist = Playlist()
    
    var tracklist = TrackList() {
        didSet {
            for track in tracklist.tracks {
                let newItem = PlaylistItem()
                newItem.track = track
                if !playlist.contains(playlistItem: newItem) {
                    DispatchQueue.main.async {
                        self.playlist.append(newPlaylistItem: newItem)
                    }
                    
                }
            }
        }
    }
    
    var store: iTrackDataStore!
    
    var count: Int {
        return playlist.itemCount
    }
    
    var state: TrackContentState {
        if count > 0 {
            return .results
        } else {
            return .none
        }
    }
    
    
    func getRowTime(indexPath: IndexPath) -> Double {
        var rowTime: Double = 0
        if indexPath.row > 10 {
            rowTime = (Double(indexPath.row % 10)) / CollectionViewConstants.rowTimeDivider
        } else {
            rowTime = (Double(indexPath.row)) / CollectionViewConstants.rowTimeDivider
        }
        
        return rowTime
    }
}


