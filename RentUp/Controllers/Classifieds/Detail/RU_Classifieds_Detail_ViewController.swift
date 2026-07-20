//
//  RU_Classifieds_Detail_ViewController.swift
//  RentUp
//
//  Created by Michaël Blin on 24/02/2026.
//

import UIKit
import SnapKit

public class RU_Classifieds_Detail_ViewController: RU_ViewController {

	public var classified: RU_Classified? {
        
		didSet {
            
			title = classified?.name ?? String(key: "settings.classified.general.section.title")

			nameValueLabel.text = classified?.name

			if let fees = classified?.fees {
                
				feesValueLabel.text = String(format: "%i €", fees)
			}
            else {
                
				feesValueLabel.text = nil
			}

			if let capacity = classified?.configuration.capacity {
                
				capacityValueLabel.text = "\(capacity)"
				capacitySectionRowStackView.isHidden = false
			}
            else {
                
				capacitySectionRowStackView.isHidden = true
			}

			if let doubles = classified?.configuration.beds.doubles, doubles > 0 {
                
				doubleBedsValueLabel.text = "\(doubles)"
				doubleBedsSectionRowStackView.isHidden = false
			}
            else {
                
				doubleBedsSectionRowStackView.isHidden = true
			}

			if let singles = classified?.configuration.beds.singles, singles > 0 {
                
				singleBedsValueLabel.text = "\(singles)"
				singleBedsSectionRowStackView.isHidden = false
			}
            else {
                
				singleBedsSectionRowStackView.isHidden = true
			}

			if let babies = classified?.configuration.beds.babies, babies > 0 {
                
				babyBedsValueLabel.text = "\(babies)"
				babyBedsSectionRowStackView.isHidden = false
			}
            else {
                
				babyBedsSectionRowStackView.isHidden = true
			}

			let hasAnyBed = (classified?.configuration.beds.doubles ?? 0) > 0 || (classified?.configuration.beds.singles ?? 0) > 0 || (classified?.configuration.beds.babies ?? 0) > 0
			configurationSectionStackView.isHidden = !hasAnyBed
            
            comparatorTipStackView.isHidden = classified?.tarification.count ?? 0 <= 1
            
            updateChecklistButton()
            
            tarificationTableView.reloadData()
		}
	}

	private lazy var nameValueLabel: RU_Label = .init()
	private lazy var feesValueLabel: RU_Label = .init()
	private lazy var capacityValueLabel: RU_Label = .init()
	private lazy var capacitySectionRowStackView: RU_Section_Row_StackView = createRow(
		icon: "person.2.fill",
		title: String(key: "settings.classified.capacity"),
		view: capacityValueLabel
	)
	private lazy var doubleBedsValueLabel: RU_Label = .init()
	private lazy var doubleBedsSectionRowStackView: RU_Section_Row_StackView = createRow(
		icon: "bed.double.fill",
		title: String(key: "settings.classified.beds.double"),
		view: doubleBedsValueLabel
	)
	private lazy var singleBedsValueLabel: RU_Label = .init()
	private lazy var singleBedsSectionRowStackView: RU_Section_Row_StackView = createRow(
		icon: "bed.double",
		title: String(key: "settings.classified.beds.single"),
		view: singleBedsValueLabel
	)
	private lazy var babyBedsValueLabel: RU_Label = .init()
	private lazy var babyBedsSectionRowStackView: RU_Section_Row_StackView = createRow(
		icon: "stroller",
		title: String(key: "settings.classified.beds.baby"),
		view: babyBedsValueLabel
	)
	private lazy var generalSectionStackView: RU_Section_StackView = {
		$0.title = String(key: "settings.classified.general.section.title")
		$0.subtitle = String(key: "settings.classified.general.section.subtitle")
		$0.addArrangedSubview(createRow(icon: "house.fill", title: String(key: "settings.classified.name"), view: nameValueLabel))
		$0.addArrangedSubview(createRow(icon: "eurosign", title: String(key: "settings.classified.fees"), view: feesValueLabel))
		return $0
	}(RU_Section_StackView())
	private lazy var configurationSectionStackView: RU_Section_StackView = {
		$0.title = String(key: "settings.classified.configuration.section.title")
		$0.subtitle = String(key: "settings.classified.configuration.section.subtitle")
		$0.addArrangedSubview(capacitySectionRowStackView)
		$0.addArrangedSubview(doubleBedsSectionRowStackView)
		$0.addArrangedSubview(singleBedsSectionRowStackView)
		$0.addArrangedSubview(babyBedsSectionRowStackView)
		return $0
	}(RU_Section_StackView())
    private lazy var comparatorTipStackView:RU_Tip_StackView = {
        
        $0.labelsStackView.spacing = UI.Margins
        $0.title = String(key: "classifieds.comparator.title")
        $0.addLabel(String(key: "classifieds.comparator.tip"))
        $0.addButton(String(key: "classifieds.comparator.button"), { [weak self] _ in
            
            let viewController:RU_Classifieds_Comparator_ViewController = .init()
            viewController.classified = self?.classified
            UI.MainController.present(RU_NavigationController(rootViewController: viewController), animated: true)
        })
        return $0
        
    }(RU_Tip_StackView())
    private lazy var checklistButton:RU_Button = {
        
        $0.image = UIImage(systemName: "checklist")
        return $0
        
    }(RU_Button(String(key: "settings.classified.checklist.manage.button")) { [weak self] _ in
        
        self?.openChecklist()
    })
    private lazy var checklistSectionStackView: RU_Section_StackView = {
        $0.title = String(key: "settings.classified.checklist.section.title")
        $0.subtitle = String(key: "settings.classified.checklist.section.subtitle")
        $0.addArrangedSubview(checklistButton)
        return $0
    }(RU_Section_StackView())
	private lazy var tarificationSectionStackView: RU_Section_StackView = {
		$0.title = String(key: "settings.classified.tarification.section.title")
		$0.subtitle = String(key: "settings.classified.tarification.section.subtitle")
        $0.addArrangedSubview(comparatorTipStackView)
		$0.addArrangedSubview(tarificationTableView)
		return $0
	}(RU_Section_StackView())
    private lazy var tarificationTableView:RU_TableView = {
        
        $0.isHeightDynamic = true
        $0.register(RU_Platform_TableViewCell.self, forCellReuseIdentifier: RU_Platform_TableViewCell.identifier)
        $0.delegate = self
        $0.dataSource = self
        return $0
        
    }(RU_TableView(frame: .zero, style: .plain))

