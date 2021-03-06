//
//  CaseNotesViewController.swift
//  EngageNYC
//
//  Created by Kamal on 29/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

class CaseNoteDO{
    var caseId:String!
    var caseNotes:String!
    var createdDate:String!
}

class CaseNotesViewController: UIViewController,UITableViewDelegate,UITableViewDataSource
{
   
    @IBOutlet weak var lblCaseNotes: UILabel!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var tblCasenotes: UITableView!
    var viewModel:CaseViewModel!
    var arrCaseNotesMain:[CaseNoteDO]!
    var selectedCaseObj:CaseDO!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerTitle.text = selectedCaseObj.caseNo
        self.bindView()
        self.reloadView()
    }
    
    func reloadView(){
        
        self.arrCaseNotesMain = self.viewModel.loadCaseNotes(caseId: selectedCaseObj.caseId, assignmentLocUnitId: selectedCaseObj.assignmentLocUnitId)
        
        self.lblCaseNotes.text = "CASE NOTES (\(self.arrCaseNotesMain.count))"
        
        self.tblCasenotes.reloadData()
        
    }
    @IBAction func btnBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension CaseNotesViewController{
    func bindView(){
        self.viewModel = CaseViewModel.getViewModel()
    }
}

extension CaseNotesViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrCaseNotesMain.count
    }
    
    
   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 64.0
}
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell:CaseNotesTableViewCell = self.tblCasenotes.dequeueReusableCell(withIdentifier: "caseNotesCell") as! CaseNotesTableViewCell!
        
        if(arrCaseNotesMain.count > 0){
            cell.setupView(forCellObject: arrCaseNotesMain[indexPath.row], index: indexPath)
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
        let alertCtrl = Alert.showUIAlert(title: "Notes", message: arrCaseNotesMain[indexPath.row].caseNotes, vc: self)
        
        let notesAction: UIAlertAction = UIAlertAction(title: "Close", style: .cancel)
        { action -> Void in
            
        }
        
        alertCtrl.addAction(notesAction)
    }
    
}
