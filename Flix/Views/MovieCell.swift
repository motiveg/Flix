//
//  MovieCell.swift
//  Flix
//
//  Created by Brian Casipit on 9/4/18.
//  Copyright © 2018 Brian Casipit. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    var movie: Movie! {
        willSet(newMovie) {
            titleLabel.text = newMovie.title
            overviewLabel.text = newMovie.overview
            
            if newMovie.posterURL != nil {
                posterImageView.af_setImage(withURL: newMovie.posterURL!)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.posterImageView.layer.cornerRadius = 3.0
        self.posterImageView.layer.masksToBounds = true
        self.posterImageView.layer.borderWidth = 0.3
        self.posterImageView.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