	public override func loadView() {
        
		super.loadView()
        
		isModal = true
        
        navigationItem.rightBarButtonItem = .init(title: String(key: "settings.classified.edit.button"), primaryAction: .init(handler: { [weak self] _ in
            
            let viewController:RU_Classifieds_Edit_ViewController = .init()
            viewController.classified = self?.classified
            UI.MainController.present(RU_NavigationController(rootViewController: viewController), animated: true)
        }))

		let contentScrollView = RU_ScrollView()
		let contentStackView = RU_StackView()
		contentStackView.axis = .vertical
		contentStackView.spacing = 2 * UI.Margins
		contentStackView.isLayoutMarginsRelativeArrangement = true
		contentStackView.layoutMargins = UIEdgeInsets(UI.Margins)
		contentScrollView.addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
			make.edges.width.equalToSuperview()
		}

		view.addSubview(contentScrollView)
		contentScrollView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}

		contentStackView.addArrangedSubview(generalSectionStackView)
		contentStackView.addArrangedSubview(configurationSectionStackView)
        contentStackView.addArrangedSubview(checklistSectionStackView)
		contentStackView.addArrangedSubview(tarificationSectionStackView)
        
        NotificationCenter.add(.updateClassifieds) { [weak self] _ in
            
            RU_Alert_ViewController.presentLoading { [weak self] alertController in
                
                RU_Classified.getAll { [weak self] error, classifieds in
                    
                    alertController?.close { [weak self] in
                      
                        self?.classified = classifieds?.first(where: { $0.uuid == self?.classified?.uuid })
                    }
                }
            }
        }
		
		updateChecklistButton()
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		updateChecklistButton()
	}

    private func createRow(icon: String, title: String, view: UIView, isHighlighted: Bool = false) -> RU_Section_Row_StackView {
        
        let stackView:RU_Section_Row_StackView = .init()
        stackView.image = UIImage(systemName: icon)
        stackView.title = title
        stackView.view = view
        stackView.isHighlighted = isHighlighted
        return stackView
    }
    
    private func updateChecklistButton() {
        
        let count = classified?.checklist?.count ?? 0
        
        if count == 0 {
            
            checklistButton.title = String(key: "settings.classified.checklist.open.button")
        }
        else {
            
            checklistButton.title = String(format: String(key: "settings.classified.checklist.manage.button"), count)
        }
    }
	
	private func openChecklist() {
		
		let viewController:RU_Classifieds_Checklist_ViewController = .init()
		viewController.classified = classified
		viewController.shouldPersistChanges = true
		viewController.completion = { [weak self] in
			
			self?.updateChecklistButton()
		}
		navigationController?.pushViewController(viewController, animated: true)
	}
}

extension RU_Classifieds_Detail_ViewController : UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return RU_Platform.all?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let platform = RU_Platform.all?[indexPath.row]
        
        let cell: RU_Platform_TableViewCell = tableView.dequeueReusableCell(withIdentifier: RU_Platform_TableViewCell.identifier) as! RU_Platform_TableViewCell
        cell.platform = platform
        
        var details:[String] = []
        
        let tarification = classified?.tarification.first(where: { $0.platform == platform })
        
        if let price = tarification?.price {
            
            details.append(String(format: String(key: "settings.classified.price"), price))
        }
        
        if let cleaning = tarification?.cleaning {
            
            details.append(String(format: String(key: "settings.classified.cleaning"), cleaning))
        }
        
        if let travelersIncluded = tarification?.travelers.included, let travelersExtra = tarification?.travelers.extraPrice {
            
            details.append(String(format: String(key: "settings.classified.travelers"), travelersExtra, travelersIncluded))
        }
        
        if let weekPercent = tarification?.offers.first(where: { $0.reductiontype == .week })?.percent {
            
            details.append(String(format: String(key: "settings.classified.offer.week"), weekPercent))
        }
        
        if let monthPercent = tarification?.offers.first(where: { $0.reductiontype == .month })?.percent {
            
            details.append(String(format: String(key: "settings.classified.offer.month"), monthPercent))
        }
        
        cell.detailsLabel.text = details.joined(separator: " • ")
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let platform = RU_Platform.all?[indexPath.row]
        
        let alertController:RU_Classified_Platform_Alert_ViewController = .init()
        alertController.isEditing = false
        alertController.classified = classified
        alertController.platform = platform
        alertController.completion = { [weak self] in
            
            self?.tarificationTableView.reloadData()
        }
        alertController.present(as: .Sheet)
    }
    
    public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        tableView.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
    }
}
