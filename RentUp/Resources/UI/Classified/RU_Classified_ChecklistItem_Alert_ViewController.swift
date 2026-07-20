//
//  RU_Classified_ChecklistItem_Alert_ViewController.swift
//  RentUp
//
//  Created by Michaël Blin on 20/07/2026.
//

import UIKit
import SnapKit

public class RU_Classified_ChecklistItem_Alert_ViewController : RU_Alert_ViewController {
	
	public var isCreating:Bool = true
	public var item:RU_Classified.ChecklistItem = .init()
	public var saveHandler:((RU_Classified.ChecklistItem)->Void)?
	
	private lazy var titleTextFieldRowStack:RU_Section_TextFieldRow_StackView = {
		
		$0.backgroundColor = Colors.Background.View
		$0.isLayoutMarginsRelativeArrangement = true
		$0.layoutMargins.bottom = UI.Margins / 2
		$0.textField.placeholder = String(key: "settings.classified.checklist.title.placeholder")
		$0.textField.textAlignment = .left
		$0.textField.autocapitalizationType = .sentences
		$0.textField.keyboardType = .default
		$0.textField.addAction(.init(handler: { [weak self] _ in
			
			self?.updateSaveButton()
			
		}), for: .editingChanged)
		return $0
		
	}(RU_Section_TextFieldRow_StackView())
	private var saveButton:RU_Button?
	
	public override func loadView() {
		
		super.loadView()
		
		add(titleTextFieldRowStack)
		
		saveButton = addButton(title: String(key: "common.validate")) { [weak self] _ in
			
			guard let self else { return }
			
			item.title = titleTextFieldRowStack.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
			saveHandler?(item)
			close()
		}
		
		addCancelButton()
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		title = isCreating ? String(key: "settings.classified.checklist.create.title") : String(key: "settings.classified.checklist.edit.title")
		titleTextFieldRowStack.textField.text = item.title
		updateSaveButton()
	}
	
	public override func viewDidAppear(_ animated: Bool) {
		
		super.viewDidAppear(animated)
		
		titleTextFieldRowStack.textField.becomeFirstResponder()
	}
	
	private func updateSaveButton() {
		
		let title = titleTextFieldRowStack.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
		saveButton?.isEnabled = !title.isEmpty
	}
}
