//
//  TrailerViewController.swift
//  Flix
//
//  Created by Brian Casipit on 9/10/18.
//  Copyright © 2018 Brian Casipit. All rights reserved.
//

import UIKit
import WebKit
import PKHUD

// TODO:
// - allow webview to change size and constraints when switching orientation

class TrailerViewController: UIViewController {
    
    var wkconfig = WKWebViewConfiguration()
    var movieId: Int?
    var titleQuery: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadTrailerWithAnimation()
    }
    
    func loadTrailerWithAnimation() {
        HUD.show(.progress)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.fetchMovieTrailer()
        }
    }
    
    func fetchMovieTrailer() {
        guard let movieId = self.movieId else { return }
        MovieApiManager().videoTrailer(movieId: movieId, queryURL: titleQuery!) { (url: URL?, error: Error?) in
            HUD.show(.progress)
            if let url = url {
                if error != nil {
                    print("Error: \(error?.localizedDescription ?? "")")
                    self.setUpWebView(trailerURL: url)
                    HUD.hide()
                    
                    // Pop up alert upon (network) error
                    // Source: https://www.ioscreator.com/tutorials/display-alert-ios-tutorial-ios10
                    let alertController = UIAlertController(title: "Error", message:
                        error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
                else {
                    self.setUpWebView(trailerURL: url)
                    HUD.flash(.success, delay: 0.35)
                }
            }
            else {
                print("Error: \(error.debugDescription)")
                HUD.hide()
                
                // Pop up alert upon (network) error
                // Source: https://www.ioscreator.com/tutorials/display-alert-ios-tutorial-ios10
                let alertController = UIAlertController(title: "Error retrieving movie trailer", message:
                    error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func setUpWebView(trailerURL: URL) {
        
        wkconfig.allowsInlineMediaPlayback = true
        
        let topBarHeight = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        let bottomBarHeight = self.tabBarController?.tabBar.frame.height ?? 0.0
        
        let trailerView = WKWebView(frame:
            CGRect(
                x: 0.0,
                y: topBarHeight,
                width: self.view.frame.width,
                height: self.view.frame.height - topBarHeight - bottomBarHeight
            ),
        configuration: wkconfig
        )
        
        //let backgroundView = UIView()
        //backgroundView.backgroundColor = #colorLiteral(red: 0, green: 0.282794466, blue: 0.5, alpha: 1)
        trailerView.backgroundColor = #colorLiteral(red: 0, green: 0.282794466, blue: 0.5, alpha: 1)
        trailerView.isOpaque = false
        
        view.addSubview(trailerView)
        let youtubeRequest = URLRequest(url: trailerURL)
        trailerView.load(youtubeRequest)
    }

}
