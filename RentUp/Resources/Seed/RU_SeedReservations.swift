//
//  RU_SeedReservations.swift
//  RentUp
//
//  Au lancement, ajoute les réservations du CSV au seul bien existant (une seule fois).
//

import Foundation

enum RU_SeedReservations {
    
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "fr_FR")
        f.dateFormat = "dd/MM/yyyy"
        f.timeZone = TimeZone.current
        return f
    }()
    
    /// Contenu CSV (colonnes : Arrivée, Départ, Nuités, Indemnité, Ménage, Plateforme, Statut, Pers., Configuration, Commentaire)
    private static let csvContent = """
    Arrivée,Départ,Nuités,Indemnité,Ménage,Plateforme,Statut,Pers.,Configuration,Commentaire
    29/08/2026,30/08/2026,1,,,Airbnb,À venir,3,Double + Simple,
    17/07/2026,19/07/2026,2,,,Abritel,À venir,4,Double + 2 Simples,
    03/07/2026,05/07/2026,2,,,Airbnb,À venir,4,Double + 2 Simples,Reconstitution Versailles
    27/06/2026,28/06/2026,1,,,Airbnb,À venir,3,Double + Simple,Deuxière réservation
    14/06/2026,16/06/2026,2,,,Airbnb,À venir,2,Double + Simple,
    16/05/2026,17/05/2026,1,,,Airbnb,À venir,4,Double + 2 Simples,
    08/05/2026,10/05/2026,2,,,Abritel,À venir,4,Double + 2 Simples,
    01/05/2026,03/05/2026,2,,,Airbnb,À venir,4,Double + 2 Simples,
    18/04/2026,19/04/2026,1,,,Booking,À venir,2,Double,
    13/04/2026,16/04/2026,3,,,Booking,À venir,3,Double + Simple,
    11/04/2026,12/04/2026,1,,,Booking,À venir,3,Double + Simple,
    08/04/2026,09/04/2026,1,,,Booking,À venir,3,Double + Simple,
    04/04/2026,05/04/2026,1,,,Booking,À venir,3,Double + 2 Simples,
    01/04/2026,03/04/2026,2,,,Booking,À venir,3,Double + Simple,
    28/03/2026,29/03/2026,1,,,Airbnb,À venir,4,Double + 2 Simples,
    23/03/2026,24/03/2026,1,,,Booking,À venir,1,Double,Sauce pesto + comté
    16/03/2026,20/03/2026,4,,,Airbnb,À venir,2,Double + Simple,
    07/03/2026,08/03/2026,1,,,Airbnb,À venir,3,Double + Simple,
    28/02/2026,02/03/2026,2,,,Booking,À venir,4,Double + Simple + Bébé,
    23/02/2026,24/02/2026,1,,,Booking,À venir,2,Double + Simple,
    20/02/2026,22/02/2026,2,,,Booking,À venir,3,Double + Simple,
    18/02/2026,19/02/2026,1,,,Airbnb,À venir,4,Double + 2 Simples,
    16/02/2026,17/02/2026,1,,,Airbnb,À venir,4,Double + 2 Simples,
    14/02/2026,15/02/2026,1,,,Booking,À venir,3,Double + Simple,
    10/02/2026,12/02/2026,2,,,Booking,À venir,2,Double + 2 Simples,
    08/02/2026,09/02/2026,1,,,Booking,En cours,3,Double + Simple,
    03/02/2026,05/02/2026,2,,,Booking,Passée,2,Double + Simple,Facture demandée
    17/01/2026,01/02/2026,15,,,Abritel,Passée,2,Double + 2 Simples,Micro ondes et pièces laissées
    08/01/2026,09/01/2026,1,,,Airbnb,Passée,2,Double + Simple,
    27/12/2025,31/12/2025,4,,"34,96 €",Abritel,Passée,3,Double + Simple,Ménage prévu le 26
    24/12/2025,26/12/2025,2,,"34,96 €",Airbnb,Passée,4,Double + 2 Simples,Ménage prévu le 23
    20/12/2025,22/12/2025,2,,,Abritel,Passée,3,Double + 2 Simples,
    12/12/2025,14/12/2025,2,,,Booking,Passée,2,Double,Facture demandée
    20/11/2025,21/11/2025,1,"45,00 €",,Airbnb,Passée,2,Double + Bébé,Non honorée
    08/11/2025,15/11/2025,7,,,Booking,Passée,2,Double + Simple,
    01/11/2025,08/11/2025,7,,,Booking,Passée,3,Double + Simple,
    29/10/2025,31/10/2025,2,,,Airbnb,Passée,4,Double + 2 Simples,
    25/10/2025,27/10/2025,2,,,Booking,Passée,3,Double + Simple + Bébé,
    22/10/2025,24/10/2025,2,,,Airbnb,Passée,2,Double + Simple,
    15/09/2025,21/09/2025,6,,,Airbnb,Passée,3,Double + 2 Simples,
    13/09/2025,14/09/2025,1,,,Airbnb,Passée,3,Double + Simple,
    22/08/2025,24/08/2025,2,,,Airbnb,Passée,2,Double,Modification (-1j)
    16/08/2025,19/08/2025,3,,,Airbnb,Passée,4,Double + 2 Simples,
    09/08/2025,10/08/2025,1,,,Airbnb,Passée,2,Double,
    26/07/2025,28/07/2025,2,,,Airbnb,Passée,4,Double + 2 Simples,
    19/07/2025,20/07/2025,1,,,Airbnb,Passée,4,Double + 2 Simples,
    05/07/2025,06/07/2025,1,,,Airbnb,Passée,4,Double + 2 Simples,
    02/07/2025,04/07/2025,2,,,Airbnb,Passée,4,Double + Simple + Bébé,
    28/06/2025,29/06/2025,1,,,Airbnb,Passée,4,Double + 2 Simples,
    25/06/2025,26/06/2025,1,,,Airbnb,Passée,4,Double + 2 Simples,
    21/06/2025,22/06/2025,1,,,Airbnb,Passée,4,Double + 2 Simples,
    14/06/2025,15/06/2025,1,,,Airbnb,Passée,2,Double + Simple,
    10/06/2025,11/06/2025,1,,,Airbnb,Passée,4,Double + Simple + Bébé,
    07/06/2025,09/06/2025,2,,,Airbnb,Passée,4,Double + Simple + Bébé,
    29/05/2025,31/05/2025,2,,,Airbnb,Passée,4,Double + 2 Simples,
    """
    
    static func seedReservationsIfNeeded(completion: @escaping () -> Void) {
        
        RU_Classified.getAll { _, classifieds in
            guard let classifieds, classifieds.count == 1 else {
                completion()
                return
            }
            let classified = classifieds[0]
            
            guard let platforms = RU_Platform.all, !platforms.isEmpty else {
                completion()
                return
            }
            
            let rows = parseCSV(csvContent)
            guard !rows.isEmpty else {
                completion()
                return
            }
            
            var bookingsToSave: [RU_Booking] = []
            for row in rows {
                guard let start = dateFormatter.date(from: row.arrivee),
                      let end = dateFormatter.date(from: row.depart),
                      end > start else { continue }
                let platform = platformNamed(row.plateforme, in: platforms)
                guard platform != nil else { continue }
                
                let b = RU_Booking()
                b.dates.start = start
                b.dates.end = end
                b.platform = platform
                b.classified = classified
                b.travelers.adults = Int(row.pers) ?? 1
                let beds = parseBeds(from: row.configuration)
                b.beds.doubles = beds.doubles
                b.beds.singles = beds.singles
                b.beds.babies = beds.babies
                if !row.commentaire.isEmpty { b.comment = row.commentaire }
                bookingsToSave.append(b)
            }
            
            guard !bookingsToSave.isEmpty else {
                completion()
                return
            }
            
            UserDefaults.delete(.bookings)
            
            let group = DispatchGroup()
            for b in bookingsToSave {
                group.enter()
                b.save { _ in group.leave() }
            }
            group.notify(queue: .main) {
                NotificationCenter.post(Notification.Name.updateBookings)
                completion()
            }
        }
    }
    
    private struct CSVRow {
        let arrivee: String
        let depart: String
        let plateforme: String
        let pers: String
        let configuration: String
        let commentaire: String
    }
    
    private static func parseCSV(_ content: String) -> [CSVRow] {
        let lines = content.split(separator: "\n", omittingEmptySubsequences: false)
            .map(String.init)
            .filter { !$0.isEmpty }
        guard lines.count > 1 else { return [] }
        let platformNames = ["Airbnb", "Booking", "Abritel"]
        var rows: [CSVRow] = []
        for i in 1 ..< lines.count {
            let line = lines[i]
            let cols = line.split(separator: ",", omittingEmptySubsequences: false)
                .map { $0.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "\"", with: "") }
            guard let platformIndex = cols.firstIndex(where: { platformNames.contains($0) }),
                  cols.count > platformIndex + 4 else { continue }
            let configuration = cols[platformIndex + 3]
            let commentaire = cols.suffix(from: platformIndex + 4).joined(separator: ",")
                .trimmingCharacters(in: .whitespaces)
            rows.append(CSVRow(
                arrivee: cols[0],
                depart: cols[1],
                plateforme: cols[platformIndex],
                pers: cols[platformIndex + 2],
                configuration: configuration,
                commentaire: commentaire
            ))
        }
        return rows
    }
    
    /// Configurations possibles → (doubles, singles, babies)
    private static let bedsByConfiguration: [String: (Int, Int, Int)] = [
        "Double": (1, 0, 0),
        "Double + Bébé": (1, 0, 1),
        "Double + Simple": (1, 1, 0),
        "Double + Simple + Bébé": (1, 1, 1),
        "Double + 2 Simples": (1, 2, 0),
        "Double + 2 Simples + Bébé": (1, 2, 1),
        "Simple": (0, 1, 0),
        "Simple + Bébé": (0, 1, 1),
        "2 Simples": (0, 2, 0),
        "2 Simples + Bébé": (0, 2, 1),
    ]
    
    private static func parseBeds(from configuration: String) -> (doubles: Int, singles: Int, babies: Int) {
        let key = configuration.trimmingCharacters(in: .whitespaces)
        if let beds = bedsByConfiguration[key] {
            return (beds.0, beds.1, beds.2)
        }
        return (1, 0, 0)
    }
    
    private static func platformNamed(_ name: String, in platforms: [RU_Platform]) -> RU_Platform? {
        let lower = name.lowercased()
        if lower.contains("airbnb") { return platforms.first { $0.type == .airbnb } }
        if lower.contains("booking") { return platforms.first { $0.type == .booking } }
        if lower.contains("abritel") { return platforms.first { $0.type == .abritel } }
        return nil
    }
}
