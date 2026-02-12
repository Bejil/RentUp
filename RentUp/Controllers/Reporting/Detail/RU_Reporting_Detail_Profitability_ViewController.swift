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
            
            // Charges : une seule fois par classified par mois (ensemble des classifieds ayant une réservation dans le mois)
            func chargesActual() -> Double {
                var classifiedFees: [String: Int] = [:]
                for b in pastBookings {
                    if nightsInMonth(b) > 0, let c = b.classified {
                        classifiedFees[c.id] = c.fees ?? 0
                    }
                }
                return Double(classifiedFees.values.reduce(0, +))
            }
            func chargesForecast() -> Double {
                var classifiedFees: [String: Int] = [:]
                for b in filteredBookings {
                    if nightsInMonth(b) > 0, let c = b.classified {
                        classifiedFees[c.id] = c.fees ?? 0
                    }
                }
                return Double(classifiedFees.values.reduce(0, +))
            }
            
            // Actuel : uniquement pour les mois <= aujourd'hui (période : plus ancienne résa → aujourd'hui)
            let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
            let isInActualPeriod = monthStart <= currentMonthStart
            var revenueActual: Double = 0
            if isInActualPeriod {
                for b in pastBookings {
                    if nightsInMonth(b) > 0, let calc = b.platform?.calculatePrice(for: b) {
                        revenueActual += calc.hostTotal
                    }
                }
            }
            let chargesActual = isInActualPeriod ? chargesActual() : 0
            let actual = chargesActual > 0 ? revenueActual / chargesActual * 100 : (revenueActual > 0 ? 100 : 0)
            actualValues?.append(actual)
            
            // Prévisionnel : toutes les réservations sur la période (plus ancienne → plus lointaine)
            var revenueForecast: Double = 0
            for b in filteredBookings {
                if nightsInMonth(b) > 0, let calc = b.platform?.calculatePrice(for: b) {
                    revenueForecast += calc.hostTotal
                }
            }
            let chargesForecast = chargesForecast()
            let forecast = chargesForecast > 0 ? revenueForecast / chargesForecast * 100 : (revenueForecast > 0 ? 100 : 0)
            forecastValues?.append(forecast)
            
            monthStart = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? monthStart
        }
        
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
