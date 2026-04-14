//
//  RU_Reporting_TableViewCell.swift
//  RentUp
//
//  Created by Michaël Blin on 09/02/2026.
//

import UIKit
import SnapKit

public class RU_Reporting_TableViewCell : RU_TableViewCell {
    
    public override class var identifier: String {
        
        return "reportingTableViewCellIdentifier"
    }
    
    public var date: Date? {
        
        didSet {
            
            if let date {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMMM yyyy"
                label.text = dateFormatter.string(from: date).capitalized
            }
        }
    }
    
    private lazy var label: RU_Label = {
        
        $0.font = Fonts.Content.Text.Bold
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        return $0
        
    }(RU_Label())
    
    public var actualValue: Double? {
        
        didSet {
            
            actualValueLabel.text = String(format: "%.0f%%", actualValue ?? 0)
        }
    }
    
    private lazy var actualValueLabel: RU_Label = {
        
        $0.font = Fonts.Content.Title.H4
        $0.textAlignment = .center
        return $0
        
    }(RU_Label())
    
    public var forecastValue: Double? {
        
        didSet {
            
            forecastValueLabel.text = String(format: "→ %.0f%%", forecastValue ?? 0)
        }
    }
    
    private lazy var forecastValueLabel: RU_Label = {
        
        $0.font = Fonts.Content.Text.Regular
        $0.textAlignment = .center
        return $0
        
    }(RU_Label())
    
    public var occupancyDetailText: String? {
        
        didSet {
            
            occupancyDetailLabel.text = occupancyDetailText
            occupancyDetailLabel.isHidden = occupancyDetailText?.isEmpty ?? true
        }
    }
    
    public var netDetailText: String? {
        
        didSet {
            
            netDetailLabel.text = netDetailText
            netDetailLabel.isHidden = netDetailText?.isEmpty ?? true
        }
    }
    
    private lazy var occupancyDetailLabel: RU_Label = {
        
        $0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size - 2)
        $0.textColor = Colors.Content.Text.withAlphaComponent(0.72)
        $0.numberOfLines = 0
        $0.isHidden = true
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        return $0
        
    }(RU_Label())
    
    private lazy var netDetailLabel: RU_Label = {
        
        $0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size - 2)
        $0.textColor = Colors.Content.Text.withAlphaComponent(0.72)
        $0.numberOfLines = 0
        $0.isHidden = true
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        return $0
        
    }(RU_Label())
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        accessoryType = .detailButton
        
        let contentStackView: RU_StackView = .init(arrangedSubviews: [label, occupancyDetailLabel, netDetailLabel])
        contentStackView.axis = .vertical
        contentStackView.spacing = UI.Margins / 4
        
        let valuesStackView: RU_StackView = .init(arrangedSubviews: [actualValueLabel, forecastValueLabel])
        valuesStackView.axis = .vertical
        valuesStackView.spacing = UI.Margins / 4
        
        let stackView: RU_StackView = .init(arrangedSubviews: [contentStackView, valuesStackView])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = UI.Margins / 2
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UI.Margins)
        }
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
