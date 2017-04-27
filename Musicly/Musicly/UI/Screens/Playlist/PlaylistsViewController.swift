//
//  PlaylistViewController.swift
//  Musicly
//
//  Created by Christopher Webb-Orenstein on 4/19/17.
//  Copyright © 2017 Christopher Webb-Orenstein. All rights reserved.
//

import UIKit
import RealmSwift

private let reuseIdentifier = "PlaylistCell"

final class PlaylistsViewController: UIViewController {
    
    let detailPop = DetailPopover()
    var collectionView : UICollectionView? = UICollectionView.setupPlaylistCollectionView()
    
    var store: iTrackDataStore? {
        didSet {
            dump(store)
        }
    }
    
    var rightBarButtonItem: UIBarButtonItem? = UIBarButtonItem.init(image: #imageLiteral(resourceName: "blue-musicnote-1").withRenderingMode(UIImageRenderingMode.alwaysOriginal), style: .done, target: self, action: #selector(pop))

    var trackList: [TrackList] = [TrackList]()
    
    override func viewDidLoad() {
        title = "Playlists"
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.register(PlaylistCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.backgroundColor = PlaylistViewControllerConstants.backgroundColor
        view.addSubview(collectionView!)
        detailPop.popView.playlistNameField.delegate = self
        guard let rightButtonItem = rightBarButtonItem else { return }
        navigationItem.rightBarButtonItems = [rightButtonItem]
        let tabbar = tabBarController as! TabBarController
        store = tabbar.store
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tabController = self.tabBarController as! TabBarController
        store = tabController.store
        guard let store = store else { return }
        store.setSearch(string: "")
        if let tracklists = store.trackLists {
            DispatchQueue.main.async {
                self.trackList = Array(tracklists)
                self.collectionView?.reloadData()
            }
        }
    }
}

extension PlaylistsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let store = store else { return 0 }
        return trackList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PlaylistCell
        let index = indexPath.row
        let track = trackList[index]
        let name = track.listName
        
        if track.tracks.count > 0 {
            if let arturl = URL(string: track.tracks[0].artworkUrl) {
                cell.configure(playlistName: name, artUrl: arturl, numberOfTracks: String(describing: track.tracks.count))
            }
        } else {
            cell.configure(playlistName: name, artUrl: nil, numberOfTracks: String(describing: track.tracks.count))
        }
        return cell
    }
    
    func pop() {
        detailPop.setupPop()
        UIView.animate(withDuration: 0.15) {
            self.detailPop.showPopView(viewController: self)
            self.detailPop.popView.isHidden = false
        }
        detailPop.popView.doneButton.addTarget(self, action: #selector(hidePop), for: .touchUpInside)
    }
    
    func hidePop() {
        guard let store = store else { return }
        guard let nameText = detailPop.popView.playlistNameField.text else { return }
        store.createNewList(name: nameText)
        if let tracklists = store.trackLists, let last = tracklists.last {
            trackList.append(last)
        }
        
        detailPop.hidePopView(viewController: self)
        detailPop.popView.isHidden = true
        view.sendSubview(toBack: detailPop)
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let destinationVC = PlaylistViewController()
        destinationVC.tracklist = trackList[indexPath.row]
        destinationVC.title = trackList[indexPath.row].listName
        store?.currentPlaylistID = trackList[indexPath.row].listId
        store?.setCurrentPlaylist()
        navigationController?.pushViewController(destinationVC, animated: false)
    }
}

extension PlaylistsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return PlaylistViewControllerConstants.collectionItemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return PlaylistViewControllerConstants.collectionViewEdge
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumItemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension PlaylistsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}