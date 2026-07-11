//
//  RU_Reporting_ViewController.swift
//  RentUp
//
//  Created by BLIN Michael on 04/02/2026.
//

import UIKit
import SnapKit

public class RU_Reporting_ViewController : RU_ViewController {
	
    private var bookings:[RU_Booking]? {
        
        didSet {
            
            reportingTipStackView.bookings = bookings
            applyFilters()
        }
    }
    private var filteredBookings:[RU_Booking]? {
        
        didSet {
            
            view.dismissPlaceholder()
            
            updateFilterNavigationItem()
            
            if filteredBookings?.isEmpty ?? true {
                
                contentScrollView.isHidden = true
                generalKPIView.isHidden = true
                generalDistributionView.isHidden = true
                
                let placeholderView = view.showPlaceholder(.Empty)
                let button = placeholderView.addButton(String(key: "bookings.create.button")) { _ in
                    
                    RU_Booking.create()
                }
                button.image = UIImage(systemName: "plus")
                
                [occupationCurrentMonthLabel, occupationPreviousMonthLabel, occupationTotalLabel, profitabilityCurrentMonthLabel, profitabilityPreviousMonthLabel, profitabilityTotalLabel].forEach { $0.text = String(key: "reporting.value.placeholder") }
            }
            else {
                
                contentScrollView.isHidden = false
                
                [occupationCurrentMonthLabel, occupationPreviousMonthLabel, occupationTotalLabel, profitabilityCurrentMonthLabel, profitabilityPreviousMonthLabel, profitabilityTotalLabel].forEach { $0.text = String(key: "reporting.value.placeholder") }
                
                let listForDistribution = distributionBookings(from: filteredBookings ?? [])
                generalKPIView.isHidden = listForDistribution.isEmpty
                generalDistributionView.isHidden = listForDistribution.isEmpty
                generalKPIView.update(bookings: listForDistribution)
                generalDistributionView.update(bookings: listForDistribution)
            }

            let listForFees = RU_Reporting_Detail_ViewController.ReportingMonthMetrics.eligibleBookings(filteredBookings ?? [])
            let hasAnyClassifiedWithFees = listForFees.contains(where: { ($0.classified?.fees ?? 0) > 0 })
            profitabilityTipView.isHidden = hasAnyClassifiedWithFees
            profitabilityPreviousMonthRow.isHidden = !hasAnyClassifiedWithFees
            profitabilityCurrentMonthRow.isHidden = !hasAnyClassifiedWithFees
            profitabilityTotalRow.isHidden = !hasAnyClassifiedWithFees
            profitabilityButton.isHidden = !hasAnyClassifiedWithFees
            
            let list = RU_Reporting_Detail_ViewController.ReportingMonthMetrics.eligibleBookings(filteredBookings ?? [])
            guard !list.isEmpty else { return }
            
            refreshOccupationAndProfitabilityMetrics(bookings: list)
        }
    }
    private enum MetricsPeriodTarget {
        case occupation
        case profitability
    }
    
    private var occupationMetricsPeriod: RU_Reporting_MetricsPeriod = .default
    private var profitabilityMetricsPeriod: RU_Reporting_MetricsPeriod = .default
    private lazy var occupationPeriodButton: RU_Button = makeMetricsPeriodButton(for: .occupation)
    private lazy var profitabilityPeriodButton: RU_Button = makeMetricsPeriodButton(for: .profitability)
    private lazy var occupationSectionStackView: RU_Section_StackView = .init()
    private lazy var profitabilitySectionStackView: RU_Section_StackView = .init()
    
    private func makeMetricsPeriodButton(for target: MetricsPeriodTarget) -> RU_Button {
        let button = RU_Button { _ in }
        button.titleFont = Fonts.Content.Button.Title.withSize(Fonts.Size)
        button.image = UIImage(systemName: "arrowtriangle.down.square")?.applyingSymbolConfiguration(.init(scale: .small))
        button.configuration?.imagePadding = UI.Margins / 2
        button.configuration?.imagePlacement = .trailing
        button.showsMenuAsPrimaryAction = true
        button.menu = makeMetricsPeriodMenu(for: target)
        button.snp.makeConstraints { make in
            make.height.equalTo(4 * UI.Margins)
        }
        return button
    }
    
