//
//  RU_Booking_Cancel_Alert_ViewController.swift
//  RentUp
//

import UIKit
import SnapKit

public class RU_Booking_Cancel_Alert_ViewController: RU_Alert_ViewController {
	
	public var booking: RU_Booking?
	public var completion: ((Error?) -> Void)?
	
	private let feesSwitch = RU_Switch()
	private let feesContainer = RU_StackView()
	private let grossAmountLabel = RU_Label()
	private let percentageLabel = RU_Label()
	private let slider = RU_Slider()
	private let amountTextField = RU_TextField()
	
	private var grossAmount: Double = 0
	private var isSyncingValues = false
	
	public init(booking: RU_Booking) {
		self.booking = booking
		self.grossAmount = booking.travelerGrossAmount
		super.init(nibName: nil, bundle: nil)
		configureContent()
	}
	
	@MainActor required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func configureContent() {
		title = String(key: "bookings.cancel.alert.title")
		add(String(key: "bookings.cancel.alert.content"))
		
		feesSwitch.isOn = false
		feesSwitch.addTarget(self, action: #selector(feesSwitchChanged), for: .valueChanged)
		
		let switchLabel = RU_Label(String(key: "bookings.cancel.alert.feesSwitch"))
		switchLabel.font = Fonts.Content.Text.Regular
		switchLabel.numberOfLines = 0
		switchLabel.textAlignment = .left
		
		let switchRow = RU_StackView(arrangedSubviews: [switchLabel, feesSwitch])
		switchRow.axis = .horizontal
		switchRow.alignment = .center
		switchRow.spacing = UI.Margins
		add(switchRow)
		
		feesContainer.axis = .vertical
		feesContainer.spacing = UI.Margins
		feesContainer.isHidden = true
		
		grossAmountLabel.textAlignment = .center
		grossAmountLabel.font = Fonts.Content.Text.Regular
		grossAmountLabel.textColor = Colors.Content.Text.withAlphaComponent(0.75)
		
		percentageLabel.textAlignment = .center
		percentageLabel.font = Fonts.Content.Text.Bold
		
		slider.minimumValue = 0
		slider.maximumValue = 100
		slider.value = 0
		slider.isContinuous = true
		slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
		
		amountTextField.keyboardType = .decimalPad
		amountTextField.textAlignment = .center
		amountTextField.placeholder = String(key: "bookings.cancel.alert.amountPlaceholder")
		amountTextField.layer.borderWidth = 1
		amountTextField.layer.borderColor = Colors.Content.Text.withAlphaComponent(0.25).cgColor
		amountTextField.layer.cornerRadius = UI.CornerRadius
		amountTextField.text = formatAmount(0)
		amountTextField.addTarget(self, action: #selector(amountTextFieldChanged), for: .editingChanged)
		
		let amountSuffixLabel = RU_Label(String(key: "settings.platform.value.amount"))
		amountSuffixLabel.setContentHuggingPriority(.required, for: .horizontal)
		
		amountTextField.setContentHuggingPriority(.required, for: .horizontal)
		amountTextField.snp.makeConstraints { make in
			make.width.equalTo(72)
		}
		
		let sliderAmountRow = RU_StackView(arrangedSubviews: [slider, amountTextField, amountSuffixLabel])
		sliderAmountRow.axis = .horizontal
		sliderAmountRow.spacing = UI.Margins / 2
		sliderAmountRow.alignment = .center
		
		feesContainer.addArrangedSubview(grossAmountLabel)
		feesContainer.addArrangedSubview(percentageLabel)
		feesContainer.addArrangedSubview(sliderAmountRow)
		add(feesContainer)
		
		updateDisplayedValues()
		
		let confirmButton = addButton(title: String(key: "bookings.cancel.alert.confirm")) { [weak self] button in
			self?.confirmCancellation(button: button)
		}
		confirmButton.type = .delete
		confirmButton.image = UIImage(systemName: "xmark")
		addCancelButton()
	}
	
	@objc private func feesSwitchChanged() {
		feesContainer.isHidden = !feesSwitch.isOn
		if !feesSwitch.isOn {
			isSyncingValues = true
			slider.value = 0
			amountTextField.text = formatAmount(0)
			isSyncingValues = false
			updateDisplayedValues()
		}
	}
	
	@objc private func sliderChanged() {
		guard !isSyncingValues else { return }
		isSyncingValues = true
		let amount = compensationFromPercentage(slider.value)
		amountTextField.text = formatAmount(amount)
		isSyncingValues = false
		updateDisplayedValues()
	}
	
	@objc private func amountTextFieldChanged() {
		guard !isSyncingValues else { return }
		isSyncingValues = true
		let amount = parsedAmount(from: amountTextField.text)
		let percentage = grossAmount > 0 ? Float(amount / grossAmount * 100) : 0
		slider.value = min(100, max(0, percentage))
		isSyncingValues = false
		updateDisplayedValues()
	}
	
	private func updateDisplayedValues() {
		let percentage = Double(slider.value)
		let amount = parsedAmount(from: amountTextField.text)
		
		grossAmountLabel.text = String(
			format: String(key: "bookings.cancel.alert.grossAmountFormat"),
			grossAmount
		)
		percentageLabel.text = String(
			format: String(key: "bookings.cancel.alert.percentageFormat"),
			percentage,
			amount
		)
	}
	
	private func compensationFromPercentage(_ percentage: Float) -> Double {
		guard grossAmount > 0 else { return 0 }
		let value = grossAmount * Double(percentage) / 100
		return (value * 100).rounded() / 100
	}
	
	private func parsedAmount(from text: String?) -> Double {
		let normalized = text?
			.replacingOccurrences(of: ",", with: ".")
			.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
		return Double(normalized) ?? 0
	}
	
	private func formatAmount(_ amount: Double) -> String {
		String(format: "%.2f", amount)
	}
	
	private func confirmCancellation(button: RU_Button?) {
		guard let booking else { return }
		
		let compensation: Double
		if feesSwitch.isOn {
			compensation = parsedAmount(from: amountTextField.text)
		} else {
			compensation = 0
		}
		
		button?.isLoading = true
		
		booking.applyCancelledStatus(compensation: compensation) { [weak self] error in
			button?.isLoading = false
			
			if let error {
				self?.close {
					RU_Alert_ViewController.present(error)
				}
			} else {
				self?.completion?(nil)
				self?.close()
			}
		}
	}
}
