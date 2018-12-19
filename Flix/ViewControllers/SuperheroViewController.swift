//
//  SuperheroViewController.swift
//  Flix
//
//  Created by Brian Casipit on 9/8/18.
//  Copyright © 2018 Brian Casipit. All rights reserved.
//

import UIKit
import PKHUD

// TODO:
// - double check constraints in horizontal orientation
// - change needed size and constraints when switching orientation
// - allow user to select genre

class SuperheroViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var movies: [Movie] = []
    var refreshControl: UIRefreshControl!
    
    // CONSTANT VALUES //
    let ACCENTCOLOR = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    let BORDERWIDTH = CGFloat(0.3)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // REFRESH CONTROL //
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(SuperheroViewController.didPullToRefresh(_:)), for: .valueChanged)
        self.refreshControl.tintColor = self.ACCENTCOLOR
        collectionView.insertSubview(refreshControl, at: 0)
        
        // COLLECTION VIEW //
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // NAVIGATION BAR //
        self.navigationController?.navigationBar.addBottomBorder(
            borderColor: self.ACCENTCOLOR,
            borderWidth: self.BORDERWIDTH,
            navHeight: self.navigationController?.navigationBar.frame.height ?? 0.0
        )
        
        self.fetchMovies()
    }
    
    func fetchMovies() {
        HUD.show(.progress)
        MovieApiManager().superheroMovies { (movies: [Movie]?, error: Error?) in
            if let movies = movies {
                self.movies = movies
                self.collectionView.reloadData()
                HUD.flash(.success, delay: 0.35)
            } else {
                self.refreshControl.endRefreshing()
                HUD.hide()
                
                // Pop up alert upon (network) error
                // Source: https://www.ioscreator.com/tutorials/display-alert-ios-tutorial-ios10
                let alertController = UIAlertController(title: "Error", message:
                    error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
    }
    
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.fetchMovies()
            self.refreshControl.endRefreshing()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UICollectionViewCell
        if let indexPath = collectionView.indexPath(for: cell) {
            let movie = movies[indexPath.row]
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.movie = movie
        }
    }
    
}

extension SuperheroViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath) as! PosterCell
        let movie = movies[indexPath.item]
        
        if movie.posterURL != nil {
            cell.posterImageView.af_setImage(withURL: movie.posterURL!)
        }
        return cell
    }
}

extension SuperheroViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.width / 2.0) - 1.0
        let height = width * 1.5
        return CGSize(width: width, height: height)
    }
}
