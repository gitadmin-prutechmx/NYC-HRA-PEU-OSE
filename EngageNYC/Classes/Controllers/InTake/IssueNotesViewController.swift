//
//  IssueNotesViewController.swift
//  EngageNYC
//
//  Created by Kamal on 29/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

class IssueNoteDO{
    var issueId:String!
    var issueNotes:String!
    var createdDate:String!
}

class IssueNotesViewController: UIViewController,UITableViewDelegate,UITableViewDataSource
{

    @IBOutlet weak var lblIssueNotes: UILabel!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var tblIssueNotes: UITableView!
    var viewModel:IssueViewModel!
    var arrIssueMain:[IssueNoteDO]!
    var selectedIssueObj:IssueDO!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerTitle.text = selectedIssueObj.issueNo
        self.bindView()
        self.reloadView()
        
    }
    
    @IBAction func btnBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func reloadView(){
        self.arrIssueMain = self.viewModel.loadIssueNotes(issueId: selectedIssueObj.issueId, assignmentId: selectedIssueObj.assignmentId)
        
        self.lblIssueNotes.text = "ISSUE NOTES (\(self.arrIssueMain.count))"
        
        self.tblIssueNotes.reloadData()
    }


}

extension IssueNotesViewController{
    func bindView(){
        self.viewModel = IssueViewModel.getViewModel()
    }
}
extension IssueNotesViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrIssueMain.count
    }
    
    // cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell:IssueNotesTableViewCell = self.tblIssueNotes.dequeueReusableCell(withIdentifier: "issueNotesCell") as! IssueNotesTableViewCell!
   
        if(arrIssueMain.count > 0){
             cell.setupView(forCellObject: arrIssueMain[indexPath.row], index: indexPath)
        }
       
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertCtrl = Alert.showUIAlert(title: "Notes", message: arrIssueMain[indexPath.row].issueNotes, vc: self)
        
        let notesAction: UIAlertAction = UIAlertAction(title: "Close", style: .cancel)
        { action -> Void in
            
        }
        
        alertCtrl.addAction(notesAction)
    }
    
}
