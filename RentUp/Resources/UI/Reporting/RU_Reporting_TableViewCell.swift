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
    public lazy var keyLabel:RU_Label = .init()
    public lazy var valueLabel:RU_Label = {
        
        $0.font = Fonts.Content.Title.H4
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        return $0
        
    }(RU_Label())
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let stackView:RU_StackView = .init(arrangedSubviews: [keyLabel,valueLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = UI.Margins
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UI.Margins)
        }
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
