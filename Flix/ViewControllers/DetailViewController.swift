//
//  DetailViewController.swift
//  Flix
//
//  Created by Brian Casipit on 9/6/18.
//  Copyright © 2018 Brian Casipit. All rights reserved.
//

import UIKit

// TODO:
// - increase font size depending on display
// - use text field for description in case of long descriptions
// - beautify

class DetailViewController: UIViewController {
    
    @IBOutlet weak var backDropImageView: UIImageView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    var movie: Movie?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let movie = movie {
            titleLabel.text = movie.title
            releaseDateLabel.text = movie.releaseDate
            overviewLabel.text = movie.overview as String
            
            if movie.posterURL != nil {
                posterImageView.af_setImage(withURL: movie.posterURL!)
            }
            
            if movie.backdropURL != nil {
                backDropImageView.af_setImage(withURL: movie.backdropURL!)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! TrailerViewController
        vc.movieId = self.movie?.id
    }
    
}
