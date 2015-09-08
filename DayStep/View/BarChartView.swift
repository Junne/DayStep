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
    func addBarChart() {
        
        barChart.backgroundColor = UIColor.clearColor()
        barChart.animationType = .Waterfall
        barChart.labelMarginTop = 5.0
        barChart.xLabels = ["SEP 1","SEP 2","SEP 3","SEP 4","SEP 5","SEP 6","SEP 7"]
        barChart.yValues = [1,24,12,18,30,10,21]
        barChart.strokeChart()        
        self.addSubview(barChart)
    }

}
