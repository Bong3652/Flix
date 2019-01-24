//
//  MovieGridViewController.swift
//  Flix
//
//  Created by APPLE on 1/10/19.
//  Copyright © 2019 Bong. All rights reserved.
//

import UIKit
import Alamofire

class MovieGridViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    

    @IBOutlet weak var movieCollectionView: UICollectionView!
    var movies = [[String:Any]]()
    override func viewDidLoad() {
        super.viewDidLoad()

        let layout = movieCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4
        let width = (view.frame.size.width - layout.minimumInteritemSpacing * 2) / 3
        layout.itemSize = CGSize(width: width, height: width * 1.5)
        
        movieCollectionView.dataSource = self
        movieCollectionView.delegate = self
        // Do any additional setup after loading the view.
        let url = URL(string: "https://api.themoviedb.org/3/movie/297762/similar?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
            // This will run when the network request returns
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                
                // TODO: Get the array of movies
                // TODO: Store the movies in a property to use elsewhere
                // TODO: Reload your table view data
                self.movies = dataDictionary["results"] as! [[String:Any]]
                self.movieCollectionView.reloadData()
                
            }
        }
        task.resume()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = movieCollectionView.dequeueReusableCell(withReuseIdentifier: "MovieGridCell", for: indexPath) as! MovieGridCollectionViewCell
        let movie = movies[indexPath.item]
        
        let baseUrl = "https://image.tmdb.org/t/p/w185"
        let posterPath = movie["poster_path"] as! String
        let posterUrl = URL(string: baseUrl + posterPath)
        
        cell.posterImage.af_setImage(withURL: posterUrl!)
        return cell
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let cell = sender as! UICollectionViewCell
        let indexPath = movieCollectionView.indexPath(for: cell)!
        let movie = movies[indexPath.item]
        
        let detailsViewController = segue.destination as! MoviesDetailViewController
        detailsViewController.movie = movie
        movieCollectionView.deselectItem(at: indexPath, animated: true)
    }

}
