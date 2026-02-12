//
//  RU_Chart_View.swift
//  RentUp
//
//  Created by Michaël Blin on 11/02/2026.
//

import SwiftUI
import Charts

public struct RU_Chart_View: View {
    
    public enum Series: String, CaseIterable, Plottable {
        
        case actual = "Actuelle"
        case forecast = "Prévisionnelle"
    }

    public struct Point: Identifiable {
        
        public let id = UUID()
        public let month: Date
        public let value: Double
        public let series: Series
    }
    
    let data: [Point]
    
    private var primaryColor: Color { Color(uiColor: Colors.Primary) }
    private var secondaryColor: Color { Color(uiColor: Colors.Secondary) }
    
    /// Borne supérieure de l'échelle Y : au moins 100, ou max des données + marge (arrondi au multiple de 10 supérieur, ex. max 120 → 130).
    private var yAxisUpperBound: Double {
        let maxVal = data.map(\.value).max() ?? 0
        guard maxVal > 100 else { return 100 }
        return (maxVal / 10).rounded(.up) * 10 + 10
    }
    
    public  var body: some View {
        
        Chart(data) { point in
            LineMark(
                x: .value("Mois", point.month),
                y: .value("%", point.value)
            )
            .foregroundStyle(by: .value("Série", point.series))
            .symbol(by: .value("Série", point.series))
            .interpolationMethod(.monotone)
        }
        .chartYScale(domain: 0 ... yAxisUpperBound)
        .chartForegroundStyleScale([
            Series.actual: primaryColor,
            Series.forecast: secondaryColor
        ])
        .chartSymbolScale([
            Series.actual: Circle(),
            Series.forecast: Circle()
        ])
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.abbreviated).year(.twoDigits))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .stride(by: 25)) { value in
                AxisGridLine()
                if let n = value.as(Double.self) {
                    AxisValueLabel("\(Int(n))%")
                }
            }
        }
        .chartLegend(spacing: UI.Margins)
        .padding(.top, UI.Margins)
        .padding(.trailing, UI.Margins/3)
    }
}
