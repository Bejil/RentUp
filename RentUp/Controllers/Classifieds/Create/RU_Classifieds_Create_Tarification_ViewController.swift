//
//  RU_Classifieds_Create_Tarification_ViewController.swift
//  RentUp
//
//  Created by Michaël Blin on 09/03/2026.
//

import UIKit
import SnapKit

public class RU_Classifieds_Create_Tarification_ViewController : RU_Classifieds_Create_ViewController {
    
    public override var classified: RU_Classified? {
        
        didSet {
            
            updatePlatforms()
        }
    }
    private lazy var tarificationTableView:RU_TableView = {
        
        $0.isHidden = true
        $0.isHeightDynamic = true
        $0.register(RU_Platform_TableViewCell.self, forCellReuseIdentifier: RU_Platform_TableViewCell.identifier)
        $0.delegate = self
        $0.dataSource = self
        return $0
        
    }(RU_TableView(frame: .zero, style: .plain))
    public override func loadView() {
        
        super.loadView()
        
navigationItem.title = String(key: "classified.create.step.3")

        let placeholderView = view.showPlaceholder()
        placeholderView.title = String(key: "classified.create.placeholder.platforms")
        placeholderView.image = UIImage(named: "placeholder_classified_plateforms")

        let label:RU_Label = .init(String(key: "classified.create.placeholder.platforms.description"))
        label.textAlignment = .center
        placeholderView.contentStackView.addArrangedSubview(label)
        
        let platformsStackView:RU_StackView = .init(arrangedSubviews: RU_Platform.all?.compactMap({
            
            createPlatformStackView($0)
        }) ?? [])
        platformsStackView.axis = .horizontal
        platformsStackView.alignment = .center
        platformsStackView.spacing = UI.Margins
        platformsStackView.distribution = .fillEqually
        placeholderView.contentStackView.addArrangedSubview(platformsStackView)
        
        placeholderView.contentStackView.addArrangedSubview(tarificationTableView)
        placeholderView.contentStackView.setCustomSpacing(placeholderView.contentStackView.spacing * 2, after: tarificationTableView)
        
        saveButton.action = { [weak self] _ in
            
            let viewController:RU_Classifieds_Create_Fees_ViewController = .init()
            viewController.classified = self?.classified
            self?.navigationController?.pushViewController(viewController, animated: true)
        }
        placeholderView.contentStackView.addArrangedSubview(saveButton)
    }
    
    private func createPlatformStackView(_ platform:RU_Platform) -> RU_StackView {
        
        let imageView:UIImageView = .init(image: platform.type?.icon)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = platform.type?.textColor
        imageView.snp.makeConstraints{ make in
            make.size.equalTo(UI.Margins*4/3)
        }
        
        let label:RU_Label = .init(platform.type?.name)
        label.textColor = platform.type?.textColor
        label.textAlignment = .center
        label.font = Fonts.Content.Text.Bold
        
        let stackView:RU_StackView = .init(arrangedSubviews: [imageView,label])
        stackView.backgroundColor = platform.type?.backgroundColor
        stackView.layer.cornerRadius = UI.CornerRadius
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = UI.Margins/2
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(UI.Margins)
        stackView.addGestureRecognizer(UITapGestureRecognizer(block: { [weak self] _ in
            
            let alertController:RU_Classified_Platform_Alert_ViewController = .init()
            alertController.isEditing = true
            alertController.classified = self?.classified
            alertController.platform = platform
            alertController.completion = { [weak self] in
                
                self?.updatePlatforms()
            }
            alertController.present(as: .Sheet)
        }))
        
        return stackView
    }
    
    private func updatePlatforms() {
        
        tarificationTableView.isHidden = classified?.tarification.isEmpty ?? true
        tarificationTableView.reloadData()
        saveButton.isEnabled = !(classified?.tarification.isEmpty ?? true)
    }
}

extension RU_Classifieds_Create_Tarification_ViewController : UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return classified?.tarification.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let platform = classified?.tarification[indexPath.row].platform
        
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
        
        let platform = classified?.tarification[indexPath.row].platform
        
        let alertController:RU_Classified_Platform_Alert_ViewController = .init()
        alertController.isEditing = true
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

