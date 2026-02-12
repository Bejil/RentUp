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
            
            let sortedBookings = bookings?.sorted { $0.dates.start > $1.dates.start }
            filteredBookings = sortedBookings
        }
    }
    private var filteredBookings:[RU_Booking]? {
        
        didSet {
            
            view.dismissPlaceholder()
            
            if filteredBookings?.isEmpty ?? true {
                
                view.showPlaceholder(.Empty)
                [occupationCurrentMonthLabel, occupationTotalLabel, profitabilityCurrentMonthLabel, profitabilityTotalLabel, totalNightsLabel, averageNightsLabel, averageGuestsLabel].forEach { $0.text = String(key: "reporting.value.placeholder") }
                mostUsedPlatformLabel.platform = nil
                mostUsedPlatformLabel.text = String(key: "reporting.value.placeholder")
                mostProfitablePlatformLabel.platform = nil
                mostProfitablePlatformLabel.text = String(key: "reporting.value.placeholder")
            }
            else {
                
                guard let filteredBookings, !filteredBookings.isEmpty else { return }
                
                let calendar = Calendar.current
                let now = Date()
                
                let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
                let currentMonthRange = calendar.range(of: .day, in: .month, for: now)
                let currentMonthDays = currentMonthRange?.count ?? 30
                let currentMonthEnd = calendar.date(byAdding: .day, value: currentMonthDays, to: currentMonthStart) ?? now
                
                let pastBookings = filteredBookings.filter { $0.dates.end < now }
                let firstPastStart = pastBookings.map(\.dates.start).min() ?? currentMonthStart
                let periodEnd = currentMonthEnd
                let totalPeriodDays = max(1, calendar.dateComponents([.day], from: firstPastStart, to: periodEnd).day ?? 1)
                
                var monthCount = 0
                var m = firstPastStart
                while m < periodEnd {
                    monthCount += 1
                    m = calendar.date(byAdding: .month, value: 1, to: m) ?? m
                }
                if monthCount == 0 { monthCount = 1 }
                
                func nightsInMonth(_ booking: RU_Booking, monthStart: Date, monthEnd: Date) -> Int {
                    let start = max(booking.dates.start, monthStart)
                    let end = min(booking.dates.end, monthEnd)
                    return max(0, calendar.dateComponents([.day], from: start, to: end).day ?? 0)
                }
                
                func daysInPeriod(_ booking: RU_Booking, periodStart: Date, periodEnd: Date) -> Int {
                    let start = max(booking.dates.start, periodStart)
                    let end = min(booking.dates.end, periodEnd)
                    return max(0, calendar.dateComponents([.day], from: start, to: end).day ?? 0)
                }
                
                // Occupation actuelle mois en cours
                var currentMonthPastNights = 0
                for b in pastBookings { currentMonthPastNights += nightsInMonth(b, monthStart: currentMonthStart, monthEnd: currentMonthEnd) }
                let occupancyCurrentMonthActual = currentMonthDays > 0 ? Double(currentMonthPastNights) / Double(currentMonthDays) * 100 : 0
                
                // Occupation prévisionnelle mois en cours
                var currentMonthAllNights = 0
                for b in filteredBookings { currentMonthAllNights += nightsInMonth(b, monthStart: currentMonthStart, monthEnd: currentMonthEnd) }
                let occupancyCurrentMonthForecast = currentMonthDays > 0 ? Double(currentMonthAllNights) / Double(currentMonthDays) * 100 : 0
                
                // Occupation actuelle totale
                var totalPastNights = 0
                for b in pastBookings { totalPastNights += daysInPeriod(b, periodStart: firstPastStart, periodEnd: periodEnd) }
                let occupancyTotalActual = Double(totalPastNights) / Double(totalPeriodDays) * 100
                
                // Occupation prévisionnelle totale
                var totalAllNights = 0
                for b in filteredBookings { totalAllNights += daysInPeriod(b, periodStart: firstPastStart, periodEnd: periodEnd) }
                let occupancyTotalForecast = Double(totalAllNights) / Double(totalPeriodDays) * 100
                
                // Charges mois en cours : une fois par classified
                var classifiedFeesCurrentMonth: [String: Int] = [:]
                for b in filteredBookings {
                    if nightsInMonth(b, monthStart: currentMonthStart, monthEnd: currentMonthEnd) <= 0 { continue }
                    if let c = b.classified { classifiedFeesCurrentMonth[c.id] = c.fees ?? 0 }
                }
                let currentMonthCharges = Double(classifiedFeesCurrentMonth.values.reduce(0, +))
                
                // Période commune pour les totaux : plus ancienne résa → aujourd'hui (même dénominateur pour actuel et prévisionnel → rendement actuel ≤ prévisionnel)
                let periodStart = firstPastStart
                let periodStartMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: periodStart)) ?? periodStart
                
                // Charges totales sur la période (une fois par classified par mois) : utilisées pour les deux totaux
                var totalCharges: Double = 0
                m = periodStartMonth
                while m < periodEnd {
                    let monthRange = calendar.range(of: .day, in: .month, for: m)
                    let daysInMonth = monthRange?.count ?? 30
                    let monthEnd = calendar.date(byAdding: .day, value: daysInMonth, to: m) ?? m
                    var feesThisMonth: [String: Int] = [:]
                    for b in filteredBookings {
                        if nightsInMonth(b, monthStart: m, monthEnd: monthEnd) <= 0 { continue }
                        if let c = b.classified { feesThisMonth[c.id] = c.fees ?? 0 }
                    }
                    totalCharges += Double(feesThisMonth.values.reduce(0, +))
                    m = calendar.date(byAdding: .month, value: 1, to: m) ?? m
                }
                
                // Rentabilité actuelle mois en cours
                var currentMonthPastRevenue: Double = 0
                for b in pastBookings {
                    if nightsInMonth(b, monthStart: currentMonthStart, monthEnd: currentMonthEnd) <= 0 { continue }
                    if let calc = b.platform?.calculatePrice(for: b) { currentMonthPastRevenue += calc.hostTotal }
                }
                let profitabilityCurrentMonthActual = currentMonthCharges > 0 ? currentMonthPastRevenue / currentMonthCharges * 100 : (currentMonthPastRevenue > 0 ? 100 : 0)
                
                // Rentabilité prévisionnelle mois en cours
                var currentMonthAllRevenue: Double = 0
                for b in filteredBookings {
                    if nightsInMonth(b, monthStart: currentMonthStart, monthEnd: currentMonthEnd) <= 0 { continue }
                    if let calc = b.platform?.calculatePrice(for: b) { currentMonthAllRevenue += calc.hostTotal }
                }
                let profitabilityCurrentMonthForecast = currentMonthCharges > 0 ? currentMonthAllRevenue / currentMonthCharges * 100 : (currentMonthAllRevenue > 0 ? 100 : 0)
                
                // Rentabilité totale : même période (→ aujourd'hui) et mêmes charges pour les deux → actuel ≤ prévisionnel
                var totalPastRevenue: Double = 0
                for b in pastBookings {
                    if let calc = b.platform?.calculatePrice(for: b) { totalPastRevenue += calc.hostTotal }
                }
                var totalAllRevenueInPeriod: Double = 0
                for b in filteredBookings where daysInPeriod(b, periodStart: periodStart, periodEnd: periodEnd) > 0 {
                    if let calc = b.platform?.calculatePrice(for: b) { totalAllRevenueInPeriod += calc.hostTotal }
                }
                let profitabilityTotalActual = totalCharges > 0 ? totalPastRevenue / totalCharges * 100 : (totalPastRevenue > 0 ? 100 : 0)
                let profitabilityTotalForecast = totalCharges > 0 ? totalAllRevenueInPeriod / totalCharges * 100 : (totalAllRevenueInPeriod > 0 ? 100 : 0)
                
                occupationCurrentMonthLabel.text = String(format: "%.0f%% (→ %.0f%%)", occupancyCurrentMonthActual, occupancyCurrentMonthForecast)
                occupationTotalLabel.text = String(format: "%.0f%% (→ %.0f%%)", occupancyTotalActual, occupancyTotalForecast)
                profitabilityCurrentMonthLabel.text = String(format: "%.0f%% (→ %.0f%%)", profitabilityCurrentMonthActual, profitabilityCurrentMonthForecast)
                profitabilityTotalLabel.text = String(format: "%.0f%% (→ %.0f%%)", profitabilityTotalActual, profitabilityTotalForecast)
                
                // Stats générales
                func nights(_ b: RU_Booking) -> Int {
                    max(0, calendar.dateComponents([.day], from: b.dates.start, to: b.dates.end).day ?? 0)
                }
                func guests(_ b: RU_Booking) -> Int {
                    (b.travelers.adults ?? 0) + (b.travelers.children ?? 0) + (b.travelers.babies ?? 0)
                }
                let totalNights = filteredBookings.reduce(0) { $0 + nights($1) }
                let bookingCount = filteredBookings.count
                totalNightsLabel.text = "\(totalNights)"
                averageNightsLabel.text = bookingCount > 0 ? String(format: "%.1f", Double(totalNights) / Double(bookingCount)) : String(key: "reporting.value.placeholder")
                let totalGuests = filteredBookings.reduce(0) { $0 + guests($1) }
                averageGuestsLabel.text = bookingCount > 0 ? String(format: "%.1f", Double(totalGuests) / Double(bookingCount)) : String(key: "reporting.value.placeholder")
                var platformBookingCount: [String: Int] = [:]
                var platformRevenue: [String: Double] = [:]
                for b in filteredBookings {
                    guard let p = b.platform else { continue }
                    platformBookingCount[p.id, default: 0] += 1
                    if let calc = p.calculatePrice(for: b) {
                        platformRevenue[p.id, default: 0] += calc.hostTotal
                    }
                }
                let mostUsed = platformBookingCount.max(by: { $0.value < $1.value })
                mostUsedPlatformLabel.platform = mostUsed.flatMap { id in RU_Platform.all?.first(where: { $0.id == id.key }) }
                let mostProfitable = platformRevenue.max(by: { $0.value < $1.value })
                mostProfitablePlatformLabel.platform = mostProfitable.flatMap { id in RU_Platform.all?.first(where: { $0.id == id.key }) }
            }
        }
    }
    private var currentFilterName:String? {
        
        didSet {
            
            updateFilterNavigationItem()
        }
    }
    private lazy var occupationCurrentMonthLabel: RU_Label = .init()
    private lazy var occupationTotalLabel: RU_Label = .init()
    private lazy var profitabilityCurrentMonthLabel: RU_Label = .init()
    private lazy var profitabilityTotalLabel: RU_Label = .init()
    private lazy var totalNightsLabel: RU_Label = .init()
    private lazy var averageNightsLabel: RU_Label = .init()
    private lazy var averageGuestsLabel: RU_Label = .init()
    private lazy var mostUsedPlatformLabel: RU_Platform_Label = .init()
    private lazy var mostProfitablePlatformLabel: RU_Platform_Label = .init()
    
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		tabBarItem = .init(title: String(key: "tabbar.reporting"), image: UIImage(systemName: "square.grid.2x2"), tag: RU_TabBarController.Indexes.allCases.firstIndex(of: .Reporting) ?? 0)
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func loadView() {
		
		super.loadView()
		
        updateFilterNavigationItem()
		navigationItem.title = String(key: "reporting.title")
        
        let contentScrollView:RU_ScrollView = .init()
        
        let contentStackView:RU_StackView = .init()
        contentStackView.axis = .vertical
        contentStackView.spacing = 2*UI.Margins
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = .init(UI.Margins)
        contentScrollView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
        }
        
        view.addSubview(contentScrollView)
        contentScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let mainSectionStackView:RU_Section_StackView = .init()
        mainSectionStackView.title = String(key: "reporting.section.main")
        mainSectionStackView.subtitle = String(key: "reporting.section.main.subtitle")
        mainSectionStackView.addArrangedSubview(createRow(icon: "moon.zzz.fill", title: String(key: "reporting.main.totalNights"), view: totalNightsLabel))
        mainSectionStackView.addArrangedSubview(createRow(icon: "moon.fill", title: String(key: "reporting.main.averageNights"), view: averageNightsLabel))
        mainSectionStackView.addArrangedSubview(createRow(icon: "person.2.fill", title: String(key: "reporting.main.averageGuests"), view: averageGuestsLabel))
        
        let mostUsedPlatformStackView:RU_StackView = .init(arrangedSubviews: [.init(),mostUsedPlatformLabel])
        mostUsedPlatformStackView.axis = .horizontal
        
        mainSectionStackView.addArrangedSubview(createRow(icon: "square.grid.2x2", title: String(key: "reporting.main.mostUsedPlatform"), view: mostUsedPlatformStackView))
        
        let mostProfitablePlatformStackView:RU_StackView = .init(arrangedSubviews: [.init(),mostProfitablePlatformLabel])
        mostProfitablePlatformStackView.axis = .horizontal
        
        mainSectionStackView.addArrangedSubview(createRow(icon: "eurosign.circle.fill", title: String(key: "reporting.main.mostProfitablePlatform"), view: mostProfitablePlatformStackView, isHighlighted: true))
        contentStackView.addArrangedSubview(mainSectionStackView)
        
        let occupationSectionStackView:RU_Section_StackView = .init()
        occupationSectionStackView.title = String(key: "reporting.section.occupancy")
        occupationSectionStackView.subtitle = String(key: "reporting.section.occupancy.subtitle")
        occupationSectionStackView.addArrangedSubview(createRow(icon: "calendar", title: String(key: "reporting.occupancy.currentMonth"), view: occupationCurrentMonthLabel))
        occupationSectionStackView.addArrangedSubview(createRow(icon: "equal.circle.fill", title: String(key: "reporting.occupancy.total"), view: occupationTotalLabel, isHighlighted: true))
        
        let occupationSectionButton:RU_Button = .init(String(key: "reporting.details.button")) { [weak self] _ in
            
            let viewController:RU_Reporting_Detail_Occupation_ViewController = .init()
            self?.navigationController?.pushViewController(viewController, animated: true)
        }
        occupationSectionButton.titleFont = Fonts.Content.Button.Title.withSize(Fonts.Size)
        occupationSectionButton.image = UIImage(systemName: "arrowtriangle.right.square")?.applyingSymbolConfiguration(.init(scale: .small))
        occupationSectionButton.configuration?.imagePadding = UI.Margins/2
        occupationSectionButton.configuration?.imagePlacement = .trailing
        occupationSectionStackView.addArrangedSubview(occupationSectionButton)
        
        contentStackView.addArrangedSubview(occupationSectionStackView)
        
        let profitabilitySectionStackView:RU_Section_StackView = .init()
        profitabilitySectionStackView.title = String(key: "reporting.section.profitability")
        profitabilitySectionStackView.subtitle = String(key: "reporting.section.profitability.subtitle")
        profitabilitySectionStackView.addArrangedSubview(createRow(icon: "eurosign", title: String(key: "reporting.profitability.currentMonth"), view: profitabilityCurrentMonthLabel))
        profitabilitySectionStackView.addArrangedSubview(createRow(icon: "equal.circle.fill", title: String(key: "reporting.profitability.total"), view: profitabilityTotalLabel, isHighlighted: true))
        
        let profitabilitySectionButton:RU_Button = .init(String(key: "reporting.details.button")) { [weak self] _ in
            
            let viewController:RU_Reporting_Detail_Profitability_ViewController = .init()
            self?.navigationController?.pushViewController(viewController, animated: true)
        }
        profitabilitySectionButton.titleFont = Fonts.Content.Button.Title.withSize(Fonts.Size)
        profitabilitySectionButton.image = UIImage(systemName: "arrowtriangle.right.square")?.applyingSymbolConfiguration(.init(scale: .small))
        profitabilitySectionButton.configuration?.imagePadding = UI.Margins/2
        profitabilitySectionButton.configuration?.imagePlacement = .trailing
        profitabilitySectionStackView.addArrangedSubview(profitabilitySectionButton)
        
        contentStackView.addArrangedSubview(profitabilitySectionStackView)
        
        NotificationCenter.add(.updateBookings) { [weak self] _ in
            
            self?.updateData()
        }
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
