//
//  BaseListViewController.swift
//  Musicly
//
//  Created by Christopher Webb-Orenstein on 5/15/17.
//  Copyright © 2017 Christopher Webb-Orenstein. All rights reserved.
//


import UIKit
import RealmSwift

class BaseListViewController: UIViewController {
    
    var dataSource: TracksDataSource
    
    init(dataSource: TracksDataSource) {
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var contentState: TrackContentState = .none {
        didSet {
            switch contentState {
            case .none:
                self.view.bringSubview(toFront: emptyView)
                print("None")
            case .results:
                self.view.bringSubview(toFront: collectionView)
            case.loaded:
                self.view.bringSubview(toFront: collectionView)
            case .loading:
                return
            }
        }
    }
    
    var emptyView = EmptyView() {
        didSet {
            emptyView.configure()
        }
    }
    
    lazy var collectionView : UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        #if CLEAR_CACHES
            let cachesFolderItems = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
            for item in cachesFolderItems {
                try? FileManager.default.removeItem(atPath: item)
            }
        #endif
        setupEmptyView(emptyView: emptyView, for: view)
        edgesForExtendedLayout = []
        setupCollectionView(collectionView: collectionView, view: view, newLayout: TrackItemsFlowLayout())
        collectionView.isHidden = true
        setupDefaultUI()
        collectionView.backgroundColor = CollectionViewConstants.backgroundColor
        collectionViewRegister(collectionView: collectionView, viewController: self, identifier: TrackCell.reuseIdentifier)
    }
}

extension BaseListViewController: TrackCellCollectionProtocol {
    
    func setupCollectionView(collectionView: UICollectionView, view: UIView, newLayout: TrackItemsFlowLayout) {
        collectionView.setup(with: newLayout)
        guard let tabbarHeight = self.tabBarController?.tabBar.frame.height else { return }
        collectionView.contentInset =  UIEdgeInsets(top: 0, left: 0, bottom: tabbarHeight + 20, right: 0)
        view.addSubview(collectionView)
        view.sendSubview(toBack: collectionView)
        view.bringSubview(toFront: emptyView)
    }
}

extension BaseListViewController: UICollectionViewDelegate, OpenPlayerProtocol {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.playlist.itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let destinationViewController = setup(playlist: dataSource.playlist, index: indexPath.row)
        navigationController?.pushViewController(destinationViewController, animated: false)
    }
}

extension BaseListViewController:  UICollectionViewDataSource  {
    
    @objc(collectionView:cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return dataSource.cellInstance(collectionView: collectionView, indexPath:indexPath)
    }
}


