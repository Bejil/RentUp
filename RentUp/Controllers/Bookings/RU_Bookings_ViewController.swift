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
            applyFilters()
		}
	}
	private var filteredBookings:[RU_Booking]? {
		
		didSet {
            
            updateFilterNavigationItem()
			
			bookingsTableView.dismissPlaceholder()
			bookingsTableView.reloadData()
			
            if oldValue == nil {
                
                scrollToClosestBooking()
            }
			
			if filteredBookings?.isEmpty ?? true {
				
				let placeholderView = bookingsTableView.showPlaceholder(.Empty)
                let button = placeholderView.addButton(String(key: "bookings.create.button")) { _ in
                    
                    RU_Booking.create()
                }
                button.image = UIImage(systemName: "plus")
			}
			
            // Historique : quand aucun filtre statut n'est actif, on exclut les réservations annulées du total.
            // Dès qu'un filtre statut est actif (y compris "cancelled"), on laisse le total refléter le filtre.
            let totalBookings = activeFilters.status == nil
                ? filteredBookings?.filter { $0.status != .cancelled } ?? []
                : filteredBookings ?? []
            let total = totalBookings.compactMap { $0.platform?.calculatePrice(for: $0)?.hostTotal }.reduce(0, +)
            
			totalValueLabel.text = String(format: "%.2f €", total)
		}
	}

    private struct ActiveFilters {
        var status: RU_Booking.Status?
        var platform: RU_Platform?
        var classified: RU_Classified?
    }
    
    private var activeFilters = ActiveFilters(status: nil, platform: nil, classified: nil)
    
    private var activeFiltersTitle: String? {
        var parts: [String] = []
        
        if let status = activeFilters.status {
            parts.append(status.text)
        }
        if let platform = activeFilters.platform, let name = platform.type?.name {
            parts.append(name)
        }
        if let classified = activeFilters.classified, let name = classified.name {
            parts.append(name)
        }
        
        return parts.isEmpty ? nil : parts.joined(separator: " + ")
    }
    
    private func applyFilters() {
        let base = bookings?.sorted { $0.dates.start > $1.dates.start } ?? []
        
        filteredBookings = base.filter { b in
            if let s = activeFilters.status, b.status != s { return false }
            
            if let p = activeFilters.platform {
                guard let bp = b.platform else { return false }
                if bp != p { return false }
            }
            
            if let c = activeFilters.classified {
                guard let bc = b.classified else { return false }
                if bc != c { return false }
            }
            
            return true
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
		
		$0.font = Fonts.Content.Title.H3
		$0.textAlignment = .center
		return $0
		
	}(RU_Label())
    private lazy var bottomStackView:RU_StackView = {
        
        $0.axis = .horizontal
        $0.spacing = UI.Margins
        $0.alignment = .center
        
        $0.addArrangedSubview(calendarButton)
        
        let visualEffectView:UIVisualEffectView = .init(effect: UIGlassEffect(style: .regular))
        visualEffectView.layer.cornerRadius = UI.CornerRadius
        $0.addArrangedSubview(visualEffectView)
        
        let totalLabel:RU_Label = .init(String(key: "bookings.total.label"))
        totalLabel.font = Fonts.Content.Text.Bold.withSize(Fonts.Size-1)
        totalLabel.textAlignment = .center
        totalLabel.setContentHuggingPriority(.required, for: .horizontal)
        totalLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        let totalStackView:RU_StackView = .init(arrangedSubviews: [totalLabel,totalValueLabel])
        totalStackView.axis = .vertical
        visualEffectView.contentView.addSubview(totalStackView)
        totalStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(3*UI.Margins/4)
        }
        
        $0.addArrangedSubview(addButton)
        
        return $0
        
    }(RU_StackView())
    private lazy var currentButton:RU_Button = {
        
        $0.type = .tertiary
        $0.image = UIImage(systemName: "chevron.down")
        
        let size = 4*UI.Margins
        
        $0.configuration?.background.cornerRadius = size/2
        $0.snp.remakeConstraints { make in
            make.size.equalTo(size)
        }
        
        return $0
        
    }(RU_Button() { [weak self] _ in
        
        self?.scrollToClosestBooking()
    })
    private lazy var calendarButton:RU_Button = {
        
        $0.type = .secondary
        $0.image = UIImage(systemName: "calendar")
        
        let size = 4*UI.Margins
        
        $0.configuration?.background.cornerRadius = size/2
        $0.snp.remakeConstraints { make in
            make.size.equalTo(size)
        }
        
        return $0
        
    }(RU_Button() { [weak self] _ in
        
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
    })
    private lazy var addButton:RU_Button = {
        
        $0.image = UIImage(systemName: "plus")
        
        let size = 4*UI.Margins
        
        $0.configuration?.background.cornerRadius = size/2
        $0.snp.remakeConstraints { make in
            make.size.equalTo(size)
        }
        
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
        
        view.addSubview(currentButton)
        
        let buttonsStackView:RU_StackView = .init(arrangedSubviews: [bottomStackView,deleteButton])
        buttonsStackView.layer.shadowOffset = .zero
        buttonsStackView.layer.shadowOpacity = 0.05
        buttonsStackView.layer.shadowRadius = UI.CornerRadius
        buttonsStackView.layer.shadowColor = Colors.Content.Text.cgColor
        buttonsStackView.axis = .vertical
        buttonsStackView.spacing = UI.Margins
        view.addSubview(buttonsStackView)
        buttonsStackView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
            make.left.right.equalToSuperview().inset(1.5 * UI.Margins)
        }
        
        currentButton.snp.makeConstraints { make in
            make.right.right.equalToSuperview().inset(1.5 * UI.Margins)
            make.bottom.equalTo(buttonsStackView.snp.top).inset(-1.5 * UI.Margins)
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
        
        let selectedBookings = bookingsTableView.indexPathsForSelectedRows?
            .compactMap({ filteredBookings?[$0.row] }) ?? []
        
        deleteButton.isEnabled = !selectedBookings.isEmpty
        
        let totalSelected = selectedBookings
            .compactMap({ $0.platform?.calculatePrice(for: $0)?.hostTotal })
            .reduce(0, +)
        deleteButton.subtitle = selectedBookings.isEmpty ? nil : String(format: "%.2f €", totalSelected)
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
    
    private func scrollToClosestBooking() {
        
        if let index = filteredBookings?.lastIndex(where: { $0.status == .current || $0.status == .upcoming }) {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                
                self?.bookingsTableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .middle)
            }
        }
    }
	
	private func updateFilterNavigationItem() {
		
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil
        
        bottomStackView.isHidden = true
        
        if !(bookings?.isEmpty ?? true) {
            
            navigationItem.rightBarButtonItem = editButtonItem
            
            if !isEditing {
                
                var children:[UIMenuElement] = .init()
                
                children.append(UIAction(title: String(key: "bookings.filter.reset"), image: UIImage(systemName: "arrow.counterclockwise"), attributes: .destructive, handler: { [weak self] _ in
                    guard let self else { return }
                    self.activeFilters = .init(status: nil, platform: nil, classified: nil)
                    self.applyFilters()
                }))
                
                children.append(UIMenu(title: String(key: "bookings.filter.status"), children: RU_Booking.Status.allCases.map({ status in
                    UIAction(title: status.text, handler: { [weak self] _ in
                        guard let self else { return }
                        let isSame = self.activeFilters.status == status
                        self.activeFilters.status = isSame ? nil : status
                        self.applyFilters()
                    })
                })))
                
                if let platforms = RU_Platform.all, !platforms.isEmpty {
                    
                    children.append(UIMenu(title: String(key: "bookings.filter.platform"), children: platforms.compactMap({ platform in
                        
                        if let name = platform.type?.name {
                            
                            return UIAction(title: name, handler: { [weak self] _ in
                                guard let self else { return }
                                let isSame = self.activeFilters.platform == platform
                                self.activeFilters.platform = isSame ? nil : platform
                                self.applyFilters()
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
                                    guard let self else { return }
                                    let isSame = self.activeFilters.classified == classified
                                    self.activeFilters.classified = isSame ? nil : classified
                                    self.applyFilters()
                                })
                            }
                            
                            return nil
                        })))
                    }
                    
                    if !children.isEmpty {
                        
                        let buttonTitle:String
                        if let title = self?.activeFiltersTitle {
                            buttonTitle = String(key: "bookings.filter.active") + title
                        }
                        else {
                            buttonTitle = String(key: "bookings.filter.button")
                        }
                        
                        self?.navigationItem.leftBarButtonItem = .init(title: buttonTitle, menu: .init(title: String(key: "bookings.filter.menu.title"), children: children))
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
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        UIView.animation {
            
            self.currentButton.alpha = 0
            
            guard let index = self.filteredBookings?.lastIndex(where: { $0.status == .current || $0.status == .upcoming }) else { return }
            
            let target = IndexPath(row: index, section: 0)
            
            if self.bookingsTableView.indexPathsForVisibleRows?.contains(target) ?? false {
                
                return
            }
            
            let visibleRows = self.bookingsTableView.indexPathsForVisibleRows?.filter { $0.section == target.section }.map(\.row).sorted() ?? []
            
            if let minVisible = visibleRows.first, index < minVisible {
                
                self.currentButton.image = UIImage(systemName: "chevron.up")
            }
            else if let maxVisible = visibleRows.last, index > maxVisible {
                
                self.currentButton.image = UIImage(systemName: "chevron.down")
            }
            else {
                
                self.currentButton.image = UIImage(systemName: "chevron.down")
            }
            
            self.currentButton.alpha = 1
        }
    }
}
