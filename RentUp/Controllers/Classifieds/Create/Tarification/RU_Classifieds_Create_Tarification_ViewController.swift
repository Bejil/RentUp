//
//  RU_Classifieds_Create_Tarification_ViewController.swift
//  RentUp
//
//  Created by Michaël Blin on 09/03/2026.
//

import UIKit
import SnapKit

public class RU_Classifieds_Create_Tarification_ViewController : RU_Classifieds_Create_ViewController {
    
    public override func loadView() {
        
        super.loadView()
        
        navigationItem.title = String(key: "Étape 3/4")
        
        let placeholderView = view.showPlaceholder()
        placeholderView.title = String(key: "Plateformes")
        placeholderView.image = UIImage(named: "placeholder_classified_plateforms")
        
        let label:RU_Label = .init(String(key: "Définissez les plateformes où votre annonce est visible. Vous pourrez ensuite ajouter des réservations pour chacune d'entre elle en fonction de vos besoins"))
        label.textAlignment = .center
        placeholderView.contentStackView.addArrangedSubview(label)
        
        let platformsStackView:RU_StackView = .init(arrangedSubviews: RU_Platform.all?.compactMap({
            
            createPlatformStackView($0)
        }) ?? [])
        platformsStackView.axis = .horizontal
        platformsStackView.alignment = .center
        platformsStackView.spacing = UI.Margins
        platformsStackView.distribution = .fillEqually
        placeholderView.contentStackView.addArrangedSubview(platformsStackView)
        placeholderView.contentStackView.setCustomSpacing(placeholderView.contentStackView.spacing * 2, after: platformsStackView)
        
        saveButton.action = { [weak self] _ in
            
            let viewController:RU_Classifieds_Create_Fees_ViewController = .init()
            viewController.classified = self?.classified
            self?.navigationController?.pushViewController(viewController, animated: true)
        }
        placeholderView.contentStackView.addArrangedSubview(saveButton)
    }
    
    private func createPlatformStackView(_ platform:RU_Platform) -> RU_StackView {
        
        let imageView:UIImageView = .init(image: platform.type?.icon)
        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints{ make in
            make.size.equalTo(UI.Margins*4/3)
        }
        
        let label:RU_Label = .init(platform.type?.name)
        label.textColor = platform.type?.textColor
        label.textAlignment = .center
        label.font = Fonts.Content.Text.Bold
        
        let stackView:RU_StackView = .init(arrangedSubviews: [imageView,label])
        stackView.backgroundColor = platform.type?.backgroundColor
        stackView.layer.cornerRadius = UI.CornerRadius
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = UI.Margins/2
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(UI.Margins)
        stackView.addGestureRecognizer(UITapGestureRecognizer(block: { _ in
            
            let alertController:RU_Alert_ViewController = .init()
            alertController.title = platform.type?.name
            alertController.addCancelButton()
            alertController.present(as: .Sheet)
        }))
        
        return stackView
    }
}
