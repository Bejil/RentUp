//
//  RU_Booking_Card_Section_StackView.swift
//  RentUp
//
//  Created by BLIN Michael on 03/02/2026.
//

import UIKit
import SnapKit

public class RU_Booking_Card_Section_StackView : RU_Section_StackView {
    
	public var booking:RU_Booking? {
		
		didSet {
			
			UIView.animation {
				
				self.isHidden = self.booking == nil
				self.alpha = self.isHidden ? 0 : 1
			}
			
			if let booking {
                
                if booking.status == .current {
                    
                    layer.shadowOpacity = 0.1
                    backgroundColor = Colors.Background.View
                    layoutMargins = .init(horizontal: inset)
                    layoutMargins.top = inset
                }
                else {
                    
                    layer.shadowOpacity = 0.0
                    backgroundColor = .clear
                    layoutMargins = .init(horizontal: inset/2)
                }
                
                statusLabel.booking = booking
                platformLabel.platform = booking.platform
                
                if let classified = booking.classified, let name = classified.name, !name.isEmpty {
                    
                    classifiedLabel.text = name
                    classifiedSectionRowStackView.isHidden = false
                }
                else {
                    
                    classifiedSectionRowStackView.isHidden = true
                }
				
				if let nights = booking.platform?.calculatePrice(for: booking)?.nights {
					
					nightsLabel.text = "\(nights)"
				}
				
				if let doubles = booking.beds.doubles, doubles > 0 {
					
					doubleBedsValueLabel.text = "\(doubles)"
					doubleBedsSectionRowStackView.isHidden = false
				}
				else {
					
					doubleBedsSectionRowStackView.isHidden = true
				}
				
				if let singles = booking.beds.singles, singles > 0 {
					
					singleBedsValueLabel.text = "\(singles)"
					singleBedsSectionRowStackView.isHidden = false
				}
				else {
					
					singleBedsSectionRowStackView.isHidden = true
				}
				
				if let babies = booking.beds.babies, babies > 0 {
					
					babyBedsValueLabel.text = "\(babies)"
					babyBedsSectionRowStackView.isHidden = false
				}
				else {
					
					babyBedsSectionRowStackView.isHidden = true
				}
				
				commentTipStackView.reset()
				
				if let comment = booking.comment, !comment.isEmpty {
					
					layoutMargins.bottom = inset
					
					commentTipStackView.isHidden = false
					commentTipStackView.add(comment)
				}
				else {
					
					layoutMargins.bottom = inset/2
					
                    commentTipStackView.isHidden = true
				}
			}
		}
	}
	private var inset:CGFloat = 1.5*UI.Margins
    private lazy var classifiedSectionRowStackView:RU_Section_Row_StackView = createRow(icon: "house", title: String(key: "bookings.create.classified.section.title"), view: classifiedLabel)
	private lazy var platformLabel: RU_Platform_Label = .init()
    private lazy var statusLabel: RU_Booking_Status_Label = .init()
	private lazy var nightsLabel: RU_Label = {
		
		$0.font = Fonts.Content.Text.Bold
		$0.textAlignment = .right
		return $0
		
	}(RU_Label())
	private lazy var classifiedLabel:RU_Label = {
		
		$0.font = Fonts.Content.Text.Regular
		$0.textAlignment = .right
		return $0
		
	}(RU_Label())
	private lazy var doubleBedsValueLabel:RU_Label = .init()
	private lazy var doubleBedsSectionRowStackView:RU_Section_Row_StackView = createRow(icon: "bed.double.fill", title: String(key: "bookings.details.configuration.beds.double"), view: doubleBedsValueLabel)
	private lazy var singleBedsValueLabel:RU_Label = .init()
	private lazy var singleBedsSectionRowStackView:RU_Section_Row_StackView = createRow(icon: "bed.double", title: String(key: "bookings.details.configuration.beds.single"), view: singleBedsValueLabel)
	private lazy var babyBedsValueLabel:RU_Label = .init()
	private lazy var babyBedsSectionRowStackView:RU_Section_Row_StackView = createRow(icon: "stroller", title: String(key: "bookings.details.configuration.beds.baby"), view: babyBedsValueLabel)
	private lazy var commentTipStackView:RU_Tip_StackView = {
		
		$0.isMinimized = true
		$0.title = String(key: "bookings.details.comment.title")
		return $0
		
	}(RU_Tip_StackView())
    
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        isHidden = true
        isLayoutMarginsRelativeArrangement = true
        layer.cornerRadius = UI.CornerRadius
        clipsToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = UI.CornerRadius
        
        let accessoryStackView:RU_StackView = .init(arrangedSubviews: [platformLabel,statusLabel])
        accessoryStackView.axis = .horizontal
        accessoryStackView.spacing = UI.Margins
        accessoryStackView.alignment = .center
        accessoryView = accessoryStackView
        
        addArrangedSubview(classifiedSectionRowStackView)
        addArrangedSubview(createRow(icon: "moon.fill", title: String(key: "home.booking.nights"), view: nightsLabel))
        addArrangedSubview(doubleBedsSectionRowStackView)
        addArrangedSubview(singleBedsSectionRowStackView)
        addArrangedSubview(babyBedsSectionRowStackView)
        
        let separator1 = UIView()
        separator1.backgroundColor = .clear
        addArrangedSubview(separator1)
        separator1.snp.makeConstraints { make in
            make.height.equalTo(UI.Margins / 2)
        }
        setCustomSpacing(UI.Margins / 2, after: separator1)
        
        addArrangedSubview(commentTipStackView)
        
        let separator2 = UIView()
        separator2.backgroundColor = .clear
        addArrangedSubview(separator2)
        separator2.snp.makeConstraints { make in
            make.height.equalTo(UI.Margins / 2)
        }
        setCustomSpacing(UI.Margins / 2, after: separator2)
        
        let button:RU_Button = .init(String(key: "home.details.button")) { [weak self] _ in
            
            let viewController:RU_Bookings_Detail_ViewController = .init()
            viewController.booking = self?.booking
            UI.MainController.present(RU_NavigationController(rootViewController: viewController), animated: true)
        }
        button.titleFont = Fonts.Content.Button.Title.withSize(Fonts.Size)
        button.image = UIImage(systemName: "arrowtriangle.right.square")?.applyingSymbolConfiguration(.init(scale: .small))
        button.configuration?.imagePadding = UI.Margins/2
        button.configuration?.imagePlacement = .trailing
        addArrangedSubview(button)
    }
	
	@MainActor required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func createRow(icon: String?, title: String?, view: UIView, isHighlighted: Bool = false) -> RU_Section_Row_StackView {
		
		let row = RU_Section_Row_StackView()
        
        if let icon {
            
            row.image = UIImage(systemName: icon)
        }
        
		row.title = title
		row.view = view
		row.isHighlighted = isHighlighted
		return row
	}
}
