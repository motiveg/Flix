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

// TODO:
// - double check constraints in horizontal orientation
// - change needed size and constraints when switching orientation
// - increase font size depending on display
// - add sorting and filtering

class NowPlayingViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var unfilteredMovies: [Movie] = []
    var displayedMovies: [Movie] = []
    var refreshControl: UIRefreshControl!
    
    // CONSTANT VALUES //
    let ACCENTCOLOR = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    let BORDERWIDTH = CGFloat(0.3)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // TABLE VIEW //
        // remove any empty cells in table view
        self.tableView.tableFooterView = UIView(frame: .zero)
        // trick to remove last separator in last cell
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 1))
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 50
        self.tableView.separatorColor = self.ACCENTCOLOR
        self.tableView.dataSource = self
        
        // REFRESH CONTROL //
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(NowPlayingViewController.didPullToRefresh(_:)), for: .valueChanged)
        self.refreshControl.tintColor = self.ACCENTCOLOR
        self.tableView.insertSubview(refreshControl, at: 0)
        
        // NAVIGATION BAR //
        self.navigationController?.navigationBar.addBottomBorder(
            borderColor: self.ACCENTCOLOR,
            borderWidth: self.BORDERWIDTH,
            navHeight: self.navigationController?.navigationBar.frame.height ?? 0.0
        )
        
        // SEARCH BAR //
        self.searchBar.addTopBorder(
            borderColor: self.ACCENTCOLOR,
            borderWidth: self.BORDERWIDTH,
            viewWidth: self.view.frame.width
        )
        self.searchBar.addBottomBorder(
            borderColor: self.ACCENTCOLOR,
            borderWidth: self.BORDERWIDTH,
            viewWidth: self.view.frame.width,
            searchBarHeight: self.searchBar.frame.height
        )
        
        // TAB NAVIGATION //
        // only needed in one view controller
        self.tabBarController?.tabBar.addTopBorder(
            borderColor: self.ACCENTCOLOR,
            borderWidth: self.BORDERWIDTH
        )
        
        self.fetchMovies()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let index = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: index, animated: true)
        }
    }
    
    func fetchMovies() {
        HUD.show(.progress)
        MovieApiManager().nowPlayingMovies { (movies: [Movie]?, error: Error?) in
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
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

extension NowPlayingViewController: UISearchBarDelegate {}

extension NowPlayingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.displayedMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let backgroundView = UIView()
        backgroundView.backgroundColor = #colorLiteral(red: 0.07843137255, green: 0.4666666667, blue: 0.9294117647, alpha: 1)
        cell.selectedBackgroundView = backgroundView
        let movie = self.displayedMovies[indexPath.row]
        cell.movie = movie
        return cell
    }
}

extension NowPlayingViewController {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let filteredMovies = Movie.filterMovies(searchString: self.searchBar.text!, movies: self.unfilteredMovies)
        self.displayedMovies = filteredMovies
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.text = ""
        self.view.endEditing(true)
        self.displayedMovies = self.unfilteredMovies
        self.tableView.reloadData()
    }
}

extension UINavigationBar {
    func addBottomBorder(borderColor: UIColor, borderWidth: CGFloat, navHeight: CGFloat) {
        let border = CALayer()
        border.backgroundColor = borderColor.cgColor
        let navHeight = Double(navHeight)
        let borderWidth = Double(borderWidth)
        let width = Double(self.frame.width)
        border.frame = CGRect(
            x: 0.0,
            y: navHeight,
            width: width,
            height: borderWidth
        )
        self.layer.addSublayer(border)
    }
}

extension UISearchBar {
    func addTopBorder(borderColor: UIColor, borderWidth: CGFloat, viewWidth: CGFloat) {
        let border = CALayer()
        border.backgroundColor = borderColor.cgColor
        let borderWidth = Double(borderWidth)
        let viewWidth = Double(viewWidth)
        border.frame = CGRect(
            x: 0.0,
            y: 0.0,
            width: viewWidth,
            height: borderWidth
        )
        self.layer.addSublayer(border)
    }
    
    func addBottomBorder(borderColor: UIColor, borderWidth: CGFloat, viewWidth: CGFloat, searchBarHeight: CGFloat) {
        let border = CALayer()
        border.backgroundColor = borderColor.cgColor
        let searchBarHeight = Double(searchBarHeight)
        let borderWidth = Double(borderWidth)
        let viewWidth = Double(viewWidth)
        border.frame = CGRect(
            x: 0.0,
            y: searchBarHeight,
            width: viewWidth,
            height: borderWidth
        )
        self.layer.addSublayer(border)
    }
}

extension UITabBar {
    func addTopBorder(borderColor: UIColor, borderWidth: CGFloat) {
        let border = CALayer()
        border.backgroundColor = borderColor.cgColor
        let borderWidth = Double(borderWidth)
        let width = Double(self.frame.width)
        border.frame = CGRect(
            x: 0.0,
            y: 0.0,
            width: width,
            height: borderWidth
        )
        self.layer.addSublayer(border)
    }
}
