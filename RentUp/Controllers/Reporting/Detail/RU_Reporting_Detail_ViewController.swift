//
//  RU_Reporting_Detail_ViewController.swift
//  RentUp
//
//  Created by Michaël Blin on 11/02/2026.
//

import UIKit
import SnapKit
import SwiftUI

public class RU_Reporting_Detail_ViewController : RU_ViewController {
    
    var bookings:[RU_Booking]? {
        
        didSet {
            applyFilters()
        }
    }
    public var filteredBookings:[RU_Booking]? {
        
        didSet {
            
            view.dismissPlaceholder()
            
            if filteredBookings?.isEmpty ?? true {
                
                view.showPlaceholder(.Empty)
            }
            
            updateUI()
        }
    }
    public var monthes:[Date]?
    public var actualValues: [Double]?
    public var forecastValues: [Double]?
    /// Texte secondaire : occupation (réel + prévisionnel) avec nuitées / jours du mois.
    public var reportingCellOccupancySummaries: [String]?
    /// Texte secondaire : total net hôte proratisé (passé du mois · mois complet).
    public var reportingCellNetSummaries: [String]?
    
    private struct ActiveFilters {
        var platform: RU_Platform?
        var classified: RU_Classified?
        var period: RU_Reporting_MetricsPeriod = .default
    }
    private var activeFilters = ActiveFilters()
    
    var metricsPeriod: RU_Reporting_MetricsPeriod {
        activeFilters.period
    }
    
    private var activeFiltersTitle: String? {
        var parts: [String] = []
        if activeFilters.period != .default {
            parts.append(activeFilters.period.title)
        }
        if let platform = activeFilters.platform, let name = platform.type?.name {
            parts.append(name)
        }
        if let classified = activeFilters.classified, let name = classified.name {
            parts.append(name)
        }
        return parts.isEmpty ? nil : parts.joined(separator: " + ")
    }
    public lazy var tableView:RU_TableView = {
        
        $0.register(RU_Reporting_TableViewCell.self, forCellReuseIdentifier: RU_Reporting_TableViewCell.identifier)
        $0.delegate = self
        $0.dataSource = self
        return $0
        
    }(RU_TableView(frame: .zero, style: .plain))
    public lazy var chartHostingController: UIHostingController<RU_Chart_View> = .init(rootView: RU_Chart_View(data: .init()))
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
        
        view.addSubview(tableView)
        
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
        
