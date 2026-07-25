//
//  RU_Booking_Card_Section_StackView.swift
//  RentUp
//
//  Created by BLIN Michael on 03/02/2026.
//

import UIKit
import SnapKit

public class RU_Booking_Card_Section_StackView : RU_Section_StackView {
    
    /// Légère mise en avant (réservation en cours sur l’accueil).
    public var isEmphasized: Bool = false {
        didSet {
            guard booking != nil else { return }
            applyCardStyle(for: booking!)
        }
    }
    
	public var booking:RU_Booking? {
		
		didSet {
			
			UIView.animation {
				
				self.isHidden = self.booking == nil
				self.alpha = self.isHidden ? 0 : 1
			}
			
			if let booking {
                
                applyCardStyle(for: booking)
                
                statusLabel.booking = booking
                platformLabel.platform = booking.platform
				classifiedLabel.text = booking.classified?.name
				datesLabel.text = Self.datesText(for: booking)
				updateMeta(for: booking)
			}
		}
	}
	
	private lazy var platformLabel: RU_Platform_Label = .init()
    private lazy var statusLabel: RU_Booking_Status_Label = .init()
	private lazy var chevronImageView: UIImageView = {
		
		$0.image = UIImage(systemName: "chevron.right")?.applyingSymbolConfiguration(.init(pointSize: 12, weight: .semibold))
		$0.tintColor = Colors.Content.Text.withAlphaComponent(0.35)
		$0.setContentHuggingPriority(.required, for: .horizontal)
		$0.setContentCompressionResistancePriority(.required, for: .horizontal)
		$0.setContentHuggingPriority(.required, for: .vertical)
		return $0
		
	}(UIImageView())
	private lazy var classifiedLabel:RU_Label = {
		
		$0.font = Fonts.Content.Text.Bold
		$0.numberOfLines = 1
		return $0
		
	}(RU_Label())
	private lazy var datesLabel:RU_Label = {
		
		$0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size - 2)
		$0.textColor = Colors.Content.Text.withAlphaComponent(0.55)
		return $0
		
	}(RU_Label())
	private lazy var nightsItem = Self.makeMetaItem(icon: "moon.fill")
	private lazy var doubleBedsItem = Self.makeMetaItem(icon: "bed.double.fill")
	private lazy var singleBedsItem = Self.makeMetaItem(icon: "bed.double")
	private lazy var babyBedsItem = Self.makeMetaItem(icon: "stroller")
	private lazy var metaItemsStackView:RU_StackView = {
		
		$0.axis = .horizontal
		$0.spacing = UI.Margins / 3
		$0.alignment = .center
		$0.distribution = .fill
		$0.addArrangedSubview(nightsItem.container)
		$0.addArrangedSubview(doubleBedsItem.container)
		$0.addArrangedSubview(singleBedsItem.container)
		$0.addArrangedSubview(babyBedsItem.container)
		
		let spacer = UIView()
		spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
		spacer.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
		$0.addArrangedSubview(spacer)
		return $0
		
	}(RU_StackView())
	private lazy var detailsStackView:RU_StackView = {
		
		$0.axis = .vertical
		$0.spacing = UI.Margins / 3
		$0.addArrangedSubview(classifiedLabel)
		$0.addArrangedSubview(datesLabel)
		$0.addArrangedSubview(metaItemsStackView)
		return $0
		
	}(RU_StackView())
    
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        isHidden = true
		isUserInteractionEnabled = true
        isLayoutMarginsRelativeArrangement = true
        layer.cornerRadius = UI.CornerRadius
        clipsToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = UI.CornerRadius
        spacing = UI.Margins/2
        
        let accessoryStackView:RU_StackView = .init(arrangedSubviews: [platformLabel, statusLabel])
        accessoryStackView.axis = .horizontal
        accessoryStackView.spacing = UI.Margins / 2
        accessoryStackView.alignment = .center
        accessoryView = accessoryStackView
		
		guard let headerView = arrangedSubviews.first else { return }
		removeArrangedSubview(headerView)
		
		let leadingStackView:RU_StackView = .init(arrangedSubviews: [headerView, detailsStackView])
		leadingStackView.axis = .vertical
		leadingStackView.spacing = UI.Margins / 2
		leadingStackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
		leadingStackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		
		let mainStackView:RU_StackView = .init(arrangedSubviews: [leadingStackView, chevronImageView])
		mainStackView.axis = .horizontal
		mainStackView.alignment = .center
		mainStackView.spacing = UI.Margins / 2
		
		addArrangedSubview(mainStackView)
		
		addGestureRecognizer(UITapGestureRecognizer(block: { [weak self] _ in
			
			self?.openDetail()
		}))
    }
	
	@MainActor required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func updateMeta(for booking: RU_Booking) {
		
		let nights = booking.platform?.calculatePrice(for: booking)?.nights ?? 0
		nightsItem.label.text = "\(nights)"
		nightsItem.container.isHidden = nights <= 0
		
		let doubles = booking.beds.doubles ?? 0
		let singles = booking.beds.singles ?? 0
		let babies = booking.beds.babies ?? 0
		
		doubleBedsItem.label.text = "\(doubles)"
		doubleBedsItem.container.isHidden = doubles <= 0
		
		singleBedsItem.label.text = "\(singles)"
		singleBedsItem.container.isHidden = singles <= 0
		
		babyBedsItem.label.text = "\(babies)"
		babyBedsItem.container.isHidden = babies <= 0
		
		metaItemsStackView.isHidden = nights <= 0 && doubles <= 0 && singles <= 0 && babies <= 0
	}
	
	private func openDetail() {
		
		guard let booking else { return }
		
		RU_Feedback.shared.make(.On)
		
		UIView.animation(0.12, {
			
			self.alpha = 0.72
		}, {
			
			UIView.animation(0.12) {
				
				self.alpha = 1
			}
		})
		
		let viewController:RU_Bookings_Detail_ViewController = .init()
		viewController.booking = booking
		UI.MainController.present(RU_NavigationController(rootViewController: viewController), animated: true)
	}
	
	private func applyCardStyle(for booking: RU_Booking) {
        
        let isProminent = isEmphasized || booking.status == .current
        
		backgroundColor = Colors.Background.View
		layoutMargins = .init(UI.Margins)
        
        layer.shadowOpacity = isEmphasized ? 0.14 : 0.1
        layer.shadowRadius = UI.CornerRadius
        layer.shadowOffset = CGSize(width: 0, height: isEmphasized ? 6 : 4)
        
        if isProminent {
            
            layer.borderWidth = isEmphasized ? 1 : 0
			layer.borderColor = booking.status.backgroundColor.withAlphaComponent(0.22).cgColor
        }
        else {
            
			layer.borderWidth = 0
			layer.borderColor = nil
        }
    }
	
	private static func datesText(for booking: RU_Booking) -> String {
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "dd/MM/yyyy"
		return String(
			format: String(key: "bookings.cell.dates.format"),
			dateFormatter.string(from: booking.dates.start),
			dateFormatter.string(from: booking.dates.end)
		)
	}
	
	private static func makeMetaItem(icon: String) -> (container: UIView, label: RU_Label) {
		
		let imageView = UIImageView(image: UIImage(systemName: icon)?.applyingSymbolConfiguration(.init(pointSize: 10, weight: .medium)))
		imageView.tintColor = Colors.Content.Text.withAlphaComponent(0.55)
		imageView.setContentHuggingPriority(.required, for: .horizontal)
		imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
		
		let label = RU_Label()
		label.font = Fonts.Content.Text.Bold.withSize(Fonts.Size - 4)
		label.textColor = Colors.Content.Text.withAlphaComponent(0.7)
		label.setContentHuggingPriority(.required, for: .horizontal)
		label.setContentCompressionResistancePriority(.required, for: .horizontal)
		
		let container = RU_StackView(arrangedSubviews: [imageView, label])
		container.axis = .horizontal
		container.spacing = UI.Margins / 4
		container.alignment = .center
		container.isLayoutMarginsRelativeArrangement = true
		container.layoutMargins = UIEdgeInsets(
			top: UI.Margins / 5,
			left: UI.Margins / 2,
			bottom: UI.Margins / 5,
			right: UI.Margins / 2
		)
		container.backgroundColor = Colors.Content.Text.withAlphaComponent(0.05)
		container.layer.cornerRadius = UI.CornerRadius / 3
		container.clipsToBounds = true
		container.setContentHuggingPriority(.required, for: .horizontal)
		container.setContentCompressionResistancePriority(.required, for: .horizontal)
		
		return (container, label)
	}
}
