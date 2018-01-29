//
//  EventsDetailViewModel.swift
//  EngageNYCDev
//
//  Created by Kamal on 09/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation

class EventsDetailViewModel{
    
    var metadataDynamicDict:[String:AnyObject] = [:]
    
    var sectionFieldDict : [String:[MetadataConfigDO]] = [:]
    var orderedSectionFieldDict: [Int: [String:[MetadataConfigDO]]] = [:]
    
    var tempArray = [MetadataConfigDO]()
    
    static func getViewModel() -> EventsDetailViewModel {
        return EventsDetailViewModel()
    }
    
    func loadEventsDetail(objEvent:EventDO)->[MetadataConfigObjects]{
        
        if let eventConfig = EventsConfigAPI.shared.getEventsConfig(){
            parseJson(jsonObject:eventConfig.configData as! Dictionary<String, AnyObject>)
        }
        
        return Utility.convertDictToArray(orderedSectionFieldDict: orderedSectionFieldDict)
     
    }
    
    
    private func parseJson(jsonObject: Dictionary<String, AnyObject>){
        
        guard let sectionResults = jsonObject["Section"] as? [[String: AnyObject]] else { return }
        
        var sequence = 0
        
        for sectionData in sectionResults {
            
            guard let fieldListResults = sectionData["fieldList"] as? [[String: AnyObject]]  else { break }
            
            let sectionName = sectionData["sectionName"] as? String  ?? ""
            
            sequence = sequence + 1
            
            sectionFieldDict = [:]
            
            tempArray = []
            
            for fieldListData in fieldListResults {
                
                let apiName = fieldListData["apiName"] as? String  ?? ""
                let dataType = fieldListData["dataType"] as? String  ?? ""
                
                if sectionFieldDict[sectionName] != nil {
                    
                    var arrayValue:[MetadataConfigDO] =  sectionFieldDict[sectionName]!
                    arrayValue.append(MetadataConfigDO(sequence: fieldListData["sequence"] as? String  ?? "", pickListValue: fieldListData["picklistValue"] as? String  ?? "", fieldName: fieldListData["fieldName"] as? String  ?? "", dataType: dataType, apiName: apiName,sectionName:sectionName))
                    
                    sectionFieldDict[sectionName] = arrayValue
                    
                    orderedSectionFieldDict[sequence] = sectionFieldDict
                }
                    
                    
                else{
                    
                    tempArray.append(MetadataConfigDO(sequence: fieldListData["sequence"] as? String  ?? "", pickListValue: fieldListData["picklistValue"] as? String  ?? "", fieldName: fieldListData["fieldName"] as? String  ?? "", dataType: dataType, apiName: apiName,sectionName:sectionName))
                    
                    
                    
                    sectionFieldDict[sectionName] = tempArray
                    
                    orderedSectionFieldDict[sequence] = sectionFieldDict
                    
                }
            }
        }
    }

    
    
    
}
