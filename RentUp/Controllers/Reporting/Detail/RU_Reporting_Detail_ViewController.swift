//
//  RU_Reporting_Detail_ViewController.swift
//  RentUp
//
//  Created by Michaël Blin on 11/02/2026.
//

import UIKit
import SnapKit
import SwiftUI

public class RU_Reporting_Detail_ViewController : RU_ViewController {
    
    private var bookings:[RU_Booking]? {
        
        didSet {
            
            let sortedBookings = bookings?.sorted { $0.dates.start > $1.dates.start }
            filteredBookings = sortedBookings
        }
    }
    public var filteredBookings:[RU_Booking]? {
        
        didSet {
            
            view.dismissPlaceholder()
            
            if filteredBookings?.isEmpty ?? true {
                
                view.showPlaceholder(.Empty)
            }
            
            updateUI()
        }
    }
    public var monthes:[Date]?
    public var actualValues: [Double]?
    public var forecastValues: [Double]?
    private var currentFilterName:String? {
        
        didSet {
            
            updateFilterNavigationItem()
        }
    }
    public lazy var tableView:RU_TableView = {
        
        $0.register(RU_Reporting_TableViewCell.self, forCellReuseIdentifier: RU_Reporting_TableViewCell.identifier)
        $0.delegate = self
        $0.dataSource = self
        return $0
        
    }(RU_TableView(frame: .zero, style: .plain))
    public lazy var chartHostingController: UIHostingController<RU_Chart_View> = .init(rootView: RU_Chart_View(data: .init()))
    private lazy var chartScrollView:UIScrollView = {
        
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = .clear
        
        $0.addSubview(chartHostingController.view)
        chartHostingController.view.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.height.equalToSuperview()
            self.chartHostingWidthConstraint = make.width.equalTo(0).constraint
        }
        addChild(chartHostingController)
        chartHostingController.didMove(toParent: self)
        
        return $0
        
    }(UIScrollView())
    private var chartHostingWidthConstraint: Constraint?
    private static let chartMonthWidth: CGFloat = 5 * UI.Margins
    private static let chartScrollThreshold = 4
    
    public override func loadView() {
        
        super.loadView()
        
        updateFilterNavigationItem()
        
        view.addSubview(tableView)
        
        let chartContainerView = UIView()
        chartContainerView.backgroundColor = Colors.Background.View
        chartContainerView.layer.cornerRadius = UI.CornerRadius
        chartContainerView.layer.shadowColor = UIColor.black.cgColor
        chartContainerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        chartContainerView.layer.shadowOpacity = 0.08
        chartContainerView.layer.shadowRadius = UI.Margins
        chartContainerView.snp.makeConstraints { make in
            make.height.equalTo(15 * UI.Margins)
        }
        chartContainerView.addSubview(chartScrollView)
        chartScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UI.Margins)
        }
        view.addSubview(chartContainerView)
        
        tableView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(chartContainerView.snp.top).offset(-UI.Margins)
        }
        
        chartContainerView.snp.makeConstraints { make in
            make.bottom.right.left.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
            make.top.equalTo(tableView.snp.bottom).inset(UI.Margins)
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
        
        let count = monthes?.count ?? 0
        let contentWidth: CGFloat = count > Self.chartScrollThreshold ? CGFloat(count) * Self.chartMonthWidth : chartScrollView.bounds.width
        chartHostingWidthConstraint?.update(offset: contentWidth)
        chartScrollView.contentSize = CGSize(width: contentWidth, height: chartScrollView.bounds.height)
    }
    
    private func updateFilterNavigationItem() {
        
        var children:[UIMenuElement] = .init()
        
        children.append(UIAction(title: String(key: "reporting.filter.reset"), image: UIImage(systemName: "arrow.counterclockwise"), attributes: .destructive, handler: { [weak self] _ in
            
            self?.currentFilterName = nil
            self?.filteredBookings = self?.bookings
        }))
        
        if let platforms = RU_Platform.all, !platforms.isEmpty {
            
            children.append(UIMenu(title: String(key: "reporting.filter.platform"), children: platforms.compactMap({ platform in
                
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
                
                children.append(UIMenu(title: String(key: "reporting.filter.classified"), children: classifieds.compactMap({ classified in
                    
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
                    buttonTitle = String(key: "reporting.filter.active") + filterName
                }
                else {
                    buttonTitle = String(key: "reporting.filter.button")
                }
                
                self?.navigationItem.rightBarButtonItem = .init(title: buttonTitle, menu: .init(title: String(key: "reporting.filter.menu.title"), children: children))
            }
        }
    }
    
    private func updateData() {
        
        view.showPlaceholder(.Loading)
        
        RU_Booking.getAll { [weak self] error, bookings in
            
            self?.view.dismissPlaceholder()
            
            if let error {
                
                self?.view.showPlaceholder(.Error, error) { [weak self] _ in
                    
                    self?.view.dismissPlaceholder()
                    self?.updateData()
                }
            }
            else {
                
                self?.bookings = bookings
            }
        }
    }
    
    public func updateUI() {
        
        tableView.reloadData()
        
        let calendar = Calendar.current
        let now = Date()
        let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
        
        if let idx = monthes?.firstIndex(where: { calendar.isDate($0, equalTo: currentMonthStart, toGranularity: .month) }), idx < (monthes?.count ?? 0) {
            
            tableView.selectRow(at: IndexPath(row: idx, section: 0), animated: true, scrollPosition: .middle)
            
            UIApplication.wait { [weak self] in
                
                self?.scrollChart(to: idx)
            }
        }
    }
    
    private func scrollChart(to index: Int) {
        
        let count = monthes?.count ?? 0
        guard count > Self.chartScrollThreshold else { return }
        let contentWidth = CGFloat(count) * Self.chartMonthWidth
        let centerX = (CGFloat(index) + 0.5) * Self.chartMonthWidth
        let visibleWidth = chartScrollView.bounds.width
        var offsetX = centerX - visibleWidth / 2
        offsetX = max(0, min(offsetX + UI.Margins, contentWidth - visibleWidth))
        chartScrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }
}

extension RU_Reporting_Detail_ViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return monthes?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: RU_Reporting_TableViewCell.identifier, for: indexPath) as! RU_Reporting_TableViewCell
        cell.date = monthes?[indexPath.row]
        cell.actualValue = actualValues?[indexPath.row]
        cell.forecastValue = forecastValues?[indexPath.row]
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        scrollChart(to: indexPath.row)
    }
}
