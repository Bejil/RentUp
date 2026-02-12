//
//  RU_Reporting_Detail_ViewController.swift
//  RentUp
//
//  Created by Michaël Blin on 09/02/2026.
//

import UIKit
import SnapKit
import SwiftUI

public class RU_Reporting_Detail_Occupation_ViewController : RU_Reporting_Detail_ViewController {
    
    public override func loadView() {
        
        super.loadView()
        
        navigationItem.title = String(key: "reporting.detail.occupation.title")
    }
    
    public override func updateUI() {
        
        if let filteredBookings, !filteredBookings.isEmpty {
                
            monthes = .init()
            actualValues = []
            forecastValues = []
            
            let calendar = Calendar.current
            let now = Date()
            let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
            let firstStart = filteredBookings.map(\.dates.start).min() ?? currentMonthStart
            let lastEnd = filteredBookings.map(\.dates.end).max() ?? currentMonthStart
            let firstMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: firstStart)) ?? firstStart
            let lastMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: lastEnd)) ?? lastEnd
            let endMonthStart = max(lastMonthStart, currentMonthStart)
            var monthStart = firstMonthStart
            
            while monthStart <= endMonthStart {
                
                monthes?.append(monthStart)
                monthStart = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? monthStart
            }
            let pastBookings = filteredBookings.filter { $0.dates.end < now }
            
            monthes?.forEach({ month in
               
                let monthRange = calendar.range(of: .day, in: .month, for: month)
                let daysInMonth = monthRange?.count ?? 30
                let monthEnd = calendar.date(byAdding: .day, value: daysInMonth, to: month) ?? month
                
                func nights(_ b: RU_Booking) -> Int {
                    
                    let start = max(b.dates.start, month)
                    let end = min(b.dates.end, monthEnd)
                    return max(0, calendar.dateComponents([.day], from: start, to: end).day ?? 0)
                }
                
                let pastNights = pastBookings.reduce(0) { $0 + nights($1) }
                let actualValue = daysInMonth > 0 ? Double(pastNights) / Double(daysInMonth) * 100 : 0
                actualValues?.append(actualValue)
                
                let allNights = filteredBookings.reduce(0) { $0 + nights($1) }
                let forecastValue = daysInMonth > 0 ? Double(allNights) / Double(daysInMonth) * 100 : 0
                forecastValues?.append(forecastValue)
            })
            
            let months = monthes ?? []
            var chartData: [RU_Chart_View.Point] = []
            for (index, month) in months.enumerated() {
                if let actual = index < actualValues?.count ?? 0 ? actualValues?[index] : 0, let forecast = index < forecastValues?.count ?? 0 ? forecastValues?[index] : 0 {
                    chartData.append(RU_Chart_View.Point(month: month, value: actual, series: .actual))
                    chartData.append(RU_Chart_View.Point(month: month, value: forecast, series: .forecast))
                }
            }
            chartHostingController.rootView = RU_Chart_View(data: chartData)
        }
        
        super.updateUI()
    }
}
