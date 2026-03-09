//
//  RU_Onboarding_Welcome_ViewController.swift
//  RentUp
//
//  Created by Michaël Blin on 13/02/2026.
//

import UIKit
import SnapKit

public class RU_Onboarding_Welcome_ViewController : RU_ViewController {

	public var completion: (() -> Void)?
	private lazy var titleLabel: RU_Label = {

		$0.textAlignment = .center
		$0.font = Fonts.Content.Title.H1
		return $0

	}(RU_Label(String(key: "onboarding.welcome.title")))
	private lazy var imageView: UIImageView = {

		$0.snp.makeConstraints { make in
			make.height.equalTo(10 * UI.Margins)
		}
		$0.contentMode = .scaleAspectFit
		return $0

	}(UIImageView(image: UIImage(named: "placeholder_welcome")))
	private lazy var contentLabel: RU_Label = {

		$0.textAlignment = .center
		return $0

	}(RU_Label(String(key: "onboarding.welcome.message")))
	private lazy var button: RU_Button = {

		$0.configuration?.imagePlacement = .trailing
		$0.image = UIImage(systemName: "arrow.right.circle")
		return $0

	}(RU_Button(String(key: "onboarding.welcome.button.start")) { _ in

		UI.MainController.present(RU_NavigationController(rootViewController: RU_Classifieds_Edit_ViewController()), animated: true)
	})
	private lazy var contentStackView: RU_StackView = {

		$0.axis = .vertical
		$0.spacing = 2 * UI.Margins
		return $0

	}(RU_StackView(arrangedSubviews: [titleLabel, imageView, contentLabel, button]))

	public override func loadView() {

		super.loadView()

		let contentScrollView: RU_ScrollView = .init()
		contentScrollView.isCentered = true
		view.addSubview(contentScrollView)
		contentScrollView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		contentScrollView.addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in

			make.edges.width.equalToSuperview().inset(2*UI.Margins)
		}

		contentStackView.animate()

		NotificationCenter.add(.updateClassifieds) { [weak self] _ in

			self?.button.isLoading = true

			RU_Classified.getAll { [weak self] _, classifieds in

				if !(classifieds?.isEmpty ?? true) {

					self?.button.isLoading = false
					self?.setSuccessContent()
				}
			}
		}
	}

	public override func close() {

		completion?()
	}

	private func setSuccessContent() {

		button.action = { [weak self] _ in

			self?.completion?()
		}

		UIView.animate(withDuration: 0.35, animations: { [weak self] in

			guard let self else { return }
			self.view.backgroundColor = Colors.Primary
			self.titleLabel.alpha = 0
			self.contentLabel.alpha = 0
			self.imageView.alpha = 0

		}) { [weak self] _ in

            self?.titleLabel.textColor = .white
			self?.titleLabel.text = String(key: "onboarding.success.title")
            
            self?.contentLabel.textColor = .white
			self?.contentLabel.text = String(key: "onboarding.success.message")
            
            self?.button.style = .inverted
			self?.button.title = String(key: "onboarding.success.button.done")
			self?.button.image = UIImage(systemName: "checkmark.circle.fill")
			self?.button.action = { [weak self] _ in

				self?.completion?()
			}
            
			UIView.animate(withDuration: 0.3) {

				self?.titleLabel.alpha = 1
				self?.contentLabel.alpha = 1
				self?.imageView.alpha = 1
			}
		}
	}
}
