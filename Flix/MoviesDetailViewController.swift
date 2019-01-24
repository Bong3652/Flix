//
//  MoviesDetailViewController.swift
//  Flix
//
//  Created by APPLE on 1/10/19.
//  Copyright © 2019 Bong. All rights reserved.
//

import UIKit
import Alamofire

class MoviesDetailViewController: UIViewController {

    @IBOutlet weak var backdropImage: UIImageView!
    @IBOutlet weak var posterImage: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var synopsisLabel: UILabel!
    
    var movie: [String:Any]!
    var data = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let id = movie["id"]!
        
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(id)/videos?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")!
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
                self.data = dataDictionary["results"] as! [[String:Any]]
                
            }
        }
        task.resume()
        
        titleLabel.text = movie["title"] as? String
        titleLabel.sizeToFit()
        
        synopsisLabel.text = movie["overview"] as? String
        synopsisLabel.sizeToFit()
        
        let baseUrl = "https://image.tmdb.org/t/p/w185"
        let posterPath = movie["poster_path"] as! String
        let posterUrl = URL(string: baseUrl + posterPath)
        
        posterImage.af_setImage(withURL: posterUrl!)
        
        let backdropPath = movie["backdrop_path"] as! String
        let backdropUrl = URL(string: "https://image.tmdb.org/t/p/w780" + backdropPath)
        
        backdropImage.af_setImage(withURL: backdropUrl!)
        
        // Do any additional setup after loading the view.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        print("Ok")
        if (segue.identifier == "toTrailer") {
            let des = segue.destination as! TrailerUIViewController
            let one = data[0]
            let key = one["key"] as! String
            des.youtubeLink = "https://www.youtube.com/watch?v=\(key)"
            print(key)
        }
    }
    
    @IBAction func didTap(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "toTrailer", sender: self)
    }
    
}
