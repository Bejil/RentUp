//
//  RU_Reporting_Detail_ViewController.swift
//  RentUp
//
//  Created by Michaël Blin on 09/02/2026.
//

import UIKit
import SnapKit
import SwiftUI
import Charts

// MARK: - Données et vue Swift Charts

private enum OccupancySeries: String, CaseIterable, Plottable {
    case actual = "Actuelle"
    case forecast = "Prévisionnelle"
}

private struct OccupancySeriesPoint: Identifiable {
    let id = UUID()
    let month: Date
    let value: Double
    let series: OccupancySeries
}

private struct OccupancyChartView: View {
    let data: [OccupancySeriesPoint]
    
    private var primaryColor: Color { Color(uiColor: Colors.Primary) }
    private var secondaryColor: Color { Color(uiColor: Colors.Secondary) }
    
    var body: some View {
        Chart(data) { point in
            LineMark(
                x: .value("Mois", point.month),
                y: .value("%", point.value)
            )
            .foregroundStyle(by: .value("Série", point.series))
            .symbol(by: .value("Série", point.series))
            .interpolationMethod(.linear)
        }
        .chartYScale(domain: 0 ... 100)
        .chartForegroundStyleScale([
            OccupancySeries.actual: primaryColor,
            OccupancySeries.forecast: secondaryColor
        ])
        .chartSymbolScale([
            OccupancySeries.actual: Circle(),
            OccupancySeries.forecast: Circle()
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

public class RU_Reporting_Detail_ViewController : RU_ViewController {
    
    private var bookings:[RU_Booking]? {
        
        didSet {
            
            let sortedBookings = bookings?.sorted { $0.dates.start > $1.dates.start }
            filteredBookings = sortedBookings
        }
    }
    private var filteredBookings:[RU_Booking]? {
        
        didSet {
            
            contentView.dismissPlaceholder()
            
            if filteredBookings?.isEmpty ?? true {
                
                contentView.showPlaceholder(.Empty)
            }
            
            updateUI()
        }
    }
    private var monthes:[Date]?
    private var currentFilterName:String? {
        
        didSet {
            
            updateFilterNavigationItem()
        }
    }
    private lazy var tableView:RU_TableView = {
        
        $0.register(RU_Reporting_TableViewCell.self, forCellReuseIdentifier: RU_Reporting_TableViewCell.identifier)
        $0.delegate = self
        $0.dataSource = self
        return $0
        
    }(RU_TableView(frame: .zero, style: .plain))
    private lazy var chartHostingController: UIHostingController<OccupancyChartView> = .init(rootView: OccupancyChartView(data: .init()))
    private lazy var chartScrollView:UIScrollView = {
        
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = .clear
        
        $0.addSubview(chartHostingController.view)
        chartHostingController.view.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.height.equalToSuperview()
            self.chartHostingWidthConstraint = make.width.equalTo(0).constraint
        }
        addChild(chartHostingController)
        chartHostingController.didMove(toParent: self)
        
        return $0
        
    }(UIScrollView())
    private var chartHostingWidthConstraint: Constraint?
    private static let chartMonthWidth: CGFloat = 5 * UI.Margins
    private static let chartScrollThreshold = 4
    
    public override func loadView() {
        
        super.loadView()
        
        updateFilterNavigationItem()
        navigationItem.title = String(key: "reporting.detail.occupation.title")
        
        let chartContainerView = UIView()
        chartContainerView.backgroundColor = Colors.Background.View
        chartContainerView.layer.cornerRadius = UI.CornerRadius
        chartContainerView.layer.shadowColor = UIColor.black.cgColor
        chartContainerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        chartContainerView.layer.shadowOpacity = 0.08
        chartContainerView.layer.shadowRadius = UI.Margins
        chartContainerView.snp.makeConstraints { make in
            make.height.equalTo(15 * UI.Margins)
        }
        chartContainerView.addSubview(chartScrollView)
        chartScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UI.Margins)
        }
        view.addSubview(chartContainerView)
        
        view.addSubview(tableView)
        
        chartContainerView.snp.makeConstraints { make in
            make.top.right.left.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
            make.bottom.equalTo(tableView.snp.top).offset(-UI.Margins)
        }
        
        tableView.snp.makeConstraints { make in
            make.bottom.right.left.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
            make.top.equalTo(chartContainerView.snp.bottom).inset(UI.Margins)
        }
        
        NotificationCenter.add(.updateBookings) { [weak self] _ in
            
            self?.updateData()
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        updateData()
    }
    
    public override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        let count = monthes?.count ?? 0
        let contentWidth: CGFloat = count > Self.chartScrollThreshold ? CGFloat(count) * Self.chartMonthWidth : chartScrollView.bounds.width
        chartHostingWidthConstraint?.update(offset: contentWidth)
        chartScrollView.contentSize = CGSize(width: contentWidth, height: chartScrollView.bounds.height)
    }
    
    private func updateFilterNavigationItem() {
        
        var children:[UIMenuElement] = .init()
        
        children.append(UIAction(title: String(key: "reporting.filter.reset"), image: UIImage(systemName: "arrow.counterclockwise"), attributes: .destructive, handler: { [weak self] _ in
            
            self?.currentFilterName = nil
            self?.filteredBookings = self?.bookings
        }))
        
        if let platforms = RU_Platform.all, !platforms.isEmpty {
            
            children.append(UIMenu(title: String(key: "reporting.filter.platform"), children: platforms.compactMap({ platform in
                
                if let name = platform.type?.name {
                    
                    return UIAction(title: name, handler: { [weak self] _ in
                        
                        self?.currentFilterName = name
                        self?.filteredBookings = self?.bookings?.filter({ $0.platform == platform })
                    })
                }
                
                return nil
            })))
        }
        
        RU_Classified.getAll { [weak self] error, classifieds in
            
            if let classifieds, !classifieds.isEmpty {
                
                children.append(UIMenu(title: String(key: "reporting.filter.classified"), children: classifieds.compactMap({ classified in
                    
                    if let name = classified.name {
                        
                        return UIAction(title: name, handler: { [weak self] _ in
                            
                            self?.currentFilterName = name
                            self?.filteredBookings = self?.bookings?.filter({ $0.classified == classified })
                        })
                    }
                    
                    return nil
                })))
            }
            
            if !children.isEmpty {
                
                let buttonTitle:String
                if let filterName = self?.currentFilterName {
                    buttonTitle = String(key: "reporting.filter.active") + filterName
                }
                else {
                    buttonTitle = String(key: "reporting.filter.button")
                }
                
                self?.navigationItem.rightBarButtonItem = .init(title: buttonTitle, menu: .init(title: String(key: "reporting.filter.menu.title"), children: children))
            }
        }
    }
    
    private func updateData() {
        
        contentView.showPlaceholder(.Loading)
        
        RU_Booking.getAll { [weak self] error, bookings in
            
            self?.contentView.dismissPlaceholder()
            
            if let error {
                
                self?.contentView.showPlaceholder(.Error, error) { [weak self] _ in
                    
                    self?.contentView.dismissPlaceholder()
                    self?.updateData()
                }
            }
            else {
                
                self?.bookings = bookings
            }
        }
    }
    
    private func updateUI() {
        
        if let filteredBookings, !filteredBookings.isEmpty {
                
            monthes = .init()
            var actualValues:[Double] = .init()
            var forecastValues:[Double] = .init()
            
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
                actualValues.append(actualValue)
                
                let allNights = filteredBookings.reduce(0) { $0 + nights($1) }
                let forecastValue = daysInMonth > 0 ? Double(allNights) / Double(daysInMonth) * 100 : 0
                forecastValues.append(forecastValue)
            })
            
            let months = monthes ?? []
            var chartData: [OccupancySeriesPoint] = []
            for (index, month) in months.enumerated() {
                let actual = index < actualValues.count ? actualValues[index] : 0
                let forecast = index < forecastValues.count ? forecastValues[index] : 0
                chartData.append(OccupancySeriesPoint(month: month, value: actual, series: .actual))
                chartData.append(OccupancySeriesPoint(month: month, value: forecast, series: .forecast))
            }
            chartHostingController.rootView = OccupancyChartView(data: chartData)
            
            tableView.reloadData()
            
            if let idx = monthes?.firstIndex(where: { calendar.isDate($0, equalTo: currentMonthStart, toGranularity: .month) }), idx < (monthes?.count ?? 0) {
                
                tableView.selectRow(at: IndexPath(row: idx, section: 0), animated: false, scrollPosition: .middle)
            }
        }
    }
}

