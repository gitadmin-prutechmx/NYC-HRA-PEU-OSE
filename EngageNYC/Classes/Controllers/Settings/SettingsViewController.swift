//
//  SettingsViewController.swift
//  EngageNYC
//
//  Created by MTX on 1/18/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

class SettingsDO{
    var offlineSyncTime:String!
    var isSyncOn:Bool!
    
    init(){
        offlineSyncTime  = ""
        isSyncOn = false
    }
}

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var lblAppVersion: UILabel!
    @IBOutlet weak var btnClosePressed: UIButton!
    @IBOutlet weak var tblSettingsUI: UITableView!
    @IBOutlet weak var btnSavePressed: UIButton!
    
    var viewModel:SettingsViewModel!
    var settingsObj:SettingsDO!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblAppVersion.text = "App Version:  \((Bundle.main.releaseVersionNumber)!) (\(Bundle.main.buildVersionNumber!))"
        
        self.bindView()
        self.reloadView()
        
    }
    
    func reloadView(){
        self.settingsObj = self.viewModel.getSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true;
    }
    
    
    @IBAction func btnSavePressed(_ sender: Any) {
        
        self.viewModel.updateSettings(objSettings: settingsObj)
        
        self.view.makeToast("Saved successfully.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
            
            if(Static.timer != nil){
                Static.timer?.invalidate()
            }
            
            Utility.startBackgroundSyncing()
            
            self.dismiss(animated: true, completion: nil)
            
        }
        
        
    }
    
    
    
    @IBAction func btnClosePressed(_ sender: UIButton) {
        
        let alertCtrl = Alert.showUIAlert(title: "Message", message: Static.exitMessage, vc: self)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .cancel)
        { action -> Void in
            
        }
        
        alertCtrl.addAction(cancelAction)
        
        let okAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
            
            
            self.dismiss(animated: true, completion: nil)
            
            
        }
        alertCtrl.addAction(okAction)
        
    }
    
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = (tableView.dequeueReusableCell(withIdentifier: "SettingsSwitchCell") as? SettingsSwitchTableViewCell)!
            
            if let obj = self.settingsObj{
                cell.setupView(autoSync: obj.isSyncOn)
            }
            
            cell.delegate = self
            
            return cell
        }
        else
        {
            let cell = (tableView.dequeueReusableCell(withIdentifier: "SliderCell")as? SettingsSliderTableViewCell)!
            
            if let obj = self.settingsObj{
                cell.setupView(syncTime: obj.offlineSyncTime)
            }
            
            cell.delegate = self
            
            return cell
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0
        {
            return 130.0
        }
            
        else
        {
            return 190.0
        }
    }
}

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

extension SettingsViewController : SettingsSwitchDelegate{
    func setSwitchValue(switchVal: Bool) {
        settingsObj.isSyncOn = switchVal
    }
}

extension SettingsViewController : SettingsSliderDelegate{
    
    func setSliderValue(sliderValue:Int){
        settingsObj.offlineSyncTime = "\(sliderValue)"
    }
}


extension SettingsViewController{
    
    func bindView(){
        self.viewModel = SettingsViewModel.getViewModel()
    }
}
