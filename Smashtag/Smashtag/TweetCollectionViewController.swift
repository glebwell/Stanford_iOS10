//
//  TweetCollectionViewController.swift
//  Smashtag
//
//  Created by Admin on 26.06.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import Twitter

public struct TweetMedia: CustomStringConvertible {
    let tweet: Twitter.Tweet
    let media: Twitter.MediaItem

    public var description: String {
        return "tweet: \(tweet) media: \(media)"
    }
}

public class Cache: NSCache<NSURL, NSData> {
    subscript (key: URL) -> Data? {
        get {
            return object(forKey: key as NSURL) as? Data
        }
        set {
            if let data = newValue {
                setObject(data as NSData, forKey: key as NSURL, cost: data.count / 1024)
            } else {
                removeObject(forKey: key as NSURL)
            }
        }
    }
}
class TweetCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    // MARK: - Public

    var tweets: [[Twitter.Tweet]] = []
        {
        didSet {
            images = tweets.flatMap{$0}
                .map{ tweet in
                    tweet.media.map{ TweetMedia(tweet: tweet, media: $0) }
                }.flatMap{$0}
        }
    }

    var scale: CGFloat = 1 {
        didSet {
            collectionView?.collectionViewLayout.invalidateLayout()
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupButtons()

        collectionView?.addGestureRecognizer(UIPinchGestureRecognizer(target: self,
                                                                      action: #selector(zoom)))
        installsStandardGestureForInteractiveMovement = true
    }

    // MARK: - Constants

    fileprivate struct LayoutConstants {
        static let minImageCellWidth: CGFloat = 60
        static let itemsPerRow: CGFloat = 3
        static let minimumLineSpacing: CGFloat = 2
        static let minimumInteritemSpacing: CGFloat = 2
        static let sectionInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)

        static let columnCountWaterfall = 3
        static let maxColumnCountWaterfall = 8
        static let minColumnCountWaterfall = 1
    }

    private struct Constants {
        static let cellId = "CollectionCell"
        static let showTweetSegue = "ShowTweets"
    }

    // MARK: - Private

    fileprivate var images = [TweetMedia]()
    private let layoutFlow = UICollectionViewFlowLayout()
    private let layoutWaterfall = CHTCollectionViewWaterfallLayout()

    private lazy var toRootVCButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop,
                                                                       target: self,
                                                                       action: #selector(toRootViewController))
    private var predefinedWidth: CGFloat {
        return floor((collectionView!.bounds.width - LayoutConstants.minimumInteritemSpacing * (LayoutConstants.itemsPerRow - 1.0) -
        LayoutConstants.sectionInsets.right - LayoutConstants.sectionInsets.left) / LayoutConstants.itemsPerRow)
    }

    fileprivate var sizePredefined: CGSize { return CGSize(width: predefinedWidth, height: predefinedWidth) }

    @objc private func toRootViewController() {
        _ = navigationController?.popToRootViewController(animated: true)
    }

    private func setupLayout() {
        layoutWaterfall.columnCount = LayoutConstants.columnCountWaterfall
        layoutWaterfall.minimumColumnSpacing = LayoutConstants.minimumLineSpacing
        layoutWaterfall.minimumInteritemSpacing = LayoutConstants.minimumInteritemSpacing

        layoutFlow.minimumInteritemSpacing = LayoutConstants.minimumInteritemSpacing
        layoutFlow.minimumLineSpacing = LayoutConstants.minimumLineSpacing
        layoutFlow.sectionInset = LayoutConstants.sectionInsets
        layoutFlow.itemSize = sizePredefined

        collectionView?.collectionViewLayout = layoutWaterfall
    }

    private func setupButtons() {
        if navigationItem.rightBarButtonItems == nil {
            navigationItem.setRightBarButton(toRootVCButton, animated: true)
        }
    }

    @objc private func zoom(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .changed {
            scale *= gesture.scale
            gesture.scale = 1
        }
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier,
            id == Constants.showTweetSegue,
            let cell = sender as? TweetCollectionViewCell,
            let media = cell.tweetMedia,
            let dvc = segue.destination as? TweetTableViewController {
            dvc.newTweets = [media.tweet]
            dvc.title = "Tweet by \(media.tweet.user.screenName)"
        }
    }


    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellId,
                                                      for: indexPath)
        if let cell = cell as? TweetCollectionViewCell {
            cell.tweetMedia = images[indexPath.row]
        }

        return cell
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let ratio = CGFloat(images[indexPath.row].media.aspectRatio)
        let predefinedSize = sizePredefined

        if let layoutFlow = collectionViewLayout as? UICollectionViewFlowLayout {
            let maxCellWidth = collectionView.bounds.size.width - layoutFlow.minimumInteritemSpacing * (LayoutConstants.itemsPerRow - 1) -
                layoutFlow.sectionInset.right - layoutFlow.sectionInset.left
            let defaultSize = layoutFlow.itemSize

            let scaledCellSize = CGSize(width: defaultSize.width * scale, height: defaultSize.height * scale)
            let cellWidth = min(max(scaledCellSize.width,
                                    LayoutConstants.minImageCellWidth), maxCellWidth)

            return CGSize(width: cellWidth, height: cellWidth / ratio)

        }
        return CGSize(width: predefinedSize.width * scale, height: predefinedSize.height * scale)
    }

    override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        swap(&images[destinationIndexPath.row], &images[sourceIndexPath.row])
        collectionView.collectionViewLayout.invalidateLayout()
    }
}


extension TweetCollectionViewController: CHTCollectionViewDelegateWaterfallLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtCHT indexPath: IndexPath) -> CGSize {

        adjustWaterfallColumnCount(collectionView)
        let ratio = CGFloat(images[indexPath.row].media.aspectRatio)
        let predefinedSize = sizePredefined
        var maxCellWidth = collectionView.bounds.size.width

        if let layout = collectionViewLayout as? CHTCollectionViewWaterfallLayout {
            maxCellWidth = maxCellWidth - layout.minimumInteritemSpacing * (LayoutConstants.itemsPerRow - 1) -
                layout.sectionInset.left - layout.sectionInset.right
        }

        let scaledSize = CGSize(width: predefinedSize.width * scale, height: predefinedSize.height * scale)
        let cellWidth = min(max(scaledSize.width, LayoutConstants.minImageCellWidth), maxCellWidth)
        return CGSize(width: cellWidth, height: cellWidth / ratio)
    }

    private func adjustWaterfallColumnCount(_ collectionView: UICollectionView) {
        if let waterfallLayout = collectionView.collectionViewLayout as? CHTCollectionViewWaterfallLayout {
            let newColumnNumber = Int(CGFloat(LayoutConstants.columnCountWaterfall) / scale)
            waterfallLayout.columnCount = min(max(newColumnNumber, LayoutConstants.minColumnCountWaterfall),
                                                LayoutConstants.maxColumnCountWaterfall)
        }
    }
}
