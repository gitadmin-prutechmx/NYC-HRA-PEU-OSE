//
//  DashBoardViewController.swift
//  Knock
//
//  Created by Kamal on 13/06/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit
import Charts


struct eventAssignmentDataStruct
{
    var eventName:String = ""
    var eventId : String = ""
    var assignmentId : String = ""
    var assignmentName : String = ""
    var totalLocations : String = ""
    var totalUnits : String = ""
    var completeAssignment : String = ""
    var noOfClients:String = ""
    
    var completedDate:NSDate?
    var assignedDate:NSDate?
    
    
}

class DashBoardViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDataSource,UICollectionViewDelegate
{
    
    
    let reuseIdentifier = "cell"
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var colChart: UICollectionView!
    
    
    
    var eventDict: [String:AssignmentEventDO] = [:]
    var chartResults = [Chart]()
    
    let status = ["Completed", "In Progress", "Pending"]
    let values = [4.0, 3.0, 3.0]
    
   
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        //        var width = UIScreen.main.bounds.width
        //        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        //        width = width - 10
        //        layout.itemSize = CGSize(width: width / 2, height: width / 2)
        //        layout.minimumInteritemSpacing = 0
        //        layout.minimumLineSpacing = 0
        //        colChart!.collectionViewLayout = layout
        
        if self.revealViewController() != nil {
            
            
            menuBtn.target = self.revealViewController()
            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            // self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
        
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 86.0/255.0, blue: 153.0/255.0, alpha: 1)
        
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
        imageView.contentMode = .scaleAspectFit
        
        
        let image = UIImage(named: "NYC")
        imageView.image = image
        self.navigationItem.titleView = imageView
        
        //self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.tableFooterView = UIView()
        let nib = UINib(nibName: "HeaderTableViewCell", bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: "headerCellID")
        
        tableView.headerView(forSection: 0)
        
        
        NotificationCenter.default.addObserver(self, selector:#selector(DashBoardViewController.UpdateAssignmentView), name: NSNotification.Name(rawValue: "UpdateAssignmentView"), object:nil
        )
        
        populateChartData()
        
        //startBackgroundSyncing()
        
