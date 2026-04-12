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
        return $0
        
    }(RU_Label())
    
    public var actualValue: Double? {
        
        didSet {
            
            actualValueLabel.text = String(format: "%.0f%%", actualValue ?? 0)
        }
    }
    
    private lazy var actualValueLabel: RU_Label = {
        
        $0.font = Fonts.Content.Title.H4
        return $0
        
    }(RU_Label())
    
    public var forecastValue: Double? {
        
        didSet {
            
            forecastValueLabel.text = String(format: "%.0f%%", forecastValue ?? 0)
        }
    }
    
    private lazy var forecastValueLabel: RU_Label = {
        
        $0.font = Fonts.Content.Text.Regular
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
        return $0
        
    }(RU_Label())
    
    private lazy var netDetailLabel: RU_Label = {
        
        $0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size - 2)
        $0.textColor = Colors.Content.Text.withAlphaComponent(0.72)
        $0.numberOfLines = 0
        $0.isHidden = true
        return $0
        
    }(RU_Label())
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        accessoryType = .disclosureIndicator
        
        let imageView: UIImageView = .init(image: UIImage(systemName: "arrow.right"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Colors.Primary
        imageView.snp.makeConstraints { make in
            make.size.equalTo(UI.Margins)
        }
        
        let headerStackView: RU_StackView = .init(arrangedSubviews: [label, .init(), actualValueLabel, imageView, forecastValueLabel])
        headerStackView.axis = .horizontal
        headerStackView.alignment = .center
        headerStackView.spacing = UI.Margins / 2
        
        let contentStackView: RU_StackView = .init(arrangedSubviews: [headerStackView, occupancyDetailLabel, netDetailLabel])
        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        contentStackView.spacing = UI.Margins / 4
        
        contentView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UI.Margins)
        }
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
