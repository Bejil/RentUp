//
//  RU_Reporting_Detail_ViewController.swift
//  RentUp
//
//  Created by Michaël Blin on 09/02/2026.
//

import UIKit
import SnapKit

private final class RU_OccupancyLineChartView: UIView {
    
    static let monthWidth: CGFloat = 5 * UI.Margins
    static let chartHeight: CGFloat = 13 * UI.Margins
    private static let leftInset: CGFloat = 2 * UI.Margins
    private static let bottomInset: CGFloat = 2.5 * UI.Margins
    private static let topInset: CGFloat = UI.Margins
    var actualValues: [Double?] = [] { didSet { setNeedsDisplay() } }
    var forecastValues: [Double?] = [] { didSet { setNeedsDisplay() } }
    var monthDates: [Date] = [] { didSet { setNeedsDisplay() } }
    var effectiveMonthWidth: CGFloat = 0 { didSet { setNeedsDisplay() } }
    
    private static func smoothPath(through points: [CGPoint]) -> UIBezierPath {
        
        let path = UIBezierPath()
        guard points.count >= 2 else {
            if let p = points.first { path.move(to: p) }
            return path
        }
        path.move(to: points[0])
        let n = points.count
        for i in 0..<(n - 1) {
            let p0 = points[max(0, i - 1)]
            let p1 = points[i]
            let p2 = points[i + 1]
            let p3 = points[min(n - 1, i + 2)]
            let tension: CGFloat = 1/6
            let c1 = CGPoint(x: p1.x + (p2.x - p0.x) * tension, y: p1.y + (p2.y - p0.y) * tension)
            let c2 = CGPoint(x: p2.x - (p3.x - p1.x) * tension, y: p2.y - (p3.y - p1.y) * tension)
            path.addCurve(to: p2, controlPoint1: c1, controlPoint2: c2)
        }
        return path
    }
    
