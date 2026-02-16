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
			
			bookingsTableView.dismissPlaceholder()
			bookingsTableView.reloadData()
			
			if let index = filteredBookings?.lastIndex(where: { $0.status == .current || $0.status == .upcoming }) {
				
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
					
					self?.bookingsTableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: false)
				}
			}
			
			if filteredBookings?.isEmpty ?? true {
				
				bookingsTableView.showPlaceholder(.Empty)
			}
			
			let total = filteredBookings?.compactMap { $0.platform?.calculatePrice(for: $0)?.hostTotal }.reduce(0, +) ?? 0
			totalValueLabel.text = String(format: "%.2f €", total)
		}
	}
	private var currentFilterName:String? {
		
		didSet {
			
			updateFilterNavigationItem()
		}
	}
    private lazy var bookingsTableView:RU_TableView = {
		
		$0.register(RU_Booking_TableViewCell.self, forCellReuseIdentifier: RU_Booking_TableViewCell.identifier)
		$0.delegate = self
		$0.dataSource = self
		return $0
		
	}(RU_TableView(frame: .zero, style: .plain))
	private lazy var totalValueLabel:RU_Label = {
		
		$0.font = Fonts.Content.Title.H4
		$0.textAlignment = .center
		$0.setContentHuggingPriority(.required, for: .horizontal)
		$0.setContentCompressionResistancePriority(.required, for: .horizontal)
		return $0
		
	}(RU_Label())
	
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
		
		updateFilterNavigationItem()
		
		navigationItem.leftBarButtonItem = .init(title: String(key: "bookings.calendar.button"), primaryAction: .init(handler: { [weak self] _ in
			
			let calendarViewController = RU_Bookings_Calendar_ViewController()
			calendarViewController.bookings = self?.bookings
			calendarViewController.didSelectBooking = { [weak self] booking in
				
				calendarViewController.dismiss {
					
					let detailViewController = RU_Bookings_Detail_ViewController()
					detailViewController.booking = booking
					self?.navigationController?.pushViewController(detailViewController, animated: true)
				}
			}
			
			UI.MainController.present(RU_NavigationController(rootViewController: calendarViewController), animated: true)
		}))
		
		let addButton:RU_Button = .init(String(key: "bookings.create.button")) { button in
			
            button?.isLoading = true
            
            RU_Classified.getAll { error, classifieds in
                
                button?.isLoading = false
                
                if let error {
                    
                    RU_Alert_ViewController.present(error)
                }
                else if classifieds?.isEmpty ?? true {
                    
                    RU_Alert_ViewController.present(RU_Error(String(key: "bookings.create.noClassifieds")))
                }
                else {
                    
                    UI.MainController.present(RU_NavigationController(rootViewController: RU_Bookings_Edit_ViewController()), animated: true)
                }
            }
		}
		addButton.image = UIImage(systemName: "plus.circle")
		
		let totalLabel:RU_Label = .init(String(key: "bookings.total.label"))
		totalLabel.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-2)
		totalLabel.textAlignment = .center
		totalLabel.setContentHuggingPriority(.required, for: .horizontal)
		totalLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
		
		let totalStackView:RU_StackView = .init(arrangedSubviews: [totalLabel,totalValueLabel])
		totalStackView.axis = .vertical
		totalStackView.spacing = UI.Margins/5
		
		let bottomStackView:RU_StackView = .init(arrangedSubviews: [totalStackView,addButton])
		bottomStackView.axis = .horizontal
		bottomStackView.spacing = UI.Margins
		bottomStackView.alignment = .center
		
        let bottomButtonsVisualEffectView:UIVisualEffectView = .init(effect: UIBlurEffect(style: .light))
        bottomButtonsVisualEffectView.contentView.addSubview(bottomStackView)
        bottomStackView.snp.makeConstraints { make in
            make.edges.equalTo(bottomButtonsVisualEffectView.contentView.safeAreaLayoutGuide).inset(UI.Margins)
        }
        bottomButtonsVisualEffectView.contentView.addLine(position: .top)
        
        view.addSubview(bookingsTableView)
        view.addSubview(bottomButtonsVisualEffectView)
        
        bookingsTableView.snp.makeConstraints { make in
            make.top.right.left.equalToSuperview()
            make.bottom.equalTo(bottomButtonsVisualEffectView.snp.top).offset(-UI.Margins)
        }
        
        bottomButtonsVisualEffectView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(UI.Margins)
            make.right.left.equalToSuperview()
            make.top.equalTo(bookingsTableView.snp.bottom).inset(UI.Margins)
        }
		
		NotificationCenter.add(.updateBookings) { [weak self] _ in
			
			self?.updateData()
		}
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		updateData()
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
		
		var children:[UIMenuElement] = .init()
		
		children.append(UIAction(title: String(key: "bookings.filter.reset"), image: UIImage(systemName: "arrow.counterclockwise"), attributes: .destructive, handler: { [weak self] _ in

			self?.currentFilterName = nil
			self?.filteredBookings = self?.bookings
		}))

		children.append(UIMenu(title: String(key: "bookings.filter.status"), children: [
			UIAction(title: String(key: "bookings.status.current"), handler: { [weak self] _ in
				self?.currentFilterName = String(key: "bookings.status.current")
				self?.filteredBookings = self?.bookings?.filter { $0.status == .current }
			}),
			UIAction(title: String(key: "bookings.status.upcoming"), handler: { [weak self] _ in
				self?.currentFilterName = String(key: "bookings.status.upcoming")
				self?.filteredBookings = self?.bookings?.filter { $0.status == .upcoming }
			}),
			UIAction(title: String(key: "bookings.status.past"), handler: { [weak self] _ in
				self?.currentFilterName = String(key: "bookings.status.past")
				self?.filteredBookings = self?.bookings?.filter { $0.status == .past }
			})
		]))

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
				
				self?.navigationItem.rightBarButtonItem = .init(title: buttonTitle, menu: .init(title: String(key: "bookings.filter.menu.title"), children: children))
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
		return cell
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		tableView.deselectRow(at: indexPath, animated: true)
		
		let viewController:RU_Bookings_Detail_ViewController = .init()
		viewController.booking = filteredBookings?[indexPath.row]
		navigationController?.pushViewController(viewController, animated: true)
	}
	
	public func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		
		return UIContextMenuConfiguration.init(identifier: indexPath as NSIndexPath, previewProvider: { () -> UIViewController? in
			
			return nil
			
		}) { (suggestedActions) -> UIMenu? in
			
			let cell = tableView.cellForRow(at: indexPath) as? RU_Booking_TableViewCell
			return cell?.menu
		}
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

