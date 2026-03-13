//
//  RU_Classifieds_Create_ViewController.swift
//  RentUp
//
//  Created by Michaël Blin on 09/03/2026.
//

import UIKit

public class RU_Classifieds_Create_ViewController : RU_ViewController {
    
    public var classified:RU_Classified?
    public lazy var saveButton:RU_Button = {
        
        $0.isEnabled = false
        $0.image = UIImage(systemName: "arrow.right")
        $0.configuration?.imagePlacement = .trailing
        return $0
        
    }(RU_Button(String(key: "classified.create.button.next")))
    
    public override func loadView() {
        
        super.loadView()
        
        isModal = true
        
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: Fonts.Content.Text.Regular.withSize(Fonts.Size-2) as Any, .foregroundColor: Colors.Navigation.Title as Any]
        UINavigationBar.appearance().standardAppearance.titleTextAttributes = titleAttributes
    }
}
