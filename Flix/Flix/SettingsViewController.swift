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
            let dark = UIColorFromHex(darkHex)
            let light = UIColorFromHex(lightHex)
            
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
