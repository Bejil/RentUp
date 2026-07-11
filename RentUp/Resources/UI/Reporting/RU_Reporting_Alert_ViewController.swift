//
//  RU_Reporting_Alert_ViewController.swift
//  RentUp
//
//  Created by Michaël Blin on 30/03/2026.
//

import UIKit
import SnapKit

public class RU_Reporting_Alert_ViewController : RU_Alert_ViewController {
    
    public var bookings:[RU_Booking]? {
        
        didSet {
            
            if let bookings, !bookings.isEmpty {
                let calendar = Calendar.current
                let now = Date()
                
                let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
                let monthM1Start = calendar.date(byAdding: .month, value: -1, to: currentMonthStart) ?? currentMonthStart
                let monthM2Start = calendar.date(byAdding: .month, value: -2, to: currentMonthStart) ?? currentMonthStart
                
                func monthEnd(from monthStart: Date) -> Date {
                    let range = calendar.range(of: .day, in: .month, for: monthStart)
                    let days = range?.count ?? 30
                    return calendar.date(byAdding: .day, value: days, to: monthStart) ?? monthStart
                }
                
                func nightsInMonth(_ b: RU_Booking, monthStart: Date, monthEnd: Date) -> Int {
                    let start = max(b.dates.start, monthStart)
                    let end = min(b.dates.end, monthEnd)
                    return max(0, calendar.dateComponents([.day], from: start, to: end).day ?? 0)
                }
                
                func bookingNights(_ b: RU_Booking) -> Int {
                    max(0, calendar.dateComponents([.day], from: b.dates.start, to: b.dates.end).day ?? 0)
                }
                
                func proratedHostTotal(_ b: RU_Booking, monthNights: Int) -> Double {
                    let totalNights = bookingNights(b)
                    guard totalNights > 0 else { return 0 }
                    guard let hostTotal = b.platform?.calculatePrice(for: b)?.hostTotal else { return 0 }
                    return hostTotal * Double(monthNights) / Double(totalNights)
                }
                
                func monthStats(monthStart: Date) -> (
                    nights: Int,
                    occupation: Double,
                    profitability: Double,
                    netTotal: Double,
                    mostUsedPlatform: RU_Platform?
                ) {
                    let end = monthEnd(from: monthStart)
                    let daysInMonth = max(1, calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30)
                    let activeBookings = RU_Reporting_Detail_ViewController.ReportingMonthMetrics.eligibleBookings(bookings)
                    
                    var nights = 0
                    var netTotal: Double = 0
                    var platformCountById: [String: Int] = [:]
                    var classifieds: [RU_Classified] = []
                    
                    for b in activeBookings {
                        let n = nightsInMonth(b, monthStart: monthStart, monthEnd: end)
                        guard n > 0 else { continue }
                        
                        nights += n
                        netTotal += proratedHostTotal(b, monthNights: n)
                        
                        if let p = b.platform {
                            platformCountById[p.uuid, default: 0] += 1
                        }
                        if let c = b.classified, !classifieds.contains(c) {
                            classifieds.append(c)
                        }
                    }
                    
                    let occupation = Double(nights) / Double(daysInMonth) * 100
                    
                    let charges = Double(classifieds.compactMap(\.fees).reduce(0, +))
                    let profitability = charges > 0 ? (netTotal / charges) * 100 : (netTotal > 0 ? 100 : 0)
                    
                    let mostUsedPlatformId = platformCountById.max(by: { $0.value < $1.value })?.key
                    let mostUsedPlatform = mostUsedPlatformId.flatMap { id in
                        RU_Platform.all?.first(where: { $0.uuid == id })
                    }
                    
                    return (nights, occupation, profitability, netTotal, mostUsedPlatform)
                }
                
                func mostProfitablePlatform(monthStart: Date) -> RU_Platform? {
                    let end = monthEnd(from: monthStart)
                    let activeBookings = RU_Reporting_Detail_ViewController.ReportingMonthMetrics.eligibleBookings(bookings)
                    var revenueByPlatformId: [String: Double] = [:]
                    
                    for b in activeBookings {
                        let monthNights = nightsInMonth(b, monthStart: monthStart, monthEnd: end)
                        guard monthNights > 0 else { continue }
                        guard let platform = b.platform else { continue }
                        let revenue = proratedHostTotal(b, monthNights: monthNights)
                        revenueByPlatformId[platform.uuid, default: 0] += revenue
                    }
                    
                    let platformId = revenueByPlatformId.max(by: { $0.value < $1.value })?.key
                    return RU_Platform.all?.first(where: { $0.uuid == platformId })
                }
                
                func formatInt(_ value: Int) -> String {
                    let formatter = NumberFormatter()
                    formatter.locale = Locale(identifier: "fr_FR")
                    formatter.numberStyle = .decimal
                    formatter.groupingSeparator = " "
                    formatter.maximumFractionDigits = 0
                    return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
                }
                
                func formatPercent(_ value: Double, fractionDigits: Int = 1) -> String {
                    let formatter = NumberFormatter()
                    formatter.locale = Locale(identifier: "fr_FR")
                    formatter.numberStyle = .decimal
                    formatter.groupingSeparator = " "
                    formatter.minimumFractionDigits = fractionDigits
                    formatter.maximumFractionDigits = fractionDigits
                    let number = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
                    return "\(number) %"
                }
                
                func formatCurrency(_ value: Double) -> String {
                    let formatter = NumberFormatter()
                    formatter.locale = Locale(identifier: "fr_FR")
                    formatter.numberStyle = .currency
                    formatter.currencyCode = "EUR"
                    formatter.maximumFractionDigits = 2
                    formatter.minimumFractionDigits = 0
                    return formatter.string(from: NSNumber(value: value)) ?? "\(value) €"
                }
                
                func monthLabel(_ date: Date) -> String {
                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: "fr_FR")
                    formatter.dateFormat = "LLLL"
                    return formatter.string(from: date).capitalized
                }
                
                // Valeurs demandées
                let m1 = monthStats(monthStart: monthM1Start)
                let m2 = monthStats(monthStart: monthM2Start)
                
                let monthM1Name = monthLabel(monthM1Start)
                let monthM2Name = monthLabel(monthM2Start)
                
                if m1.netTotal > m2.netTotal {
                    
                    emojiLabel.text = "🤩"
                    title = String(key: "reporting.alert.title.congrats")
                    contentLabel.text = String(format: String(key: "reporting.alert.content.better"), monthM1Name, monthM2Name)
                    
                    UIApplication.wait {
                        
                        MB_Confetti.start()
                    }
                }
                else if m1.netTotal < m2.netTotal {
                    
                    emojiLabel.text = "😔"
                    title = String(key: "reporting.alert.title.monthlyReview")
                    contentLabel.text = String(format: String(key: "reporting.alert.content.worse"), monthM1Name, monthM2Name)
                }
                else {
                    
                    emojiLabel.text = "😌"
                    title = String(key: "reporting.alert.title.monthlyReview")
                    contentLabel.text = String(format: String(key: "reporting.alert.content.equal"), monthM1Name, monthM2Name)
                }
                
                nightsTextField?.text = formatInt(m1.nights)
                platformLabel.platform = mostProfitablePlatform(monthStart: monthM1Start)
                occupationTextField?.text = formatPercent(m1.occupation, fractionDigits: 1)
                profitabilityTextField?.text = formatPercent(m1.profitability, fractionDigits: 1)
                totalTextField?.text = formatCurrency(m1.netTotal)
            }
        }
    }
    private lazy var liquidView:RU_Liquid_View = .init(color: Colors.Primary)
    private lazy var emojiLabel:RU_Label = {
        
        $0.font = Fonts.Content.Title.H1.withSize(Fonts.Size+75)
        return $0
        
    }(RU_Label())
    private lazy var contentLabel:RU_Label = {
        
        $0.textAlignment = .center
        return $0
        
    }(RU_Label())
    private var nightsTextField:RU_TextField?
    private lazy var platformLabel:RU_Platform_Label = .init()
    private var occupationTextField:RU_TextField?
    private var profitabilityTextField:RU_TextField?
    private var totalTextField:RU_TextField?
    private lazy var rowStackView:RU_StackView = {
        
        $0.isHidden = true
        $0.axis = .vertical
        return $0
        
    }(RU_StackView())
    
    public override func loadView() {
        
        super.loadView()
        
        backgroundView.addSubview(liquidView)
        liquidView.snp.makeConstraints { (make) in
            
            make.edges.equalToSuperview()
        }
        liquidView.startFill(duration: 1.5)
        
        containerView.addSubview(emojiLabel)
        emojiLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(containerView.snp.top).inset(-UI.Margins/2)
        }
        
        add(contentLabel)
        
        let nightsSectionTextFieldRowStackView:RU_Section_TextFieldRow_StackView = .init()
        nightsSectionTextFieldRowStackView.image = UIImage(systemName: "moon.stars")!
        nightsSectionTextFieldRowStackView.title = String(key: "reporting.alert.row.nights")
        nightsSectionTextFieldRowStackView.textField.isEnabled = false
        nightsSectionTextFieldRowStackView.layoutMargins.bottom = UI.Margins/2
        nightsTextField = nightsSectionTextFieldRowStackView.textField
        rowStackView.addArrangedSubview(nightsSectionTextFieldRowStackView)
        
        let platformLabelStackView:RU_StackView = .init(arrangedSubviews: [.init(),platformLabel])
        platformLabelStackView.axis = .horizontal
        
        let platformSectionRowStackView:RU_Section_Row_StackView = .init()
        platformSectionRowStackView.image = UIImage(systemName: "app.badge.fill")
        platformSectionRowStackView.title = String(key: "reporting.alert.row.featuredPlatform")
        platformSectionRowStackView.layoutMargins.bottom = UI.Margins/2
        platformSectionRowStackView.view = platformLabelStackView
        rowStackView.addArrangedSubview(platformSectionRowStackView)
        
        let occupationSectionTextFieldRowStackView:RU_Section_TextFieldRow_StackView = .init()
        occupationSectionTextFieldRowStackView.image = UIImage(systemName: "calendar")!
        occupationSectionTextFieldRowStackView.title = String(key: "reporting.alert.row.occupation")
        occupationSectionTextFieldRowStackView.textField.isEnabled = false
        occupationSectionTextFieldRowStackView.layoutMargins.bottom = UI.Margins/2
        occupationTextField = occupationSectionTextFieldRowStackView.textField
        rowStackView.addArrangedSubview(occupationSectionTextFieldRowStackView)
        
        let profitabilitySectionTextFieldRowStackView:RU_Section_TextFieldRow_StackView = .init()
        profitabilitySectionTextFieldRowStackView.image = UIImage(systemName: "eurosign")!
        profitabilitySectionTextFieldRowStackView.title = String(key: "reporting.alert.row.profitability")
        profitabilitySectionTextFieldRowStackView.textField.isEnabled = false
        profitabilitySectionTextFieldRowStackView.layoutMargins.bottom = UI.Margins/2
        profitabilityTextField = profitabilitySectionTextFieldRowStackView.textField
        rowStackView.addArrangedSubview(profitabilitySectionTextFieldRowStackView)
        
        let totalSectionTextFieldRowStackView:RU_Section_TextFieldRow_StackView = .init()
        totalSectionTextFieldRowStackView.isHighlighted = true
        totalSectionTextFieldRowStackView.image = UIImage(systemName: "equal.circle.fill")!
        totalSectionTextFieldRowStackView.title = String(key: "reporting.alert.row.total")
        totalSectionTextFieldRowStackView.textField.isEnabled = false
        totalSectionTextFieldRowStackView.layoutMargins.bottom = UI.Margins/2
        totalTextField = totalSectionTextFieldRowStackView.textField
        rowStackView.addArrangedSubview(totalSectionTextFieldRowStackView)
        
        add(rowStackView)
        
        addDismissButton()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        rowStackView.isHidden = false
        rowStackView.animate()
    }
    
    public override func close(_ completion: (() -> Void)? = nil) {
        
        liquidView.startDrain(duration: 2.0) { [weak self] in
            
            self?.liquidView.removeFromSuperview()
        }
        
        MB_Confetti.stop()
        
        super.close(completion)
    }
}
