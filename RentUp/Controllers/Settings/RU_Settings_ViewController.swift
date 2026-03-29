//
//  RU_Settings_ViewController.swift
//  RentUp
//
//  Created by BLIN Michael on 20/01/2026.
//

import UIKit
import SnapKit
import UniformTypeIdentifiers

public class RU_Settings_ViewController: RU_ViewController {
	
	private lazy var platformsTableView:RU_TableView = {
		
		$0.isHeightDynamic = true
		$0.register(RU_Platform_TableViewCell.self, forCellReuseIdentifier: RU_Platform_TableViewCell.identifier)
		$0.delegate = self
		$0.dataSource = self
		return $0
		
	}(RU_TableView(frame: .zero, style: .plain))
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
        tabBarItem = .init(title: String(key: "tabbar.settings"), image: UIImage(systemName: "slider.horizontal.3")?.withRenderingMode(.alwaysTemplate), tag: RU_TabBarController.Indexes.allCases.firstIndex(of: .Settings) ?? 0)
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func loadView() {
		
		super.loadView()
		
		navigationItem.title = String(key: "settings.title")
		
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
        
        let accountSectionTitleStackView:RU_Section_StackView = .init()
        accountSectionTitleStackView.title = String(key: "settings.account.section.title")
        accountSectionTitleStackView.subtitle = String(key: "settings.account.section.subtitle")
        let accountButton:RU_Button = .init(String(key: "settings.account.button")) { _ in
            
            RU_Account_Alert_ViewController().present(as: .Sheet)
        }
        accountButton.image = UIImage(systemName: "person.crop.circle")
        accountSectionTitleStackView.addArrangedSubview(accountButton)
        contentStackView.addArrangedSubview(accountSectionTitleStackView)
		
		let platformsSectionTitleStackView:RU_Section_StackView = .init()
		platformsSectionTitleStackView.title = String(key: "settings.platforms.section.title")
		platformsSectionTitleStackView.subtitle = String(key: "settings.platforms.section.subtitle")
		platformsSectionTitleStackView.addArrangedSubview(platformsTableView)
		contentStackView.addArrangedSubview(platformsSectionTitleStackView)
		
		let dataSectionStackView:RU_Section_StackView = .init()
        dataSectionStackView.title = String(key: "settings.data.section.title")
        dataSectionStackView.subtitle = String(key: "settings.data.section.subtitle")
        
        let importButton:RU_Button = .init(String(key: "settings.data.import.button")) { [weak self] _ in
            
            let alertController: RU_Alert_ViewController = .init()
            alertController.title = String(key: "settings.data.import.conditions.title")
            
            let fileSection: RU_Section_StackView = .init()
            fileSection.title = String(key: "settings.data.import.conditions.file.section.title")
            fileSection.subtitle = String(key: "settings.data.import.conditions.file.section.subtitle")
            let fileTypeValue: RU_Label = .init(String(key: "settings.data.import.conditions.file.type.value"))
            fileTypeValue.font = Fonts.Content.Text.Bold
            fileTypeValue.textAlignment = .right
            let fileTypeRow: RU_Section_Row_StackView = .init()
            fileTypeRow.image = UIImage(systemName: "doc.text")
            fileTypeRow.title = String(key: "settings.data.import.conditions.file.type.title")
            fileTypeRow.view = fileTypeValue
            fileSection.addArrangedSubview(fileTypeRow)
            alertController.add(fileSection)
            
            let columnsAndFormatsSection: RU_Section_StackView = .init()
            columnsAndFormatsSection.title = String(key: "settings.data.import.conditions.columns.section.title")
            columnsAndFormatsSection.subtitle = String(key: "settings.data.import.conditions.formats.section.subtitle")
            let dateFormatValue: RU_Label = .init("dd/MM/yyyy")
            dateFormatValue.font = Fonts.Content.Text.Bold
            dateFormatValue.textAlignment = .right
            let arrivalRow: RU_Section_Row_StackView = .init()
            arrivalRow.image = UIImage(systemName: "calendar")
            arrivalRow.title = String(key: "settings.data.import.conditions.column.arrival")
            arrivalRow.view = dateFormatValue
            columnsAndFormatsSection.addArrangedSubview(arrivalRow)
            
            let departureValue: RU_Label = .init("dd/MM/yyyy")
            departureValue.font = Fonts.Content.Text.Bold
            departureValue.textAlignment = .right
            let departureRow: RU_Section_Row_StackView = .init()
            departureRow.image = UIImage(systemName: "calendar")
            departureRow.title = String(key: "settings.data.import.conditions.column.departure")
            departureRow.view = departureValue
            columnsAndFormatsSection.addArrangedSubview(departureRow)
            
            let amountFormatValue: RU_Label = .init(String(key: "settings.data.import.conditions.format.amount.value"))
            amountFormatValue.font = Fonts.Content.Text.Bold
            amountFormatValue.textAlignment = .right
            let compensationRow: RU_Section_Row_StackView = .init()
            compensationRow.image = UIImage(systemName: "eurosign")
            compensationRow.title = String(key: "settings.data.import.conditions.column.compensation")
            compensationRow.view = amountFormatValue
            columnsAndFormatsSection.addArrangedSubview(compensationRow)
            
            let cleaningValue: RU_Label = .init(String(key: "settings.data.import.conditions.format.amount.value"))
            cleaningValue.font = Fonts.Content.Text.Bold
            cleaningValue.textAlignment = .right
            let cleaningRow: RU_Section_Row_StackView = .init()
            cleaningRow.image = UIImage(systemName: "eurosign")
            cleaningRow.title = String(key: "settings.data.import.conditions.column.cleaning")
            cleaningRow.view = cleaningValue
            columnsAndFormatsSection.addArrangedSubview(cleaningRow)
            
            let platformFormatValue: RU_Label = .init(String(key: "settings.data.import.conditions.format.platform.value"))
            platformFormatValue.font = Fonts.Content.Text.Bold
            platformFormatValue.textAlignment = .right
            let platformRow: RU_Section_Row_StackView = .init()
            platformRow.image = UIImage(systemName: "square.grid.2x2")
            platformRow.title = String(key: "settings.data.import.conditions.column.platform")
            platformRow.view = platformFormatValue
            columnsAndFormatsSection.addArrangedSubview(platformRow)
            
            let peopleFormatValue: RU_Label = .init(String(key: "settings.data.import.conditions.format.people.value"))
            peopleFormatValue.font = Fonts.Content.Text.Bold
            peopleFormatValue.textAlignment = .right
            let peopleRow: RU_Section_Row_StackView = .init()
            peopleRow.image = UIImage(systemName: "person.2")
            peopleRow.title = String(key: "settings.data.import.conditions.column.people")
            peopleRow.view = peopleFormatValue
            columnsAndFormatsSection.addArrangedSubview(peopleRow)
            
            let configurationFormatValue: RU_Label = .init(String(key: "settings.data.import.conditions.format.configuration.value"))
            configurationFormatValue.font = Fonts.Content.Text.Bold
            configurationFormatValue.numberOfLines = 0
            configurationFormatValue.textAlignment = .right
            let configurationRow: RU_Section_Row_StackView = .init()
            configurationRow.image = UIImage(systemName: "bed.double")
            configurationRow.title = String(key: "settings.data.import.conditions.column.configuration")
            configurationRow.view = configurationFormatValue
            columnsAndFormatsSection.addArrangedSubview(configurationRow)
            
            let commentValue: RU_Label = .init(String(key: "settings.data.import.conditions.column.comment"))
            commentValue.font = Fonts.Content.Text.Bold
            commentValue.textAlignment = .right
            let commentRow: RU_Section_Row_StackView = .init()
            commentRow.image = UIImage(systemName: "text.bubble")
            commentRow.title = String(key: "settings.data.import.conditions.column.comment")
            commentRow.view = commentValue
            columnsAndFormatsSection.addArrangedSubview(commentRow)
            
            alertController.add(columnsAndFormatsSection)
            alertController.addButton(title: String(key: "settings.data.import.conditions.confirm")) { [weak self] _ in
                
                alertController.close { [weak self] in
                    
                    let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.commaSeparatedText, .plainText], asCopy: true)
                    picker.delegate = self
                    picker.allowsMultipleSelection = false
                    UI.MainController.present(picker, animated: true)
                }
            }
            alertController.addCancelButton()
            alertController.present(as: .Sheet)
        }
        importButton.image = UIImage(systemName: "square.and.arrow.down")
        dataSectionStackView.addArrangedSubview(importButton)
		
		let resetButton:RU_Button = .init(String(key: "settings.reset.button")) { _ in
			
			let alertController:RU_Alert_ViewController = .init()
			alertController.title = String(key: "settings.reset.alert.title")
            alertController.add(UIImage(named: "placeholder_trash"))
			alertController.add(String(key: "settings.reset.alert.content"))
			let button = alertController.addButton(title: String(key: "settings.reset.alert.button")) { [weak self] _ in
				
				alertController.close() { [weak self] in
					
					self?.reset()
				}
			}
			button.type = .delete
			alertController.addCancelButton()
			alertController.present()
		}
		resetButton.type = .delete
		resetButton.image = UIImage(systemName: "trash")
        dataSectionStackView.addArrangedSubview(resetButton)
        
        contentStackView.addArrangedSubview(dataSectionStackView)
        
        // MARK: - About Section
        let aboutSectionStackView:RU_Section_StackView = .init()
        aboutSectionStackView.title = String(key: "settings.about.section.title")
        aboutSectionStackView.subtitle = String(key: "settings.about.section.subtitle")
        
        let versionLabel:RU_Label = .init()
        versionLabel.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let versionRow:RU_Section_Row_StackView = .init()
        versionRow.image = UIImage(systemName: "info.circle.fill")
        versionRow.title = String(key: "settings.about.version")
        versionRow.view = versionLabel
        aboutSectionStackView.addArrangedSubview(versionRow)
        contentStackView.addArrangedSubview(aboutSectionStackView)
		 
        NotificationCenter.add(.updateAccount) { [weak self] _ in
            
            self?.updateAccount()
        }
	}
    
    public override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        updateAccount()
    }
    
    private func updateAccount() {
        
        navigationItem.rightBarButtonItem = RU_Account.shared.isLoggedIn ? .init(title: String(key: "settings.account.signout"), primaryAction: .init(handler: { _ in
            
            RU_Account.shared.signOut { error in
                    
                if let error {
                    
                    RU_Alert_ViewController.present(error)
                }
            }
            
        })) : nil
    }
	
	private func reset() {
		
		RU_Alert_ViewController.presentLoading { [weak self] alertController in
			
			RU_Platform.getAll { [weak self] error in
				
				alertController?.close { [weak self] in
					
					if let error {
						
						RU_Alert_ViewController.present(error, handler: { [weak self] in
							
							self?.reset()
						})
					}
					else {
						
						NotificationCenter.post(.updateClassifieds)
						NotificationCenter.post(.updateBookings)
                        
                        RU_Account.shared.reset { error in
                            
                            if let error {
                                
                                RU_Alert_ViewController.present(error)
                            }
                            else {
                                
                                UIApplication.reset()
                            }
                        }
					}
				}
			}
		}
	}
    
    private func importBookings(from url: URL) {
        
        RU_Alert_ViewController.presentLoading { [weak self] alertController in
            
            guard let self else { return }
            let group = DispatchGroup()
            var loadError: Error?
            
            group.enter()
            RU_Platform.getAll { error in
                if loadError == nil, let error { loadError = error }
                group.leave()
            }
            
            group.enter()
            RU_Classified.getAll { error, classifieds in
                if loadError == nil, let error { loadError = error }
                self.importClassifieds = classifieds ?? []
                group.leave()
            }
            
            group.notify(queue: .main) {
                
                if let loadError {
                    alertController?.close {
                        RU_Alert_ViewController.present(loadError)
                    }
                    return
                }
                
                guard !(self.importClassifieds?.isEmpty ?? true) else {
                    alertController?.close {
                        RU_Alert_ViewController.present(RU_Error(String(key: "settings.data.import.error.noClassified")))
                    }
                    return
                }
                
                alertController?.close { [weak self] in
                    
                    guard let self else { return }
                    let selectAlertController: RU_Classified_Select_Alert_ViewController = .init()
                    selectAlertController.classifieds = self.importClassifieds
                    selectAlertController.selectHandler = { [weak self] selectedClassified in
                        
                        guard let self, let selectedClassified else { return }
                        self.importBookings(from: url, for: selectedClassified)
                    }
                    selectAlertController.present(as: .Sheet)
                }
            }
        }
    }
    
    private var importClassifieds: [RU_Classified]?
    
    private func importBookings(from url: URL, for selectedClassified: RU_Classified) {
        
        let parseResult = parseCSV(url: url, selectedClassified: selectedClassified)
        if let error = parseResult.error {
            RU_Alert_ViewController.present(error)
            return
        }
        
        let bookings = parseResult.bookings
        guard !bookings.isEmpty else {
            RU_Alert_ViewController.present(RU_Error(String(key: "settings.data.import.error.noValidBookings")))
            return
        }
        
        RU_Alert_ViewController.presentLoading { alertController in
            
            let saveGroup = DispatchGroup()
            var saveError: Error?
            
            bookings.forEach { booking in
                saveGroup.enter()
                booking.save { error in
                    if saveError == nil, let error { saveError = error }
                    saveGroup.leave()
                }
            }
            
            saveGroup.notify(queue: .main) {
                alertController?.close {
                    if let saveError {
                        RU_Alert_ViewController.present(saveError)
                    }
                    else {
                        NotificationCenter.post(.updateBookings)
                        let alertController = RU_Alert_ViewController.present(RU_Error(String(format: String(key: "settings.data.import.success.message"), bookings.count)))
                        alertController.title = String(key: "settings.data.import.success.title")
                    }
                }
            }
        }
    }
    
    private func parseCSV(url: URL, selectedClassified: RU_Classified) -> (bookings: [RU_Booking], error: Error?) {
        
        let hasAccess = url.startAccessingSecurityScopedResource()
        defer {
            if hasAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        guard let content = try? String(contentsOf: url, encoding: .utf8) else {
            return ([], RU_Error(String(key: "settings.data.import.error.read")))
        }
        
        let lines = content
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .split(separator: "\n")
            .map { String($0) }
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        guard let headerLine = lines.first else {
            return ([], RU_Error(String(key: "settings.data.import.error.empty")))
        }
        
        let header = parseCSVRow(headerLine).map(normalizeHeader)
        let expected = ["arrivee", "depart", "indemnite", "menage", "plateforme", "pers.", "configuration", "commentaire"]
        guard header == expected else {
            return ([], RU_Error(String(key: "settings.data.import.error.format")))
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "fr_FR")
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        var bookings: [RU_Booking] = []
        
        for line in lines.dropFirst() {
            let columns = parseCSVRow(line)
            if columns.count < 8 { continue }
            
            guard let start = dateFormatter.date(from: columns[0].trimmingCharacters(in: .whitespacesAndNewlines)),
                  let end = dateFormatter.date(from: columns[1].trimmingCharacters(in: .whitespacesAndNewlines)) else { continue }
            
            let platform = platformFromString(columns[4])
            let travelers = Int(columns[5].trimmingCharacters(in: .whitespacesAndNewlines)) ?? 1
            let beds = bedsFromConfiguration(columns[6])
            
            guard let platform else { continue }
            
            let booking = RU_Booking()
            booking.dates.start = start
            booking.dates.end = end
            booking.platform = platform
            booking.travelers.adults = max(1, travelers)
            booking.travelers.children = 0
            booking.travelers.babies = 0
            booking.beds = beds
            booking.classified = selectedClassified
            booking.costs.compensation = parseCurrency(columns[2])
            booking.costs.cleaning = parseCurrency(columns[3])
            booking.comment = {
                let value = columns[7].trimmingCharacters(in: .whitespacesAndNewlines)
                return value.isEmpty ? nil : value
            }()
            
            if booking.dates.end > booking.dates.start {
                bookings.append(booking)
            }
        }
        
        return (bookings, nil)
    }
    
    private func parseCSVRow(_ line: String) -> [String] {
        
        var values: [String] = []
        var current = ""
        var isInQuotes = false
        
        for character in line {
            if character == "\"" {
                isInQuotes.toggle()
                continue
            }
            
            if character == ",", isInQuotes == false {
                values.append(current)
                current = ""
            }
            else {
                current.append(character)
            }
        }
        
        values.append(current)
        return values
    }
    
    private func normalizeHeader(_ value: String) -> String {
        
        return value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
    }
    
    private func parseCurrency(_ value: String) -> Int {
        
        let cleaned = value
            .replacingOccurrences(of: "\u{00A0}", with: " ")
            .replacingOccurrences(of: "€", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        let normalized = cleaned.replacingOccurrences(of: ",", with: ".")
        let filtered = normalized.filter { "0123456789.-".contains($0) }
        let amount = Double(filtered) ?? 0
        return Int(amount.rounded())
    }
    
    private func platformFromString(_ value: String) -> RU_Platform? {
        
        let normalized = value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
        
        let type: RU_Platform.PlatformType?
        if normalized.contains("airbnb") {
            type = .airbnb
        }
        else if normalized.contains("booking") {
            type = .booking
        }
        else if normalized.contains("abritel") {
            type = .abritel
        }
        else {
            type = nil
        }
        
        guard let type else { return nil }
        
        if let existing = RU_Platform.all?.first(where: { $0.type == type }) {
            return existing
        }
        
        let platform = RU_Platform()
        platform.type = type
        return platform
    }
    
    private func bedsFromConfiguration(_ value: String) -> RU_Classified.Configuration.Beds {
        
        let normalized = value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
        
        let beds: RU_Classified.Configuration.Beds = .init()
        beds.doubles = normalized.contains("double") ? 1 : 0
        beds.singles = normalized.contains("simple") || normalized.contains("single") ? 1 : 0
        beds.babies = normalized.contains("bebe") || normalized.contains("baby") ? 1 : 0
        
        if (beds.doubles ?? 0) == 0 && (beds.singles ?? 0) == 0 {
            // Garantit canSave du booking si la colonne "Configuration" est incomplète.
            beds.doubles = 1
        }
        
        return beds
    }
    
}

extension RU_Settings_ViewController : UITableViewDelegate, UITableViewDataSource {
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
        return RU_Platform.all?.filter({ $0.commission != nil }).count ?? 0
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let platform = RU_Platform.all?.filter({ $0.commission != nil })[indexPath.row]
		
		let cell = tableView.dequeueReusableCell(withIdentifier: RU_Platform_TableViewCell.identifier, for: indexPath) as! RU_Platform_TableViewCell
		cell.platform = platform
		cell.detailsLabel.text = platform?.detail
		return cell
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		tableView.deselectRow(at: indexPath, animated: true)
        
        let platform = RU_Platform.all?.filter({ $0.commission != nil })[indexPath.row]
        
        let alertController:RU_Platform_Alert_ViewController = .init()
        alertController.platform = platform
        alertController.present(as: .Sheet)
	}
    
    public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        tableView.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
    }
}

extension RU_Settings_ViewController: UIDocumentPickerDelegate {
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        guard let url = urls.first else { return }
        importBookings(from: url)
    }
}

