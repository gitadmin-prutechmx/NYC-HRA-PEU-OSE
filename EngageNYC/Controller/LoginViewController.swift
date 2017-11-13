//
//  LoginViewController.swift
//  MTXGIS
//
//  Created by Kamal on 22/02/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController,DownloadProgressViewDelegate {
    
    
    var downloadProgressView:DownloadProgressView!
    
    
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var message: UILabel!
    
    
    func downloadProgressViewDidCancel(downloadProgressView: DownloadProgressView) {
        self.downloadProgressView.dismiss()
        print("Cancel")
    }
    
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        //self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //initialize download progress view
        self.downloadProgressView = DownloadProgressView()
        self.downloadProgressView.delegate = self
        
        //        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 102.0/255.0, blue: 204.0/255.0, alpha: 1)
        //
        //        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        self.navigationController?.isNavigationBarHidden = true
        
        
        if(Network.reachability?.isReachable)!{
            
            onlineEnterToDashBoard()
        }
        else{
            offlineEnterToDashBoard()
        }
        
        
        
    }
    
    
    func offlineEnterToDashBoard(){
        
        
        var userInfoData =  ManageCoreData.fetchData(salesforceEntityName: "UserInfo", isPredicate:false) as! [UserInfo]
        
        if(userInfoData.count > 0){
            
            appDelegate.getUserSetting()
            
           
            SalesforceConfig.currentUserEmail = userInfoData[0].contactEmail!
            SalesforceConfig.currentUserContactId = userInfoData[0].contactId!
            SalesforceConfig.currentUserExternalId = userInfoData[0].externalId!
            SalesforceConnection.salesforceUserId = userInfoData[0].userId!
            
            
            if let contactName = userInfoData[0].contactName{
                SalesforceConfig.currentContactName = contactName
            }
            
            
            self.performSegue(withIdentifier: "loginIdentifier", sender: nil)
        }
        
        
        
    }
    
    
    
    
    
    func onlineEnterToDashBoard(){
        
        loadingSpinner.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.gray
        loadingSpinner.startAnimating()
        
        
        message.text = "Syncing Data.."
        SyncUtility.syncDataWithSalesforce(isPullDataFromSFDC: true,controller: self)
        
        
        
        
    }
    
    
    
    
    
    @IBAction func UnwindBackFromLogout(segue:UIStoryboardSegue) {
        
        // ManageCoreData.DeleteAllDataFromEntities()
        Utilities.timer?.invalidate()
        print("UnwindBackFromLogout")
        
    }
    
    @IBAction func UnwindBackFromForgotPassword(segue:UIStoryboardSegue) {
        
        
        print("UnwindBackFromForgotPassword")
        
        
    }
    
    
    
    
    
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
