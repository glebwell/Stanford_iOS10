//
//  ImageTableViewCell.swift
//  Smashtag
//
//  Created by Gleb on 04.06.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    @IBOutlet weak var tweetImage: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!

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
                        self?.tweetImage?.image = UIImage(data: imageData)
                        self?.spinner?.stopAnimating()
                    }
                }
            }
        }
    }
    
}
