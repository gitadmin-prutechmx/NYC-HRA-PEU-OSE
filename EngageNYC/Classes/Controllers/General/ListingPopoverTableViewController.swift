//
//  ListingPopoverTableViewController.swift
//  EngageNYC
//
//  Created by Kamal on 07/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

class ListingPopOverDO{
    var id:String!
    var name:String!
    var additionalId:String!
}

enum virtualUnitName:String{
    case unknown = "Unknown"
}

enum noClientName:String{
    case unknown = "Undisclosed"
}

enum PopoverType : String {
    case navigation = "NavigationMenu"
    case eventsType = "EventsType"
    case unitsList = "UnitsList"
    case surveyList = "SurveyList"
    case clientList = "ClientList"
    case inTakeClientList = "InTakeClientList"
    case inTakeCaseList = "InTakeCaseList"
    case inTakeIssueList = "InTakeIssueList"
}

protocol ListingPopoverDelegate {
    
    func selectedItem(withObj obj: ListingPopOverDO, selectedIndex index : Int ,popOverType type:PopoverType)
    
}

class ListingPopoverTableViewController: UITableViewController {
    
    var arrList = [ListingPopOverDO]()
    var type : PopoverType?
    var delegate : ListingPopoverDelegate?
    
    var selectedId : String?
    let IMAGE_WIDTH_MARGIN = 110
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.isScrollEnabled = true
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        
        self.preferredContentSize = CGSize(width: 200, height: 200)
        
        
        self.tableView.reloadData()
        
        self.calculateHeight()
        
    }
    
    // MARK: Class Methods
    //    func getListing() {
    //
    //        if type == .navigation{
    //            arrList = Constant.shared.getConstant(withKey: .NavigationMenu) as! [String]
    //        }
    //
    //        if type == .unitsList{
    //            arrList = []
    //        }
    //
    //        self.tableView.reloadData()
    //
    //        self.calculateHeight()
    //    }
    
    func calculateHeight()  {
        
        let when = DispatchTime.now() + 0.1
        DispatchQueue.main.asyncAfter(deadline: when) {
            
            var height = 0
            let strwidth = self.getLongestString()
            let font = UIFont(name: "NHaasGroteskDSPro-55Rg", size: 18.0)
            let width = self.widthOfString(strwidth, withFont: font!)
            
            for index in 0...self.arrList.count{
                let frame = self.tableView.rectForRow(at: IndexPath(row: index, section: 0))
                height = height + Int(frame.size.height)
                
            }
            
            
            if height > 600{
                height = 600
            }
            
            self.preferredContentSize = CGSize(width: Int(width)+self.IMAGE_WIDTH_MARGIN, height: height)
        }
    }
    
    
    func getLongestString() -> String {
        
        var longestWord = ""
        
        for item in self.arrList
        {
            let str = item.name
            if longestWord == "" || (str?.count)! > longestWord.count {
                longestWord = str!
            }
        }
        
        return longestWord
    }
    
    func widthOfString(_ string: String, withFont font: UIFont) -> CGFloat {
        let attributes: [NSAttributedStringKey : Any] = [NSFontAttributeName as NSString: font]
        return NSAttributedString(string: string, attributes: attributes as [String : Any]).size().width
    }
    
    
}


// MARK: - Table view data source
extension ListingPopoverTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrList.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PopOverListCell
        cell.selectionStyle = .none
        cell.contentView.backgroundColor = UIColor.white
        cell.lblTitle.textColor = UIColor.Charcoal
        cell.isUserInteractionEnabled = true
        cell.alpha = 1
        
        cell.setupCell(title: arrList[indexPath.row].name)
        
        
        if(arrList[indexPath.row].name == virtualUnitName.unknown.rawValue || arrList[indexPath.row].name == noClientName.unknown.rawValue){
            cell.lblTitle.textColor = UIColor.red
        }
        
        if(type == .navigation){
            
            if(arrList[indexPath.row].name == NavigationItems.home.rawValue){
                cell.lblImage.image = UIImage(named: "Home")
            }
            else if(arrList[indexPath.row].name == NavigationItems.events.rawValue){
                cell.lblImage.image = UIImage(named: "Events")
            }
            else if(arrList[indexPath.row].name == NavigationItems.accessNYC.rawValue){
                cell.lblImage.image = UIImage(named: "Outside")
            }
            else if(arrList[indexPath.row].name == NavigationItems.refreshData.rawValue){
                cell.lblImage.image = UIImage(named: "Refresh")
            }
            else if(arrList[indexPath.row].name == NavigationItems.settings.rawValue){
                cell.lblImage.image = UIImage(named: "Settings")
            }
            else if(arrList[indexPath.row].name == NavigationItems.signOut.rawValue){
                cell.lblImage.image = UIImage(named: "Logout")
            }
        }
            
        else if(type == .inTakeClientList){
            
            if(arrList[indexPath.row].name == InTakeClient.client.rawValue){
                cell.lblImage.image = UIImage(named: "Edit")
            }
            else if(arrList[indexPath.row].name == InTakeClient.cases.rawValue){
                cell.lblImage.image = UIImage(named: "Case")
            }
            
        }
            
        else if(type == .inTakeCaseList){
            
            if(arrList[indexPath.row].name == InTakeCase.cases.rawValue){
                cell.lblImage.image = UIImage(named: "Case")
            }
            if(arrList[indexPath.row].name == InTakeCase.notes.rawValue){
                cell.lblImage.image = UIImage(named: "Note")
            }
            
            if(arrList[indexPath.row].name == InTakeCase.issues.rawValue){
                cell.lblImage.image = UIImage(named: "Issues")
            }
            
        }
            
        else if(type == .inTakeIssueList){
            
            if(arrList[indexPath.row].name == InTakeIssue.issue.rawValue){
                cell.lblImage.image = UIImage(named: "Issues")
            }
            if(arrList[indexPath.row].name == InTakeIssue.notes.rawValue){
                cell.lblImage.image = UIImage(named: "Note")
            }
            
            
        }
            
            
        else if(type == .unitsList || type == .eventsType || type == .surveyList || type == .clientList){
            
            if selectedId == arrList[indexPath.row].id{
                cell.lblImage.image = UIImage(named: "checked")
            }
            else{
                cell.lblImage.image = UIImage()
            }
            
        }
        
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //var title = ""
        self.dismiss(animated: true, completion: nil)
        
        if let cell = tableView.cellForRow(at: indexPath) as? PopOverListCell{
            
            cell.contentView.backgroundColor = UIColor.BrightBlue
            cell.lblTitle.textColor = UIColor.white
            
            
            if delegate != nil{
                
                delegate?.selectedItem(withObj: arrList[indexPath.row], selectedIndex: indexPath.row, popOverType: type!)
                
            }
            
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! PopOverListCell
        cell.contentView.backgroundColor = UIColor.white
        cell.lblTitle.textColor = UIColor.black
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! PopOverListCell
        cell.contentView.backgroundColor = UIColor.BrightBlue
        cell.lblTitle.textColor = UIColor.white
    }
    
    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! PopOverListCell
        cell.contentView.backgroundColor = UIColor.white
        cell.lblTitle.textColor = UIColor.black
    }
    
}