extension RU_Reporting_Detail_ViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return monthes?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: RU_Reporting_TableViewCell.identifier, for: indexPath) as! RU_Reporting_TableViewCell
        
        if let monthStart = monthes?[indexPath.row] {
            
            let dateFormatter:DateFormatter = .init()
            dateFormatter.dateFormat = "MMMM yyyy"
            cell.keyLabel.text = dateFormatter.string(from: monthStart)
            
            if let filteredBookings, !filteredBookings.isEmpty {
                
                let calendar = Calendar.current
                let pastBookings = filteredBookings.filter { $0.dates.end < Date() }
                let monthRange = calendar.range(of: .day, in: .month, for: monthStart)
                let daysInMonth = monthRange?.count ?? 30
                let monthEnd = calendar.date(byAdding: .day, value: daysInMonth, to: monthStart) ?? monthStart
                let pastNights = pastBookings.compactMap({
                    
                    let start = max($0.dates.start, monthStart)
                    let end = min($0.dates.end, monthEnd)
                    return max(0, calendar.dateComponents([.day], from: start, to: end).day ?? 0)
                    
                }).reduce(0, +)
                let allNights = filteredBookings.compactMap({
                    
                    let start = max($0.dates.start, monthStart)
                    let end = min($0.dates.end, monthEnd)
                    return max(0, calendar.dateComponents([.day], from: start, to: end).day ?? 0)
                    
                }).reduce(0, +)
                
                let actual = daysInMonth > 0 ? Double(pastNights) / Double(daysInMonth) * 100 : 0
                let forecast = daysInMonth > 0 ? Double(allNights) / Double(daysInMonth) * 100 : 0
                cell.valueLabel.text = String(format: "%.0f%% (→ %.0f%%)", actual, forecast)
            }
        }
        
        return cell
    }
}
