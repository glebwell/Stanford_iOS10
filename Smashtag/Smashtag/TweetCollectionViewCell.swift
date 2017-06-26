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

    var imageUrl: URL? {
        didSet {
            updateUI()
        }

    }

    private func updateUI() {
        if let url = imageUrl {
            spinner?.startAnimating()

            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                if let imageData = try? Data(contentsOf: url), url == self?.imageUrl {
                    DispatchQueue.main.async {
                        self?.tweetImageView?.image = UIImage(data: imageData)
                        self?.spinner?.stopAnimating()
                    }
                }
            }
        }
    }
}
