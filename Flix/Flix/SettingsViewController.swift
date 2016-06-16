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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        colorSchemeSwitch.on = defaults.boolForKey("dark_scheme")
        orderSegCon.selectedSegmentIndex = defaults.integerForKey("order_by")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func colorSchemeChange(sender: AnyObject) {
        defaults.setBool(colorSchemeSwitch.on, forKey: "dark_scheme")
        defaults.synchronize()
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
