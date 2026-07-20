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
        
        guard let filteredBookings, !filteredBookings.isEmpty else { return }
        
        let calendar = Calendar.current
        let now = Date()
        let list = RU_Reporting_Detail_ViewController.ReportingMonthMetrics.eligibleBookings(filteredBookings)
        guard !list.isEmpty else { return }
        
        monthes = .init()
        actualValues = []
        forecastValues = []
        var occupancySummaries: [String] = []
        var netSummaries: [String] = []
        
        let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
        let earliestStart = list.map(\.dates.start).min()
        let latestEnd = list.map(\.dates.end).max()
        let monthRange = metricsPeriod.monthRange(
            calendar: calendar,
            now: now,
            earliestBookingStart: earliestStart,
            latestBookingEnd: latestEnd
        )
        var monthStart = monthRange.firstMonthStart
        
        while monthStart <= monthRange.lastMonthStart {
            
            monthes?.append(monthStart)
            monthStart = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? monthStart
        }
        let pastBookings = list.filter { $0.dates.end < now }
        
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
            
            let allNights = list.reduce(0) { $0 + nights($1) }
            let forecastValue = daysInMonth > 0 ? Double(allNights) / Double(daysInMonth) * 100 : 0
            forecastValues?.append(forecastValue)
            
            occupancySummaries.append(String(
                format: String(key: "reporting.cell.occupancyLine"),
                actualValue, pastNights, daysInMonth, forecastValue, allNights
            ))
            
            let isInActualPeriod = calendar.compare(month, to: currentMonthStart, toGranularity: .month) != .orderedDescending
            var revenueActual: Double = 0
            if isInActualPeriod {
                for b in pastBookings {
                    revenueActual += RU_Reporting_Detail_ViewController.ReportingMonthMetrics.proratedHostTotal(booking: b, monthStart: month, calendar: calendar)
                }
            }
            var revenueForecast: Double = 0
            for b in list {
                revenueForecast += RU_Reporting_Detail_ViewController.ReportingMonthMetrics.proratedHostTotal(booking: b, monthStart: month, calendar: calendar)
            }
            netSummaries.append(String(
                format: String(key: "reporting.cell.netLine"),
                RU_Reporting_Detail_ViewController.ReportingMonthMetrics.formatNetEUR(revenueActual),
                RU_Reporting_Detail_ViewController.ReportingMonthMetrics.formatNetEUR(revenueForecast)
            ))
        })
        
        reportingCellOccupancySummaries = occupancySummaries
        reportingCellNetSummaries = netSummaries
        
        let months = monthes ?? []
        var chartData: [RU_Chart_View.Point] = []
        for (index, month) in months.enumerated() {
            if let actual = index < actualValues?.count ?? 0 ? actualValues?[index] : 0, let forecast = index < forecastValues?.count ?? 0 ? forecastValues?[index] : 0 {
                chartData.append(RU_Chart_View.Point(month: month, value: actual, series: .actual))
                chartData.append(RU_Chart_View.Point(month: month, value: forecast, series: .forecast))
            }
        }
        chartHostingController.rootView = RU_Chart_View(data: chartData)
        
        super.updateUI()
    }
}
