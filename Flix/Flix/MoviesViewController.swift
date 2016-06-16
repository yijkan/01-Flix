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

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate {
    
    @IBOutlet weak var moviesTable: UITableView!
    @IBOutlet weak var moviesSearchBar: UISearchBar!
    @IBOutlet weak var networkErrorView: UIView!
    
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    var refreshControl: UIRefreshControl!
    
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
//            self.networkErrorView.hidden = true
        }
    }
    
    func loadTable(useHUD:Bool) {
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
                        self.filteredMovies = self.movies
                        self.moviesTable.reloadData()
                    }
                    self.refreshControl.endRefreshing()

                } else {
                    self.refreshControl.endRefreshing()
                    self.fadeErrorIn()
                }
            }
        )
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        moviesTable.insertSubview(refreshControl, atIndex: 0)
        
        moviesTable.dataSource = self
        moviesTable.delegate = self
        
        moviesSearchBar.delegate = self
        
        loadTable(true)
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        loadTable(false)
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
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let baseURL = "http://image.tmdb.org/t/p/w342"
        let posterPath = movie["poster_path"] as! String
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        let imageRequest = NSURLRequest(URL: NSURL(string: baseURL + posterPath)!)
        cell.posterView.setImageWithURLRequest(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    if imageResponse != nil {
                        cell.posterView.alpha = 0.0
                        cell.posterView.image = image
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            cell.posterView.alpha = 1.0
                        })
                    } else {
                        cell.posterView.image = image
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    cell.posterView.image = nil
                }
        )
        return cell
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
