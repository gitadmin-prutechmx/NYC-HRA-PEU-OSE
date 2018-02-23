//
//  EventsDetailViewController.swift
//  EngageNYCDev
//
//  Created by Kamal on 08/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

class MetadataConfigDO{
    
    var sequence:String = ""
    var pickListValue:String = ""
    var fieldName:String = ""
    var dataType:String = ""
    var apiName:String = ""
    var sectionName:String = ""
    
init(fieldName:String) {
    
        self.sequence = ""
        self.pickListValue = ""
        self.fieldName = fieldName
        self.dataType = ""
        self.apiName = ""
        self.sectionName = ""

    }
init(sequence:String,pickListValue:String,fieldName:String,dataType:String,apiName:String,sectionName:String) {
        self.sequence = sequence
        self.pickListValue = pickListValue
        self.fieldName = fieldName
        self.dataType = dataType
        self.apiName = apiName
        self.sectionName = sectionName
        
        
    }
}

struct MetadataConfigObjects {
    var sectionName : String!
    var sectionObjects : [MetadataConfigDO]!
}


class EventsDetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tblEventsConfig: UITableView!
    
    var objEvent:EventDO!
    var viewModel:EventsDetailViewModel!
    var metadataConfigArray = [MetadataConfigObjects]()
    
    var eventsDynamicDict:[String : AnyObject] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
   
        eventsDynamicDict = objEvent.eventsDynamic as! [String : AnyObject]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.reloadView()
    }
    
    func setupView() {
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.bindView()
        }
    }
    
    func reloadView(){
        
        DispatchQueue.main.async {
            self.metadataConfigArray = self.viewModel.loadEventsDetail(objEvent: self.objEvent)
            print(self.metadataConfigArray)
            self.tblEventsConfig.reloadData()
        }
    }
    
    
}

extension EventsDetailViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.metadataConfigArray.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return metadataConfigArray[section].sectionName
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return metadataConfigArray[section].sectionObjects.count
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let metadataConfigObject:MetadataConfigDO = metadataConfigArray[indexPath.section].sectionObjects[indexPath.row]

        
        if(metadataConfigObject.dataType == "BOOLEAN")
        {
            
            let switchCell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            
            
            switchCell.textLabel?.text = metadataConfigObject.fieldName
            switchCell.textLabel?.font = UIFont.init(name: "Arial", size: 16.0)
            
            switchCell.backgroundColor = UIColor.white
            
            switchCell.selectionStyle = .none
            
            
            //accessory switch
            let uiSwitch = UISwitch(frame: CGRect.zero)
            
            uiSwitch.tag = indexPath.row
            
            uiSwitch.backgroundColor = UIColor.white
            
            
            if let switchValue = eventsDynamicDict[metadataConfigObject.apiName] {
                uiSwitch.isOn = switchValue as! Bool
            }
            else
            {
                uiSwitch.isOn = false
            }
            
            
           
            uiSwitch.isEnabled = false
            
            
            
            switchCell.accessoryView = uiSwitch
            
            return switchCell
            
            
        }
        else{
            
            let textCell = tableView.dequeueReusableCell(withIdentifier: "rightDetailCell", for: indexPath)
            
            
            
            textCell.textLabel?.text = metadataConfigObject.fieldName
            textCell.textLabel?.font = UIFont.init(name: "Arial", size: 16.0)
            
            if let val = eventsDynamicDict[metadataConfigObject.apiName] {
                if(metadataConfigObject.apiName == "Event_Staff_Lead__c"){
                    textCell.detailTextLabel?.text = objEvent.eventStaffLeadName
                }
                else{
                    textCell.detailTextLabel?.text = "\(val)"
                }
            }
            else{
                textCell.detailTextLabel?.text = ""
            }
            
            textCell.detailTextLabel?.font = UIFont.init(name: "Arial", size: 16.0)
            
            textCell.selectionStyle = .none
            
            return textCell
        }
        
        
    }
}

extension EventsDetailViewController {
    
    func bindView() {
        self.viewModel = EventsDetailViewModel.getViewModel()
    }
}


