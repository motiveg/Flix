//
//  DetailViewController.swift
//  Flix
//
//  Created by Brian Casipit on 9/6/18.
//  Copyright © 2018 Brian Casipit. All rights reserved.
//

import UIKit
//import DeviceKit

// TODO:
// - double check constraints in horizontal orientation
// - change needed size and constraints when switching orientation
// - increase font size depending on display
// - beautify

class DetailViewController: UIViewController {
    
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var backDropImageView: UIImageView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var overviewTextView: UITextView!
    
    
    @IBOutlet weak var backDropImageTopConstraint: NSLayoutConstraint!
    
    // FIXME: find a cleaner solution for backdrop bottom border;
    // copied extension for other borders did not produce expected results
    @IBOutlet weak var viewBehindBackDropBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewBehindBackDropHeightConstraint: NSLayoutConstraint!
    
    
    var movie: Movie?
    
    // CONSTANT VALUES //
    let ACCENTCOLOR = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    let BORDERWIDTH = CGFloat(0.3)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // SET OUTLETS //
        if let movie = movie {
            titleLabel.text = movie.title
            releaseDateLabel.text = movie.releaseDate
            overviewTextView.text = movie.overview as String
            
            if movie.posterURL != nil {
                posterImageView.af_setImage(withURL: movie.posterURL!)
            }
            
            if movie.backdropURL != nil {
                backDropImageView.af_setImage(withURL: movie.backdropURL!)
            }
        }
        
        // BACKDROP IMAGE VIEW //
        let navHeight = self.navigationController?.navigationBar.frame.height ?? 0.0
        backDropImageTopConstraint.constant = backDropImageTopConstraint.constant + navHeight
        self.backDropImageView.layer.masksToBounds = true
        
        // VIEW BEHIND BACKDROP IMAGE VIEW //
        // FIXME: find a cleaner solution for backdrop bottom border;
        // copied extension for other borders did not produce expected results
        self.viewBehindBackDropHeightConstraint.constant = self.viewBehindBackDropHeightConstraint.constant + 0.3
        self.viewBehindBackDropBottomConstraint.constant = self.viewBehindBackDropBottomConstraint.constant - 0.3
        
        // POSTER IMAGE VIEW //
        self.posterImageView.layer.cornerRadius = 3.0
        self.posterImageView.layer.masksToBounds = true
        self.posterImageView.layer.borderWidth = self.BORDERWIDTH
        self.posterImageView.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        // OVERVIEW TEXT VIEW //
        self.overviewTextView.layer.cornerRadius = 3.0
        self.overviewTextView.layer.masksToBounds = true
    }
    
    // Temporary solutions to start text view at top
    
    // SOLUTION 1 //
    // - scrolls text view up when view appears
    //override func viewDidAppear(_ animated: Bool) {
    //    self.overviewTextView.setContentOffset(CGPoint.zero, animated: true)
    //}
    
    // SOLUTION 2 //
    // - starts text view at top but text doesn't fully load
    override func viewWillAppear(_ animated: Bool) {
        self.overviewTextView.isScrollEnabled = false
    }
    override func viewDidAppear(_ animated: Bool) {
        self.overviewTextView.isScrollEnabled = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! TrailerViewController
        vc.movieId = self.movie?.id
        vc.titleQuery = self.movie?.titleQuery
    }
    
}
