//
//  ChartViewModel.swift
//  EngageNYC
//
//  Created by Kamal on 12/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation

enum chartType:String{
    case totalUnits = "Total Units"
    case unitsCompleted = "Units Completed"
    case noResponse = "No Response"
    case followupNeeded = "FollowUp Needed"
}

class ChartViewModel{
    
    static func getViewModel() -> ChartViewModel {
        return ChartViewModel()
    }
    
}

//    func populateChartData(isTwoMinuteSync:Bool?=false){
//
//        chart1Label = ""
//        chart1Value = ""
//
//        chart2Label = ""
//        chart2Value = ""
//
//        chart3Label = ""
//        chart3Value = ""
//
//        chart4Label = ""
//        chart4Value = ""
//

//
//        if(isTwoMinuteSync!){
//
//            if(totalUnitsChart != nil){
//                totalUnitsChart.percentage = 100
//                totalUnitsChart.labelText = chart1Value
//            }
//            if(unitsCompletedChart != nil){
//                unitsCompletedChart.percentage = 100
//                unitsCompletedChart.labelText = chart2Value
//            }
//
//            if(noResponseChart != nil){
//                noResponseChart.percentage = Float(chart3Value)!
//                noResponseChart.labelText = chart3Value + "%"
//            }
//
//            if(followUpNeededChart != nil){
//                followUpNeededChart.percentage = Float(chart4Value)!
//                followUpNeededChart.labelText = chart4Value + "%"
//            }
//
//
//        }
//        else{
//            colChart.reloadData()
//        }
//
//
//
//    }


