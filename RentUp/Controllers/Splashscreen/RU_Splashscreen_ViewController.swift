//
//  RU_Splashscreen_ViewController.swift
//  RentUp
//
//  Created by BLIN Michael on 02/02/2026.
//

import UIKit

public class RU_Splashscreen_ViewController : RU_ViewController {
    
    public var completion:((Bool)->Void)?
    
    public override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        setUpPlatforms()
    }
    
    private func setUpPlatforms() {
        
        RU_Alert_ViewController.presentLoading { [weak self] alertController in
            
            RU_Platform.setUp { [weak self] error in
                
                if let error {
                    
                    alertController?.close { [weak self] in
                        
                        RU_Alert_ViewController.present(error, handler: { [weak self] in
                            
                            self?.setUpPlatforms()
                        })
                    }
                }
                else {
                    
                    RU_Classified.getAll { error, classifieds in
                        
                        alertController?.close { [weak self] in
                            
                            if let error {
                                
                                RU_Alert_ViewController.present(error, handler: { [weak self] in
                                    
                                    self?.setUpPlatforms()
                                })
                            }
                            else {
                                
                                self?.loadBookingsCSVIfNeeded(classifieds: classifieds)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func loadBookingsCSVIfNeeded(classifieds: [RU_Classified]?) {
        
        if false, !(classifieds?.isEmpty ?? true), let url = Bundle.main.url(forResource: "RU_Bookings", withExtension: "csv"), let content = try? String(contentsOf: url, encoding: .utf8) {
            
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
        
        completion?(!(classifieds?.isEmpty ?? true))
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
