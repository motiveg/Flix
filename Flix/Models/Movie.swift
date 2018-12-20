//
//  Movie.swift
//  Flix
//
//  Created by Brian Casipit on 9/27/18.
//  Copyright © 2018 Brian Casipit. All rights reserved.
//

import Foundation

class Movie {
    
    var id: Int
    var title: String?
    var titleQuery: URL?
    var releaseDate: String?
    var overview: String
    var posterURL: URL?
    var backdropURL: URL?
    
    init(dictionary: [String: Any]) {
        
        id = dictionary["id"] as? Int ?? -1
        title = dictionary["title"] as? String ?? "No title"
        let youtubeBase = "https://www.youtube.com"
        if title != "No title" {
            let searchQuery = "/results?search_query="
            let movieTitle = title?.replacingOccurrences(of: " ", with: "+")
            titleQuery = URL(string: youtubeBase + searchQuery + movieTitle! + "+trailer")
        } else {
            titleQuery = URL(string: youtubeBase)
        }
        
        // Format date string
        let getFormatter = DateFormatter()
        let formatter = DateFormatter()
        
        // Configure the input + output format to parse the date string
        getFormatter.dateFormat = "yyyy-MM-dd"
        formatter.dateFormat = "MM/dd/yyyy"
        
        // Configure output format
        formatter.dateStyle = .long
        
        releaseDate = "No release date"
        if let releaseDateString = dictionary["release_date"] as? String {
            if let date = getFormatter.date(from: releaseDateString) {
                releaseDate = formatter.string(from: date)
            }
        }
        
        overview = dictionary["overview"] as? String ?? "No Overview"
        
        // base poster URLs
        let defaultImageString = "https://raw.githubusercontent.com/motiveg/Flix/master/ImageNotLoaded.png"
        let baseLQURLString = "https://image.tmdb.org/t/p/w92"
        let baseURLString = "https://image.tmdb.org/t/p/w500"
        
        // use a default image before trying to get the poster image
        posterURL = URL(string: defaultImageString)!
        
        // use low quality, 92px, size poster first
        posterURL = URL(string: baseLQURLString)!
        
        let posterPath = dictionary["poster_path"] as? String
        if let posterPath = posterPath {
            let fullPosterPath = baseURLString + posterPath
            posterURL = URL(string: fullPosterPath)
        }
        
        let backdropPath = dictionary["backdrop_path"] as? String
        if let backdropPath = backdropPath {
            let fullBackdropPath = baseURLString + backdropPath
            backdropURL = URL(string: fullBackdropPath)
        }
    }
    
    class func movies(dictionaries: [[String: Any]]) -> [Movie] {
        var movies: [Movie] = []
        for dictionary in dictionaries {
            let movie = Movie(dictionary: dictionary)
            movies.append(movie)
        }
        
        return movies
    }
    
    class func filterMovies(searchString: String, movies: [Movie]) -> [Movie] {
        var filteredMovies: [Movie] = []
        
        if searchString != "" {
            for movie in movies {
                let title = movie.title!
                if (title.lowercased().contains(searchString.lowercased())) {
                    filteredMovies.append(movie)
                }
            }
        } else {
            filteredMovies = movies
        }
        return filteredMovies
    }
    
}
