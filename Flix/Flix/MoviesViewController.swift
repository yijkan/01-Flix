//
//  MoviesViewController.swift
//  Flix
//
//  Created by Yijin Kang on 6/15/16.
//  Copyright © 2016 Yijin Kang. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var viewSelector: UISegmentedControl!
    
    @IBOutlet weak var moviesTable: UITableView!
    @IBOutlet weak var moviesCollection: UICollectionView!
    
    @IBOutlet weak var moviesSearchBar: UISearchBar!
    
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var detailsTitle: UILabel!
    @IBOutlet weak var detailsOverview: UILabel!
    
    
    var movies: [NSDictionary]? = []
    var filteredMovies: [NSDictionary]?

    func fadeErrorIn() {
//        if self.networkErrorView.hidden {
            self.networkErrorView.alpha = 0.0
            self.networkErrorView.hidden = false
            UIView.animateWithDuration(0.3, animations:{ () -> Void in
                self.networkErrorView.alpha = 0.75
            })
//        } else {
//            //already visible 
//            //TODO maybe blink once?
//        }
        
        // TODO decide later if I want to do anything about the error re-appearing
    }
    
    func fadeErrorOut() {
        // TODO doesn't seem to be animating
        if !self.networkErrorView.hidden {
            self.networkErrorView.alpha = 0.75
            UIView.animateWithDuration(0.3, animations:{ () -> Void in
                self.networkErrorView.alpha = 0.0
            })
            self.networkErrorView.hidden = true
        }
    }
    
    func sortMovies() {
        let sortBy = [ {(m1: NSDictionary, m2: NSDictionary) -> Bool in (m1["popularity"] as! Double) > (m2["popularity"] as! Double)}, // order by popularity
            {(m1: NSDictionary, m2: NSDictionary) -> Bool in (m1["title"] as! String) < (m2["title"] as! String)} // order by title
        ]
        self.movies = self.movies!.sort(sortBy[self.defaults.integerForKey("order_by")])
        self.filteredMovies = self.movies
        self.moviesTable.reloadData()
        self.moviesCollection.reloadData()
    }
    
    var refreshTableControl: UIRefreshControl!
    var refreshCollectionControl: UIRefreshControl!
    
    func loadMovies(useHUD:Bool) {
        let apiKey = "95dd50b36271bd60b6404e430282e991"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        if useHUD {MBProgressHUD.showHUDAddedTo(self.view, animated: true)}

        let task: NSURLSessionDataTask =
            session.dataTaskWithRequest(request, completionHandler: { (dataOrNil, response, error) in
                if useHUD {MBProgressHUD.hideHUDForView(self.view, animated: true)}
                if let data = dataOrNil {
                    self.fadeErrorOut()
                    
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                        self.movies = responseDictionary["results"] as! [NSDictionary]
                        self.sortMovies()
                    }
                    self.refreshTableControl.endRefreshing()
                    self.refreshCollectionControl.endRefreshing()
                } else {
                    self.refreshTableControl.endRefreshing()
                    self.refreshCollectionControl.endRefreshing()
                    self.fadeErrorIn()
                    self.movies = []
                    self.sortMovies()
                }
            }
        )
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshTableControl = UIRefreshControl()
        refreshTableControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        moviesTable.insertSubview(refreshTableControl, atIndex: 0)
        
        refreshCollectionControl = UIRefreshControl()
        refreshCollectionControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        moviesCollection.insertSubview(refreshCollectionControl, atIndex: 0)
        // make sure CollectionView bounces vertical!
        
        moviesTable.dataSource = self
        moviesTable.delegate = self
        
        moviesCollection.dataSource = self
        moviesCollection.delegate = self
        
        moviesSearchBar.delegate = self
        
        loadMovies(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        sortMovies()
    }
    
//    TODO um???
//    override func viewDidAppear(animated: Bool) {
//        navigationController?.hidesBarsOnSwipe = true
//    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        loadMovies(false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onTap(sender: AnyObject) {
        view.endEditing(true)
    }
    
    // UITableViewDataSource Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = filteredMovies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = moviesTable.dequeueReusableCellWithIdentifier("movieCell", forIndexPath: indexPath) as! MovieCell
        let movie = filteredMovies![indexPath.row]
        cell.movie = movie
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let baseURL = "http://image.tmdb.org/t/p/w342"
        let posterPath = movie["poster_path"] as! String
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        let imageRequest = NSURLRequest(URL: NSURL(string: baseURL + posterPath)!)
        cell.posterImageView.setImageWithURLRequest(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    if imageResponse != nil {
                        cell.posterImageView.alpha = 0.0
                        cell.posterImageView.image = image
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            cell.posterImageView.alpha = 1.0
                        })
                    } else {
                        cell.posterImageView.image = image
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    cell.posterImageView.image = nil
                }
        )
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let movies = filteredMovies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCollectionViewCell", forIndexPath: indexPath) as! MovieCollectionViewCell
        let movie = filteredMovies![indexPath.row]
        cell.movie = movie
        let baseURL = "http://image.tmdb.org/t/p/w342"
        let posterPath = movie["poster_path"] as! String
        let imageRequest = NSURLRequest(URL: NSURL(string: baseURL + posterPath)!)
        cell.posterImageView.setImageWithURLRequest(
            imageRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                if imageResponse != nil {
                    cell.posterImageView.alpha = 0.0
                    cell.posterImageView.image = image
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        cell.posterImageView.alpha = 1.0
                    })
                } else {
                    cell.posterImageView.image = image
                }
            },
            failure: { (imageRequest, imageResponse, error) -> Void in
                cell.posterImageView.image = nil
            }
        )
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("\(indexPath.row) selected")
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        let movie = filteredMovies![indexPath.row]
        detailsTitle.text = movie["title"] as! String
        detailsOverview.text = movie["overview"] as! String
        
        detailsView.alpha = 0.0
        UIView.animateWithDuration(0.3, animations:{ () -> Void in
            self.detailsView.alpha = 0.9
        })
    }
    
    @IBAction func closeDetails(sender: AnyObject) {
        detailsView.alpha = 0.9
        UIView.animateWithDuration(0.3, animations:{ () -> Void in
            self.detailsView.alpha = 0.0
        })
    }
    
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovies = searchText.isEmpty ? movies : movies!.filter({(movie: NSDictionary) -> Bool in
            let movieTitle = movie["title"] as! String
            return movieTitle.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil })
        moviesTable.reloadData()
    }

    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.moviesSearchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        moviesSearchBar.showsCancelButton = false
        moviesSearchBar.text = ""
        moviesSearchBar.resignFirstResponder()
        filteredMovies = movies
        moviesTable.reloadData()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        print("they see me scrollin, they hatin")
        view.endEditing(true)
    }
    
    @IBAction func viewChange(sender: AnyObject) {
        switch viewSelector.selectedSegmentIndex {
        case 0:
            moviesTable.hidden = false
            moviesCollection.hidden = true
        case 1:
            moviesTable.hidden = true
            moviesCollection.hidden = false
        default:
            moviesTable.hidden = false
            moviesCollection.hidden = true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("preparing for segue")
        if let cell = sender as? UITableViewCell {
            let indexPath = moviesTable.indexPathForCell(cell)
            let movie = filteredMovies![indexPath!.row]
            print(movie["title"])
            
            let detailVC = segue.destinationViewController as! DetailsViewController
            detailVC.movie = movie
        } else {
            
        }
        
        
    }
    
}
