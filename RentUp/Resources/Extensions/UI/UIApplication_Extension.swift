//
//  UIApplication_Extension.swift
//  LettroLine
//
//  Created by BLIN Michael on 13/02/2025.
//

import UIKit

extension UIApplication {
	
	public static var isDebug:Bool {
		
		var state = false
		
#if DEBUG
		state = true
#endif
		
		return state
	}
	
	public func topMostViewController() -> UIViewController? {
		
		return UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.flatMap { $0.windows }.first { $0.rootViewController != nil }?.rootViewController?.topMostViewController()
	}
	
	public static func wait(_ delay:Double = 0.3, _ completion:(()->Void)?) {
		
		DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
			
			completion?()
		}
	}
    
    public static func reset() {
        
        UserDefaults.reset()
        
        UIApplication.presentWelcome()
    }
    
    public static func presentWelcome() {
        
        let connectedScenes = UIApplication.shared.connectedScenes
        let windowScene = connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        let window = windowScene?.keyWindow
        (window?.rootViewController as? RU_TabBarController)?.viewControllers?.forEach { $0.tabBarItem.badgeValue = nil }
        
        let controller:RU_Onboarding_Welcome_ViewController = .init()
        controller.completion = {
            
            UIApplication.setTabBarControllerAsRootViewController()
        }
        window?.rootViewController = controller
    }
    
    public static func setTabBarControllerAsRootViewController() {
        
        let connectedScenes = UIApplication.shared.connectedScenes
        let windowScene = connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        let window = windowScene?.keyWindow
        window?.rootViewController = RU_TabBarController()
        
        updateTabBarBadges()
        
        if let window {
            
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {}, completion: { _ in
                
                UIApplication.loadBookingsCSVIfNeeded()
            })
        }
    }
    
    public static func updateTabBarBadges() {
        
        let connectedScenes = UIApplication.shared.connectedScenes
        let windowScene = connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        let window = windowScene?.keyWindow
        
        if let tabBarController = window?.rootViewController as? RU_TabBarController {
            
            tabBarController.viewControllers?.forEach { $0.tabBarItem.badgeValue = nil }
            
            RU_Booking.getAll { _, bookings in
                
                if !(bookings?.isEmpty ?? true) {
                    
                    var indexesToBadge: [RU_TabBarController.Indexes] = [.Bookings]
                    
                    if bookings?.current != nil || Date().nextUpcomingHolidayOpportunity(withinDays: 60) != nil {
                        
                        indexesToBadge.append(.Home)
                    }
                    
                    if bookings?.current != nil {
                        
                        indexesToBadge.append(.Bookings)
                    }
                    
                    for index in indexesToBadge {
                        
                        if let tabIndex = RU_TabBarController.Indexes.allCases.firstIndex(where: { $0 == index }), tabIndex < (tabBarController.viewControllers?.count ?? 0) {
                            
                            tabBarController.viewControllers?[tabIndex].tabBarItem.badgeValue = "!"
                        }
                    }
                }
            }
        }
    }
    
    private static func loadBookingsCSVIfNeeded(_ state:Bool = false) {
        
        if state {
            
            RU_Alert_ViewController.presentLoading { alertController in
                
                RU_Classified.getAll { error, classifieds in
                    
                    alertController?.close {
                        
                        if !(classifieds?.isEmpty ?? true), let url = Bundle.main.url(forResource: "RU_Bookings", withExtension: "csv"), let content = try? String(contentsOf: url, encoding: .utf8) {
                            
                            UserDefaults.delete(.bookings)
                            
                            let platforms = RU_Platform.all ?? []
                            let dateFormatter: DateFormatter = {
                                let f = DateFormatter()
                                f.dateFormat = "dd/MM/yyyy"
                                f.locale = Locale(identifier: "fr_FR")
                                return f
                            }()
                            let lines = content.components(separatedBy: .newlines)
                            guard let headerLine = lines.first,
                                  headerLine.contains("Arrivée"),
                                  headerLine.contains("Départ") else {
                                return
                            }
                            for line in lines.dropFirst() {
                                guard !line.trimmingCharacters(in: .whitespaces).isEmpty else { continue }
                                let row = UIApplication.parseCSVLine(line)
                                guard row.count >= 8 else { continue }
                                let arriveeStr = row[0]
                                let departStr = row[1]
                                let indemniteStr = row[2]
                                let menageStr = row[3]
                                let plateformeStr = row[4]
                                let persStr = row[5]
                                let configStr = row[6]
                                let commentaire = row[7]
                                guard let start = dateFormatter.date(from: arriveeStr),
                                      let end = dateFormatter.date(from: departStr) else { continue }
                                let booking = RU_Booking()
                                booking.classified = classifieds?.first
                                booking.dates.start = start
                                booking.dates.end = end
                                booking.costs.compensation = UIApplication.parseEuroAmount(indemniteStr)
                                booking.costs.cleaning = UIApplication.parseEuroAmount(menageStr)
                                let platformType = UIApplication.parsePlatformType(plateformeStr)
                                booking.platform = platforms.first { $0.type == platformType }
                                if let p = Int(persStr.trimmingCharacters(in: .whitespaces)), p > 0 {
                                    booking.travelers.adults = p
                                }
                                let beds = UIApplication.parseConfigurationBeds(configStr)
                                booking.beds.doubles = beds.doubles
                                booking.beds.singles = beds.singles
                                booking.beds.babies = beds.babies
                                booking.comment = commentaire.isEmpty ? nil : commentaire
                                
                                booking.save(nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private static func parseCSVLine(_ line: String) -> [String] {
        
        var row: [String] = []
        var current = ""
        var inQuotes = false
        
        for char in line {
            
            if char == "\"" {
                
                inQuotes.toggle()
            }
            else if char == "," && !inQuotes {
                
                row.append(current)
                current = ""
            }
            else {
                
                current.append(char)
            }
        }
        
        row.append(current)
        return row
    }

    private static func parseEuroAmount(_ value: String) -> Int? {
        
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }
        let digits = trimmed.replacingOccurrences(of: "€", with: "").replacingOccurrences(of: " ", with: "").trimmingCharacters(in: .whitespaces)
        let normalized = digits.replacingOccurrences(of: ",", with: ".")
        guard let d = Double(normalized) else { return nil }
        return Int(d.rounded())
    }

    private static func parsePlatformType(_ value: String) -> RU_Platform.PlatformType? {
        
        let lower = value.trimmingCharacters(in: .whitespaces).lowercased()
        switch lower {
        case "airbnb": return .airbnb
        case "booking": return .booking
        case "abritel": return .abritel
        default: return nil
        }
    }

    private static func parseConfigurationBeds(_ configuration: String) -> (doubles: Int?, singles: Int?, babies: Int?) {
        
        let trimmed = configuration.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return (nil, nil, nil) }
        var doubles = 0
        var singles = 0
        var babies = 0
        let parts = trimmed.components(separatedBy: " + ").map { $0.trimmingCharacters(in: .whitespaces) }
        
        for part in parts {
            
            if part.lowercased().hasPrefix("double") {
                
                let n = parseLeadingNumber(part, suffix: "double") ?? UIApplication.parseLeadingNumber(part, suffix: "doubles") ?? 1
                doubles += n
            }
            else if part.lowercased().contains("simple") {
                
                let n = parseLeadingNumber(part, suffix: "simple") ?? UIApplication.parseLeadingNumber(part, suffix: "simples") ?? 1
                singles += n
            }
            else if part.lowercased().contains("bébé") {
                
                let n = parseLeadingNumber(part, suffix: "bébé") ?? UIApplication.parseLeadingNumber(part, suffix: "bébés") ?? 1
                babies += n
            }
        }
        
        return (
            doubles > 0 ? doubles : nil,
            singles > 0 ? singles : nil,
            babies > 0 ? babies : nil
        )
    }

    private static func staticparseLeadingNumber(_ part: String, suffix: String) -> Int? {
        
        let lower = part.lowercased()
        let suf = suffix.lowercased()
        guard lower.hasSuffix(suf) else { return nil }
        let prefix = lower.dropLast(suf.count).trimmingCharacters(in: .whitespaces)
        guard !prefix.isEmpty, let n = Int(prefix), n > 0 else { return nil }
        return n
    }
    
    private static func parseLeadingNumber(_ part: String, suffix: String) -> Int? {
        
        let lower = part.lowercased()
        let suf = suffix.lowercased()
        guard lower.hasSuffix(suf) else { return nil }
        let prefix = lower.dropLast(suf.count).trimmingCharacters(in: .whitespaces)
        guard !prefix.isEmpty, let n = Int(prefix), n > 0 else { return nil }
        return n
    }
}
