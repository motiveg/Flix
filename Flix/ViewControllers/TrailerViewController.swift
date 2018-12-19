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

class TrailerViewController: UIViewController {
    
    var wkconfig = WKWebViewConfiguration()
    var movieId: Int?
    
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
        MovieApiManager().videoTrailer(movieId: movieId) { (url: URL?, error: Error?) in
            HUD.show(.progress)
            if let url = url {
                self.setUpWebView(trailerURL: url)
                HUD.flash(.success, delay: 0.35)
            }
            else {
                print("Error fetching trailer url: \(error.debugDescription)")
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
        
        view.addSubview(trailerView)
        let youtubeRequest = URLRequest(url: trailerURL)
        trailerView.load(youtubeRequest)
    }

}
