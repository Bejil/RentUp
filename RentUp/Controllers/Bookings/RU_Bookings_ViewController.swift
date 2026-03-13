//
//  RU_Bookings_ViewController.swift
//  RentUp
//
//  Created by BLIN Michael on 20/01/2026.
//

import UIKit
import SnapKit

public class RU_Bookings_ViewController: RU_ViewController {
	
	private var bookings:[RU_Booking]? {
		
		didSet {
            
            let sortedBookings = bookings?.sorted { $0.dates.start > $1.dates.start }
			filteredBookings = sortedBookings
		}
	}
	private var filteredBookings:[RU_Booking]? {
		
		didSet {
            
            updateFilterNavigationItem()
			
			bookingsTableView.dismissPlaceholder()
			bookingsTableView.reloadData()
			
			if let index = filteredBookings?.lastIndex(where: { $0.status == .current || $0.status == .upcoming }) {
				
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
					
                    self?.bookingsTableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .middle)
				}
			}
			
			if filteredBookings?.isEmpty ?? true {
				
				let placeholderView = bookingsTableView.showPlaceholder(.Empty)
                let button = placeholderView.addButton(String(key: "bookings.create.button")) { _ in
                    
                    RU_Booking.create()
                }
                button.image = UIImage(systemName: "plus")
			}
			
