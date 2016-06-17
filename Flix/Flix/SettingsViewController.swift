//
//  SettingsViewController.swift
//  Flix
//
//  Created by Yijin Kang on 6/16/16.
//  Copyright © 2016 Yijin Kang. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    @IBOutlet weak var colorSchemeSwitch: UISwitch!
    @IBOutlet weak var orderSegCon: UISegmentedControl!
    @IBOutlet weak var colorSchemeLabel: UILabel!
    @IBOutlet weak var orderLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // this function is copied from https://coderwall.com/p/6rfitq/ios-ui-colors-with-hex-values-in-swfit
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    func setColors() {
        if defaults.boolForKey("dark_scheme") {
            let black = UIColor.blackColor()
            let white = UIColor.whiteColor()
            
            view.backgroundColor = black
            colorSchemeLabel.textColor = white
            orderLabel.textColor = white
            if let navigationBar = navigationController?.navigationBar {
                navigationBar.barTintColor = black
                navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: white]
            }
            UIApplication.sharedApplication().statusBarStyle = .LightContent
            
        } else {
            let dark = UIColorFromHex(0x3D007A, alpha: 1.0)
            let light = UIColorFromHex(0xFAF5FF, alpha: 1.0)
            
            view.backgroundColor = light
            colorSchemeLabel.textColor = dark
            orderLabel.textColor = dark
            if let navigationBar = navigationController?.navigationBar {
                navigationBar.barTintColor = light
                navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: dark]
            }
            UIApplication.sharedApplication().statusBarStyle = .Default
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        colorSchemeSwitch.on = defaults.boolForKey("dark_scheme")
        orderSegCon.selectedSegmentIndex = defaults.integerForKey("order_by")
        
        setColors()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func colorSchemeChange(sender: AnyObject) {
        defaults.setBool(colorSchemeSwitch.on, forKey: "dark_scheme")
        defaults.synchronize()
        
        setColors()
    }
    
    @IBAction func orderChange(sender: AnyObject) {
        defaults.setInteger(orderSegCon.selectedSegmentIndex, forKey: "order_by")
        defaults.synchronize()
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
