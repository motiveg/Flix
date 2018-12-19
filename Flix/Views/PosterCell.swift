//
//  PosterCell.swift
//  Flix
//
//  Created by Brian Casipit on 9/8/18.
//  Copyright © 2018 Brian Casipit. All rights reserved.
//

import UIKit

class PosterCell: UICollectionViewCell {
    
    @IBOutlet weak var posterImageView: UIImageView!
    
    override func awakeFromNib() {
        self.posterImageView.layer.cornerRadius = 3.0
        self.posterImageView.layer.masksToBounds = true
        self.posterImageView.layer.borderWidth = 0.3
        self.posterImageView.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
}
