//
//  RU_Onboarding_Account_ViewController.swift
//  RentUp
//
//  Created by Michaël Blin on 14/03/2026.
//

import UIKit
import SnapKit

public class RU_Onboarding_Account_ViewController : RU_ViewController {
    
    public override func loadView() {

        super.loadView()
        
        let titleLabel: RU_Label = .init(String(key: "onboarding.account.title"))
        titleLabel.textAlignment = .center
        titleLabel.font = Fonts.Content.Title.H1
        
        let imageView: UIImageView = .init(image: UIImage(named: "placeholder_welcome"))
        imageView.snp.makeConstraints { make in
            make.height.equalTo(10 * UI.Margins)
        }
        imageView.contentMode = .scaleAspectFit
        
        let contentLabel: RU_Label = .init(String(key: "onboarding.account.content"))
        contentLabel.textAlignment = .center
        
        let signInButton: RU_Button = .init(String(key: "onboarding.account.signIn.button")) { [weak self] _ in
            
            self?.navigationController?.pushViewController(RU_Onboarding_Account_SignIn_ViewController(), animated: true)
        }
        signInButton.titleFont = Fonts.Content.Button.Title.withSize(Fonts.Size)
        signInButton.style = .tinted
        
        let signUpButton: RU_Button = .init(String(key: "onboarding.account.signUp.button")) { [weak self] _ in
            
            self?.navigationController?.pushViewController(RU_Onboarding_Account_SignUp_ViewController(), animated: true)
        }
        signUpButton.titleFont = Fonts.Content.Button.Title.withSize(Fonts.Size)
        
        let buttonsStackView:RU_StackView = .init(arrangedSubviews: [signInButton,signUpButton])
        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = UI.Margins
        buttonsStackView.alignment = .center
        
        let socialStackView:RU_Account_Social_StackView = .init()
        
        let contentStackView: RU_StackView = .init(arrangedSubviews: [titleLabel,imageView,contentLabel,buttonsStackView,socialStackView])
        contentStackView.axis = .vertical
        contentStackView.spacing = 2 * UI.Margins

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
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