            let total = filteredBookings?.filter({
                
                currentFilterName == RU_Booking.Status.cancelled.text ? $0.status == .cancelled : $0.status != .cancelled
                
            }).compactMap { $0.platform?.calculatePrice(for: $0)?.hostTotal }.reduce(0, +) ?? 0
			totalValueLabel.text = String(format: "%.2f €", total)
		}
	}
	private var currentFilterName:String? {
		
		didSet {
			
			updateFilterNavigationItem()
		}
	}
    private lazy var bookingsTableView:RU_TableView = {
		
        $0.allowsMultipleSelectionDuringEditing = true
		$0.register(RU_Booking_TableViewCell.self, forCellReuseIdentifier: RU_Booking_TableViewCell.identifier)
		$0.delegate = self
		$0.dataSource = self
		return $0
		
	}(RU_TableView(frame: .zero, style: .plain))
	private lazy var totalValueLabel:RU_Label = {
		
		$0.font = Fonts.Content.Title.H2
		$0.textAlignment = .right
		return $0
		
	}(RU_Label())
    private lazy var bottomStackView:RU_StackView = {
        
        $0.layer.shadowOffset = .zero
        $0.layer.shadowOpacity = 0.05
        $0.layer.shadowRadius = UI.CornerRadius
        $0.layer.shadowColor = Colors.Content.Text.cgColor
        $0.axis = .horizontal
        $0.spacing = UI.Margins
        $0.alignment = .center
        
        let visualEffectView:UIVisualEffectView = .init(effect: UIGlassEffect(style: .regular))
        visualEffectView.layer.cornerRadius = UI.CornerRadius
        $0.addArrangedSubview(visualEffectView)
        
        let totalLabel:RU_Label = .init(String(key: "bookings.total.label"))
        totalLabel.font = Fonts.Content.Text.Bold.withSize(Fonts.Size-1)
        totalLabel.textAlignment = .left
        totalLabel.setContentHuggingPriority(.required, for: .horizontal)
        totalLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        let totalStackView:RU_StackView = .init(arrangedSubviews: [totalLabel,totalValueLabel])
        totalStackView.axis = .horizontal
        totalStackView.alignment = .center
        totalStackView.spacing = UI.Margins/2
        visualEffectView.contentView.addSubview(totalStackView)
        totalStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UI.Margins)
        }
        
        $0.addArrangedSubview(addButton)
        
        return $0
        
    }(RU_StackView())
    private lazy var addButton:RU_Button = {
        
        $0.image = UIImage(systemName: "plus")
        $0.snp.removeConstraints()
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        return $0
        
    }(RU_Button() { _ in
        
        RU_Booking.create()
    })
    private lazy var deleteButton:RU_Button = {
        
        $0.isHidden = true
        $0.image = UIImage(systemName: "trash")
        $0.type = .delete
        return $0
        
    }(RU_Button(String(key: "bookings.delete.button")) { [weak self] _ in
        
        let alertController:RU_Alert_ViewController = .init()
        alertController.title = String(key: "bookings.delete.alert.title")
        alertController.add(String(key: "bookings.delete.alert.content"))
        let button = alertController.addButton(title: String(key: "bookings.delete.alert.button")) { [weak self] button in
            
            button?.isLoading = true
            
            let dispatchGroup = DispatchGroup()
            
            self?.bookingsTableView.indexPathsForSelectedRows?.forEach({
                
                dispatchGroup.enter()
                
                self?.bookings?[$0.row].delete { _ in
                    
                    dispatchGroup.leave()
                }
            })
            
            dispatchGroup.notify(queue: .main) { [weak self] in
                
                button?.isLoading = false
                
                alertController.close()
                
                self?.setEditing(false, animated: true)
                
                self?.updateData()
            }
        }
        button.type = .delete
        button.image = UIImage(systemName: "trash")
        alertController.addCancelButton()
        alertController.present()
    })
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		tabBarItem = .init(title: String(key: "tabbar.bookings"), image: UIImage(systemName: "list.bullet.clipboard"), tag: RU_TabBarController.Indexes.allCases.firstIndex(of: .Bookings) ?? 0)
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func loadView() {
		
		super.loadView()
		
		navigationItem.title = String(key: "bookings.title")
		
		view.addSubview(bookingsTableView)
        view.addSubview(bottomStackView)
        
        bookingsTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let buttonsStackView:RU_StackView = .init(arrangedSubviews: [bottomStackView,deleteButton])
        buttonsStackView.axis = .vertical
        view.addSubview(buttonsStackView)
        buttonsStackView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
            make.left.right.equalToSuperview().inset(1.5 * UI.Margins)
        }
		
		NotificationCenter.add(.updateBookings) { [weak self] _ in
			
			self?.updateData()
		}
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		updateData()
	}
    
    public override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        addButton.configuration?.background.cornerRadius = bottomStackView.frame.size.height/2
        addButton.snp.remakeConstraints { make in
            make.size.equalTo(bottomStackView.frame.size.height)
        }
        bookingsTableView.contentInset.bottom = bottomStackView.frame.size.height + (2*UI.Margins)
        bookingsTableView.verticalScrollIndicatorInsets.bottom = bookingsTableView.contentInset.bottom
    }
    
    public override func setEditing(_ editing: Bool, animated: Bool) {
        
        super.setEditing(editing, animated: animated)
        
        updateFilterNavigationItem()
        bookingsTableView.setEditing(editing, animated: animated)
        
        updateSelection()
        
        UIView.animation {
            
            self.deleteButton.isHidden = !editing
            self.deleteButton.alpha = self.deleteButton.isHidden ? 0 : 1
            
            self.bottomStackView.isHidden = editing
            self.bottomStackView.alpha = self.bottomStackView.isHidden ? 0 : 1
        }
    }
    
    private func updateSelection() {
        
        deleteButton.isEnabled = !(bookingsTableView.indexPathsForSelectedRows?.isEmpty ?? true)
    }
	
	private func updateData() {
		
		bookingsTableView.showPlaceholder(.Loading)
		
		RU_Booking.getAll { [weak self] error, bookings in
			
			self?.bookingsTableView.dismissPlaceholder()
			
			if let error {
				
				self?.bookingsTableView.showPlaceholder(.Error, error) { [weak self] _ in
					
					self?.bookingsTableView.dismissPlaceholder()
					self?.updateData()
				}
			}
			else {
				
				self?.bookings = bookings
			}
		}
	}
	
	private func updateFilterNavigationItem() {
		
        navigationItem.leftBarButtonItem = nil
        
        bottomStackView.isHidden = true
        
        if !(bookings?.isEmpty ?? true) {
            
            navigationItem.rightBarButtonItems = [editButtonItem]
            
            if !isEditing {
                
                navigationItem.leftBarButtonItem = .init(title: String(key: "bookings.calendar.button"), primaryAction: .init(handler: { [weak self] _ in
                    
                    let calendarViewController = RU_Bookings_Calendar_ViewController()
                    calendarViewController.bookings = self?.bookings?.filter({ $0.status != .cancelled })
                    calendarViewController.didSelectBooking = { [weak self] booking in
                        
                        calendarViewController.dismiss {
                            
                            let detailViewController = RU_Bookings_Detail_ViewController()
                            detailViewController.booking = booking
                            self?.navigationController?.pushViewController(detailViewController, animated: true)
                        }
                    }
                    
                    UI.MainController.present(RU_NavigationController(rootViewController: calendarViewController), animated: true)
                }))
                
                var children:[UIMenuElement] = .init()
                
                children.append(UIAction(title: String(key: "bookings.filter.reset"), image: UIImage(systemName: "arrow.counterclockwise"), attributes: .destructive, handler: { [weak self] _ in
                    
                    self?.currentFilterName = nil
                    self?.filteredBookings = self?.bookings
                }))
                
                children.append(UIMenu(title: String(key: "bookings.filter.status"), children: RU_Booking.Status.allCases.map({ status in
                    UIAction(title: status.text, handler: { [weak self] _ in
                        self?.currentFilterName = status.text
                        self?.filteredBookings = self?.bookings?.filter { $0.status == status }
                    })
                })))
                
                if let platforms = RU_Platform.all, !platforms.isEmpty {
                    
                    children.append(UIMenu(title: String(key: "bookings.filter.platform"), children: platforms.compactMap({ platform in
                        
                        if let name = platform.type?.name {
                            
                            return UIAction(title: name, handler: { [weak self] _ in
                                
                                self?.currentFilterName = name
                                self?.filteredBookings = self?.bookings?.filter({ $0.platform == platform })
                            })
                        }
                        
                        return nil
                    })))
                }
                
                RU_Classified.getAll { [weak self] error, classifieds in
                    
                    if let classifieds, !classifieds.isEmpty {
                        
                        children.append(UIMenu(title: String(key: "bookings.filter.classified"), children: classifieds.compactMap({ classified in
                            
                            if let name = classified.name {
                                
                                return UIAction(title: name, handler: { [weak self] _ in
                                    
                                    self?.currentFilterName = name
                                    self?.filteredBookings = self?.bookings?.filter({ $0.classified == classified })
                                })
                            }
                            
                            return nil
                        })))
                    }
                    
                    if !children.isEmpty {
                        
                        let buttonTitle:String
                        if let filterName = self?.currentFilterName {
                            buttonTitle = String(key: "bookings.filter.active") + filterName
                        }
                        else {
                            buttonTitle = String(key: "bookings.filter.button")
                        }
                        
                        var rightBarButtonItems = self?.navigationItem.rightBarButtonItems ?? []
                        rightBarButtonItems.append(.init(title: buttonTitle, menu: .init(title: String(key: "bookings.filter.menu.title"), children: children)))
                        self?.navigationItem.rightBarButtonItems = rightBarButtonItems
                    }
                }
                
                bottomStackView.isHidden = false
            }
        }
	}
}

