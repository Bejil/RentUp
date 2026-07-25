//
//  RU_Reporting_Detail_Profitability_ViewController.swift
//  RentUp
//
//  Created by Michaël Blin on 11/02/2026.
//

import UIKit
import SnapKit
import SwiftUI

public class RU_Reporting_Detail_Profitability_ViewController: RU_Reporting_Detail_ViewController {
    
    public override func loadView() {
        
        super.loadView()
        
        navigationItem.title = String(key: "reporting.detail.profitability.title")
    }
    
    public override func updateUI() {
        
        guard let filteredBookings, !filteredBookings.isEmpty else { return }
        
        let calendar = Calendar.current
        let now = Date()
        let list = RU_Reporting_Detail_ViewController.ReportingMonthMetrics.eligibleBookings(filteredBookings)
        guard !list.isEmpty else { return }
        
        let pastBookings = list.filter { $0.dates.end < now }
        let earliestStart = list.map(\.dates.start).min()
        let latestEnd = list.map(\.dates.end).max()
        let monthRange = metricsPeriod.monthRange(
            calendar: calendar,
            now: now,
            earliestBookingStart: earliestStart,
            latestBookingEnd: latestEnd
        )
        
        var monthStart = monthRange.firstMonthStart
        monthes = []
        actualValues = []
        forecastValues = []
        var occupancySummaries: [String] = []
        var netSummaries: [String] = []
        
        while monthStart <= monthRange.lastMonthStart {
            monthes?.append(monthStart)
            let daysInMonth = RU_Reporting_Detail_ViewController.ReportingMonthMetrics.daysInMonth(monthStart: monthStart, calendar: calendar)
            
            let metrics = RU_Reporting_Detail_ViewController.ReportingMonthMetrics.profitabilityPercentages(
                monthStart: monthStart,
                bookings: filteredBookings,
                now: now,
                calendar: calendar
            )
            actualValues?.append(metrics.actual)
            forecastValues?.append(metrics.forecast)
            
            let pastNightsOcc = pastBookings.reduce(0) {
                $0 + RU_Reporting_Detail_ViewController.ReportingMonthMetrics.nightsInMonth(booking: $1, monthStart: monthStart, calendar: calendar)
            }
            let forecastNightsOcc = list.reduce(0) {
                $0 + RU_Reporting_Detail_ViewController.ReportingMonthMetrics.nightsInMonth(booking: $1, monthStart: monthStart, calendar: calendar)
            }
            let occPctActual = daysInMonth > 0 ? Double(pastNightsOcc) / Double(daysInMonth) * 100 : 0
            let occPctForecast = daysInMonth > 0 ? Double(forecastNightsOcc) / Double(daysInMonth) * 100 : 0
            occupancySummaries.append(String(
                format: String(key: "reporting.cell.occupancyLine"),
                occPctActual, pastNightsOcc, daysInMonth, occPctForecast, forecastNightsOcc
            ))
            netSummaries.append(String(
                format: String(key: "reporting.cell.netLine"),
                RU_Reporting_Detail_ViewController.ReportingMonthMetrics.formatNetEUR(metrics.revenueActual),
                RU_Reporting_Detail_ViewController.ReportingMonthMetrics.formatNetEUR(metrics.revenueForecast)
            ))
            
            monthStart = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? monthStart
        }
        
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
