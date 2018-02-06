//
//  DashboardViewModel.swift
//  EngageNYC
//
//  Created by Kamal on 12/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation

class DashboardViewModel{
    
    var dashboardInfo : DashboardInfo!
    var chartColorDict:[String:UIColor] = [:]
    
    static func getViewModel() -> DashboardViewModel {
        return DashboardViewModel()
    }
    
    
    func bindChartColor(){
        chartColorDict = [:]
        
        chartColorDict[chartType.totalUnits.rawValue] =   UIColor(red: CGFloat(165.0/255), green: CGFloat(225.0/255), blue: CGFloat(255.0/255), alpha: 1)
        chartColorDict[chartType.unitsCompleted.rawValue] =   UIColor(red: CGFloat(91.0/255), green: CGFloat(192.0/255), blue: CGFloat(74.0/255), alpha: 1)
        chartColorDict[chartType.noResponse.rawValue] =   UIColor(red: CGFloat(206.0/255), green: CGFloat(88.0/255), blue: CGFloat(127.0/255), alpha: 1)
        chartColorDict[chartType.followupNeeded.rawValue] =   UIColor(red: CGFloat(229.0/255), green: CGFloat(229.0/255), blue: CGFloat(137.0/255), alpha: 1)
        
    }
    
    
    func populateDashboard(){
        
        if(dashboardInfo == nil){
            dashboardInfo = DashboardInfo()
        }
        
        self.bindChartColor()
        
        self.populateChart()
        self.populateAssignment()
    }
    
    
    func populateChart(){
        
        
        var arrCharts = [ChartDO]()
        
        if let charts = ChartAPI.shared.getAllCharts(){
            for chart:Chart in charts{
                
                let objChart = ChartDO()
                objChart.chartLabel = chart.chartLabel
                objChart.chartValue = chart.chartValue
                objChart.chartColor = chartColorDict[objChart.chartLabel]
                objChart.percentage = chart.chartValue
                
                arrCharts.append(objChart)
                
            }
        }
        
        self.dashboardInfo.arrCharts = arrCharts
    }
    
    func populateAssignment(){
        
        //Not show Completed assignments by default
        
        //first get all assignments
        
        var arrAssignments = [AssignmentDO]()
        
        
//
//                        let objAssignment = AssignmentDO()
//                        objAssignment.assignmentId = "1"
//                        objAssignment.assignmentName = "QA Assignment"
//                        objAssignment.eventName = ""
//                        objAssignment.totalUnits = "1"
//                        objAssignment.totalContacts = "2"
//                        objAssignment.totalLocations = "3"
//                        objAssignment.completePercent = "100"
//                        objAssignment.completedDate = nil
//                        objAssignment.assignedDate = nil
//                        objAssignment.assignmentStatus = "assigned"
//
//         arrAssignments.append(objAssignment)
        
        
        if let assignments = AssignmentDetailAPI.shared.getAllAssignments(){
            for assignment:Assignment in assignments{

                let objAssignment = AssignmentDO()
                objAssignment.assignmentId = assignment.assignmentId
                objAssignment.assignmentName = assignment.assignmentName
                objAssignment.eventName = assignment.eventName
                objAssignment.totalUnits = assignment.totalUnits
                objAssignment.totalContacts = assignment.totalContacts
                objAssignment.totalLocations = assignment.totalLocations
                objAssignment.assignmentId = assignment.assignmentId
                objAssignment.completePercent = assignment.completePercent
                objAssignment.completedDate = assignment.completedDate
                objAssignment.assignedDate = assignment.assignedDate
                objAssignment.assignmentStatus = assignment.status


                arrAssignments.append(objAssignment)

            }
        }
        
        self.dashboardInfo.arrAssignments = arrAssignments
        
        
    }
    
    func getAssignmentHeader() -> [SortingHeaderCell]? {
        
        var header = [SortingHeaderCell]()
        
        header.append(SortingHeaderCell(withTitle: "Event Name", headerSubTitle: "", headerArrowPostion: .none, allignment: .left))
        header.append(SortingHeaderCell(withTitle: "Assignment Name", headerSubTitle: "", headerArrowPostion: .up, allignment: .left))
        header.append(SortingHeaderCell(withTitle: "Locations", headerSubTitle: "", headerArrowPostion: .none, allignment: .center))
        header.append(SortingHeaderCell(withTitle: " Units", headerSubTitle: "", headerArrowPostion: .none, allignment: .center))
        header.append(SortingHeaderCell(withTitle: "Complete Percent", headerSubTitle: "", headerArrowPostion: .none, allignment: .center))
         header.append(SortingHeaderCell(withTitle: "NoOfClients", headerSubTitle: "", headerArrowPostion: .none, allignment: .center))
        return header
    }
    
    
    
}
