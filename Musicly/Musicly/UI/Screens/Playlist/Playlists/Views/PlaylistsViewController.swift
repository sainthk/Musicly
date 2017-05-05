import UIKit
import RealmSwift

private let reuseIdentifier = "PlaylistCell"

final class PlaylistsViewController: UIViewController {
    
    let detailPop = NewPlaylistPopover()
    lazy var collectionView : UICollectionView = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: UICollectionViewFlowLayout())
    var tabController: TabBarController!
    var store: iTrackDataStore!
    var rightBarButtonItem: UIBarButtonItem!
    var trackList: [TrackList] = [TrackList]()
    
    override func viewDidLoad() {
        title = "Playlists"
        setupPlaylistCollectionView()
        rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "blue-musicnote").withRenderingMode(UIImageRenderingMode.alwaysOriginal), style: .done, target: self, action: #selector(pop))
        tabController = tabBarController as! TabBarController
        collectionViewSetup()
        
        detailPop.popView.playlistNameField.delegate = self
        guard let rightButtonItem = rightBarButtonItem else { return }
        navigationItem.rightBarButtonItems = [rightButtonItem]
        let tabbar = tabBarController as! TabBarController
        store = tabbar.store
    }
    
    func collectionViewSetup() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PlaylistCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = PlaylistViewControllerConstants.backgroundColor
        view.addSubview(collectionView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store = tabController.store
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

extension PlaylistsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let tracklists = store.trackLists {
            DispatchQueue.main.async {
                self.trackList = Array(tracklists)
            }
        }
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
        guard let nameText = detailPop.popView.playlistNameField.text else { return }
        store.createNewList(name: nameText)
        if let tracklists = store.trackLists, let last = tracklists.last {
            trackList.append(last)
        }
        detailPop.hidePopView(viewController: self)
        detailPop.popView.isHidden = true
        view.sendSubview(toBack: detailPop)
        DispatchQueue.main.async {
            self.trackList = self.store.lists
            self.collectionView.reloadData()
        }
    }
}

extension PlaylistsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let destinationVC = PlaylistViewController()
        destinationVC.title = trackList[indexPath.row].listName
        store.currentPlaylistID = trackList[indexPath.row].listId
        destinationVC.tracklist = store.setupCurrentPlaylist()
        dump(trackList)
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(destinationVC, animated: false)
        }
    }
}

extension PlaylistsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func setupPlaylistCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: layout)
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .vertical
            flowLayout.minimumLineSpacing = 10
        }
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        layout.itemSize = PlaylistViewControllerConstants.itemSize
    }
}