    private func metricsPeriod(for target: MetricsPeriodTarget) -> RU_Reporting_MetricsPeriod {
        switch target {
        case .occupation: return occupationMetricsPeriod
        case .profitability: return profitabilityMetricsPeriod
        }
    }
    
    private func updateMetricsPeriodButtons() {
        updateMetricsPeriodButton(occupationPeriodButton, for: .occupation)
        updateMetricsPeriodButton(profitabilityPeriodButton, for: .profitability)
    }
    
    private func updateMetricsPeriodButton(_ button: RU_Button, for target: MetricsPeriodTarget) {
        button.title = metricsPeriod(for: target).title
        button.configuration?.titleLineBreakMode = .byTruncatingTail
        button.menu = makeMetricsPeriodMenu(for: target)
    }
    
    private func makeMetricsPeriodMenu(for target: MetricsPeriodTarget) -> UIMenu {
        let currentPeriod = metricsPeriod(for: target)
        var children: [UIMenuElement] = RU_Reporting_MetricsPeriod.presets.map { preset in
            UIAction(
                title: preset.title,
                state: currentPeriod.matchesPreset(preset) ? .on : .off
            ) { [weak self] _ in
                self?.setMetricsPeriod(preset, for: target)
            }
        }
        children.append(
            UIAction(
                title: String(key: "reporting.period.custom"),
                image: UIImage(systemName: "calendar.badge.clock"),
                state: currentPeriod.isCustom ? .on : .off
            ) { [weak self] _ in
                self?.presentCustomMetricsPeriodAlert(for: target)
            }
        )
        return UIMenu(title: String(key: "reporting.period.menu"), children: children)
    }
    
    private func setMetricsPeriod(_ period: RU_Reporting_MetricsPeriod, for target: MetricsPeriodTarget) {
        switch target {
        case .occupation:
            occupationMetricsPeriod = period
        case .profitability:
            profitabilityMetricsPeriod = period
        }
        updateMetricsPeriodButtons()
        let list = RU_Reporting_Detail_ViewController.ReportingMonthMetrics.eligibleBookings(filteredBookings ?? [])
        guard !list.isEmpty else { return }
        refreshOccupationAndProfitabilityMetrics(bookings: list)
    }
    
    private func presentCustomMetricsPeriodAlert(for target: MetricsPeriodTarget) {
        let calendar = Calendar.current
        let now = Date()
        let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
        let defaultFrom = calendar.date(byAdding: .month, value: -6, to: currentMonthStart) ?? currentMonthStart
        let currentPeriod = metricsPeriod(for: target)
        
        let initialFrom: Date
        let initialTo: Date
        if case .custom(let from, let to) = currentPeriod {
            initialFrom = from
            initialTo = to
        } else {
            initialFrom = defaultFrom
            initialTo = now
        }
        
        RU_Booking.getAll { [weak self] error, bookings in
            if let error {
                RU_Alert_ViewController.present(error)
                return
            }
            
            let calendarViewController = RU_Reporting_Period_Calendar_ViewController(from: initialFrom, to: initialTo)
            calendarViewController.bookings = RU_Reporting_Detail_ViewController.ReportingMonthMetrics.eligibleBookings(bookings ?? [])
            calendarViewController.didSelectRange = { [weak self] from, to in
                self?.setMetricsPeriod(.custom(from: from, to: to), for: target)
            }
            UI.MainController.present(RU_NavigationController(rootViewController: calendarViewController), animated: true)
        }
    }
    
