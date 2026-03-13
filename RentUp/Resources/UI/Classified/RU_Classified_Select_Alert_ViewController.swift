//
//  RU_Classified_Select_Alert_ViewController.swift
//  RentUp
//
//  Created by Michaël Blin on 12/03/2026.
//

import UIKit

public class RU_Classified_Select_Alert_ViewController : RU_Alert_ViewController {
    
    public var selectHandler:((RU_Classified?)->())?
    public var classifieds:[RU_Classified]? {
        
        didSet {
            
            tableView.reloadData()
        }
    }
    private lazy var tableView:RU_TableView = {
        
        $0.isHeightDynamic = true
        $0.register(RU_Classified_TableViewCell.self, forCellReuseIdentifier: RU_Classified_TableViewCell.identifier)
        $0.delegate = self
        $0.dataSource = self
        return $0
        
    }(RU_TableView(frame: .zero, style: .plain))
    
    public override func loadView() {
        
        super.loadView()
        
        title = String(key: "Sélectionnez une annonce")
        add(tableView)
        addCancelButton()
    }
}

extension RU_Classified_Select_Alert_ViewController : UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return classifieds?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: RU_Classified_TableViewCell.identifier, for: indexPath) as! RU_Classified_TableViewCell
        cell.classified = classifieds?[indexPath.row]
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        close { [weak self] in
          
            self?.selectHandler?(self?.classifieds?[indexPath.row])
        }
    }
}
