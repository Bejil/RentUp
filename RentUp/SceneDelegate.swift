//
//  SceneDelegate.swift
//  RentUp
//
//  Created by BLIN Michael on 20/01/2026.
//

import UIKit
import IQKeyboardManagerSwift

public class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	public var window: UIWindow?

	public func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		
		// Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
		// If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
		// This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
		guard let windowScene = (scene as? UIWindowScene) else { return }
		
		window = UIWindow(windowScene: windowScene)
		window?.backgroundColor = Colors.Background.Application
		
		let viewController:RU_Splashscreen_ViewController = .init()
		viewController.completion = { [weak self] state in
			
            if state {
                
                self?.setTabBarControllerAsRootViewController()
            }
            else {
                
                let controller:RU_Onboarding_Welcome_ViewController = .init()
                controller.completion = { [weak self] in
                    
                    self?.setTabBarControllerAsRootViewController()
                }
                self?.window?.rootViewController = controller
            }
		}
		window?.rootViewController = viewController
		window?.makeKeyAndVisible()
		
		IQKeyboardManager.shared.isEnabled = true
	}

	public func sceneDidDisconnect(_ scene: UIScene) {
		// Called as the scene is being released by the system.
		// This occurs shortly after the scene enters the background, or when its session is discarded.
		// Release any resources associated with this scene that can be re-created the next time the scene connects.
		// The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
	}

	public func sceneDidBecomeActive(_ scene: UIScene) {
		// Called when the scene has moved from an inactive state to an active state.
		// Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
	}

	public func sceneWillResignActive(_ scene: UIScene) {
		// Called when the scene will move from an active state to an inactive state.
		// This may occur due to temporary interruptions (ex. an incoming phone call).
	}

	public func sceneWillEnterForeground(_ scene: UIScene) {

		updateTabBarBadges()
	}

	public func sceneDidEnterBackground(_ scene: UIScene) {
		// Called as the scene transitions from the foreground to the background.
		// Use this method to save data, release shared resources, and store enough scene-specific state information
		// to restore the scene back to its current state.
	}
    
    private func setTabBarControllerAsRootViewController() {
        
        window?.rootViewController = RU_TabBarController()
        
        updateTabBarBadges()
        
        if let window {
            
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {}, completion: { [weak self] _ in
                
                self?.loadBookingsCSVIfNeeded()
            })
        }
    }
    
    private func updateTabBarBadges() {
        
        if let tabBarController = window?.rootViewController as? RU_TabBarController {
            
            tabBarController.viewControllers?.forEach { $0.tabBarItem.badgeValue = nil }
            
            RU_Booking.getAll { _, bookings in
                
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
    
    private func loadBookingsCSVIfNeeded() {
        
        RU_Alert_ViewController.presentLoading { [weak self] alertController in
            
            RU_Classified.getAll { [weak self] error, classifieds in
                
                alertController?.close { [weak self] in
                  
                    if false, let self, !(classifieds?.isEmpty ?? true), let url = Bundle.main.url(forResource: "RU_Bookings", withExtension: "csv"), let content = try? String(contentsOf: url, encoding: .utf8) {
                        
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
                            let row = parseCSVLine(line)
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
                            booking.costs.compensation = parseEuroAmount(indemniteStr)
                            booking.costs.cleaning = parseEuroAmount(menageStr)
                            let platformType = parsePlatformType(plateformeStr)
                            booking.platform = platforms.first { $0.type == platformType }
                            if let p = Int(persStr.trimmingCharacters(in: .whitespaces)), p > 0 {
                                booking.travelers.adults = p
                            }
                            let beds = parseConfigurationBeds(configStr)
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
    
    private func parseCSVLine(_ line: String) -> [String] {
        
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

    private func parseEuroAmount(_ value: String) -> Int? {
        
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }
        let digits = trimmed.replacingOccurrences(of: "€", with: "").replacingOccurrences(of: " ", with: "").trimmingCharacters(in: .whitespaces)
        let normalized = digits.replacingOccurrences(of: ",", with: ".")
        guard let d = Double(normalized) else { return nil }
        return Int(d.rounded())
    }

    private func parsePlatformType(_ value: String) -> RU_Platform.PlatformType? {
        
        let lower = value.trimmingCharacters(in: .whitespaces).lowercased()
        switch lower {
        case "airbnb": return .airbnb
        case "booking": return .booking
        case "abritel": return .abritel
        default: return nil
        }
    }

    private func parseConfigurationBeds(_ configuration: String) -> (doubles: Int?, singles: Int?, babies: Int?) {
        
        let trimmed = configuration.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return (nil, nil, nil) }
        var doubles = 0
        var singles = 0
        var babies = 0
        let parts = trimmed.components(separatedBy: " + ").map { $0.trimmingCharacters(in: .whitespaces) }
        
        for part in parts {
            
            if part.lowercased().hasPrefix("double") {
                
                let n = parseLeadingNumber(part, suffix: "double") ?? parseLeadingNumber(part, suffix: "doubles") ?? 1
                doubles += n
            }
            else if part.lowercased().contains("simple") {
                
                let n = parseLeadingNumber(part, suffix: "simple") ?? parseLeadingNumber(part, suffix: "simples") ?? 1
                singles += n
            }
            else if part.lowercased().contains("bébé") {
                
                let n = parseLeadingNumber(part, suffix: "bébé") ?? parseLeadingNumber(part, suffix: "bébés") ?? 1
                babies += n
            }
        }
        
        return (
            doubles > 0 ? doubles : nil,
            singles > 0 ? singles : nil,
            babies > 0 ? babies : nil
        )
    }

    private func parseLeadingNumber(_ part: String, suffix: String) -> Int? {
        
        let lower = part.lowercased()
        let suf = suffix.lowercased()
        guard lower.hasSuffix(suf) else { return nil }
        let prefix = lower.dropLast(suf.count).trimmingCharacters(in: .whitespaces)
        guard !prefix.isEmpty, let n = Int(prefix), n > 0 else { return nil }
        return n
    }
}

