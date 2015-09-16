//
//  LineChartView.swift
//  DayStep
//
//  Created by Junne on 9/7/15.
//  Copyright (c) 2015 Junne. All rights reserved.
//

import UIKit
import PNChartSwift

class LineChartView: UIView {
    internal var lineChart:PNLineChart = PNLineChart(frame: CGRectMake(0, 135.0, 320, 200.0))
    func addLineChart(myData:[Int]) {
        lineChart.yLabelHeight = 30.0
        lineChart.yLabelNum = 30000.0
        lineChart.yValueMax = 30000.0
        lineChart.showLabel = true
        lineChart.backgroundColor = UIColor.clearColor()
        lineChart.xLabels = myData.map({
            (number:Int) -> String in
                    return String(number)
                })
        lineChart.showCoordinateAxis = true
        var data01:PNLineChartData = PNLineChartData()
        data01.color = PNGreenColor
        data01.itemCount = myData.count
        data01.inflexionPointStyle = PNLineChartData.PNLineChartPointStyle.PNLineChartPointStyleCycle
        data01.getData = ({(index: Int) -> PNLineChartDataItem in
            var yValue:CGFloat = CGFloat(myData[index])
            var item = PNLineChartDataItem(y: yValue)
            return item
        })
        
        lineChart.chartData = [data01]
        lineChart.strokeChart()
        self.addSubview(lineChart)

    }

}
