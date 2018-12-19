//
//  PopularViewController.swift
//  Flix
//
//  Created by Brian Casipit on 9/30/18.
//  Copyright © 2018 Brian Casipit. All rights reserved.
//

import UIKit
import AlamofireImage
import PKHUD

// TODO:
// - increase font size depending on display
// - add sorting and filtering

class PopularViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var displayedMovies: [Movie] = []
    var unfilteredMovies: [Movie] = []
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(PopularViewController.didPullToRefresh(_:)), for: .valueChanged)
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 50
        self.tableView.insertSubview(refreshControl, at: 0)
        self.tableView.dataSource = self
        
        self.searchBar.delegate = self
        
        self.fetchMovies()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let index = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: index, animated: true)
        }
    }
    
    func fetchMovies() {
        
        MovieApiManager().popularMovies { (movies: [Movie]?, error: Error?) in
            if let movies = movies {
                self.unfilteredMovies = movies
                
                // apply filters
                let filteredMovies = Movie.filterMovies(searchString: self.searchBar.text!, movies: self.unfilteredMovies)
                self.displayedMovies = filteredMovies
                
                self.tableView.reloadData()
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
        HUD.show(.progress)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.fetchMovies()
            self.refreshControl.endRefreshing()
        }
    }
    
    @IBAction func hideKeyboard(_ sender: Any) {
        self.searchBar.endEditing(true)
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.searchBar.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        if let indexPath = self.tableView.indexPath(for: cell) {
            let movie = self.displayedMovies[indexPath.row]
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.movie = movie
        }
    }
    
}

extension PopularViewController: UISearchBarDelegate {}

extension PopularViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.displayedMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = self.displayedMovies[indexPath.row]
        cell.movie = movie
        return cell
    }
}

extension PopularViewController {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let filteredMovies = Movie.filterMovies(searchString: self.searchBar.text!, movies: self.unfilteredMovies)
        self.displayedMovies = filteredMovies
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.text = ""
        self.displayedMovies = self.unfilteredMovies
        self.view.endEditing(true)
        self.tableView.reloadData()
    }
}