        tableView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(chartContainerView.snp.top).offset(-UI.Margins)
        }
        
        chartContainerView.snp.makeConstraints { make in
            make.bottom.right.left.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
            make.top.equalTo(tableView.snp.bottom).inset(UI.Margins)
        }
        
        NotificationCenter.add(.updateBookings) { [weak self] _ in
            
            self?.updateData()
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if bookings == nil {
            updateData()
        }
    }
    
    public override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        let count = monthes?.count ?? 0
        let contentWidth: CGFloat = count > Self.chartScrollThreshold ? CGFloat(count) * Self.chartMonthWidth : chartScrollView.bounds.width
        chartHostingWidthConstraint?.update(offset: contentWidth)
        chartScrollView.contentSize = CGSize(width: contentWidth, height: chartScrollView.bounds.height)
    }
    
    private func applyFilters() {
        var base = bookings ?? []
        
        if let platform = activeFilters.platform {
            base = base.filter { $0.platform == platform }
        }
        if let classified = activeFilters.classified {
            base = base.filter { $0.classified == classified }
        }
        
        filteredBookings = base.sorted { $0.dates.start > $1.dates.start }
        updateFilterNavigationItem()
    }
    
    private func setMetricsPeriod(_ period: RU_Reporting_MetricsPeriod) {
        activeFilters.period = period
        updateFilterNavigationItem()
        updateUI()
    }
    
    private func presentCustomMetricsPeriodCalendar() {
        let calendar = Calendar.current
        let now = Date()
        let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
        let defaultFrom = calendar.date(byAdding: .month, value: -6, to: currentMonthStart) ?? currentMonthStart
        let currentPeriod = activeFilters.period
        
        let initialFrom: Date
        let initialTo: Date
        if case .custom(let from, let to) = currentPeriod {
            initialFrom = from
            initialTo = to
        } else {
            initialFrom = defaultFrom
            initialTo = now
        }
        
        let calendarViewController = RU_Reporting_Period_Calendar_ViewController(from: initialFrom, to: initialTo)
        calendarViewController.bookings = bookings ?? []
        calendarViewController.didSelectRange = { [weak self] from, to in
            self?.setMetricsPeriod(.custom(from: from, to: to))
        }
        UI.MainController.present(RU_NavigationController(rootViewController: calendarViewController), animated: true)
    }
    
    private func makeMetricsPeriodMenu() -> UIMenu {
        let currentPeriod = activeFilters.period
        var children: [UIMenuElement] = RU_Reporting_MetricsPeriod.presets.map { preset in
            UIAction(
                title: preset.title,
                state: currentPeriod.matchesPreset(preset) ? .on : .off
            ) { [weak self] _ in
                self?.setMetricsPeriod(preset)
            }
        }
        children.append(
            UIAction(
                title: String(key: "reporting.period.custom"),
                image: UIImage(systemName: "calendar.badge.clock"),
                state: currentPeriod.isCustom ? .on : .off
            ) { [weak self] _ in
                self?.presentCustomMetricsPeriodCalendar()
            }
        )
        return UIMenu(title: String(key: "reporting.period.menu"), children: children)
    }
    
    private func updateFilterNavigationItem() {
        
        var children:[UIMenuElement] = .init()
        
        children.append(UIAction(title: String(key: "reporting.filter.reset"), image: UIImage(systemName: "arrow.counterclockwise"), attributes: .destructive, handler: { [weak self] _ in
            self?.activeFilters = ActiveFilters()
            self?.applyFilters()
        }))
        
        children.append(makeMetricsPeriodMenu())
        
        if let platforms = RU_Platform.all, !platforms.isEmpty {
            
            children.append(UIMenu(title: String(key: "reporting.filter.platform"), children: platforms.compactMap({ platform in
                
                if let name = platform.type?.name {
                    
                    return UIAction(title: name, state: self.activeFilters.platform == platform ? .on : .off, handler: { [weak self] _ in
                        guard let self else { return }
                        self.activeFilters.platform = (self.activeFilters.platform == platform) ? nil : platform
                        self.applyFilters()
                    })
                }
                
                return nil
            })))
        }
        
        RU_Classified.getAll { [weak self] error, classifieds in
            
            guard let self else { return }
            
            if let classifieds, !classifieds.isEmpty {
                
                children.append(UIMenu(title: String(key: "reporting.filter.classified"), children: classifieds.compactMap({ classified in
                    
                    if let name = classified.name {
                        
                        return UIAction(title: name, state: self.activeFilters.classified == classified ? .on : .off, handler: { [weak self] _ in
                            guard let self else { return }
                            self.activeFilters.classified = (self.activeFilters.classified == classified) ? nil : classified
                            self.applyFilters()
                        })
                    }
                    
                    return nil
                })))
            }
            
            if !children.isEmpty {
                
                let buttonTitle:String
                if let title = self.activeFiltersTitle {
                    buttonTitle = String(key: "reporting.filter.active") + title
                }
                else {
                    buttonTitle = String(key: "reporting.filter.button")
                }
                
                self.navigationItem.rightBarButtonItem = .init(title: buttonTitle, menu: .init(title: String(key: "reporting.filter.menu.title"), children: children))
            }
        }
    }
    
    private func updateData() {
        
        if bookings != nil {
            updateUI()
            return
        }
        
        view.showPlaceholder(.Loading)
        
        RU_Booking.getAll { [weak self] error, bookings in
            
            self?.view.dismissPlaceholder()
            
            if let error {
                
                self?.view.showPlaceholder(.Error, error) { [weak self] _ in
                    
                    self?.view.dismissPlaceholder()
                    self?.updateData()
                }
            }
            else {
                
                self?.bookings = ReportingMonthMetrics.eligibleBookings(bookings ?? [])
            }
        }
    }
    
    public func updateUI() {
        
        tableView.reloadData()
        
        let calendar = Calendar.current
        let now = Date()
        let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
        
        if let idx = monthes?.firstIndex(where: { calendar.isDate($0, equalTo: currentMonthStart, toGranularity: .month) }), idx < (monthes?.count ?? 0) {
            
            tableView.selectRow(at: IndexPath(row: idx, section: 0), animated: true, scrollPosition: .middle)
            
            UIApplication.wait { [weak self] in
                
                self?.scrollChart(to: idx)
            }
        }
    }
    
    private func scrollChart(to index: Int) {
        
        let count = monthes?.count ?? 0
        guard count > Self.chartScrollThreshold else { return }
        let contentWidth = CGFloat(count) * Self.chartMonthWidth
        let centerX = (CGFloat(index) + 0.5) * Self.chartMonthWidth
        let visibleWidth = chartScrollView.bounds.width
        var offsetX = centerX - visibleWidth / 2
        offsetX = max(0, min(offsetX + UI.Margins, contentWidth - visibleWidth))
        chartScrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }
    
    /// Résas qui chevauchent le mois (même critère que les nuitées comptées au reporting).
    private func filteredBookings(intersectingMonthAt indexPath: IndexPath) -> [RU_Booking] {
        
        guard let monthStart = monthes?[indexPath.row], let list = filteredBookings else { return [] }
        let calendar = Calendar.current
        return list.filter {
            ReportingMonthMetrics.nightsInMonth(booking: $0, monthStart: monthStart, calendar: calendar) > 0
        }
        .sorted { $0.dates.start > $1.dates.start }
    }
}

