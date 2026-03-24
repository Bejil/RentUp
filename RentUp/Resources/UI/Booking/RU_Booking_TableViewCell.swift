//
//  RU_TableViewCell.swift
//  RentUp
//
//  Created by BLIN Michael on 21/01/2026.
//

import UIKit
import SnapKit

public class RU_Booking_TableViewCell : RU_TableViewCell {
	
	public override class var identifier: String {
		
		return "bookingTableViewCellIdentifier"
	}
	public var deleteHandler:((RU_Booking?)->Void)?
	public var editHandler:((RU_Booking?)->Void)?
    public var cancelHandler:((RU_Booking?,Bool)->Void)?
	public var booking:RU_Booking? {
		
		didSet {
			
			classifiedLabel.text = booking?.classified?.name
			platformLabel.platform = booking?.platform
			statusLabel.booking = booking
			
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "dd/MM/yyyy"
			
			if let start = booking?.dates.start, let end = booking?.dates.end {
				
				datesLabel.text = String(format: String(key: "bookings.cell.dates.format"), dateFormatter.string(from: start), dateFormatter.string(from: end))
			}
			
			if let booking, let calculation = booking.platform?.calculatePrice(for: booking) {
				
				priceLabel.text = String(format: "%.2f €", calculation.hostTotal)
			}
		}
	}
	private lazy var classifiedLabel:RU_Label = {
		
		$0.font = Fonts.Content.Title.H4
		return $0
		
	}(RU_Label())
	private lazy var platformLabel:RU_Platform_Label = .init()
	private lazy var statusLabel:RU_Booking_Status_Label = .init()
	private lazy var datesLabel:RU_Label = {
		
		$0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-2)
		return $0
		
	}(RU_Label())
	private lazy var priceLabel:RU_Label = {
		
		$0.font = Fonts.Content.Title.H4
		$0.textAlignment = .right
		$0.setContentHuggingPriority(.required, for: .horizontal)
		$0.setContentCompressionResistancePriority(.required, for: .horizontal)
		return $0
		
	}(RU_Label())
	public var menu:UIMenu? {
		
		get{
            
            var actions:[UIAction] = .init()
            
            if booking?.status == .cancelled {
                
                actions.append(UIAction(title: String(key: "bookings.cell.approve.button"), image: UIImage(systemName: "checkmark"), handler: { [weak self] _ in
                    
                    self?.cancelHandler?(self?.booking,false)
                }))
            }
            else {
                
                actions.append(UIAction(title: String(key: "bookings.cell.cancel.button"), image: UIImage(systemName: "xmark"), handler: { [weak self] _ in
                    
                    self?.cancelHandler?(self?.booking,true)
                }))
            }
            
            actions.append(UIAction(title: String(key: "bookings.cell.edit.button"), image: UIImage(systemName: "slider.horizontal.3"), handler: { [weak self] _ in
                
                self?.editHandler?(self?.booking)
            }))
            
            actions.append(UIAction(title: String(key: "bookings.cell.delete.button"), image: UIImage(systemName: "trash"), attributes: .destructive, handler: { [weak self] _ in
                
                self?.deleteHandler?(self?.booking)
            }))
			
			return .init(children: actions)
		}
	}
	public var trailingSwipeActionsConfiguration:UISwipeActionsConfiguration {
		
		get{
			
			var actionsArray:[UIContextualAction] = .init()
			
			let deleteContextualAction:UIContextualAction = .init(style: .destructive, title: String(key: "bookings.cell.delete.button")) { [weak self] _, _, completion in
				
				self?.deleteHandler?(self?.booking)
				completion(true)
			}
			deleteContextualAction.image = UIImage(systemName: "trash")
			deleteContextualAction.backgroundColor = Colors.Button.Delete.Background
			actionsArray.append(deleteContextualAction)
			
			let editContextualAction:UIContextualAction = .init(style: .normal, title: String(key: "bookings.cell.edit.button")) { [weak self] _, _, completion in
				
				self?.editHandler?(self?.booking)
				completion(true)
			}
			editContextualAction.image = UIImage(systemName: "slider.horizontal.3")
			editContextualAction.backgroundColor = Colors.Primary
			actionsArray.append(editContextualAction)
            
            if booking?.status == .cancelled {
                
                let approveContextualAction:UIContextualAction = .init(style: .destructive, title: String(key: "bookings.cell.approve.button")) { [weak self] _, _, completion in
                    
                    self?.cancelHandler?(self?.booking, false)
                    completion(true)
                }
                approveContextualAction.image = UIImage(systemName: "checkmark")
                approveContextualAction.backgroundColor = Colors.Primary
                actionsArray.append(approveContextualAction)
            }
            else {
                
                let cancelContextualAction:UIContextualAction = .init(style: .destructive, title: String(key: "bookings.cell.cancel.button")) { [weak self] _, _, completion in
                    
                    self?.cancelHandler?(self?.booking, true)
                    completion(true)
                }
                cancelContextualAction.image = UIImage(systemName: "xmark")
                cancelContextualAction.backgroundColor = Colors.Button.Delete.Background
                actionsArray.append(cancelContextualAction)
            }
			
			let actionsConfiguration:UISwipeActionsConfiguration = .init(actions: actionsArray)
			actionsConfiguration.performsFirstActionWithFullSwipe = true
			
			return actionsConfiguration
		}
	}
	
	public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		accessoryType = .disclosureIndicator
		
		let tagsStackView:RU_StackView = .init(arrangedSubviews: [statusLabel,.init(),platformLabel])
		tagsStackView.axis = .horizontal
		tagsStackView.alignment = .center
		
		let detailsStackView:RU_StackView = .init(arrangedSubviews: [classifiedLabel,datesLabel])
		detailsStackView.axis = .vertical
		detailsStackView.spacing = UI.Margins/3
		
		let label:RU_Label = .init(String(key: "bookings.cell.estimatedRevenue"))
		label.font = Fonts.Content.Text.Regular
		label.textAlignment = .right
		label.adjustsFontSizeToFitWidth = true
		label.minimumScaleFactor = 0.5
		
		let priceStackView:RU_StackView = .init(arrangedSubviews: [label,priceLabel])
		priceStackView.axis = .vertical
		
		label.snp.makeConstraints { make in
			make.width.equalTo(priceLabel)
		}
		
		let contentStackView:RU_StackView = .init(arrangedSubviews: [detailsStackView,priceStackView])
		contentStackView.axis = .horizontal
		contentStackView.alignment = .center
		contentStackView.spacing = UI.Margins
		
		let containerStackView:RU_StackView = .init(arrangedSubviews: [tagsStackView,contentStackView])
		containerStackView.axis = .vertical
		containerStackView.spacing = 3*UI.Margins/4
		contentView.addSubview(containerStackView)
		containerStackView.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UI.Margins)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		
		super.init(coder: aDecoder)
	}
}
