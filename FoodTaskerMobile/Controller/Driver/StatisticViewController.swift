//
//  StatisticViewController.swift
//  FoodTaskerMobile
//
//  Created by Dylan on 2020/02/12.
//  Copyright © 2020 Dylan. All rights reserved.
//

import UIKit
import Charts

class StatisticViewController: UIViewController {

    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var viewChart: BarChartView!
    
    var weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        //#1 Initialize chart
        self.initializeChart()
        //#2 load chart
        self.loadDataToChart()
    }
    
    func initializeChart() {
        viewChart.noDataText = "No Data"
        viewChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInBounce)
        viewChart.xAxis.labelPosition = .bottom
        
        viewChart.chartDescription?.text = ""
        
        viewChart.legend.enabled = false
        viewChart.scaleYEnabled = false
        viewChart.scaleXEnabled = false
        viewChart.pinchZoomEnabled = false
        viewChart.doubleTapToZoomEnabled = false
        
        viewChart.leftAxis.axisMinimum = 0.0
        viewChart.leftAxis.axisMaximum = 100
        viewChart.highlighter = nil
        viewChart.rightAxis.enabled = false
        viewChart.xAxis.drawGridLinesEnabled = false
    }
    
    func loadDataToChart() {
        APIManager.shared.getDriverRevenue { (json) in
            if json != nil {
                let revenue = json["revenue"]
                
                var dataEntries: [BarChartDataEntry] = []
                
                for i in 0..<self.weekdays.count {
                    let day = self.weekdays[i]
                    let dataEntry = BarChartDataEntry(x: Double(i), y: revenue[day].double!)
                    dataEntries.append(dataEntry)
                }
                
                let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Revenue by day")
                chartDataSet.colors = ChartColorTemplates.material()
                
                let chartData = BarChartData()
                chartData.addDataSet(chartDataSet)
                self.viewChart.data = chartData
            }
        }
    }
}
