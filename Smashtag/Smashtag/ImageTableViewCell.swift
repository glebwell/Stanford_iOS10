//
//  ImageTableViewCell.swift
//  Smashtag
//
//  Created by Gleb on 04.06.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    func setContent(_ image: UIImage) {
        imageView?.image = image
    }
}
