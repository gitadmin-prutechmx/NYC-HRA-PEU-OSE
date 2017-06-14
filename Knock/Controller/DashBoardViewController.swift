//
//  DashBoardViewController.swift
//  Knock
//
//  Created by Kamal on 13/06/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit
import Charts

class DashBoardViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var circleChartView: PieChartView!
    
    @IBOutlet weak var barChartView: PieChartView!
    
    @IBOutlet weak var pieChartView: PieChartView!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var assignmentIdArray = [String]()
    var assignmentArray = [String]()
    var assignmentEventIdArray = [String]()
    
    var totalLocArray = [String]()
    var totalUnitsArray = [String]()
    
    var eventDict: [String:EventDO] = [:]
    
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 102.0/255.0, blue: 204.0/255.0, alpha: 1)
        
       
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        

        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.tableFooterView = UIView()
        let nib = UINib(nibName: "HeaderTableViewCell", bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: "headerCellID")
        
        tableView.headerView(forSection: 0)
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        
         createCharts(chartType: circleChartView,radius: 0.5)
         createCharts(chartType: pieChartView,radius: 0.0)
         createCharts(chartType: barChartView,radius: 0.0)
         populateEventAssignmentData()
        
    }
    
    func createCharts(chartType:PieChartView,radius:CGFloat){
        
        let status = ["Completed", "In Progress", "Pending"]
        let values = [4.0, 3.0, 3.0]
        
        var colors: [UIColor] = []
        
        // Color object : get rgb
        
        
        let completedColor = UIColor(red: CGFloat(18.0/255), green: CGFloat(136.0/255), blue: CGFloat(189.0/255), alpha: 1)
        let InProgressColor = UIColor(red: CGFloat(173.0/255), green: CGFloat(235.0/255), blue: CGFloat(253.0/255), alpha: 1)
        let PendingColor = UIColor(red: CGFloat(54.0/255), green: CGFloat(191.0/255), blue: CGFloat(244.0/255), alpha: 1)
       // let BlankColor = UIColor(red: CGFloat(235.0/255), green: CGFloat(237.0/255), blue: CGFloat(248.0/255), alpha: 1)
        
        colors.append(completedColor)
        colors.append(InProgressColor)
        colors.append(PendingColor)
       // colors.append(BlankColor)
        
        
        var entries = [PieChartDataEntry]()
        for (index, value) in values.enumerated() {
            let entry = PieChartDataEntry()
            entry.y = value
            entry.label = status[index]
            entries.append( entry)
        }
        
        // 3. chart setup
        let set = PieChartDataSet( values: entries, label: "")
        // this is custom extension method. Download the code for more details.
        
        
        
        /* for _ in 0..<values.count {
         //let red = Double(arc4random_uniform(256))
         let red = Double(arc4random_uniform(256))
         let green = Double(arc4random_uniform(256))
         let blue = Double(arc4random_uniform(256))
         
         let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
         colors.append(color)
         }
         
         */
        
        set.colors = colors
        let data = PieChartData(dataSet: set)
        chartType.data = data
        chartType.noDataText = "No data available"
        // user interaction
        chartType.isUserInteractionEnabled = true
        
        let d = Description()
        d.text = ""
        chartType.chartDescription = d
        //pieChartView.centerText = "Pie Chart"
        chartType.holeRadiusPercent = radius
        chartType.transparentCircleColor = UIColor.clear
        
        chartType.animate(xAxisDuration: TimeInterval(5))
        
        
        
        
      
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
        cell.assignmentId.text = assignmentIdArray[indexPath.row]

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
