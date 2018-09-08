//
//  NowPlayingViewController.swift
//  Flix
//
//  Created by Brian Casipit on 9/4/18.
//  Copyright © 2018 Brian Casipit. All rights reserved.
//

import UIKit
import AlamofireImage
import PKHUD

class NowPlayingViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var movies: [[String: Any]] = []
    var filteredMovies: [[String: Any]] = []
    var refreshControl: UIRefreshControl!
    var searching = false
    
    
    @IBAction func hideKeyboard(_ sender: Any) {
        //        if (searchBar.isFirstResponder) {
        searchBar.endEditing(true)
        //        } else {
        //            view.endEditing(true)
        //        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(NowPlayingViewController.didPullToRefresh(_:)), for: .valueChanged)
        
        tableView.insertSubview(refreshControl, at: 0)
        tableView.dataSource = self
        
        fetchMovies()
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        searchBar.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        if let indexPath = tableView.indexPath(for: cell) {
            let movie = movies[indexPath.row]
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.movie = movie
        }
    }
    
    func fetchMovies() {
        
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=a6b37c5a69c374b9b6b793763d8f959b")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
            // This will run when the network request returns
            if let error = error {
                self.refreshControl.endRefreshing()
                HUD.hide()
                
                // Pop up alert upon (network) error
                // Source: https://www.ioscreator.com/tutorials/display-alert-ios-tutorial-ios10
                let alertController = UIAlertController(title: "Error", message:
                    error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                self.present(alertController, animated: true, completion: nil)
                
                print(error.localizedDescription)
                
            } else if let data = data {
                
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                
                print (dataDictionary)
                
                let movies = dataDictionary["results"] as! [[String: Any]]
                self.movies = movies
                
                self.tableView.reloadData()
                HUD.flash(.success, delay: 0.35)
            }
        }
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (searching && !filteredMovies.isEmpty) {
            print(filteredMovies.count)
            return filteredMovies.count
        } else {
            print(movies.count)
            return movies.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        var movie = [String: Any]()
        
        if (searching && !filteredMovies.isEmpty) {
            movie = filteredMovies[indexPath.row]
        } else {
            movie = movies[indexPath.row]
        }
        
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        // use a default image before trying to get the poster image
        let defaultImageString = "https://raw.githubusercontent.com/motiveg/Flix/master/ImageNotLoaded.png"
        let defaultImageURL = URL(string: defaultImageString)!
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.posterImageView.af_setImage(withURL: defaultImageURL)
        
        let posterPathString = movie["poster_path"] as! String
        
        // use low quality, 92px, size poster first
        let baseLQURLString = "https://image.tmdb.org/t/p/w92"
        let posterLQURL = URL(string: baseLQURLString)!
        cell.posterImageView.af_setImage(withURL: posterLQURL)
        
        // use 500px after
        let baseURLString = "https://image.tmdb.org/t/p/w500"
        let posterURL = URL(string: baseURLString + posterPathString)!
        cell.posterImageView.af_setImage(withURL: posterURL)
        
        return cell
    }
    
    //    @IBAction func onTap(_ sender: Any) {
    //        if (searchBar.isFirstResponder) {
    //            view.endEditing(true)
    //        }
    //    }
    
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl) {
        HUD.show(.progress)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.fetchMovies()
            self.refreshControl.endRefreshing()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if (searchBar.text != "") {
            if !(filteredMovies.isEmpty) {
                filteredMovies.removeAll()
            }
            for movie in movies {
                let title = movie["title"] as! String
                let searchText: String = searchBar.text!
                if (title.lowercased().contains(searchText.lowercased())) {
                    filteredMovies.append(movie)
                }
            }
            searching = true
        } else {
            searching = false
        }
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searching = false
        filteredMovies.removeAll()
        view.endEditing(true)
        self.tableView.reloadData()
    }
    
}

