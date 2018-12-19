//
//  MovieApiManager.swift
//  Flix
//
//  Created by Brian Casipit on 9/30/18.
//  Copyright © 2018 Brian Casipit. All rights reserved.
//

import Foundation

class MovieApiManager {
    
    static let baseUrl = "https://api.themoviedb.org/3/movie/"
    var session: URLSession
    
    static let partialNowPlaying = "now_playing?api_key="
    static let partialSuperhero = "363088/similar?api_key=" // using Wonderwoman
    static let partialPopular = "popular?api_key="
    static let partialVideos = "/videos?api_key=" // prefix movie id to this
    
    init() {
        session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
    }
    
    func nowPlayingMovies(completion: @escaping ([Movie]?, Error?) -> ()) {
        let url = URL(string: MovieApiManager.baseUrl + MovieApiManager.partialNowPlaying + MovieApiKeys.APIKEY)!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let task = session.dataTask(with: request) { (data, response, error) in
            // This will run when the network request returns
            if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let movieDictionaries = dataDictionary["results"] as! [[String: Any]]
                
                let movies = Movie.movies(dictionaries: movieDictionaries)
                completion(movies, nil)
            } else {
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    func superheroMovies(completion: @escaping ([Movie]?, Error?) -> ()) {
        let url = URL(string: MovieApiManager.baseUrl + MovieApiManager.partialSuperhero + MovieApiKeys.APIKEY)!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let task = session.dataTask(with: request) { (data, response, error) in
            // This will run when the network request returns
            if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let movieDictionaries = dataDictionary["results"] as! [[String: Any]]

                let movies = Movie.movies(dictionaries: movieDictionaries)
                completion(movies, nil)
            } else {
                completion(nil, error)
            }
        }
        task.resume()
    }

    func popularMovies(completion: @escaping ([Movie]?, Error?) -> ()) {
        let url = URL(string: MovieApiManager.baseUrl + MovieApiManager.partialPopular + MovieApiKeys.APIKEY)!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let task = session.dataTask(with: request) { (data, response, error) in
            // This will run when the network request returns
            if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let movieDictionaries = dataDictionary["results"] as! [[String: Any]]

                let movies = Movie.movies(dictionaries: movieDictionaries)
                completion(movies, nil)
            } else {
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    func videoTrailer(movieId: Int, completion: @escaping (URL?, Error?) -> ()) {
        let idString = String(movieId)
        let url = URL(string: MovieApiManager.baseUrl + idString + MovieApiManager.partialVideos + MovieApiKeys.APIKEY)!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let results = dataDictionary["results"] as! [[String: Any]]
                let firstVideoDictionary = results[0]
                let videoKey = firstVideoDictionary["key"] as! String
                let youtubeBase = "https://www.youtube.com/watch?v="
                let videoURL = URL(string: youtubeBase + videoKey)
                
                completion(videoURL, nil)
            } else {
                completion(nil, error)
            }
        }
        task.resume()
    }
    
}