    override func draw(_ rect: CGRect) {
        guard !monthDates.isEmpty else { return }
        let plotLeft = Self.leftInset
        let plotBottom = rect.height - Self.bottomInset
        let plotTop = Self.topInset
        let plotHeight = plotBottom - plotTop
        let count = monthDates.count
        let monthW = effectiveMonthWidth > 0 ? effectiveMonthWidth : Self.monthWidth
        let plotWidth = CGFloat(count) * monthW
        
        let yAxisLabelAttributes: [NSAttributedString.Key: Any] = [
            .font: Fonts.Content.Text.Regular.withSize(Fonts.Size - 2),
            .foregroundColor: Colors.Content.Text
        ]
        
        for pct in [0, 25, 50, 75, 100] {
            let y = plotBottom - (CGFloat(pct) / 100) * plotHeight
            let path = UIBezierPath()
            path.move(to: CGPoint(x: plotLeft, y: y))
            path.addLine(to: CGPoint(x: plotLeft + plotWidth, y: y))
            Colors.Content.Text.withAlphaComponent(0.15).setStroke()
            path.lineWidth = 1
            path.stroke()
            let label = "\(pct)%"
            (label as NSString).draw(at: CGPoint(x: 0, y: y - 6), withAttributes: yAxisLabelAttributes)
        }
        
        for i in 0..<count {
            let x = plotLeft + (CGFloat(i) + 0.5) * monthW
            let path = UIBezierPath()
            path.move(to: CGPoint(x: x, y: plotTop))
            path.addLine(to: CGPoint(x: x, y: plotBottom))
            Colors.Content.Text.withAlphaComponent(0.08).setStroke()
            path.lineWidth = 1
            path.stroke()
            
            let dateformatter:DateFormatter = .init()
            dateformatter.dateFormat = "MMM yy"
            
            let label = dateformatter.string(from: monthDates[i])
            let size = (label as NSString).size(withAttributes: yAxisLabelAttributes)
            (label as NSString).draw(at: CGPoint(x: x - size.width / 2, y: plotBottom + 4), withAttributes: yAxisLabelAttributes)
        }
        
        func pointFor(value: Double, index: Int) -> CGPoint {
            let x = plotLeft + (CGFloat(index) + 0.5) * monthW
            let y = plotBottom - (CGFloat(value) / 100) * plotHeight
            return CGPoint(x: x, y: y)
        }
        
        let actualPoints = actualValues.enumerated().compactMap { idx, v -> CGPoint? in
            guard let v = v else { return nil }
            return pointFor(value: v, index: idx)
        }
        if actualPoints.count >= 2 {
            let path = Self.smoothPath(through: actualPoints)
            Colors.Primary.setStroke()
            path.lineWidth = 2
            path.lineCapStyle = .round
            path.lineJoinStyle = .round
            path.stroke()
            for p in actualPoints {
                let circle = UIBezierPath(ovalIn: CGRect(x: p.x - 3, y: p.y - 3, width: 6, height: 6))
                Colors.Primary.setFill()
                circle.fill()
                Colors.Primary.setStroke()
                circle.lineWidth = 1
                circle.stroke()
            }
        }
        
        let forecastPoints = forecastValues.enumerated().compactMap { idx, v -> CGPoint? in
            guard let v = v else { return nil }
            return pointFor(value: v, index: idx)
        }
        if forecastPoints.count >= 2 {
            let path = Self.smoothPath(through: forecastPoints)
            Colors.Secondary.setStroke()
            path.lineWidth = 2
            path.lineCapStyle = .round
            path.lineJoinStyle = .round
            path.stroke()
            for p in forecastPoints {
                let r = CGRect(x: p.x - 3, y: p.y - 3, width: 6, height: 6)
                let square = UIBezierPath(rect: r)
                Colors.Secondary.setFill()
                square.fill()
                Colors.Secondary.setStroke()
                square.lineWidth = 1
                square.stroke()
            }
        }
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
            
            updateChartView()
            tableView.reloadData()
        }
    }
    private var monthes:[Date]?
    private lazy var chartScrollView:UIScrollView = {
        
        $0.addSubview(occupancyChartView)
        return $0
        
    }(UIScrollView())
    private lazy var occupancyChartView:RU_OccupancyLineChartView = .init()
    private var currentFilterName:String? {
        
        didSet {
            
            updateFilterNavigationItem()
        }
    }
    private lazy var tableView:RU_TableView = {
        
        $0.isHeightDynamic = true
        $0.register(RU_Reporting_TableViewCell.self, forCellReuseIdentifier: RU_Reporting_TableViewCell.identifier)
        $0.delegate = self
        $0.dataSource = self
        return $0
        
    }(RU_TableView(frame: .zero, style: .plain))
    
    public override func loadView() {
        
        super.loadView()
        
        updateFilterNavigationItem()
        navigationItem.title = String(key: "reporting.detail.occupation.title")
        
        let contentScrollView:RU_ScrollView = .init()
        contentScrollView.isCentered = false
        
        let contentStackView:RU_StackView = .init()
        contentStackView.axis = .vertical
        contentStackView.spacing = 2*UI.Margins
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = .init(UI.Margins)
        contentScrollView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.top.bottom.left.equalToSuperview()
            make.right.width.equalToSuperview()
        }
        
        contentView.addSubview(contentScrollView)
        contentScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let chartContainerView = UIView()
        chartContainerView.backgroundColor = Colors.Background.View
        chartContainerView.layer.cornerRadius = UI.CornerRadius
        chartContainerView.layer.shadowColor = UIColor.black.cgColor
        chartContainerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        chartContainerView.layer.shadowOpacity = 0.08
        chartContainerView.layer.shadowRadius = UI.Margins
        chartContainerView.snp.makeConstraints { make in
            make.height.equalTo(RU_OccupancyLineChartView.chartHeight + UI.Margins)
        }
        contentStackView.addArrangedSubview(chartContainerView)
        
        chartContainerView.addSubview(chartScrollView)
        chartScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UI.Margins)
        }
        
        let legendStackView = RU_StackView()
        legendStackView.axis = .vertical
        legendStackView.spacing = UI.Margins/5
        legendStackView.isLayoutMarginsRelativeArrangement = true
        legendStackView.layoutMargins = .init(horizontal: UI.Margins)
        
        let actualLineView = UIView()
        actualLineView.backgroundColor = Colors.Primary
        actualLineView.layer.cornerRadius = UI.CornerRadius/5
        actualLineView.snp.makeConstraints { make in
            make.width.equalTo(UI.Margins)
            make.height.equalTo(UI.Margins/2)
        }
        let actualLegendLabel = RU_Label()
        actualLegendLabel.text = String(key: "reporting.detail.legend.actual")
        actualLegendLabel.font = Fonts.Content.Text.Regular.withSize(Fonts.Size - 1)
        let actualLegendRow = RU_StackView(arrangedSubviews: [actualLineView, actualLegendLabel])
        actualLegendRow.axis = .horizontal
        actualLegendRow.spacing = UI.Margins / 2
        actualLegendRow.alignment = .center
        
        let forecastLineView = UIView()
        forecastLineView.backgroundColor = Colors.Secondary
        forecastLineView.layer.cornerRadius = UI.CornerRadius/5
        forecastLineView.snp.makeConstraints { make in
            make.width.equalTo(UI.Margins)
            make.height.equalTo(UI.Margins/2)
        }
        let forecastLegendLabel = RU_Label()
        forecastLegendLabel.text = String(key: "reporting.detail.legend.forecast")
        forecastLegendLabel.font = Fonts.Content.Text.Regular.withSize(Fonts.Size - 1)
        let forecastLegendRow = RU_StackView(arrangedSubviews: [forecastLineView, forecastLegendLabel])
        forecastLegendRow.axis = .horizontal
        forecastLegendRow.spacing = UI.Margins / 2
        forecastLegendRow.alignment = .center
        
        legendStackView.addArrangedSubview(actualLegendRow)
        legendStackView.addArrangedSubview(forecastLegendRow)
        contentStackView.addArrangedSubview(legendStackView)
        
        contentStackView.addArrangedSubview(tableView)
        
        let totalSection:RU_Section_Row_StackView = .init()
        totalSection.title = String(key: "reporting.detail.total")
        totalSection.image = UIImage(systemName: "eurosign")
        totalSection.isHighlighted = true
        bottomButtonsStackView.addArrangedSubview(totalSection)
        
        NotificationCenter.add(.updateBookings) { [weak self] _ in
            
            self?.updateData()
        }
    }
    
    public override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        let count = occupancyChartView.monthDates.count
        let minWidth = chartScrollView.bounds.width
        let rawWidth = CGFloat(count) * RU_OccupancyLineChartView.monthWidth
        let contentWidth = max(rawWidth, minWidth)
        let effectiveMonthWidth = contentWidth / CGFloat(count)
        
        occupancyChartView.effectiveMonthWidth = effectiveMonthWidth
        occupancyChartView.frame = CGRect(x: 0, y: 0, width: contentWidth, height: RU_OccupancyLineChartView.chartHeight)
        chartScrollView.contentSize = CGSize(width: contentWidth, height: 0)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        updateData()
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
    
    private func updateChartView() {
        
        if let filteredBookings, !filteredBookings.isEmpty {
            
            monthes = .init()
            
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
            var actualValues: [Double?] = []
            var forecastValues: [Double?] = []
            
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
            
            occupancyChartView.actualValues = actualValues
            occupancyChartView.forecastValues = forecastValues
            occupancyChartView.monthDates = monthes ?? []
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
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