extension RU_Reporting_Detail_ViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return monthes?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: RU_Reporting_TableViewCell.identifier, for: indexPath) as! RU_Reporting_TableViewCell
        cell.date = monthes?[indexPath.row]
        cell.actualValue = actualValues?[indexPath.row]
        cell.forecastValue = forecastValues?[indexPath.row]
        let row = indexPath.row
        if let lines = reportingCellOccupancySummaries, row < lines.count {
            cell.occupancyDetailText = lines[row]
        } else {
            cell.occupancyDetailText = nil
        }
        if let nets = reportingCellNetSummaries, row < nets.count {
            cell.netDetailText = nets[row]
        } else {
            cell.netDetailText = nil
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        scrollChart(to: indexPath.row)
    }
    
    public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        let viewController: RU_Bookings_List_ViewController = .init()
        viewController.bookings = filteredBookings(intersectingMonthAt: indexPath)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - Métriques mois (occupation / CA net proratisé)

extension RU_Reporting_Detail_ViewController {
    
    enum ReportingMonthMetrics {
        
        static func daysInMonth(monthStart: Date, calendar: Calendar) -> Int {
            calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30
        }
        
        static func monthEnd(monthStart: Date, calendar: Calendar) -> Date {
            let days = daysInMonth(monthStart: monthStart, calendar: calendar)
            return calendar.date(byAdding: .day, value: days, to: monthStart) ?? monthStart
        }
        
        static func nightsInMonth(booking: RU_Booking, monthStart: Date, calendar: Calendar) -> Int {
            let end = monthEnd(monthStart: monthStart, calendar: calendar)
            let start = max(booking.dates.start, monthStart)
            let last = min(booking.dates.end, end)
            return max(0, calendar.dateComponents([.day], from: start, to: last).day ?? 0)
        }
        
        static func bookingNights(_ booking: RU_Booking, calendar: Calendar) -> Int {
            max(0, calendar.dateComponents([.day], from: booking.dates.start, to: booking.dates.end).day ?? 0)
        }
        
        static func proratedHostTotal(booking: RU_Booking, monthStart: Date, calendar: Calendar) -> Double {
            let monthNights = nightsInMonth(booking: booking, monthStart: monthStart, calendar: calendar)
            guard monthNights > 0 else { return 0 }
            let totalNights = bookingNights(booking, calendar: calendar)
            guard totalNights > 0 else { return 0 }
            guard let hostTotal = booking.platform?.calculatePrice(for: booking)?.hostTotal else { return 0 }
            return hostTotal * Double(monthNights) / Double(totalNights)
        }
        
        static func formatNetEUR(_ value: Double) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = Locale(identifier: "fr_FR")
            formatter.currencyCode = "EUR"
            formatter.maximumFractionDigits = 0
            return formatter.string(from: NSNumber(value: value)) ?? "—"
        }
        
        static func eligibleBookings(_ bookings: [RU_Booking]) -> [RU_Booking] {
            bookings.filter { booking in
                guard booking.isCancelled || booking.status == .cancelled else {
                    return true
                }
                return (booking.costs.compensation ?? 0) > 0
            }
        }
        