extension RU_Bookings_ViewController: UITableViewDelegate, UITableViewDataSource {
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return filteredBookings?.count ?? 0
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell:RU_Booking_TableViewCell = tableView.dequeueReusableCell(withIdentifier: RU_Booking_TableViewCell.identifier, for: indexPath) as! RU_Booking_TableViewCell
		cell.booking = filteredBookings?[indexPath.row]
		cell.deleteHandler = { booking in
			
			let alertController:RU_Booking_Delete_Alert_ViewController = .init()
			alertController.booking = booking
			alertController.present()
		}
		cell.editHandler = { [weak self] booking in
			
			let viewController:RU_Bookings_Edit_ViewController = .init()
			viewController.booking = booking
			self?.navigationController?.pushViewController(viewController, animated: true)
		}
        cell.cancelHandler = { [weak self] booking, state in
            
            booking?.isCancelled = state
            
            RU_Alert_ViewController.presentLoading { [weak self] alertController in
              
                booking?.save { [weak self] error in
                    
                    alertController?.close { [weak self] in
                        
                        if let error {
                            
                            RU_Alert_ViewController.present(error)
                        }
                        else {
                            
                            self?.updateData()
                        }
                    }
                }
            }
        }
		return cell
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
        if !tableView.isEditing {
            
            tableView.deselectRow(at: indexPath, animated: true)
            
            let viewController:RU_Bookings_Detail_ViewController = .init()
            viewController.booking = filteredBookings?[indexPath.row]
            navigationController?.pushViewController(viewController, animated: true)
        }
        else {
            
            updateSelection()
        }
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        if tableView.isEditing {
            
            updateSelection()
        }
    }
	
	public func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		
        if !tableView.isEditing {
            
            return UIContextMenuConfiguration.init(identifier: indexPath as NSIndexPath, previewProvider: { () -> UIViewController? in
                
                return nil
                
            }) { (suggestedActions) -> UIMenu? in
                
                let cell = tableView.cellForRow(at: indexPath) as? RU_Booking_TableViewCell
                return cell?.menu
            }
        }
        
        return nil
	}
	
	public func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
		
		guard let indexPath = configuration.identifier as? IndexPath else { return }
		
		animator.addCompletion {
			
			tableView.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
		}
	}
	
	public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		
		let cell = tableView.cellForRow(at: indexPath) as? RU_Booking_TableViewCell
		return cell?.trailingSwipeActionsConfiguration
	}
}

