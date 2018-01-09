//
//  ListingPopoverTableViewController.swift
//  EngageNYC
//
//  Created by Kamal on 07/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit


enum PopoverType : String {
    case navigation = "NavigationMenu"
    case eventsType = "EventsType"
}

@objc protocol ListingPopoverDelegate {
    
    func selectedItem(withName name: String, selectedIndex index : Int)
    @objc optional func selectedItem(withName name: String, headerValue header : String, selectedIndex index : IndexPath)
}

class ListingPopoverTableViewController: UITableViewController {
    
    var arrList = [String]()
    var type : PopoverType?
    var delegate : ListingPopoverDelegate?
    var otherText : String?
    var selectedText : String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.isScrollEnabled = false
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        
        self.preferredContentSize = CGSize(width: 200, height: 200)
        
        self.getListing()
        
    }
    
    // MARK: Class Methods
    func getListing() {
        
        if type == .navigation{
            arrList = ["Home"]
            //arrList = Constant.shared.getConstant(withKey: .NavigationMenu) as! [String]
            
        }
        else if type == .eventsType{
            arrList = ["test", "test1"]
        }
        
        self.tableView.reloadData()
        
        self.calculateHeight()
    }
    
    func calculateHeight()  {
        
        let when = DispatchTime.now() + 0.1
        DispatchQueue.main.asyncAfter(deadline: when) {
            
            var height = 0
            let width = 200
            
            for index in 0...self.arrList.count{
                let frame = self.tableView.rectForRow(at: IndexPath(row: index, section: 0))
                height = height + Int(frame.size.height)
            }
            
            
            if height > 600{
                height = 600
            }
            
            self.preferredContentSize = CGSize(width: width, height: height)
        }
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
        
        cell.setupCell(title: arrList[indexPath.row])
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var title = ""
        self.dismiss(animated: true, completion: nil)
        
        if let cell = tableView.cellForRow(at: indexPath) as? PopOverListCell{
            
            cell.contentView.backgroundColor = UIColor.BrightBlue
            cell.lblTitle.textColor = UIColor.white
            
            title = arrList[indexPath.row]
            if delegate != nil{
                delegate?.selectedItem(withName: title, selectedIndex: indexPath.row)
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


