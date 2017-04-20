 //
 //  ViewController.swift
 //  Musically
 //
 //  Created by Christopher Webb-Orenstein on 4/9/17.
 //  Copyright © 2017 Christopher Webb-Orenstein. All rights reserved.
 //
 
 import UIKit
 
 private let reuseIdentifier = "trackCell"
 
 final class TracksViewController: UIViewController {
    
    fileprivate var searchBar = UISearchBar() {
        didSet {
            searchBar.returnKeyType = .done
        }
    }
    
    fileprivate var playlist: Playlist? = Playlist()
    fileprivate var selectedIndex: Int?
    fileprivate var selectedImage = UIImageView()
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    fileprivate var store: iTrackDataStore? = iTrackDataStore(searchTerm: "")
    //  fileprivate var tracks: [iTrack?]?
    
    fileprivate var searchBarActive: Bool = false {
        didSet {
            if searchBarActive == true {
                navigationItem.rightBarButtonItems = []
            } else {
                if let buttonItem = buttonItem {
                    navigationItem.rightBarButtonItems = [buttonItem]
                }
            }
        }
    }
    
    private var image = #imageLiteral(resourceName: "search-button")
    var buttonItem: UIBarButtonItem?
    
    fileprivate lazy var small: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = EdgeAttributes.sectionInset
        layout.itemSize = RowSize.smallLayout.rawValue
        layout.minimumInteritemSpacing = SmallLayoutProperties.minimumInteritemSpacing
        layout.minimumLineSpacing = SmallLayoutProperties.minimumLineSpacing
        return layout
    }()
    
    var infoLabel: UILabel = UILabel.setupInfoLabel()
    
    var musicIcon: UIImageView = {
        var musicIcon = UIImageView()
        musicIcon.image = #imageLiteral(resourceName: "headphones-blue")
        return musicIcon
    }()
    
    var collectionView : UICollectionView? = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        searchController.delegate = self
        image = image.withRenderingMode(.alwaysOriginal)
        title = "Music.ly"
        commonInit()
        setSearchBarColor(searchBar: searchBar)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let searchBarText = searchBar.text, searchBarText.characters.count > 0 {
            searchBarActive = true
        }
        if searchBarActive == true {
            navigationItem.rightBarButtonItems = []
        } else {
            guard let buttonItem = buttonItem else { return }
            navigationItem.rightBarButtonItems = [buttonItem]
        }
    }
    
    // TODO: - Consolidate navigation bar and buttonItem methods
    
    func commonInit() {
        buttonItem = UIBarButtonItem(image: image,
                                     style: .plain,
                                     target: self,
                                     action: #selector(navigationBarSetup))
        edgesForExtendedLayout = [.all]
        collectionView?.isHidden = true
        setupCollectionView()
        setupSearchButton()
        setupDefaultUI()
        loadData()
        setup()
    }
    
    func navigationBarSetup() {
        navigationController?.navigationBar.barTintColor = NavigationBarAttributes.navBarTint
        searchController.hidesNavigationBarDuringPresentation = false
        searchBar = searchController.searchBar
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = .white
        navigationItem.rightBarButtonItem?.tintColor = .white
        searchBar.becomeFirstResponder()
    }
    
    // MARK: - Adds searchButton to navigation bar
    
    func setupSearchButton() {
        navigationItem.setRightBarButton(buttonItem, animated: false)
    }
    
    // Loads dummy data
    
    private func loadData() {
        store?.setSearch(string: "Test")
        store?.searchForTracks { tracks, errors in
            if let tracks = tracks {
                tracks.forEach { self.playlist?.append(value: $0) }
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView?.collectionViewLayout.invalidateLayout()
        collectionView?.layoutIfNeeded()
    }
    
    private func collectionViewRegister() {
        collectionView?.register(TrackCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.dataSource = self
        collectionView?.delegate = self
    }
    
    fileprivate func setupCollectionView() {
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            
            let newLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            newLayout.sectionInset = EdgeAttributes.sectionInset
            newLayout.itemSize = RowSize.item.rawValue
            newLayout.minimumInteritemSpacing = CollectionViewConstants.layoutSpacingMinItem
            newLayout.minimumLineSpacing = CollectionViewConstants.layoutSpacingMinLine
            
            flowLayout.scrollDirection = .vertical
            
            collectionView?.layoutIfNeeded()
            collectionView?.collectionViewLayout = newLayout
            view.backgroundColor = CollectionViewAttributes.backgroundColor
            
            collectionView?.frame = UIScreen.main.bounds
            setupInfoLabel(infoLabel: infoLabel)
            setupMusicIcon(icon: musicIcon)
            
            if let collectionView = collectionView {
                view.addSubview(collectionView)
            }
            collectionViewRegister()
        }
        collectionView?.backgroundColor = CollectionViewConstants.backgroundColor
        if let collectionView = collectionView {
            view.addSubview(collectionView)
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBarActive = cancelSearching(searchBar, searchBarActive: searchBarActive)
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: false)
        searchBarActive = false
    }
 }
 
 // MARK: - UICollectionViewDataSource
 
 extension TracksViewController: UICollectionViewDataSource {
    
    // TODO: - Fix reloadAtSections so that collectionView does not need 50 items in order not to crash
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let playlist = playlist else { return CollectionViewConstants.defaultItemCount }
        if playlist.itemCount > 0 {
            return playlist.itemCount
        }
        return CollectionViewConstants.defaultItemCount
    }
    
    fileprivate func setTrackCell(indexPath: IndexPath?, cell: TrackCell, rowTime: Double) {
        if let index = indexPath,
            let track = playlist?.playlistItem(at: index.row)?.track {
            guard let artURL = track.artworkUrl else { return }
            guard let trackName = track.trackName else { return }
            cell.configureCell(with: trackName, with: artURL)
            DispatchQueue.main.asyncAfter(deadline: .now() + rowTime) {
                UIView.animate(withDuration: CollectionViewConstants.baseDuration + rowTime) {
                    cell.alpha = 1
                }
            }
        }
    }
 }
 
 extension TracksViewController {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        let destinationVC: PlayerViewController? = PlayerViewController()
        if let destinationViewController = destinationVC {
            guard let selectedIndex = selectedIndex else { return }
            destinationViewController.playList = playlist
            destinationViewController.index = selectedIndex
            destinationViewController.setupPlayItem(index: selectedIndex)
            navigationController?.pushViewController(destinationViewController, animated: false)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TrackCell
        cell.alpha = 0
        let rowTime = (Double(indexPath.row % 10)) / CollectionViewConstants.rowTimeDivider
        setTrackCell(indexPath: indexPath, cell: cell, rowTime: rowTime)
        return cell
    }
 }
 
 // MARK: - UICollectionViewDelegate
 
 extension TracksViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return RowSize.header.rawValue
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionViewLayout == small {
            return RowSize.smallLayout.rawValue
        }
        return RowSize.track.rawValue
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return EdgeAttributes.edgeForStandard
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumItemSpacingForSectionAt section: Int) -> CGFloat {
        return CollectionViewConstants.layoutSpacingMinItem
    }
 }
 
 // MARK: - UISearchController Delegate
 
 extension TracksViewController: UISearchControllerDelegate {
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        
        searchBarActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBarActive = false
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if !searchBarActive {
            collectionView?.reloadData()
            searchBarActive = true
        }
        searchController.searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !searchBarActive {
            searchBarActive = true
            collectionView?.reloadData()
        }
        searchController.searchBar.resignFirstResponder()
    }
    
    // TODO: - Handle searchbar without text
    
    fileprivate func setup() {
        setSearchBarColor(searchBar: searchBar)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchBar.barTintColor = .white
    }
    
    // TODO: - Cleanup logic
    
    func searchBarHasInput() {
        
        guard let collectionView = collectionView else { return }
        collectionView.backgroundView?.isHidden = true
        
        infoLabel.isHidden = true
        musicIcon.isHidden = true
        collectionView.reloadData()
        self.playlist?.removeAll()
        store?.searchForTracks { [weak self] tracks, error in
            tracks?.forEach {
                self?.playlist?.append(value: $0)
            }
            collectionView.reloadData()
            collectionView.performBatchUpdates ({
                DispatchQueue.main.async {
                    if let collectionView = self?.collectionView {
                        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
                        collectionView.isHidden = false
                    }
                }
            }, completion: { finished in
                print(finished)
            })
            print(self?.playlist?.itemCount ?? "no count")
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let barText = searchBar.getTextFromBar()
        store?.setSearch(string: barText)
        searchBarActive = true
        if barText != "" {
            searchBarHasInput()
        }
        navigationController?.navigationBar.topItem?.title = "Search: \(barText)"
        
        UIView.animate(withDuration: 1.8) {
            self.collectionView?.alpha = 1
        }
    }
    
    func cancelSearching(_ searchBar: UISearchBar, searchBarActive: Bool) -> Bool {
        return false
    }
 }
 
 // MARK: - UISearchResultsUpdating
 
 extension TracksViewController: UISearchResultsUpdating {
    
    func filterContentForSearchText(searchText: String) {
        print("filter")
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        if searchString != nil {
            playlist?.removeAll()
            if let searchString = searchString {
                store?.setSearch(string: searchString)
                store?.searchForTracks { tracks, error in
                    self.store?.searchForTracks { tracks, error in
                        
                        if let tracks = tracks {
                            
                            tracks.forEach {
                                self.playlist?.append(value: $0)
                            }
                        }
                        //    self.tracks = tracks
                    }
                }
            }
        }
        collectionView?.reloadData()
    }
    
    public func updateSearchResults(for searchController: UISearchController) {
        searchBarActive = true
    }
 }
 
 // MARK: - UISearchBarDelegate
 
 extension TracksViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navigationItem.setRightBarButton(buttonItem, animated: false)
        searchBarActive = false
    }
    
 }