        struct MainKPIs {
            let bookingCount: Int
            let totalNights: Int
            let averageNights: Double
            let averageGuests: Double
            let mostUsedPlatform: RU_Platform?
            let mostProfitablePlatform: RU_Platform?
        }
        
        static func mainKPIs(bookings: [RU_Booking], calendar: Calendar = .current) -> MainKPIs {
            let list = eligibleBookings(bookings)
            guard !list.isEmpty else {
                return MainKPIs(bookingCount: 0, totalNights: 0, averageNights: 0, averageGuests: 0, mostUsedPlatform: nil, mostProfitablePlatform: nil)
            }
            
            var totalNights = 0
            var totalGuests = 0
            var platformCountById: [String: (platform: RU_Platform?, count: Int)] = [:]
            var platformRevenueById: [String: (platform: RU_Platform?, revenue: Double)] = [:]
            
            for booking in list {
                let nights = bookingNights(booking, calendar: calendar)
                totalNights += nights
                
                let guests = max(1, (booking.travelers.adults ?? 0) + (booking.travelers.children ?? 0) + (booking.travelers.babies ?? 0))
                totalGuests += guests
                
                if let platform = booking.platform {
                    let key = platform.uuid
                    var bucket = platformCountById[key] ?? (platform, 0)
                    bucket.count += 1
                    platformCountById[key] = bucket
                    
                    let revenue = platform.calculatePrice(for: booking)?.hostTotal ?? 0
                    var revenueBucket = platformRevenueById[key] ?? (platform, 0)
                    revenueBucket.revenue += revenue
                    platformRevenueById[key] = revenueBucket
                }
            }
            
            let count = list.count
            let mostUsedPlatform = platformCountById.max(by: { $0.value.count < $1.value.count })?.value.platform
            let mostProfitablePlatform = platformRevenueById.max(by: { $0.value.revenue < $1.value.revenue })?.value.platform
            
            return MainKPIs(
                bookingCount: count,
                totalNights: totalNights,
                averageNights: Double(totalNights) / Double(count),
                averageGuests: Double(totalGuests) / Double(count),
                mostUsedPlatform: mostUsedPlatform,
                mostProfitablePlatform: mostProfitablePlatform
            )
        }
        
        static func uniqueClassifiedFees(for bookings: [RU_Booking]) -> Double {
            var classifieds: [RU_Classified] = []
            bookings.compactMap(\.classified).forEach {
                if !classifieds.contains($0) {
                    classifieds.append($0)
                }
            }
            return Double(classifieds.compactMap(\.fees).reduce(0, +))
        }
        
        /// Taux de rendement = revenu net proratisé du mois / charges (frais uniques par bien).
        static func profitabilityPercentages(
            monthStart: Date,
            bookings: [RU_Booking],
            now: Date,
            calendar: Calendar = .current
        ) -> (actual: Double, forecast: Double, revenueActual: Double, revenueForecast: Double) {
            let list = eligibleBookings(bookings)
            let pastBookings = list.filter { $0.dates.end < now }
            let pastInMonth = pastBookings.filter { nightsInMonth(booking: $0, monthStart: monthStart, calendar: calendar) > 0 }
            let allInMonth = list.filter { nightsInMonth(booking: $0, monthStart: monthStart, calendar: calendar) > 0 }
            
            let chargesActual = uniqueClassifiedFees(for: pastInMonth)
            let chargesForecast = uniqueClassifiedFees(for: allInMonth)
            
            var revenueActual = 0.0
            for booking in pastInMonth {
                revenueActual += proratedHostTotal(booking: booking, monthStart: monthStart, calendar: calendar)
            }
            var revenueForecast = 0.0
            for booking in allInMonth {
                revenueForecast += proratedHostTotal(booking: booking, monthStart: monthStart, calendar: calendar)
            }
            
            let actual = chargesActual > 0 ? revenueActual / chargesActual * 100 : (revenueActual > 0 ? 100 : 0)
            let forecast = chargesForecast > 0 ? revenueForecast / chargesForecast * 100 : (revenueForecast > 0 ? 100 : 0)
            return (actual, forecast, revenueActual, revenueForecast)
        }
    }
}