        Utilities.startBackgroundSyncing()
        
    }
    
   
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        colChart.collectionViewLayout.invalidateLayout()
    }
    
    @IBAction func syncData(_ sender: Any) {
        
        Utilities.forceSyncDataWithSalesforce(vc: self)
    }
    
    func UpdateAssignmentView(){
        
        print("UpdateAssignmentView")
        
        
        populateEventAssignmentData()
        populateChartData(isTwoMinuteSync: true)
        
        
        //updateTableViewData()
    }
    
    
    // Cleanup notifications added in viewDidLoad
    deinit {
        NotificationCenter.default.removeObserver("UpdateAssignmentView")
    }
    
    
    

    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        populateEventAssignmentData()
        
    }
    
    //MARK: - chartMethods
    
    func barChartData(custumView:UIView)
    {
        
        let colors = getColors()
        
        let chart = BarChartView(frame: custumView.frame)
        
        //let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        //let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
        
        
        var dataEntries: [BarChartDataEntry] = []
        //String(describing: languages)z
        //        for i in 0..<chart1StatusArray.count
        //        {
        //            let dataEntry =   BarChartDataEntry(x: chart1ValueArray[i], y: Double(i))
        //            dataEntries.append(dataEntry)
        //        }
        
        
        
        //chart.isUserInteractionEnabled = true
        
        let d = Description()
        d.text = " "
        chart.chartDescription = d
        
        
        let set = BarChartDataSet( values: dataEntries, label: "")
        set.colors = colors
        
        
        let barChartData = BarChartData(dataSet: set)
        chart.data = barChartData
        chart.noDataText = "No data available"
        
        
        
        //   barChartData.xAxis.labelPosition = .Bottom
        
        
        
        
        custumView.addSubview(chart)
        
        
    }
    
    var totalUnitsChart:GaugeView!
    var unitsCompletedChart:GaugeView!
    var noResponseChart:GaugeView!
    var followUpNeededChart:GaugeView!
    
    func circleChartData(custumView:UIView,chartValue:Float,chartText:String, chartColor:UIColor,chartType:String)
    {
        // let colors = getColors()
        
        
        if(chartType == "Total Units"){
            
            totalUnitsChart = GaugeView(frame: custumView.frame)
            
            totalUnitsChart.percentage = chartValue
            
            
            // chart.labelText = " "
            totalUnitsChart.labelText = chartText
            
            totalUnitsChart.thickness = 20
            
            //  totalUnitsChart.labelFont = UIFont.systemFont(ofSize: 28, weight: UIFontWeightThin)
            totalUnitsChart.labelFont = UIFont.init(name: "Arial", size: 17.0)
            
            totalUnitsChart.labelColor = UIColor.black
            totalUnitsChart.gaugeBackgroundColor = UIColor(red: CGFloat(204.0/255), green: CGFloat(204.0/255), blue: CGFloat(204.0/255), alpha: 1)
            totalUnitsChart.gaugeColor = chartColor
            
            totalUnitsChart.isUserInteractionEnabled = true
            totalUnitsChart.accessibilityLabel = "Gauge"
            
            
            custumView.addSubview(totalUnitsChart)
        }
        else if(chartType == "Units Completed"){
            
            unitsCompletedChart = GaugeView(frame: custumView.frame)
            
            unitsCompletedChart.percentage = chartValue
            
            
            // chart.labelText = " "
            unitsCompletedChart.labelText = chartText
            
            unitsCompletedChart.thickness = 20
            
            // unitsCompletedChart.labelFont = UIFont.systemFont(ofSize: 28, weight: UIFontWeightThin)
            unitsCompletedChart.labelFont = UIFont.init(name: "Arial", size: 17.0)
            unitsCompletedChart.labelColor = UIColor.black
            unitsCompletedChart.gaugeBackgroundColor = UIColor(red: CGFloat(204.0/255), green: CGFloat(204.0/255), blue: CGFloat(204.0/255), alpha: 1)
            unitsCompletedChart.gaugeColor = chartColor
            
            unitsCompletedChart.isUserInteractionEnabled = true
            unitsCompletedChart.accessibilityLabel = "Gauge"
            
            
            custumView.addSubview(unitsCompletedChart)
        }
        else if(chartType == "No Response"){
            
            noResponseChart = GaugeView(frame: custumView.frame)
            
            noResponseChart.percentage = chartValue
            
            
            // chart.labelText = " "
            noResponseChart.labelText = chartText
            
            noResponseChart.thickness = 20
            
            // noResponseChart.labelFont = UIFont.systemFont(ofSize: 28, weight: UIFontWeightThin)
            noResponseChart.labelFont = UIFont.init(name: "Arial", size: 17.0)
            noResponseChart.labelColor = UIColor.black
            noResponseChart.gaugeBackgroundColor = UIColor(red: CGFloat(204.0/255), green: CGFloat(204.0/255), blue: CGFloat(204.0/255), alpha: 1)
            noResponseChart.gaugeColor = chartColor
            
            noResponseChart.isUserInteractionEnabled = true
            noResponseChart.accessibilityLabel = "Gauge"
            
            
            custumView.addSubview(noResponseChart)
        }
        else if(chartType == "FollowUp Needed"){
            
            followUpNeededChart = GaugeView(frame: custumView.frame)
            
            followUpNeededChart.percentage = chartValue
            
            
            // chart.labelText = " "
            followUpNeededChart.labelText = chartText
            
            followUpNeededChart.thickness = 20
            
            followUpNeededChart.labelFont = UIFont.init(name: "Arial", size: 17.0)//UIFont.systemFont(ofSize: 28, weight: UIFontWeightThin)
            followUpNeededChart.labelColor = UIColor.black
            followUpNeededChart.gaugeBackgroundColor = UIColor(red: CGFloat(204.0/255), green: CGFloat(204.0/255), blue: CGFloat(204.0/255), alpha: 1)
            followUpNeededChart.gaugeColor = chartColor
            
            followUpNeededChart.isUserInteractionEnabled = true
            followUpNeededChart.accessibilityLabel = "Gauge"
            
            
            custumView.addSubview(followUpNeededChart)
        }
    }
    
    func updateChartData(custumView:UIView)
    {
        
        let chart = LineChartView(frame: custumView.frame)
        var entries = [PieChartDataEntry]()
        for (index, value) in values.enumerated() {
            let entry = PieChartDataEntry()
            entry.y = value
            entry.label = status[index]
            entries.append( entry)
        }
        // 3. chart setup
        let set = LineChartDataSet( values: entries, label: "")
        
        var colors: [UIColor] = []
        
        for _ in 0..<values.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        set.colors = colors
        let data = LineChartData(dataSet: set)
        chart.data = data
        chart.noDataText = "No data available"
        chart.isUserInteractionEnabled = true
        
        let d = Description()
        //d.text = "iOSCharts.io"
        chart.chartDescription = d
        
        custumView.addSubview(chart)
    }
    
    
    func getColors()->[UIColor]{
        
        var colors: [UIColor] = []
        
        // Color object : get rgb
        
        let completedColor = UIColor(red: CGFloat(18.0/255), green: CGFloat(136.0/255), blue: CGFloat(189.0/255), alpha: 1)
        let InProgressColor = UIColor(red: CGFloat(173.0/255), green: CGFloat(235.0/255), blue: CGFloat(253.0/255), alpha: 1)
        let PendingColor = UIColor(red: CGFloat(54.0/255), green: CGFloat(191.0/255), blue: CGFloat(244.0/255), alpha: 1)
        // let BlankColor = UIColor(red: CGFloat(235.0/255), green: CGFloat(237.0/255), blue: CGFloat(248.0/255), alpha: 1)
        
        colors.append(completedColor)
        colors.append(InProgressColor)
        colors.append(PendingColor)
        
        return colors
        // colors.append(BlankColor)
        
    }
    
    
    
    
    var chart1Label:String = ""
    var chart1Value:String = ""
    
    var chart2Label:String = ""
    var chart2Value:String = ""
    
    var chart3Label:String = ""
    var chart3Value:String = ""
    
    var chart4Label:String = ""
    var chart4Value:String = ""
    
    
    func populateChartData(isTwoMinuteSync:Bool?=false){
        
        chart1Label = ""
        chart1Value = ""
        
        chart2Label = ""
        chart2Value = ""
        
        chart3Label = ""
        chart3Value = ""
        
        chart4Label = ""
        chart4Value = ""
        
        chartResults =  ManageCoreData.fetchData(salesforceEntityName: "Chart",isPredicate:false) as! [Chart]
        
        
        let chart1Results = ManageCoreData.fetchData(salesforceEntityName: "Chart",predicateFormat: "chartType == %@",predicateValue: "Chart1",isPredicate:true) as! [Chart]
        
        if(chart1Results.count > 0){
            
            chart1Label = chart1Results[0].chartLabel!
            chart1Value = chart1Results[0].chartValue!
            
        }
        
        let chart2Results = ManageCoreData.fetchData(salesforceEntityName: "Chart",predicateFormat: "chartType == %@",predicateValue: "Chart2",isPredicate:true) as! [Chart]
        
        if(chart2Results.count > 0){
            
            chart2Label = chart2Results[0].chartLabel!
            chart2Value = chart2Results[0].chartValue!
            
        }
        
        let chart3Results = ManageCoreData.fetchData(salesforceEntityName: "Chart",predicateFormat: "chartType == %@",predicateValue: "Chart3",isPredicate:true) as! [Chart]
        
        if(chart3Results.count > 0){
            
            chart3Label = chart3Results[0].chartLabel!
            chart3Value = chart3Results[0].chartValue!
            
        }
        
        let chart4Results = ManageCoreData.fetchData(salesforceEntityName: "Chart",predicateFormat: "chartType == %@",predicateValue: "Chart4",isPredicate:true) as! [Chart]
        
        if(chart4Results.count > 0){
            
            chart4Label = chart4Results[0].chartLabel!
            chart4Value = chart4Results[0].chartValue!
            
        }
        
        
        if(isTwoMinuteSync!){
            
            if(totalUnitsChart != nil){
                totalUnitsChart.percentage = 100
                totalUnitsChart.labelText = chart1Value
            }
            if(unitsCompletedChart != nil){
                unitsCompletedChart.percentage = 100
                unitsCompletedChart.labelText = chart2Value
            }
            
            if(noResponseChart != nil){
                noResponseChart.percentage = Float(chart3Value)!
                noResponseChart.labelText = chart3Value + "%"
            }
            
            if(followUpNeededChart != nil){
                followUpNeededChart.percentage = Float(chart4Value)!
                followUpNeededChart.labelText = chart4Value + "%"
            }
            
            
        }
        else{
            colChart.reloadData()
        }
        
        
        
    }
    
    var eventAssignmentDataArray = [eventAssignmentDataStruct]()
    
    func populateEventAssignmentData()
    {
        eventAssignmentDataArray = []
        
        eventDict = [:]
        
        
        
        createEventDictionary()
        
        //location count and unit count
        
        
        //location --> assignmentid
        //units----> locationId
        
        let assignmentResults = ManageCoreData.fetchData(salesforceEntityName: "Assignment",isPredicate:false) as! [Assignment]
        
        if(assignmentResults.count > 0){
            
            for assignmentdata in assignmentResults{
                
                
                let assignmentStatus = assignmentdata.status!
                
                let eventObject = eventDict[assignmentdata.eventId!]
                
                let objectEventAssignmentStruct:eventAssignmentDataStruct = eventAssignmentDataStruct(eventName:(eventObject?.eventName!)!,eventId: assignmentdata.eventId!, assignmentId: assignmentdata.id!, assignmentName: assignmentdata.name!, totalLocations: assignmentdata.totalLocations!, totalUnits: assignmentdata.totalUnits!, completeAssignment: assignmentdata.completePercent!,noOfClients:assignmentdata.noOfClients!,completedDate:assignmentdata.completedDate,assignedDate:assignmentdata.assignedDate)
                
                
                //show completed assignments as well
                if(Utilities.currentShowHideAssignments == true){
                    eventAssignmentDataArray.append(objectEventAssignmentStruct)
                    
                }
                else{
                    if(assignmentStatus != "Completed"){
                        eventAssignmentDataArray.append(objectEventAssignmentStruct)
                    }
                }
            }
            
        }
        
        if(Utilities.currentSortingFieldName == "Assignment"){
            if(Utilities.currentSortingTypeAscending){
                eventAssignmentDataArray = eventAssignmentDataArray.sorted { $0.assignmentName < $1.assignmentName }
            }
            else{
                eventAssignmentDataArray = eventAssignmentDataArray.sorted { $0.assignmentName > $1.assignmentName }
            }
        }
        else if(Utilities.currentSortingFieldName == "Event"){
            if(Utilities.currentSortingTypeAscending){
                eventAssignmentDataArray = eventAssignmentDataArray.sorted { $0.eventName < $1.eventName }
            }
            else{
                eventAssignmentDataArray = eventAssignmentDataArray.sorted { $0.eventName > $1.eventName }
            }
        }
        else{
            if(Utilities.currentSortingTypeAscending){
                
                eventAssignmentDataArray.sort(by: {$0.assignedDate?.compare($1.assignedDate as! Date) == .orderedAscending})
                
                eventAssignmentDataArray.sort(by: {$0.completedDate?.compare($1.completedDate as! Date) == .orderedAscending})
                
                
                
                
            }
            else{
                
                eventAssignmentDataArray.sort(by: {$0.assignedDate?.compare($1.assignedDate as! Date) == .orderedDescending})
                
                eventAssignmentDataArray.sort(by: {$0.completedDate?.compare($1.completedDate as! Date) == .orderedDescending})
                
                
                
            }
            
        }
        
        // assignmentArray.sort()
        
        tableView.reloadData()
        
        
        
        
    }
    
    
    
    func createEventDictionary(){
        
        
        
        let eventResults =  ManageCoreData.fetchData(salesforceEntityName: "AssignmentEvent", isPredicate:false) as! [AssignmentEvent]
        
        if(eventResults.count > 0){
            
            for eventData in eventResults{
                
                if eventDict[eventData.id!] == nil{
                    eventDict[eventData.id!] = AssignmentEventDO(eventId: eventData.id!, eventName: eventData.name!, startDate: eventData.startDate!, endDate: eventData.endDate!)
                }
                
                
            }
        }
        
    }
    
    
    
    // MARK: - Models
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chartResults.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath)as!ChartCollectionViewCell
        
        //cell.lblChart.text = chart1Label
        
        //  cell.chartView = UIView()
        
        if indexPath.row == 0
        {
            //R165 G225 B255
            circleChartData(custumView: cell.chartView, chartValue: 100, chartText: chart1Value, chartColor: UIColor(red: CGFloat(165.0/255), green: CGFloat(225.0/255), blue: CGFloat(255.0/255), alpha: 1),chartType:chart1Label)
            
            cell.lblChart.text = chart1Label
            
            //barChartData(custumView: cell.chartView)
            
            //cell.lblChart.text = chart1Label
            
        }
        
        if indexPath.row == 1
        {
            //Green R91 G192 B74
            circleChartData(custumView: cell.chartView, chartValue: 100, chartText: chart2Value, chartColor: UIColor(red: CGFloat(91.0/255), green: CGFloat(192.0/255), blue: CGFloat(74.0/255), alpha: 1),chartType:chart2Label)
            
            cell.lblChart.text = chart2Label
            
        }
        if indexPath.row == 2
        {
            //Red R206 G88 B127
            circleChartData(custumView: cell.chartView, chartValue: Float(chart3Value)!, chartText: chart3Value + "%", chartColor: UIColor(red: CGFloat(206.0/255), green: CGFloat(88.0/255), blue: CGFloat(127.0/255), alpha: 1),chartType:chart3Label)
            
            cell.lblChart.text = chart3Label
            
        }
        if indexPath.row == 3
        {
            //Yellow R229 G229 B137
            circleChartData(custumView: cell.chartView, chartValue: Float(chart4Value)!, chartText: chart4Value + "%", chartColor: UIColor(red: CGFloat(229.0/255), green: CGFloat(229.0/255), blue: CGFloat(137.0/255), alpha: 1),chartType:chart4Label)
            
            cell.lblChart.text = chart4Label
            // updateChartData(custumView: cell.chartView)
            
        }
        
        
        
        
        
        //cell.myLabel.text = self.items[indexPath.item]
        //cell.backgroundColor = UIColor.cyan // make cell more visible in our example project
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }
    
    
    // MARK: UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventAssignmentDataArray.count//assignmentArray.count
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
        
        cell.assignmentName.text = eventAssignmentDataArray[indexPath.row].assignmentName
        
        
        //let eventObject = eventDict[eventAssignmentDataArray[indexPath.row].eventId]
        
        
        cell.eventName.text = eventAssignmentDataArray[indexPath.row].eventName//eventObject?.eventName
        
        cell.locations.text = eventAssignmentDataArray[indexPath.row].totalLocations
        
        cell.units.text = eventAssignmentDataArray[indexPath.row].totalUnits
        
        cell.assignmentId.text = eventAssignmentDataArray[indexPath.row].assignmentId
        
        
        cell.completePercent.text = eventAssignmentDataArray[indexPath.row].completeAssignment //+ "%"
        
        cell.noOfClients.text = eventAssignmentDataArray[indexPath.row].noOfClients
        
        
        
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
        return  35.0
    }
    
    
    
    @IBAction func UnwindBackFromMapLocation(segue:UIStoryboardSegue) {
        
        if (self.revealViewController().frontViewPosition == FrontViewPosition.right)
        {
            //self.revealViewController().revealToggle(animated: true)
            self.revealViewController().revealToggle(animated: true)
        }
        
        
        print("UnwindBackFromMapLocation")
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Row selected, so set textField to relevant value, hide tableView
        // endEditing can trigger some other action according to requirements
        
        SalesforceConnection.assignmentId =  eventAssignmentDataArray[indexPath.row].assignmentId
        //assignmentIdArray[indexPath.row]
        SalesforceConnection.assignmentName = eventAssignmentDataArray[indexPath.row].assignmentName
        //assignmentArray[indexPath.row]
        
        
        
        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "sortingPopOverIdentifier" {
            
            let sortingVC = segue.destination as! SortingTableViewController
            sortingVC.preferredContentSize = CGSize(width: 375, height: 260)
            
            
            
            sortingVC.setShowHideCompletedAssignments{ [weak self] (isCompletedAssignments:Bool) -> Void in
                
                print(isCompletedAssignments)
                
                Utilities.currentShowHideAssignments = isCompletedAssignments
                self?.populateEventAssignmentData()
                //self?.mapView.setViewpoint(viewpoint)
            }
            
            sortingVC.setSortingEventAssignments{
                [weak self] (sortingFieldName:String,sortingType:Bool) -> Void in
                
                Utilities.currentSortingFieldName = sortingFieldName
                Utilities.currentSortingTypeAscending = sortingType
                
                self?.populateEventAssignmentData()
                
                print(sortingFieldName)
                print(sortingType)
                
                
            }
            
            //            let navcontroller = segue.destination as! UINavigationController
            //            let sortingVC = navcontroller.topViewController as! SortingTableViewController
            //            sortingVC.preferredContentSize = CGSize(width: 375, height: 220)
            //
            //            if let pop = sortingVC.popoverPresentationController {
            //                pop.passthroughViews = nil
            //            }
            
            
            //  controller.presentationController?.delegate = self
            //            controller.popoverPresentationController?.sourceView = self.view
            //            controller.popoverPresentationController?.sourceRect = self.searchBar.frame
            
            
            //controller.delegate = self
        }
    }
    
    
    //    
    //     func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    //        
    //        let currentCell = self.tableView.cellForRow(at: self.tableView.indexPathForSelectedRow!) as! EventAssignmentViewCell
    //        
    //        
    //        SalesforceConnection.assignmentId =  currentCell.assignmentId.text!
    //        SalesforceConnection.assignmentName = currentCell.assignmentName.text!
    //        
    //    }
    
    
}
