//
//  ChartCollectionViewCell.swift
//  Knock
//
//  Created by Cloudzeg Laptop on 6/29/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class ChartCollectionViewCell: UICollectionViewCell
{
    
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var lblChart: UILabel!
    
    func setupView(forCellObject object : ChartDO, index: IndexPath) {
        
        if(object.chartLabel == chartType.totalUnits.rawValue || object.chartLabel == chartType.unitsCompleted.rawValue)
        {
            object.percentage = "100"
        }
        self.circleChartData(objChart: object)
        lblChart.text = object.chartLabel

    }
    
    func circleChartData(objChart:ChartDO)
    {
        if let gview = chartView.viewWithTag(1000)
        {
            gview.removeFromSuperview()
        }
        let gaugeView = GaugeView(frame: chartView.frame)
        gaugeView.tag = 1000
        gaugeView.percentage = Float(objChart.percentage)!
        
        gaugeView.labelText = objChart.chartValue
        
        gaugeView.thickness = 20
    
        gaugeView.labelFont = UIFont.init(name: "Arial", size: 17.0)
        
        gaugeView.labelColor = UIColor.black
        gaugeView.gaugeBackgroundColor = UIColor(red: CGFloat(204.0/255), green: CGFloat(204.0/255), blue: CGFloat(204.0/255), alpha: 1)
        gaugeView.gaugeColor = objChart.chartColor
        
        gaugeView.isUserInteractionEnabled = true
        gaugeView.accessibilityLabel = "Gauge"
        
        
        chartView.addSubview(gaugeView)
        
    }
    
   
    
}
