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
        let pastBookings = filteredBookings.filter { $0.dates.end < now }
        let firstStart = filteredBookings.map(\.dates.start).min()!
        let lastEnd = filteredBookings.map(\.dates.end).max()!
        let firstMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: firstStart)) ?? firstStart
        let lastMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: lastEnd)) ?? lastEnd
        var monthStart = firstMonthStart
        monthes = []
        actualValues = []
        forecastValues = []
        var occupancySummaries: [String] = []
        var netSummaries: [String] = []
        
        while monthStart <= lastMonthStart {
            monthes?.append(monthStart)
            let monthRange = calendar.range(of: .day, in: .month, for: monthStart)
            let daysInMonth = monthRange?.count ?? 30
            let monthEnd = calendar.date(byAdding: .day, value: daysInMonth, to: monthStart) ?? monthStart
            
            func nightsInMonth(_ b: RU_Booking) -> Int {
                let start = max(b.dates.start, monthStart)
                let end = min(b.dates.end, monthEnd)
                return max(0, calendar.dateComponents([.day], from: start, to: end).day ?? 0)
            }
            func bookingNights(_ b: RU_Booking) -> Int {
                max(0, calendar.dateComponents([.day], from: b.dates.start, to: b.dates.end).day ?? 0)
            }
            func proratedHostTotal(_ b: RU_Booking) -> Double {
                let monthNights = nightsInMonth(b)
                guard monthNights > 0 else { return 0 }
                let totalNights = bookingNights(b)
                guard totalNights > 0 else { return 0 }
                guard let hostTotal = b.platform?.calculatePrice(for: b)?.hostTotal else { return 0 }
                return hostTotal * Double(monthNights) / Double(totalNights)
            }
            func uniqueClassifiedFees(for bookings: [RU_Booking]) -> Double {
                var classifieds: [RU_Classified] = []
                bookings.compactMap({ $0.classified }).forEach {
                    if !classifieds.contains($0) {
                        classifieds.append($0)
                    }
                }
                return Double(classifieds.compactMap({ $0.fees }).reduce(0, +))
            }
            
            // Charges : une seule fois par classified par mois (ensemble des classifieds ayant une réservation dans le mois)
            func chargesActual() -> Double {
                return uniqueClassifiedFees(for: pastBookings.filter({ nightsInMonth($0) > 0 }))
            }
            func chargesForecast() -> Double {
                return uniqueClassifiedFees(for: filteredBookings.filter({ nightsInMonth($0) > 0 }))
            }
            
            // Actuel : uniquement pour les mois <= aujourd'hui (période : plus ancienne résa → aujourd'hui)
            let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
            let isInActualPeriod = monthStart <= currentMonthStart
            var revenueActual: Double = 0
            if isInActualPeriod {
                for b in pastBookings {
                    revenueActual += proratedHostTotal(b)
                }
            }
            let chargesActual = isInActualPeriod ? chargesActual() : 0
            let actual = chargesActual > 0 ? revenueActual / chargesActual * 100 : (revenueActual > 0 ? 100 : 0)
            actualValues?.append(actual)
            
            // Prévisionnel : toutes les réservations sur la période (plus ancienne → plus lointaine)
            var revenueForecast: Double = 0
            for b in filteredBookings {
                revenueForecast += proratedHostTotal(b)
            }
            let chargesForecast = chargesForecast()
            let forecast = chargesForecast > 0 ? revenueForecast / chargesForecast * 100 : (revenueForecast > 0 ? 100 : 0)
            forecastValues?.append(forecast)
            
            let pastNightsOcc = pastBookings.reduce(0) { $0 + nightsInMonth($1) }
            let forecastNightsOcc = filteredBookings.reduce(0) { $0 + nightsInMonth($1) }
            let occPctActual = daysInMonth > 0 ? Double(pastNightsOcc) / Double(daysInMonth) * 100 : 0
            let occPctForecast = daysInMonth > 0 ? Double(forecastNightsOcc) / Double(daysInMonth) * 100 : 0
            occupancySummaries.append(String(
                format: String(key: "reporting.cell.occupancyLine"),
                occPctActual, pastNightsOcc, daysInMonth, occPctForecast, forecastNightsOcc
            ))
            netSummaries.append(String(
                format: String(key: "reporting.cell.netLine"),
                RU_Reporting_Detail_ViewController.ReportingMonthMetrics.formatNetEUR(revenueActual),
                RU_Reporting_Detail_ViewController.ReportingMonthMetrics.formatNetEUR(revenueForecast)
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
