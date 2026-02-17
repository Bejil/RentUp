//
//  RU_ViewController.swift
//  RentUp
//
//  Created by BLIN Michael on 28/11/2025.
//

import UIKit
import SnapKit

public class RU_ViewController: UIViewController {

	public var isModal:Bool = false {
		
		didSet {
            
            navigationItem.leftBarButtonItem = nil
            closeButton.isHidden = true
            
            if let navigationController, navigationController.viewControllers.count < 2 {
                
                navigationItem.leftBarButtonItem = .init(image: UIImage(systemName: "xmark"), primaryAction: .init(handler: { [weak self] _ in
                    
                    RU_Feedback.shared.make(.Off)
                    
                    self?.close()
                }))
            }
            else {
                
                closeButton.isHidden = false
            }
		}
	}
    private lazy var closeButton:RU_Button = {
        
        $0.isHidden = true
        $0.type = .navigation
        $0.image = UIImage(systemName: "xmark")
        $0.configuration?.contentInsets = .zero
        return $0
        
    }(RU_Button() { [weak self] _ in
        
        self?.close()
    })
	
	public override func loadView() {
		
		super.loadView()
		
        view.backgroundColor = Colors.Background.View
        
        let tapGestureRecognizer:UITapGestureRecognizer = .init { [weak self] sender in
			
			if let weakSelf = self {
				
				let touchLocation = sender.location(in: weakSelf.view)
				
				let view:UIView = .init()
				view.isUserInteractionEnabled = false
				weakSelf.view.addSubview(view)
				view.snp.makeConstraints { make in
					make.centerX.equalTo(touchLocation.x)
					make.centerY.equalTo(touchLocation.y)
					make.size.equalTo(2*UI.Margins)
				}
				view.pulse() {
					
					view.removeFromSuperview()
				}
			}
		}
		tapGestureRecognizer.cancelsTouchesInView = false
		view.addGestureRecognizer(tapGestureRecognizer)
        
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            
            make.top.left.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
        }
	}
	
	public override func viewWillDisappear(_ animated: Bool) {
		
		super.viewWillDisappear(animated)
		
		UI.MainController.resignFirstResponder()
	}
    
    public override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        view.bringSubviewToFront(closeButton)
    }
	
	public func close() {
		
		dismiss()
	}
	
	public func dismiss(_ completion:(()->Void)? = nil) {
		
		if navigationController?.viewControllers.count ?? 0 > 1 {
			
			navigationController?.popViewController(animated: true)
			completion?()
		}
		else {
			
			dismiss(animated: true, completion: completion)
		}
	}
}
