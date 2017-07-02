//
//  TweetCollectionViewCell.swift
//  Smashtag
//
//  Created by Admin on 26.06.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class TweetCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var tweetImageView: UIImageView!

    var cache: Cache?

    var tweetMedia: TweetMedia? {
        didSet {
            updateUI()
        }
    }

    private func updateUI() {
        tweetImageView?.image = nil
        if let url = tweetMedia?.media.url {
            spinner?.startAnimating()

            if let imageData = cache?[url] {
                tweetImageView?.image = UIImage(data: imageData)
                spinner?.stopAnimating()
                return
            }

            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                if let imageData = try? Data(contentsOf: url), url == self?.tweetMedia?.media.url {
                    DispatchQueue.main.async {
                        self?.tweetImageView?.image = UIImage(data: imageData)
                        self?.cache?[url] = imageData
                        self?.spinner?.stopAnimating()
                    }
                }
            }
        }
    }
}
