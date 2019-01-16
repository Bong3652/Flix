//
//  MoviesViewController.swift
//  Flix
//
//  Created by APPLE on 1/8/19.
//  Copyright © 2019 Bong. All rights reserved.
//

import UIKit
import AlamofireImage

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var movies = [[String:Any]]()
    var searchedMovies = [[String:Any]]()
    
    @IBOutlet weak var moviesTableView: UITableView!
    @IBOutlet weak var movieSearchBar: UISearchBar!
    
    var isMoreDataLoading = false
    var loadingMoreView:movieUIActivityIndicatorView?
    
    let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")!
    lazy var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pinch = UIPinchGestureRecognizer(target: moviesTableView, action: #selector(didPinch))
        moviesTableView.isUserInteractionEnabled = true
        moviesTableView.addGestureRecognizer(pinch)
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: moviesTableView.contentSize.height, width: moviesTableView.bounds.size.width, height: movieUIActivityIndicatorView.defaultHeight)
        loadingMoreView = movieUIActivityIndicatorView(frame: frame)
        loadingMoreView!.isHidden = true
        moviesTableView.addSubview(loadingMoreView!)
        
        var insets = moviesTableView.contentInset
        insets.bottom += movieUIActivityIndicatorView.defaultHeight
        moviesTableView.contentInset = insets
        
        //refresh
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControl.Event.valueChanged)
        // add refresh control to table view
        moviesTableView.insertSubview(refreshControl, at: 0)
        
        moviesTableView.dataSource = self
        moviesTableView.delegate = self
        movieSearchBar.delegate = self

        // Do any additional setup after loading the view.
//        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")!
//        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
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
                self.moviesTableView.reloadData()
                
            }
        }
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searchedMovies.count != 0) {
            return searchedMovies.count
        } else {
            return movies.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = moviesTableView.dequeueReusableCell(withIdentifier: "MovieCell") as! MovieTableViewCell
        let movie: [String:Any]
        if (searchedMovies.count == 0) {
            movie = movies[indexPath.row]
        } else {
            movie = searchedMovies[indexPath.row]
        }
        let title = movie["title"] as! String
        let synap = movie["overview"] as! String
        
        let baseUrl = "https://image.tmdb.org/t/p/w185"
        let posterPath = movie["poster_path"] as! String
        let posterUrl = URL(string: baseUrl + posterPath)
        
        cell.posterImage.af_setImage(withURL: posterUrl!)
        cell.titleLabel.text = title
        cell.synopsisLabel.text = synap
        return cell
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    @objc func refreshControlAction(_ refreshControl: UIRefreshControl) {
        
        // ... Create the URLRequest `myRequest` ...
        
        // Configure session so that completion handler is executed on main UI thread
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
//        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")!
//        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            // ... Use the new data to update the data source ...
            
            // Reload the tableView now that there is new data
            self.moviesTableView.reloadData()
            
            // Tell the refreshControl to stop spinning
            refreshControl.endRefreshing()
        }
        task.resume()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = moviesTableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - moviesTableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && moviesTableView.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: moviesTableView.contentSize.height, width: moviesTableView.bounds.size.width, height: movieUIActivityIndicatorView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // Code to load more results
                loadMoreData()
            }
        }
    }
    
    func loadMoreData() {
        
        // ... Create the NSURLRequest (myRequest) ...
        // Configure session so that completion handler is executed on main UI thread
        let session = URLSession(configuration: URLSessionConfiguration.default,
                                 delegate:nil,
                                 delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            // Update flag
            self.isMoreDataLoading = false
            
            // Stop the loading indicator
            self.loadingMoreView!.stopAnimating()
            
            // ... Use the new data to update the data source ...
            
            // Reload the tableView now that there is new data
            self.moviesTableView.reloadData()
        })
        task.resume()
        
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let cell = sender as! UITableViewCell
        let indexPath = moviesTableView.indexPath(for: cell)!
        let movie = movies[indexPath.row]
        
        let detailsViewController = segue.destination as! MoviesDetailViewController
        detailsViewController.movie = movie
        moviesTableView.deselectRow(at: indexPath, animated: true)
    }
    @IBAction func didPinch(_ sender: UIPinchGestureRecognizer) {
        let scale = sender.scale
        sender.view?.transform = (sender.view?.transform.scaledBy(x: scale, y: scale))!
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText != "") {
        searchedMovies = movies.filter({($0["title"] as! String).prefix(searchText.count) == searchText})
        } else {
            searchBarCancelButtonClicked(movieSearchBar)
        }
        moviesTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchedMovies.removeAll()
        moviesTableView.reloadData()
    }
    
}
