//
//  RU_Tip.swift
//  RentUp
//
//  Created by BLIN Michael on 22/01/2026.
//

import UIKit
import SnapKit

public class RU_Tip_StackView: RU_StackView {
	
    public var isMinimized:Bool = false {
        
        didSet {
            
            layoutMargins = isMinimized ? .init(horizontal: UI.Margins, vertical: UI.Margins/2) : .init(UI.Margins)
            
            titleLabel.isHidden = isMinimized
            
            iconImageView.snp.remakeConstraints { make in
                make.size.equalTo((isMinimized ? 2 : 4) * UI.Margins).priority(.high)
            }
            
            contentStackView.spacing = UI.Margins/(isMinimized ? 2 : 1)
        }
    }
	public var icon:UIImage? {
		
		didSet {
			
            iconImageView.isHidden = icon == nil
            iconImageView.image = icon
		}
	}
	public var title:String? {
		
		didSet {
			
			titleLabel.isHidden = title == nil
			titleLabel.text = title
		}
	}
	private lazy var iconImageView: UIImageView = {
        
        $0.contentMode = .scaleAspectFit
		$0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		$0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		$0.snp.makeConstraints { make in
			make.size.equalTo(4 * UI.Margins).priority(.high)
		}
		return $0
	}(UIImageView(image: UIImage(named: "placeholder_tip")))
	private lazy var titleLabel:RU_Label = {
		
		$0.isHidden = true
		$0.font = Fonts.Content.Title.H4
		return $0
		
	}(RU_Label())
	public lazy var labelsStackView:RU_StackView = {
		
		$0.isHidden = true
		$0.axis = .vertical
		$0.spacing = UI.Margins/3
		return $0
		
	}(RU_StackView())
    public lazy var buttonsStackView:RU_StackView = {
        
        $0.isHidden = true
        $0.axis = .vertical
        $0.spacing = UI.Margins/3
        return $0
        
    }(RU_StackView())
    private lazy var contentStackView:RU_StackView = {
        
        $0.axis = .horizontal
        $0.spacing = UI.Margins
        $0.alignment = .center
        $0.addArrangedSubview(iconImageView)
        
        let textStackView:RU_StackView = .init(arrangedSubviews: [titleLabel,labelsStackView])
        textStackView.axis = .vertical
        textStackView.spacing = UI.Margins/2
        $0.addArrangedSubview(textStackView)
        
        return $0
        
    }(RU_StackView())
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
        
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = .init(UI.Margins)
        layer.cornerRadius = UI.CornerRadius
        backgroundColor = Colors.Tip.Background
        axis = .vertical
        spacing = UI.Margins
        addArrangedSubview(contentStackView)
        addArrangedSubview(buttonsStackView)
	}
	
	@MainActor required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public func reset() {
		
        labelsStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
	}
	
	@discardableResult public func addLabel(_ string:String) -> RU_Label {
		
        let label:RU_Label = .init(string)
        labelsStackView.addArrangedSubview(label)
		updateContent()
        
        return label
	}
    
    public func addButton(_ title:String, _ completion:((RU_Button?)->Void)?) {
        
        let button:RU_Button = .init(title) { button in
            
            completion?(button)
        }
        button.type = .tertiary
        button.titleFont = Fonts.Content.Button.Title.withSize(Fonts.Size+1)
        button.snp.makeConstraints { make in
            make.height.equalTo(4*UI.Margins)
        }
        buttonsStackView.addArrangedSubview(button)
        updateContent()
    }
	
	private func updateContent() {
		
        labelsStackView.isHidden = labelsStackView.arrangedSubviews.isEmpty
        buttonsStackView.isHidden = buttonsStackView.arrangedSubviews.isEmpty
	}
}
