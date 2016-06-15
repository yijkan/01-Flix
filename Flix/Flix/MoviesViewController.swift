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

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var moviesTable: UITableView!
    var movies: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        moviesTable.insertSubview(refreshControl, atIndex: 0)
        
        moviesTable.dataSource = self
        moviesTable.delegate = self
        
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
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task: NSURLSessionDataTask =
            session.dataTaskWithRequest(request,
                                        completionHandler: { (dataOrNil, response, error) in
                                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                                            if let data = dataOrNil {
                                                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                                                    data, options:[]) as? NSDictionary {
                                                        print("response: \(responseDictionary)")
                                                        self.movies = responseDictionary["results"] as! [NSDictionary]
                                                        self.moviesTable.reloadData()
                                                    }
                                            }
                                        }
        )
        task.resume()
        
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        let apiKey = "95dd50b36271bd60b6404e430282e991"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        let session = NSURLSession (
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task: NSURLSessionDataTask =
            session.dataTaskWithRequest(request,
                                        completionHandler: { (dataOrNil, response, error) in
                                            if let data = dataOrNil {
                                                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                                                    data, options:[]) as? NSDictionary {
                                                    print("response: \(responseDictionary)")
                                                    self.movies = responseDictionary["results"] as! [NSDictionary]
                                                    self.moviesTable.reloadData()
                                                    refreshControl.endRefreshing()
                                                }
                                            }
                }
        )
        task.resume()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UITableViewDataSource Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = moviesTable.dequeueReusableCellWithIdentifier("movieCell", forIndexPath: indexPath) as! MovieCell
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let baseURL = "http://image.tmdb.org/t/p/w342"
        let posterPath = movie["poster_path"] as! String
        print(baseURL + posterPath)
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.posterView.setImageWithURL(NSURL(string: baseURL + posterPath)!)
        return cell
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
