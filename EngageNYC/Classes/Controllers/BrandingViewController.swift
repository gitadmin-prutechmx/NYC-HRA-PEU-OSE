//
//  BrandingViewController.swift
//  EngageNYC
//
//  Created by Kamal on 07/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit
import SalesforceSDKCore

class BrandingViewController: UIViewController {

    @IBOutlet weak var errorMessage: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Branding Screen"
        
        NetworkUtility.shared.registerForNetworkConnectivityStatus()
        if(NetworkUtility.shared.isConnected() == false && SFUserAccountManager.sharedInstance().currentUser == nil){
            self.errorMessage.text = "No internet connection."
        }else{
            self.errorMessage.text = ""
        }
        
    }

}