    private func refreshOccupationAndProfitabilityMetrics(bookings listCopy: [RU_Booking]) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let calendar = Calendar.current
            let now = Date()
            let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
            let currentMonthRange = calendar.range(of: .day, in: .month, for: now)
            let currentMonthDays = currentMonthRange?.count ?? 30
            let currentMonthEnd = calendar.date(byAdding: .day, value: currentMonthDays, to: currentMonthStart) ?? now
            let previousMonthStart = calendar.date(byAdding: .month, value: -1, to: currentMonthStart) ?? currentMonthStart
            let previousMonthRange = calendar.range(of: .day, in: .month, for: previousMonthStart)
            let previousMonthDays = previousMonthRange?.count ?? 30
            let previousMonthEnd = calendar.date(byAdding: .day, value: previousMonthDays, to: previousMonthStart) ?? previousMonthStart
            let pastBookings = listCopy.filter { $0.dates.end < now }
            let earliestStart = pastBookings.map(\.dates.start).min()
            let occupationBounds = self.occupationMetricsPeriod.bounds(
                calendar: calendar,
                now: now,
                earliestBookingStart: earliestStart
            )
            let profitabilityBounds = self.profitabilityMetricsPeriod.bounds(
                calendar: calendar,
                now: now,
                earliestBookingStart: earliestStart
            )
            let occupationPeriodStart = occupationBounds.start
            let occupationPeriodEnd = occupationBounds.end
            let occupationPeriodDays = max(1, calendar.dateComponents([.day], from: occupationPeriodStart, to: occupationPeriodEnd).day ?? 1)
            let profitabilityPeriodStart = profitabilityBounds.start
            let profitabilityPeriodEnd = profitabilityBounds.end
                func nightsInMonth(_ b: RU_Booking, monthStart: Date, monthEnd: Date) -> Int {
                    let start = max(b.dates.start, monthStart), end = min(b.dates.end, monthEnd)
                    return max(0, calendar.dateComponents([.day], from: start, to: end).day ?? 0)
                }
                func daysInPeriod(_ b: RU_Booking, periodStart: Date, periodEnd: Date) -> Int {
                    let start = max(b.dates.start, periodStart), end = min(b.dates.end, periodEnd)
                    return max(0, calendar.dateComponents([.day], from: start, to: end).day ?? 0)
                }
                func bookingNights(_ b: RU_Booking) -> Int {
                    max(0, calendar.dateComponents([.day], from: b.dates.start, to: b.dates.end).day ?? 0)
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
                func proratedHostTotal(_ b: RU_Booking, monthStart: Date, monthEnd: Date) -> Double {
                    let monthNights = nightsInMonth(b, monthStart: monthStart, monthEnd: monthEnd)
                    guard monthNights > 0 else { return 0 }
                    let totalNights = bookingNights(b)
                    guard totalNights > 0 else { return 0 }
                    guard let hostTotal = b.platform?.calculatePrice(for: b)?.hostTotal else { return 0 }
                    return hostTotal * Double(monthNights) / Double(totalNights)
                }
                func proratedHostTotalInPeriod(_ b: RU_Booking, periodStart: Date, periodEnd: Date) -> Double {
                    let periodNights = daysInPeriod(b, periodStart: periodStart, periodEnd: periodEnd)
                    guard periodNights > 0 else { return 0 }
                    let totalNights = bookingNights(b)
                    guard totalNights > 0 else { return 0 }
                    guard let hostTotal = b.platform?.calculatePrice(for: b)?.hostTotal else { return 0 }
                    return hostTotal * Double(periodNights) / Double(totalNights)
                }
                
                let currentMonthPastBookingsForOcc = pastBookings.filter({ nightsInMonth($0, monthStart: currentMonthStart, monthEnd: currentMonthEnd) > 0 })
                var currentMonthPastNights = 0
                for b in currentMonthPastBookingsForOcc { currentMonthPastNights += nightsInMonth(b, monthStart: currentMonthStart, monthEnd: currentMonthEnd) }
                let occCurrActual = currentMonthDays > 0 ? Double(currentMonthPastNights) / Double(currentMonthDays) * 100 : 0
                let currentMonthAllBookingsForOcc = listCopy.filter({ nightsInMonth($0, monthStart: currentMonthStart, monthEnd: currentMonthEnd) > 0 })
                var currentMonthAllNights = 0
                for b in currentMonthAllBookingsForOcc { currentMonthAllNights += nightsInMonth(b, monthStart: currentMonthStart, monthEnd: currentMonthEnd) }
                let occCurrForecast = currentMonthDays > 0 ? Double(currentMonthAllNights) / Double(currentMonthDays) * 100 : 0
                let previousMonthPastBookingsForOcc = pastBookings.filter({ nightsInMonth($0, monthStart: previousMonthStart, monthEnd: previousMonthEnd) > 0 })
                var previousMonthPastNights = 0
                for b in previousMonthPastBookingsForOcc { previousMonthPastNights += nightsInMonth(b, monthStart: previousMonthStart, monthEnd: previousMonthEnd) }
                let occPrevActual = previousMonthDays > 0 ? Double(previousMonthPastNights) / Double(previousMonthDays) * 100 : 0
                let previousMonthAllBookingsForOcc = listCopy.filter({ nightsInMonth($0, monthStart: previousMonthStart, monthEnd: previousMonthEnd) > 0 })
                var previousMonthAllNights = 0
                for b in previousMonthAllBookingsForOcc { previousMonthAllNights += nightsInMonth(b, monthStart: previousMonthStart, monthEnd: previousMonthEnd) }
                let occPrevForecast = previousMonthDays > 0 ? Double(previousMonthAllNights) / Double(previousMonthDays) * 100 : 0
                let totalPastBookingsForOcc = pastBookings.filter({ daysInPeriod($0, periodStart: occupationPeriodStart, periodEnd: occupationPeriodEnd) > 0 })
                var totalPastNights = 0
                for b in totalPastBookingsForOcc { totalPastNights += daysInPeriod(b, periodStart: occupationPeriodStart, periodEnd: occupationPeriodEnd) }
                let occTotActual = Double(totalPastNights) / Double(occupationPeriodDays) * 100
                let totalAllBookingsForOcc = listCopy.filter({ daysInPeriod($0, periodStart: occupationPeriodStart, periodEnd: occupationPeriodEnd) > 0 })
                var totalAllNights = 0
                for b in totalAllBookingsForOcc { totalAllNights += daysInPeriod(b, periodStart: occupationPeriodStart, periodEnd: occupationPeriodEnd) }
                let occTotForecast = Double(totalAllNights) / Double(occupationPeriodDays) * 100
                let currentMonthProfitability = RU_Reporting_Detail_ViewController.ReportingMonthMetrics.profitabilityPercentages(
                    monthStart: currentMonthStart,
                    bookings: listCopy,
                    now: now,
                    calendar: calendar
                )
                let profCurrActual = currentMonthProfitability.actual
                let profCurrForecast = currentMonthProfitability.forecast
                
                let previousMonthProfitability = RU_Reporting_Detail_ViewController.ReportingMonthMetrics.profitabilityPercentages(
                    monthStart: previousMonthStart,
                    bookings: listCopy,
                    now: now,
                    calendar: calendar
                )
                let profPrevActual = previousMonthProfitability.actual
                let profPrevForecast = previousMonthProfitability.forecast
                let profitabilityPeriodStartMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: profitabilityPeriodStart)) ?? profitabilityPeriodStart
                var monthCursor = profitabilityPeriodStartMonth
                var totalChargesActual: Double = 0
                var totalChargesForecast: Double = 0
                while monthCursor < profitabilityPeriodEnd {
                    autoreleasepool {
                        let monthRange = calendar.range(of: .day, in: .month, for: monthCursor)
                        let daysInMonth = monthRange?.count ?? 30
                        let monthEnd = calendar.date(byAdding: .day, value: daysInMonth, to: monthCursor) ?? monthCursor
                        let monthPastBookings = pastBookings.filter({ nightsInMonth($0, monthStart: monthCursor, monthEnd: monthEnd) > 0 })
                        let monthAllBookings = listCopy.filter({ nightsInMonth($0, monthStart: monthCursor, monthEnd: monthEnd) > 0 })
                        totalChargesActual += uniqueClassifiedFees(for: monthPastBookings)
                        totalChargesForecast += uniqueClassifiedFees(for: monthAllBookings)
                    }
                    monthCursor = calendar.date(byAdding: .month, value: 1, to: monthCursor) ?? monthCursor
                }
                var totalPastRev: Double = 0
                autoreleasepool {
                    for b in pastBookings where daysInPeriod(b, periodStart: profitabilityPeriodStart, periodEnd: profitabilityPeriodEnd) > 0 {
                        totalPastRev += proratedHostTotalInPeriod(b, periodStart: profitabilityPeriodStart, periodEnd: profitabilityPeriodEnd)
                    }
                }
                var totalAllRev: Double = 0
                autoreleasepool {
                    for b in listCopy where daysInPeriod(b, periodStart: profitabilityPeriodStart, periodEnd: profitabilityPeriodEnd) > 0 {
                        totalAllRev += proratedHostTotalInPeriod(b, periodStart: profitabilityPeriodStart, periodEnd: profitabilityPeriodEnd)
                    }
                }
                let profTotActual = totalChargesActual > 0 ? totalPastRev / totalChargesActual * 100 : (totalPastRev > 0 ? 100 : 0)
                let profTotForecast = totalChargesForecast > 0 ? totalAllRev / totalChargesForecast * 100 : (totalAllRev > 0 ? 100 : 0)
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.occupationCurrentMonthLabel.text = String(format: "%.0f%% (→ %.0f%%)", occCurrActual, occCurrForecast)
                    self.occupationPreviousMonthLabel.text = String(format: "%.0f%% (→ %.0f%%)", occPrevActual, occPrevForecast)
                    self.occupationTotalLabel.text = String(format: "%.0f%% (→ %.0f%%)", occTotActual, occTotForecast)
                    self.profitabilityCurrentMonthLabel.text = String(format: "%.0f%% (→ %.0f%%)", profCurrActual, profCurrForecast)
                    self.profitabilityPreviousMonthLabel.text = String(format: "%.0f%% (→ %.0f%%)", profPrevActual, profPrevForecast)
                    self.profitabilityTotalLabel.text = String(format: "%.0f%% (→ %.0f%%)", profTotActual, profTotForecast)
                }
        }
    }
    
    private struct ActiveFilters {
        var status: RU_Booking.Status?
        var platform: RU_Platform?
        var classified: RU_Classified?
    }
    private var activeFilters = ActiveFilters(status: nil, platform: nil, classified: nil)
    private var activeFiltersTitle: String? {
        var parts: [String] = []

        if let status = activeFilters.status {
            parts.append(status.text)
        }

        if let platform = activeFilters.platform, let name = platform.type?.name {
            parts.append(name)
        }

        if let classified = activeFilters.classified, let name = classified.name {
            parts.append(name)
        }

        return parts.isEmpty ? nil : parts.joined(separator: " + ")
    }

    private func applyFilters() {
        let base = bookings ?? []

        filteredBookings = base.filter { b in
            if let s = activeFilters.status, b.status.text != s.text { return false }

            if let p = activeFilters.platform {
                guard let bp = b.platform else { return false }
                if bp != p { return false }
            }

            if let c = activeFilters.classified {
                guard let bc = b.classified else { return false }
                if bc != c { return false }
            }

            return true
        }
    }
    private lazy var reportingTipStackView: RU_Reporting_Tip_StackView = .init()
    private lazy var contentScrollView:RU_ScrollView = .init()
    private lazy var occupationCurrentMonthLabel: RU_Label = .init()
    private lazy var occupationPreviousMonthLabel: RU_Label = .init()
    private lazy var occupationTotalLabel: RU_Label = .init()
    private lazy var profitabilityTipView:RU_Tip_StackView = {
        
        $0.title = String(key: "reporting.profitability.tip.title")
        $0.addLabel(String(key: "reporting.profitability.tip.content"))
        return $0
        
    }(RU_Tip_StackView())
    private lazy var profitabilityPreviousMonthRow:RU_Section_Row_StackView = createRow(icon: "eurosign.circle", title: String(key: "reporting.profitability.previousMonth"), view: profitabilityPreviousMonthLabel)
    private lazy var profitabilityCurrentMonthRow:RU_Section_Row_StackView = createRow(icon: "eurosign", title: String(key: "reporting.profitability.currentMonth"), view: profitabilityCurrentMonthLabel)
    private lazy var profitabilityTotalRow:RU_Section_Row_StackView = createRow(icon: "equal.circle.fill", title: String(key: "reporting.profitability.total"), view: profitabilityTotalLabel, isHighlighted: true)
    private lazy var profitabilityCurrentMonthLabel: RU_Label = .init()
    private lazy var profitabilityPreviousMonthLabel: RU_Label = .init()
    private lazy var profitabilityTotalLabel: RU_Label = .init()
    private lazy var profitabilityButton:RU_Button = {
        
        $0.titleFont = Fonts.Content.Button.Title.withSize(Fonts.Size)
        $0.image = UIImage(systemName: "arrowtriangle.right.square")?.applyingSymbolConfiguration(.init(scale: .small))
        $0.configuration?.imagePadding = UI.Margins/2
        $0.configuration?.imagePlacement = .trailing
        return $0
        
    }(RU_Button(String(key: "reporting.details.button")) { [weak self] _ in
        
        self?.pushProfitabilityDetail()
    })
    private lazy var generalKPIView: RU_Reporting_General_KPI_View = .init()
    private lazy var generalDistributionView: RU_Reporting_General_Distribution_View = .init()
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		tabBarItem = .init(title: String(key: "tabbar.reporting"), image: UIImage(systemName: "chart.line.text.clipboard"), tag: RU_TabBarController.Indexes.allCases.firstIndex(of: .Reporting) ?? 0)
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func loadView() {
		
		super.loadView()
		
        updateFilterNavigationItem()
		navigationItem.title = String(key: "reporting.title")
        
        view.addSubview(contentScrollView)
        contentScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let contentStackView:RU_StackView = .init()
        contentStackView.axis = .vertical
        contentStackView.spacing = 2*UI.Margins
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = .init(UI.Margins)
        contentScrollView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
        }
        
        contentStackView.addArrangedSubview(reportingTipStackView)
        contentStackView.addArrangedSubview(generalKPIView)
        contentStackView.addArrangedSubview(generalDistributionView)
        
        let occupationSectionStackView = self.occupationSectionStackView
        occupationSectionStackView.title = String(key: "reporting.section.occupancy")
        occupationSectionStackView.subtitle = String(key: "reporting.section.occupancy.subtitle")
        occupationSectionStackView.accessoryView = occupationPeriodButton
        occupationSectionStackView.addArrangedSubview(createRow(icon: "calendar.badge.clock", title: String(key: "reporting.occupancy.previousMonth"), view: occupationPreviousMonthLabel))
        occupationSectionStackView.addArrangedSubview(createRow(icon: "calendar", title: String(key: "reporting.occupancy.currentMonth"), view: occupationCurrentMonthLabel))
        occupationSectionStackView.addArrangedSubview(createRow(icon: "equal.circle.fill", title: String(key: "reporting.occupancy.total"), view: occupationTotalLabel, isHighlighted: true))
        
        let occupationSectionButton:RU_Button = .init(String(key: "reporting.details.button")) { [weak self] _ in
            
            self?.pushOccupationDetail()
        }
        occupationSectionButton.titleFont = Fonts.Content.Button.Title.withSize(Fonts.Size)
        occupationSectionButton.image = UIImage(systemName: "arrowtriangle.right.square")?.applyingSymbolConfiguration(.init(scale: .small))
        occupationSectionButton.configuration?.imagePadding = UI.Margins/2
        occupationSectionButton.configuration?.imagePlacement = .trailing
        occupationSectionStackView.addArrangedSubview(occupationSectionButton)
        contentStackView.addArrangedSubview(occupationSectionStackView)
        
        let profitabilitySectionStackView = self.profitabilitySectionStackView
        profitabilitySectionStackView.title = String(key: "reporting.section.profitability")
        profitabilitySectionStackView.subtitle = String(key: "reporting.section.profitability.subtitle")
        profitabilitySectionStackView.accessoryView = profitabilityPeriodButton
        profitabilitySectionStackView.addArrangedSubview(profitabilityTipView)
        profitabilitySectionStackView.addArrangedSubview(profitabilityPreviousMonthRow)
        profitabilitySectionStackView.addArrangedSubview(profitabilityCurrentMonthRow)
        profitabilitySectionStackView.addArrangedSubview(profitabilityTotalRow)
        profitabilitySectionStackView.addArrangedSubview(profitabilityButton)
        contentStackView.addArrangedSubview(profitabilitySectionStackView)
        
        updateMetricsPeriodButtons()
        
        NotificationCenter.add(.updateBookings) { [weak self] _ in
            
            self?.updateData()
        }
        
        NotificationCenter.add(.updateClassifieds) { [weak self] _ in
            
            self?.updateData()
        }
	}
    
    public override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        updateData()
    }
    
    private func metricsBookings() -> [RU_Booking]? {
        RU_Reporting_Detail_ViewController.ReportingMonthMetrics.eligibleBookings(filteredBookings ?? [])
    }
    
    private func pushProfitabilityDetail() {
        let viewController = RU_Reporting_Detail_Profitability_ViewController()
        viewController.bookings = metricsBookings()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func pushOccupationDetail() {
        let viewController = RU_Reporting_Detail_Occupation_ViewController()
        viewController.bookings = metricsBookings()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func distributionBookings(from bookings: [RU_Booking]) -> [RU_Booking] {
        if activeFilters.status == nil {
            return RU_Reporting_Detail_ViewController.ReportingMonthMetrics.eligibleBookings(bookings)
        }
        return bookings
    }
    
    private func updateFilterNavigationItem() {
        
        navigationItem.rightBarButtonItem = nil
        
        if !(bookings?.isEmpty ?? true) {
            
            var children:[UIMenuElement] = .init()
            
            children.append(UIAction(title: String(key: "bookings.filter.reset"), image: UIImage(systemName: "arrow.counterclockwise"), attributes: .destructive, handler: { [weak self] _ in
                guard let self else { return }
                self.activeFilters = .init(status: nil, platform: nil, classified: nil)
                self.applyFilters()
            }))
            
            children.append(UIMenu(title: String(key: "bookings.filter.status"), children: RU_Booking.Status.allCases.map({ status in
                UIAction(title: status.text, handler: { [weak self] _ in
                    guard let self else { return }
                    let isSame = self.activeFilters.status?.text == status.text
                    self.activeFilters.status = isSame ? nil : status
                    self.applyFilters()
                })
            })))
            
            if let platforms = RU_Platform.all, !platforms.isEmpty {
                
                children.append(UIMenu(title: String(key: "bookings.filter.platform"), children: platforms.compactMap({ platform in
                    
                    if let name = platform.type?.name {
                        
                        return UIAction(title: name, handler: { [weak self] _ in
                            guard let self else { return }
                            self.activeFilters.platform = (self.activeFilters.platform == platform) ? nil : platform
                            self.applyFilters()
                        })
                    }
                    
                    return nil
                })))
            }
            
            RU_Classified.getAll { [weak self] error, classifieds in
                
                if let classifieds, !classifieds.isEmpty {
                    
                    children.append(UIMenu(title: String(key: "bookings.filter.classified"), children: classifieds.compactMap({ classified in
                        
                        if let name = classified.name {
                            
                            return UIAction(title: name, handler: { [weak self] _ in
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
                    if let title = self?.activeFiltersTitle {
                        buttonTitle = String(key: "bookings.filter.active") + title
                    }
                    else {
                        buttonTitle = String(key: "bookings.filter.button")
                    }
                    
                    self?.navigationItem.rightBarButtonItem = .init(title: buttonTitle, menu: .init(title: String(key: "bookings.filter.menu.title"), children: children))
                }
            }
        }
    }
    
    private func updateData() {
        
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
                
                self?.bookings = bookings
            }
        }
    }
    
    private func createRow(icon: String?, title: String?, view: UIView, isHighlighted: Bool = false) -> RU_Section_Row_StackView {
        
        let row = RU_Section_Row_StackView()
        
        if let icon {
            
            row.image = UIImage(systemName: icon)
        }
        
        row.title = title
        row.view = view
        row.isHighlighted = isHighlighted
        return row
    }
}
