//
//  DetailsViewController.swift
//  Flix
//
//  Created by Yijin Kang on 6/16/16.
//  Copyright © 2016 Yijin Kang. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    
    var movie: NSDictionary!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewText: UITextView!
    @IBOutlet weak var posterImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = movie["title"] as! String
        overviewText.text = movie["overview"] as! String
        
        if let posterPath = movie["poster_path"] as? String {
            print(posterPath)
            let smallImageRequest = NSURLRequest(URL: NSURL(string: "http://image.tmdb.org/t/p/w45\(posterPath)")!)
            let largeImageRequest = NSURLRequest(URL: NSURL(string: "http://image.tmdb.org/t/p/original\(posterPath)")!)
        
            posterImageView.setImageWithURLRequest(
                smallImageRequest,
                placeholderImage: nil,
                success: { (smallImageRequest, smallImageResponse, smallImage) in
                    self.posterImageView.alpha = 0.0
                    self.posterImageView.image = smallImage;
                    UIView.animateWithDuration(
                        0.3,
                        animations: { () -> Void in self.posterImageView.alpha = 1.0 },
                        completion: { (success) -> Void in
                            self.posterImageView.setImageWithURLRequest(
                                largeImageRequest,
                                placeholderImage: smallImage,
                                success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                    self.posterImageView.image = largeImage
                                },
                                failure: { (request, response, error) -> Void in
                                    self.posterImageView.image = smallImage
                                }
                            )
                        }
                    )
                },
                failure: { (request, response, error) -> Void in
                    self.posterImageView.setImageWithURLRequest(
                        largeImageRequest,
                        placeholderImage: nil,
                        success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                            self.posterImageView.image = largeImage
                        },
                        failure: { (request, response, error) -> Void in
                            self.posterImageView.image = nil
                        }
                    )
                }
            )
            
        } else {
            
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // TODO set colors
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
