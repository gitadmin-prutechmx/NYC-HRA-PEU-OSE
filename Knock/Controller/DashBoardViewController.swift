//
//  DashBoardViewController.swift
//  Knock
//
//  Created by Kamal on 13/06/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit
import PieCharts

class DashBoardViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var pieChart2: PieChart!
    @IBOutlet weak var tblData: UITableView!
    var isCricleChart:Bool!
    var isPieChart:Bool!
    @IBOutlet weak var vwHidden: UIView!
    @IBOutlet weak var btnShow: UIButton!
    @IBOutlet weak var pieChartHidden: PieChart!
    @IBOutlet weak var btnCross: UIButton!
    @IBOutlet weak var pieChart3: PieChart!
    @IBOutlet weak var pieChart1: PieChart!
    
    fileprivate static let alpha: CGFloat = 0.5
    
    
    
    var assignmentIdArray = [String]()
    var assignmentArray = [String]()
    var assignmentEventIdArray = [String]()
    
    var totalLocArray = [String]()
    var totalUnitsArray = [String]()
    
    var eventDict: [String:EventDO] = [:]
    
    
    
    let colors = [
        UIColor.magenta.withAlphaComponent(alpha),
        UIColor.cyan.withAlphaComponent(alpha),
        UIColor.blue.withAlphaComponent(alpha),
        UIColor.magenta.withAlphaComponent(alpha),
        UIColor.cyan.withAlphaComponent(alpha),
        UIColor.red.withAlphaComponent(alpha),
        UIColor.magenta.withAlphaComponent(alpha),
        UIColor.orange.withAlphaComponent(alpha),
        UIColor.brown.withAlphaComponent(alpha),
        UIColor.lightGray.withAlphaComponent(alpha),
        UIColor.gray.withAlphaComponent(alpha),
        ]
    
    fileprivate var currentColorIndex = 0
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 102.0/255.0, blue: 204.0/255.0, alpha: 1)
        
       
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        

        
        
        isPieChart = true
        tblData.delegate = self
        tblData.dataSource = self
        
        self.tblData.tableFooterView = UIView()
        let nib = UINib(nibName: "HeaderTableViewCell", bundle: nil)
        
        tblData.register(nib, forCellReuseIdentifier: "headerCellID")
        
        tblData.headerView(forSection: 0)
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        
        pieChart1.layers = [createCustomViewsLayer(), createTextLayer()]
        pieChart1.models = createModels()
        
        pieChart2.layers = [createPlainTextLayer1()]
        
        pieChart2.models = createModels1()
        
        pieChart3.layers = [createCustomViewsLayer(),createTextLayer()]
        pieChart3.models = createModels()
        
        populateEventAssignmentData()
        
        //
        //        pieChartHidden.layers = [createCustomViewsLayer(), createTextLayer()]
        //        // pieChart1.delegate = self
        //        pieChartHidden.models = createModels()
    }
    
    func populateEventAssignmentData(){
      
        
        createEventDictionary()
        
        //location count and unit count
       
        
        //location --> assignmentid
        //units----> locationId
        
        let assignmentResults = ManageCoreData.fetchData(salesforceEntityName: "Assignment",isPredicate:false) as! [Assignment]
            
        if(assignmentResults.count > 0){
                
            for assignmentdata in assignmentResults{
                    assignmentArray.append(assignmentdata.name!)
                    assignmentIdArray.append(assignmentdata.id!)
                    assignmentEventIdArray.append(assignmentdata.eventId!)
                    totalLocArray.append(assignmentdata.totalLocations!)
                    totalUnitsArray.append(assignmentdata.totalUnits!)
                }
            }

        tableView.reloadData()
        
       
    
     
    }
    
    func createEventDictionary(){
        
        
        
        let eventResults =  ManageCoreData.fetchData(salesforceEntityName: "Event", isPredicate:false) as! [Event]
        
        if(eventResults.count > 0){
            
            for eventData in eventResults{
                
                if eventDict[eventData.id!] == nil{
                    eventDict[eventData.id!] = EventDO(eventId: eventData.id!, eventName: eventData.name!, startDate: eventData.startDate!, endDate: eventData.endDate!)
                }
                
                
            }
        }
        
    }
    

    
    // MARK: - Models
    
    fileprivate func createModels() -> [PieSliceModel]
    {
        let alpha: CGFloat = 0.5
        
        return [
            PieSliceModel(value: 3, color: UIColor.cyan.withAlphaComponent(alpha)),
            PieSliceModel(value: 1, color: UIColor.blue.withAlphaComponent(alpha)),
            PieSliceModel(value: 1, color: UIColor.magenta.withAlphaComponent(alpha)),
            
            PieSliceModel(value: 4, color: UIColor.cyan.withAlphaComponent(alpha)),
            PieSliceModel(value: 2, color: UIColor.blue.withAlphaComponent(alpha)),
            PieSliceModel(value: 1.5, color: UIColor.magenta.withAlphaComponent(alpha)),
            PieSliceModel(value: 0.5, color: UIColor.orange.withAlphaComponent(alpha))
            
        ]
    }
    
    // MARK: - Layers
    
    fileprivate func createCustomViewsLayer() -> PieCustomViewsLayer {
        let viewLayer = PieCustomViewsLayer()
        
        let settings = PieCustomViewsLayerSettings()
        settings.viewRadius = 135
        settings.hideOnOverflow = false
        viewLayer.settings = settings
        
        // viewLayer.viewGenerator = createViewGenerator()
        
        return viewLayer
    }
    
    fileprivate func createTextLayer() -> PiePlainTextLayer {
        let textLayerSettings = PiePlainTextLayerSettings()
        textLayerSettings.viewRadius = 60
        textLayerSettings.hideOnOverflow = true
        textLayerSettings.label.font = UIFont.systemFont(ofSize: 12)
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        textLayerSettings.label.textGenerator = {slice in
            return formatter.string(from: slice.data.percentage * 100 as NSNumber)!
        }
        
        let textLayer = PiePlainTextLayer()
        textLayer.settings = textLayerSettings
        return textLayer
    }
    
    // MARK: - Models
    
    fileprivate func createModels1() -> [PieSliceModel] {
        
        let models = [
            PieSliceModel(value: 2, color: colors[0]),
            PieSliceModel(value: 2, color: colors[1]),
            PieSliceModel(value: 2, color: colors[2])
        ]
        
        currentColorIndex = models.count
        return models
    }
    
    
    
    // MARK: - Layers
    
    fileprivate func createPlainTextLayer1() -> PiePlainTextLayer {
        
        let textLayerSettings = PiePlainTextLayerSettings()
        textLayerSettings.viewRadius = 55
        textLayerSettings.hideOnOverflow = true
        textLayerSettings.label.font = UIFont.systemFont(ofSize: 8)
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        textLayerSettings.label.textGenerator = {slice in
            return formatter.string(from: slice.data.percentage * 100 as NSNumber)!
            //.map{"\($0)%"} ?? ""
        }
        
        let textLayer = PiePlainTextLayer()
        textLayer.settings = textLayerSettings
        return textLayer
    }
    
    fileprivate func createTextWithLinesLayer1() -> PieLineTextLayer {
        let lineTextLayer = PieLineTextLayer()
        var lineTextLayerSettings = PieLineTextLayerSettings()
        lineTextLayerSettings.lineColor = UIColor.lightGray
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        lineTextLayerSettings.label.font = UIFont.systemFont(ofSize: 14)
        lineTextLayerSettings.label.textGenerator = {slice in
            return formatter.string(from: slice.data.model.value as NSNumber).map{"\($0)"} ?? ""
        }
        
        lineTextLayer.settings = lineTextLayerSettings
        return lineTextLayer
    }
    
    
    
    // MARK: UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assignmentArray.count
    }
    
    // cell height
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataRowId", for: indexPath) as! EventAssignmentViewCell
        
        cell.assignmentName.text = assignmentArray[indexPath.row]
        
        let eventObject = eventDict[assignmentEventIdArray[indexPath.row]]
 
        cell.eventName.text = eventObject?.eventName
        
        cell.locations.text = totalLocArray[indexPath.row]
        cell.units.text = totalUnitsArray[indexPath.row]

        cell.completePercent.text = "0%"
        
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Dequeue with the reuse identifier
        
        let identifier = "headerCellID"
        var cell: HeaderTableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? HeaderTableViewCell
        if cell == nil {
            tableView.register(UINib(nibName: "HeaderTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? HeaderTableViewCell
        }
        
        return cell
    
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return  67.0
    }


}
