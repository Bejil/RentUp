//
//  RU_Classified_ChecklistItem_TableViewCell.swift
//  RentUp
//
//  Created by Michaël Blin on 20/07/2026.
//

import UIKit
import SnapKit

public class RU_Classified_ChecklistItem_TableViewCell : RU_TableViewCell {
	
	public override class var identifier: String {
		
		return "classifiedChecklistItemTableViewCellIdentifier"
	}
	
	public var infoHandler:(()->Void)?
	public var titleCommitHandler:((String?)->Void)?
	
	public var showsInfoButton:Bool = true {
		
		didSet {
			
			updateAccessoryVisibility()
		}
	}
	
	public var showsSelectionControl:Bool = false {
		
		didSet {
			
			selectionImageView.isHidden = !showsSelectionControl
			updateSelectionAppearance()
			setNeedsLayout()
		}
	}
	
	public var isItemSelected:Bool = false {
		
		didSet {
			
			updateSelectionAppearance()
		}
	}
	
	public var isTitleEditing:Bool = false {
		
		didSet {
			
			guard oldValue != isTitleEditing else { return }
			updateEditingAppearance()
		}
	}
	
	public var verticalInset:CGFloat = UI.Margins {
		
		didSet {
			
			contentStackView.snp.remakeConstraints { make in
				make.edges.equalToSuperview().inset(UIEdgeInsets(top: verticalInset, left: UI.Margins, bottom: verticalInset, right: UI.Margins))
			}
		}
	}
	
	public var item:RU_Classified.ChecklistItem? {
		
		didSet {
			
			titleLabel.text = item?.title
			titleTextField.text = item?.title
		}
	}
	
	private lazy var selectionImageView:UIImageView = {
		
		$0.isHidden = true
		$0.contentMode = .scaleAspectFit
		$0.setContentHuggingPriority(.required, for: .horizontal)
		$0.setContentCompressionResistancePriority(.required, for: .horizontal)
		$0.snp.makeConstraints { make in
			make.size.equalTo(1.75 * UI.Margins)
		}
		return $0
		
	}(UIImageView())
	private lazy var titleLabel:RU_Label = {
		
		$0.font = Fonts.Content.Text.Bold
		$0.numberOfLines = 0
		return $0
		
	}(RU_Label())
	private lazy var titleTextField:RU_TextField = {
		
		$0.isHidden = true
		$0.font = Fonts.Content.Text.Bold
		$0.placeholder = String(key: "settings.classified.checklist.title.placeholder")
		$0.autocapitalizationType = .sentences
		$0.returnKeyType = .done
		$0.inset = .zero
		$0.backgroundColor = .clear
		$0.snp.remakeConstraints { make in
			make.height.greaterThanOrEqualTo(2 * UI.Margins)
		}
		$0.addAction(.init(handler: { [weak self] _ in
			
			self?.commitTitleEditing()
			
		}), for: .editingDidEndOnExit)
		$0.addAction(.init(handler: { [weak self] _ in
			
			guard self?.isTitleEditing == true else { return }
			self?.commitTitleEditing()
			
		}), for: .editingDidEnd)
		return $0
		
	}(RU_TextField())
	private lazy var infoButton:UIButton = {
		
		$0.setImage(UIImage(systemName: "pencil.circle"), for: .normal)
		$0.tintColor = Colors.TableView.Tint
		$0.addAction(.init(handler: { [weak self] _ in
			
			self?.infoHandler?()
			
		}), for: .touchUpInside)
		$0.setContentHuggingPriority(.required, for: .horizontal)
		$0.setContentCompressionResistancePriority(.required, for: .horizontal)
		$0.snp.makeConstraints { make in
			make.size.equalTo(2.5 * UI.Margins)
		}
		return $0
		
	}(UIButton(type: .system))
	private lazy var contentStackView:RU_StackView = {
		
		$0.axis = .horizontal
		$0.spacing = UI.Margins
		$0.alignment = .center
		return $0
		
	}(RU_StackView(arrangedSubviews: [selectionImageView, titleLabel, titleTextField, infoButton]))
	
	public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		accessoryType = .none
		clipsToBounds = true
		contentView.clipsToBounds = true
		
		contentView.addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UIEdgeInsets(top: UI.Margins, left: UI.Margins, bottom: UI.Margins, right: UI.Margins))
		}
		
		updateSelectionAppearance()
		updateEditingAppearance()
	}
	
	public override func layoutSubviews() {
		
		super.layoutSubviews()
		
		// Évite le décalage résiduel du mode édition natif de UITableView
		if showsSelectionControl || !isEditing {
			
			contentView.frame = bounds
		}
	}
	
	public override func prepareForReuse() {
		
		super.prepareForReuse()
		
		infoHandler = nil
		titleCommitHandler = nil
		showsInfoButton = true
		showsSelectionControl = false
		isItemSelected = false
		isTitleEditing = false
		verticalInset = UI.Margins
		contentView.frame = bounds
	}
	
	public func beginTitleEditing() {
		
		isTitleEditing = true
		titleTextField.becomeFirstResponder()
	}
	
	private func commitTitleEditing() {
		
		guard isTitleEditing else { return }
		
		let title = titleTextField.text
		isTitleEditing = false
		titleCommitHandler?(title)
	}
	
	private func updateEditingAppearance() {
		
		titleLabel.isHidden = isTitleEditing
		titleTextField.isHidden = !isTitleEditing
		updateAccessoryVisibility()
		
		if isTitleEditing {
			
			titleTextField.text = item?.title
		}
	}
	
	private func updateAccessoryVisibility() {
		
		infoButton.isHidden = !showsInfoButton || isTitleEditing
	}
	
	private func updateSelectionAppearance() {
		
		guard showsSelectionControl else { return }
		
		if isItemSelected {
			
			selectionImageView.image = UIImage(systemName: "checkmark.circle.fill")
			selectionImageView.tintColor = Colors.Secondary
		}
		else {
			
			selectionImageView.image = UIImage(systemName: "circle")
			selectionImageView.tintColor = Colors.Content.Text.withAlphaComponent(0.35)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		
		super.init(coder: aDecoder)
	}
}
