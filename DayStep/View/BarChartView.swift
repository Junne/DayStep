//
//  BarChartView.swift
//  DayStep
//
//  Created by Junne on 9/7/15.
//  Copyright (c) 2015 Junne. All rights reserved.
//

import UIKit
import PNChartSwift

class BarChartView: UIView {
    
    var barChart = PNBarChart(frame: CGRectMake(0, 135.0, 320.0, 200.0))
    func addBarChart(myData:[Int]) {
        
        barChart.backgroundColor = UIColor.clearColor()
        barChart.animationType = .Waterfall
        barChart.labelMarginTop = 5.0
        barChart.yValues = myData
        barChart.showLabel = true
        barChart.xLabels = myData.map({
            (number:Int) -> String in
            return String(number)
        })
        barChart.strokeChart()
        self.addSubview(barChart)
    }

}
