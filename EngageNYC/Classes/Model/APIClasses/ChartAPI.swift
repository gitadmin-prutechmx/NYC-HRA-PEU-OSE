//
//  ChartAPI.swift
//  EngageNYCDev
//
//  Created by Kamal on 11/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation
import SalesforceSDKCore

final class ChartAPI : SFCommonAPI
{
    
    private static var sharedInstance: ChartAPI = {
        let instance = ChartAPI()
        return instance
    }()
    
    class var shared:ChartAPI!{
        get{
            return sharedInstance
        }
    }
    
    /// Get Charts Data from rest api. We are saving these to core data for offline use.
    ///
    /// - Parameters:
    ///   - callback: callback block.
    ///   - failure: failure block.
    //func syncDownWithCompletion(completion: @escaping (()->()), failure: @escaping ((String)->()))
    func syncDownWithCompletion(completion: @escaping (()->()))
    {
        var externalIdParams : [String:String] = [:]
        
        let req = SFRestRequest(method: .POST, path: SalesforceRestApiUrl.assignmentdetailchart, queryParams: nil)
        req.endpoint = ""
        
        if let userObject = UserDetailAPI.shared.getUserDetail(){
            externalIdParams["externalId"] = userObject.externalId
        }
        
        do {
            
            let bodyData = try JSONSerialization.data(withJSONObject: externalIdParams, options: [])
            req.setCustomRequestBodyData(bodyData, contentType: "application/json")
        }
        catch{
            
            
        }
        
        self.sendRequest(request: req, callback: { (response) in
            self.ChartsFromJSONList(jsonResponse: response)
            completion()
        }) { (error) in
            print(error)
            //failure(error)
        }
    }
    
    /// Get all the events from core data.
    ///
    /// - Returns: array of events.
    func getAllCharts()->[Chart]? {
        
        let chartResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.chart.rawValue ,isPredicate:false) as? [Chart]
        
        return chartResults
    }
    
    
    /// Convert the provided JSON into array of Events objects.
    ///
    /// - Parameter jsonResponse: json fetched from api.
    /// - Returns: nothing.
    private func ChartsFromJSONList(jsonResponse:Any){
        
        //First Delete all event records from Core data then insert
        
        ManageCoreData.DeleteAllRecords(salesforceEntityName: coreDataEntity.chart.rawValue,completion: { isSuccess in
            
            ChartAPI.fromJSONObject(jsonObject: jsonResponse as! NSDictionary)
            
        })
        
    }
    
}

extension ChartAPI {
    
    /// Convert JSON into object.
    ///
    /// - Parameter jsonObject: fetched JSON from api.
    /// - Returns: Nothing.
    class func fromJSONObject(jsonObject:NSDictionary){
        
        //Chart
       
        let chart1  = jsonObject.value(forKey: "Chart1") as? [String: AnyObject]
        let chart2  = jsonObject.value(forKey: "Chart2") as? [String: AnyObject]
        let chart3  = jsonObject.value(forKey: "Chart3") as? [String: AnyObject]
        let chart4  = jsonObject.value(forKey: "Chart4") as? [String: AnyObject]
        
        
        
        
        let chart1Obj = Chart(context: context)
        chart1Obj.chartType = "Chart1"
        chart1Obj.chartField = "TotalUnits"
        chart1Obj.chartLabel = chartType.totalUnits.rawValue
        chart1Obj.chartValue = String(chart1?["TotalUnits"] as! Int)
        
        print(chart1Obj.chartValue!)
        
        appDelegate.saveContext()
        
        
        
        
        let chart2Object = Chart(context: context)
        chart2Object.chartType = "Chart2"
        chart2Object.chartField = "UnitsCompleted"
        chart2Object.chartLabel = chartType.unitsCompleted.rawValue
        chart2Object.chartValue = String(chart2?["UnitsCompleted"] as! Int)
        
        print(chart2Object.chartValue!)
        
        appDelegate.saveContext()
        
        let chart3Object = Chart(context: context)
        chart3Object.chartType = "Chart3"
        chart3Object.chartField = "NoResponse"
        chart3Object.chartLabel = chartType.noResponse.rawValue
        chart3Object.chartValue = String(chart3?["NoResponse"] as! Int)
        
        print( chart3Object.chartValue!)
        
        appDelegate.saveContext()
        
        let chart4Object = Chart(context: context)
        chart4Object.chartType = "Chart4"
        chart4Object.chartField = "FollowUpNeeded"
        chart4Object.chartLabel = chartType.followupNeeded.rawValue
        chart4Object.chartValue = String(chart4?["FollowUpNeeded"] as! Int)
        
        print(chart4Object.chartValue!)
        
        appDelegate.saveContext()
        
        
        
    }
}
