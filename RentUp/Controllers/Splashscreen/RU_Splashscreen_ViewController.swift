//
//  RU_Splashscreen_ViewController.swift
//  RentUp
//
//  Created by BLIN Michael on 02/02/2026.
//

import UIKit
import SnapKit
import Lottie

public class RU_Splashscreen_ViewController : RU_ViewController {
    
    public var completion:((Bool)->Void)?
	
	private var isAnimationFinished = false
	private var isLoadingFinished = false
	private var hasClassifieds = false
	
	private lazy var animationView:LottieAnimationView = {
		
		$0.animation = LottieAnimation.named("splash_house")
		$0.loopMode = .playOnce
		$0.animationSpeed = 0.7
		$0.contentMode = .scaleAspectFit
		$0.backgroundBehavior = .pauseAndRestore
		return $0
		
	}(LottieAnimationView())
	
	private lazy var appNameLabel:RU_Label = {
		
		$0.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
			?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
        $0.font = Fonts.Content.Title.H1.withSize(Fonts.Content.Title.H1.pointSize + 10)
        $0.textColor = Colors.Primary
		$0.textAlignment = .center
		return $0
		
	}(RU_Label())
	
	private lazy var baselineLabel:RU_Label = {
		
		$0.text = String(key: "splashscreen.baseline")
		$0.font = Fonts.Content.Text.Regular
		$0.textColor = Colors.Content.Text.withAlphaComponent(0.5)
		$0.textAlignment = .center
		return $0
		
	}(RU_Label())
	
	private lazy var contentStackView:RU_StackView = {
		
		$0.axis = .vertical
		$0.alignment = .center
		$0.addArrangedSubview(animationView)
		$0.addArrangedSubview(appNameLabel)
		$0.addArrangedSubview(baselineLabel)
		$0.setCustomSpacing(UI.Margins / 2, after: appNameLabel)
		return $0
		
	}(RU_StackView())
    
	public override func loadView() {
		
		super.loadView()
		
		view.addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
			make.center.equalToSuperview()
			make.left.right.equalToSuperview().inset(2 * UI.Margins)
		}
		
		animationView.snp.makeConstraints { make in
			make.width.height.equalTo(12 * UI.Margins)
		}
	}
	
    public override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
		
		playAnimation()
        setUpPlatforms()
    }
	
	private func playAnimation() {
		
		isAnimationFinished = false
		animationView.play { [weak self] finished in
			
			guard finished else { return }
			
			self?.isAnimationFinished = true
			self?.finishIfReady()
		}
	}
	
	private func finishIfReady() {
		
		guard isAnimationFinished, isLoadingFinished else { return }
		
		completion?(hasClassifieds)
	}
    
    private func setUpPlatforms() {
        
		RU_Platform.getAll { [weak self] error in
			
			if let error {
				
				self?.animationView.stop()
				
				RU_Alert_ViewController.present(error, canDismiss: false, handler: { [weak self] in
					
					self?.animationView.currentProgress = 0
					self?.playAnimation()
					self?.setUpPlatforms()
				})
			}
			else {
				
				RU_Classified.getAll { [weak self] error, classifieds in
					
					if let error {
						
						self?.animationView.stop()
						
						RU_Alert_ViewController.present(error, canDismiss: false, handler: { [weak self] in
							
							self?.animationView.currentProgress = 0
							self?.playAnimation()
							self?.setUpPlatforms()
						})
					}
					else {
						
						self?.hasClassifieds = !(classifieds?.isEmpty ?? true)
						self?.isLoadingFinished = true
						self?.finishIfReady()
					}
				}
			}
		}
    }
}
