//
//  EventsRegistrationViewController.swift
//  EngageNYCDev
//
//  Created by Kamal on 08/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit

class EventRegDO{
    var id:String!
    var clientName:String!
    var regDate:String! 
}

class EventsRegistrationViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var objEvent:EventDO!
    var viewModel: EventsRegViewModel!
    var arrEventsRegMain = [EventRegDO]()
    
    @IBOutlet weak var tblRegstrations: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
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
            self.arrEventsRegMain = self.viewModel.loadEventsReg(objEvent: self.objEvent)
            self.tblRegstrations.reloadData()
        }
    }
    

}

extension EventsRegistrationViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrEventsRegMain.count
    }
    
    // cell height
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {

        let cell:EventsRegTableViewCell = self.tblRegstrations.dequeueReusableCell(withIdentifier: "eventsRegCell") as! EventsRegTableViewCell!

        if(arrEventsRegMain.count > 0){

            cell.setupView(forCellObject:arrEventsRegMain[indexPath.row],index:indexPath)
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
    }
}


extension EventsRegistrationViewController {
    
    func bindView() {
        self.viewModel = EventsRegViewModel.getViewModel()
    }
}




