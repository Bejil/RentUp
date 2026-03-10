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
            
            filteredBookings = bookings
        }
    }
    private var filteredBookings:[RU_Booking]? {
        
        didSet {
            
            view.dismissPlaceholder()
            
            if filteredBookings?.isEmpty ?? true {
                
                contentScrollView.isHidden = true
                
                let placeholderView = view.showPlaceholder(.Empty)
                let button = placeholderView.addButton(String(key: "bookings.create.button")) { _ in
                    
                    RU_Booking.create()
                }
                button.image = UIImage(systemName: "plus")
                
                [occupationCurrentMonthLabel, occupationPreviousMonthLabel, occupationTotalLabel, profitabilityCurrentMonthLabel, profitabilityPreviousMonthLabel, profitabilityTotalLabel, totalNightsLabel, averageNightsLabel, averageGuestsLabel].forEach { $0.text = String(key: "reporting.value.placeholder") }
                mostUsedPlatformLabel.platform = nil
                mostUsedPlatformLabel.text = String(key: "reporting.value.placeholder")
                mostProfitablePlatformLabel.platform = nil
                mostProfitablePlatformLabel.text = String(key: "reporting.value.placeholder")
            }
            else {
                
                contentScrollView.isHidden = false
                
                [occupationCurrentMonthLabel, occupationPreviousMonthLabel, occupationTotalLabel, profitabilityCurrentMonthLabel, profitabilityPreviousMonthLabel, profitabilityTotalLabel, totalNightsLabel, averageNightsLabel, averageGuestsLabel].forEach { $0.text = String(key: "reporting.value.placeholder") }
                mostUsedPlatformLabel.platform = nil
                mostUsedPlatformLabel.text = String(key: "reporting.value.placeholder")
                mostProfitablePlatformLabel.platform = nil
                mostProfitablePlatformLabel.text = String(key: "reporting.value.placeholder")
            }

            let listForFees = filteredBookings?.filter { $0.status != .cancelled } ?? []
            let hasAnyClassifiedWithFees = listForFees.contains(where: { ($0.classified?.fees ?? 0) > 0 })
            profitabilityTipView.isHidden = hasAnyClassifiedWithFees
            profitabilityPreviousMonthRow.isHidden = !hasAnyClassifiedWithFees
            profitabilityCurrentMonthRow.isHidden = !hasAnyClassifiedWithFees
            profitabilityTotalRow.isHidden = !hasAnyClassifiedWithFees
            profitabilityButton.isHidden = !hasAnyClassifiedWithFees
            
            guard let list = filteredBookings?.filter({ $0.status != .cancelled }), !list.isEmpty else { return }
            
            let listCopy = list
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
                let rawFirst = pastBookings.map(\.dates.start).min() ?? currentMonthStart
                let maxStart = calendar.date(byAdding: .month, value: -60, to: currentMonthEnd) ?? rawFirst
                let firstPastStart = rawFirst < maxStart ? maxStart : rawFirst
                let periodEnd = currentMonthEnd
                let totalPeriodDays = max(1, calendar.dateComponents([.day], from: firstPastStart, to: periodEnd).day ?? 1)
                func nightsInMonth(_ b: RU_Booking, monthStart: Date, monthEnd: Date) -> Int {
                    let start = max(b.dates.start, monthStart), end = min(b.dates.end, monthEnd)
                    return max(0, calendar.dateComponents([.day], from: start, to: end).day ?? 0)
                }
                func daysInPeriod(_ b: RU_Booking, periodStart: Date, periodEnd: Date) -> Int {
                    let start = max(b.dates.start, periodStart), end = min(b.dates.end, periodEnd)
                    return max(0, calendar.dateComponents([.day], from: start, to: end).day ?? 0)
                }
                var currentMonthPastNights = 0
                for b in pastBookings { currentMonthPastNights += nightsInMonth(b, monthStart: currentMonthStart, monthEnd: currentMonthEnd) }
                let occCurrActual = currentMonthDays > 0 ? Double(currentMonthPastNights) / Double(currentMonthDays) * 100 : 0
                var currentMonthAllNights = 0
                for b in listCopy { currentMonthAllNights += nightsInMonth(b, monthStart: currentMonthStart, monthEnd: currentMonthEnd) }
                let occCurrForecast = currentMonthDays > 0 ? Double(currentMonthAllNights) / Double(currentMonthDays) * 100 : 0
                var previousMonthPastNights = 0
                for b in pastBookings { previousMonthPastNights += nightsInMonth(b, monthStart: previousMonthStart, monthEnd: previousMonthEnd) }
                let occPrevActual = previousMonthDays > 0 ? Double(previousMonthPastNights) / Double(previousMonthDays) * 100 : 0
                var previousMonthAllNights = 0
                for b in listCopy { previousMonthAllNights += nightsInMonth(b, monthStart: previousMonthStart, monthEnd: previousMonthEnd) }
                let occPrevForecast = previousMonthDays > 0 ? Double(previousMonthAllNights) / Double(previousMonthDays) * 100 : 0
                var totalPastNights = 0
                for b in pastBookings { totalPastNights += daysInPeriod(b, periodStart: firstPastStart, periodEnd: periodEnd) }
                let occTotActual = Double(totalPastNights) / Double(totalPeriodDays) * 100
                var totalAllNights = 0
                for b in listCopy { totalAllNights += daysInPeriod(b, periodStart: firstPastStart, periodEnd: periodEnd) }
                let occTotForecast = Double(totalAllNights) / Double(totalPeriodDays) * 100
                var classifiedFees: [String: Int] = [:]
                for b in listCopy {
                    if nightsInMonth(b, monthStart: currentMonthStart, monthEnd: currentMonthEnd) <= 0 { continue }
                    if let c = b.classified { classifiedFees[c.id] = c.fees ?? 0 }
                }
                let currentMonthCharges = Double(classifiedFees.values.reduce(0, +))
                let periodStart = firstPastStart
                var periodStartMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: periodStart)) ?? periodStart
                var totalCharges: Double = 0
                while periodStartMonth < periodEnd {
                    autoreleasepool {
                        let monthRange = calendar.range(of: .day, in: .month, for: periodStartMonth)
                        let daysInMonth = monthRange?.count ?? 30
                        let monthEnd = calendar.date(byAdding: .day, value: daysInMonth, to: periodStartMonth) ?? periodStartMonth
                        var fees: [String: Int] = [:]
                        for b in listCopy {
                            if nightsInMonth(b, monthStart: periodStartMonth, monthEnd: monthEnd) <= 0 { continue }
                            if let c = b.classified { fees[c.id] = c.fees ?? 0 }
                        }
                        totalCharges += Double(fees.values.reduce(0, +))
                    }
                    periodStartMonth = calendar.date(byAdding: .month, value: 1, to: periodStartMonth) ?? periodStartMonth
                }
                var currMonthPastRev: Double = 0
                autoreleasepool {
                    for b in pastBookings {
                        if nightsInMonth(b, monthStart: currentMonthStart, monthEnd: currentMonthEnd) <= 0 { continue }
                        if let calc = b.platform?.calculatePrice(for: b) { currMonthPastRev += calc.hostTotal }
                    }
                }
                let profCurrActual = currentMonthCharges > 0 ? currMonthPastRev / currentMonthCharges * 100 : (currMonthPastRev > 0 ? 100 : 0)
                var currMonthAllRev: Double = 0
                autoreleasepool {
                    for b in listCopy {
                        if nightsInMonth(b, monthStart: currentMonthStart, monthEnd: currentMonthEnd) <= 0 { continue }
                        if let calc = b.platform?.calculatePrice(for: b) { currMonthAllRev += calc.hostTotal }
                    }
                }
                let profCurrForecast = currentMonthCharges > 0 ? currMonthAllRev / currentMonthCharges * 100 : (currMonthAllRev > 0 ? 100 : 0)
                var previousMonthFees: [String: Int] = [:]
                for b in listCopy {
                    if nightsInMonth(b, monthStart: previousMonthStart, monthEnd: previousMonthEnd) <= 0 { continue }
                    if let c = b.classified { previousMonthFees[c.id] = c.fees ?? 0 }
                }
                let previousMonthCharges = Double(previousMonthFees.values.reduce(0, +))
                var prevMonthPastRev: Double = 0
                for b in pastBookings {
                    if nightsInMonth(b, monthStart: previousMonthStart, monthEnd: previousMonthEnd) <= 0 { continue }
                    if let calc = b.platform?.calculatePrice(for: b) { prevMonthPastRev += calc.hostTotal }
                }
                let profPrevActual = previousMonthCharges > 0 ? prevMonthPastRev / previousMonthCharges * 100 : (prevMonthPastRev > 0 ? 100 : 0)
                var prevMonthAllRev: Double = 0
                for b in listCopy {
                    if nightsInMonth(b, monthStart: previousMonthStart, monthEnd: previousMonthEnd) <= 0 { continue }
                    if let calc = b.platform?.calculatePrice(for: b) { prevMonthAllRev += calc.hostTotal }
                }
                let profPrevForecast = previousMonthCharges > 0 ? prevMonthAllRev / previousMonthCharges * 100 : (prevMonthAllRev > 0 ? 100 : 0)
                var totalPastRev: Double = 0
                autoreleasepool {
                    for b in pastBookings { if let calc = b.platform?.calculatePrice(for: b) { totalPastRev += calc.hostTotal } }
                }
                var totalAllRev: Double = 0
                autoreleasepool {
                    for b in listCopy where daysInPeriod(b, periodStart: periodStart, periodEnd: periodEnd) > 0 {
                        if let calc = b.platform?.calculatePrice(for: b) { totalAllRev += calc.hostTotal }
                    }
                }
                let profTotActual = totalCharges > 0 ? totalPastRev / totalCharges * 100 : (totalPastRev > 0 ? 100 : 0)
                let profTotForecast = totalCharges > 0 ? totalAllRev / totalCharges * 100 : (totalAllRev > 0 ? 100 : 0)
                func nights(_ b: RU_Booking) -> Int { max(0, calendar.dateComponents([.day], from: b.dates.start, to: b.dates.end).day ?? 0) }
                func guests(_ b: RU_Booking) -> Int { (b.travelers.adults ?? 0) + (b.travelers.children ?? 0) + (b.travelers.babies ?? 0) }
                let totalNights = listCopy.reduce(0) { $0 + nights($1) }
                let count = listCopy.count
                let avgNightsStr = count > 0 ? String(format: "%.1f", Double(totalNights) / Double(count)) : String(key: "reporting.value.placeholder")
                let totalGuests = listCopy.reduce(0) { $0 + guests($1) }
                let avgGuestsStr = count > 0 ? String(format: "%.1f", Double(totalGuests) / Double(count)) : String(key: "reporting.value.placeholder")
                var platCount: [String: Int] = [:]
                var platRev: [String: Double] = [:]
                autoreleasepool {
                    for b in listCopy {
                        guard let p = b.platform else { continue }
                        platCount[p.id, default: 0] += 1
                        if let calc = p.calculatePrice(for: b) { platRev[p.id, default: 0] += calc.hostTotal }
                    }
                }
                let mostUsedId = platCount.max(by: { $0.value < $1.value })?.key
                let mostProfId = platRev.max(by: { $0.value < $1.value })?.key
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.occupationCurrentMonthLabel.text = String(format: "%.0f%% (→ %.0f%%)", occCurrActual, occCurrForecast)
                    self.occupationPreviousMonthLabel.text = String(format: "%.0f%% (→ %.0f%%)", occPrevActual, occPrevForecast)
                    self.occupationTotalLabel.text = String(format: "%.0f%% (→ %.0f%%)", occTotActual, occTotForecast)
                    self.profitabilityCurrentMonthLabel.text = String(format: "%.0f%% (→ %.0f%%)", profCurrActual, profCurrForecast)
                    self.profitabilityPreviousMonthLabel.text = String(format: "%.0f%% (→ %.0f%%)", profPrevActual, profPrevForecast)
                    self.profitabilityTotalLabel.text = String(format: "%.0f%% (→ %.0f%%)", profTotActual, profTotForecast)
                    self.totalNightsLabel.text = "\(totalNights)"
                    self.averageNightsLabel.text = avgNightsStr
                    self.averageGuestsLabel.text = avgGuestsStr
                    self.mostUsedPlatformLabel.platform = mostUsedId.flatMap { id in RU_Platform.all?.first(where: { $0.id == id }) }
                    self.mostProfitablePlatformLabel.platform = mostProfId.flatMap { id in RU_Platform.all?.first(where: { $0.id == id }) }
                }
            }
        }
    }
    private var currentFilterName:String? {
        
        didSet {
            
            updateFilterNavigationItem()
        }
    }
    private lazy var contentScrollView:RU_ScrollView = .init()
    private lazy var occupationCurrentMonthLabel: RU_Label = .init()
    private lazy var occupationPreviousMonthLabel: RU_Label = .init()
    private lazy var occupationTotalLabel: RU_Label = .init()
    private lazy var profitabilityTipView:RU_Tip_StackView = {
        
        $0.title = String(key: "reporting.profitability.tip.title")
        $0.add(RU_Label(String(key: "reporting.profitability.tip.content")))
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
        
        let viewController:RU_Reporting_Detail_Profitability_ViewController = .init()
        self?.navigationController?.pushViewController(viewController, animated: true)
    })
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
        
        view.addSubview(contentScrollView)
        
        let contentStackView:RU_StackView = .init()
        contentStackView.axis = .vertical
        contentStackView.spacing = 2*UI.Margins
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = .init(UI.Margins)
        contentScrollView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
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
        occupationSectionStackView.addArrangedSubview(createRow(icon: "calendar.badge.clock", title: String(key: "reporting.occupancy.previousMonth"), view: occupationPreviousMonthLabel))
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
        profitabilitySectionStackView.addArrangedSubview(profitabilityTipView)
        profitabilitySectionStackView.addArrangedSubview(profitabilityPreviousMonthRow)
        profitabilitySectionStackView.addArrangedSubview(profitabilityCurrentMonthRow)
        profitabilitySectionStackView.addArrangedSubview(profitabilityTotalRow)
        profitabilitySectionStackView.addArrangedSubview(profitabilityButton)
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
        
        if filteredBookings?.isEmpty ?? true {
            
            navigationItem.rightBarButtonItem = nil
        }
        else {
            
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
