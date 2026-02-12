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
    public var date:Date? {
        
        didSet {
            
            if let date {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMMM yyyy"
                label.text = dateFormatter.string(from: date)
            }
        }
    }
    private lazy var label:RU_Label = .init()
    public var actualValue:Double? {
        
        didSet {
            
            actualValueLabel.text = String(format: "%.0f%%", actualValue ?? 0)
        }
    }
    private lazy var actualValueLabel:RU_Label = {
        
        $0.font = Fonts.Content.Title.H4
        return $0
        
    }(RU_Label())
    public var forecastValue:Double? {
        
        didSet {
            
            forecastValueLabel.text = String(format: "%.0f%%", forecastValue ?? 0)
        }
    }
    private lazy var forecastValueLabel:RU_Label = {
        
        $0.font = Fonts.Content.Text.Regular
        return $0
        
    }(RU_Label())
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let imageView:UIImageView = .init(image: UIImage(systemName: "arrow.right"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Colors.Primary
        imageView.snp.makeConstraints { make in
            make.size.equalTo(UI.Margins)
        }
        
        let stackView:RU_StackView = .init(arrangedSubviews: [label,.init(),actualValueLabel,imageView,forecastValueLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = UI.Margins/2
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UI.Margins)
        }
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
