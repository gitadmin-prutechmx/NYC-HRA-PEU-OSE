//
//  SideMenuViewController.swift
//  MTXGIS
//
//  Created by Kamal on 24/02/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit
import SalesforceSDKCore

class SideMenuViewController: UITableViewController {
    
    @IBOutlet var sideMenuTableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //  self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 30.0/255.0, green: 89.0/255.0, blue: 151.0/255.0, alpha: 1)
        
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 30.0/255.0, green: 89.0/255.0, blue: 151.0/255.0, alpha: 1)
        let nav = self.navigationController?.navigationBar
        //  nav?.barStyle = UIBarStyle.black
        nav?.setTitleVerticalPositionAdjustment(CGFloat(7), for: UIBarMetrics.default)
        nav?.tintColor = UIColor.white
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        let titleLabel = UILabel(frame: CGRect(x:0, y:-10, width:self.view.frame.size.width, height:50))
        
        titleLabel.text = SalesforceConfig.currentUserEmail
        
        titleLabel.textColor = UIColor.white
        titleLabel.numberOfLines = 2
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.font = UIFont.init(name: "System", size: 22.0)
        
        nav?.addSubview(titleLabel)
        
    }
    
    
    
    /* self.navigationController!.navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 80.0)*/
    
    /*let height: CGFloat = 45 //whatever height you want
     
     let bounds = self.navigationController!.navigationBar.bounds
     self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height + height)*/
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

// MARK: - UITableViewDataSource methods

extension SideMenuViewController
{
    
    
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 3
        {
            
            Utilities.timer?.invalidate()
            SFAuthenticationManager.shared().logout()
            //appDelegate.setupRootViewController(isLogin: false)
            
        }
        else if indexPath.row == 2
        {
            
            if let eventVC = EventsStoryboard().instantiateViewController(withIdentifier: "EventsViewController") as? EventsViewController{
                
                let navigationController = UINavigationController(rootViewController: eventVC)
                navigationController.modalPresentationStyle = UIModalPresentationStyle.formSheet
                self.present(navigationController, animated: true)
            }
          
        }
    }
    
}

