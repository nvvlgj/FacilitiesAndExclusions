//
//  ViewController.swift
//  RadiusAgent
//
//  Created by Lalitha Guru Jyothi Nandiraju on 29/06/23.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    static let cellReuseIdentifier = "facilitiesCell"
    
    var facilities: [Facility] = []
    var exclusions: [[Exclusion]] = []
    var enableExclusion: Bool = false
    
    var facilitiesTableView: UITableView?
    var disabledIndexPaths: [IndexPath: [IndexPath]] = [:]

    override func viewDidLoad() {
        FacilitiesDataParser.parseFacilitiesData { facilitiesAndExclusions in
            self.facilities = facilitiesAndExclusions.facilities
            self.exclusions = facilitiesAndExclusions.exclusions
            
            DispatchQueue.main.async {
                self.facilitiesTableView?.reloadData()
            }
        }
        
        super.viewDidLoad()
        setupSetupSubviews()
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.facilities.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.facilities[section].options.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return facilities[section].name
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellReuseIdentifier) ?? UITableViewCell()
        let facilityOption = facilities[indexPath.section].options[indexPath.row]
        cell.textLabel?.text = facilityOption.name
        cell.imageView?.image = UIImage(named: facilityOption.icon)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // Look for already selected index in the section.
        let selectedIndices = tableView.indexPathsForSelectedRows?.filter({ selectedIndexPath in
            return selectedIndexPath.section == indexPath.section
        })
        if let selectedIndex = selectedIndices?.first {
            // Allow only one selection in a section.
            tableView.deselectRow(at: selectedIndex, animated: false)
            
            // Find matching exclusion set of row that is going to be deselected and ENABLE corresponding exclusion rows.
            let facility = facilities[selectedIndex.section]
            let facilityOption = facility.options[selectedIndex.row]
            let matchingExclusionSets = findMatchingExclusionSets(facility: facility, facilityOption: facilityOption)
            if matchingExclusionSets.count > 0 {
                for matchingExclusionSet in matchingExclusionSets {
                    let facilityIndex = facilities.firstIndex(where: { $0.facilityId == matchingExclusionSet.facilityId })
                    let facilityOptionsIndex = facilities[facilityIndex!].options.firstIndex { $0.id == matchingExclusionSet.optionsId }
                    
                    let exclusionIndexPath = IndexPath(row: facilityOptionsIndex!, section: facilityIndex!)
                    Self.updateSelection(cell: tableView.cellForRow(at: exclusionIndexPath)!, disable: false)
                }
            }
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Find matching exclusion set of row that is going to be deselected and DISABLE corresponding exclusion rows.
        let facility = facilities[indexPath.section]
        let facilityOption = facility.options[indexPath.row]
        let matchingExclusionSets = findMatchingExclusionSets(facility: facility, facilityOption: facilityOption)
        if matchingExclusionSets.count > 0 {
            for matchingExclusionSet in matchingExclusionSets {
                let facilityIndex = facilities.firstIndex(where: { $0.facilityId == matchingExclusionSet.facilityId })
                let facilityOptionsIndex = facilities[facilityIndex!].options.firstIndex {
                    $0.id == matchingExclusionSet.optionsId
                }
                
                let exclusionIndexPath = IndexPath(row: facilityOptionsIndex!, section: facilityIndex!)
                Self.updateSelection(cell: tableView.cellForRow(at: exclusionIndexPath)!, disable: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        // Return nil to disable deselection once selection starts in the table.
        return nil
    }
    
    // MARK: - Private Helpers
    
    /// Updates selection state of a cell.
    static func updateSelection(cell: UITableViewCell, disable: Bool) {
        if disable {
            cell.backgroundColor = .tertiarySystemBackground
            cell.isUserInteractionEnabled = false
            cell.accessoryType = .detailButton
        } else {
            cell.backgroundColor = .systemBackground
            cell.isUserInteractionEnabled = true
            cell.accessoryType = .none
        }
    }
    
    func setupSetupSubviews() {
        let tableView = UITableView()
        tableView.allowsMultipleSelection = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.cellReuseIdentifier)

        self.view.addSubview(tableView)
        self.facilitiesTableView = tableView

        let navBar = UINavigationBar()
        navBar.translatesAutoresizingMaskIntoConstraints = false

        let navItem = UINavigationItem(title: "Facilities")
        navItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.save, target: self, action: #selector(self.someAction))
        navBar.setItems([navItem], animated: false)
        
        view.addSubview(navBar)
        
        self.view.addConstraints([
            self.view.leadingAnchor.constraint(equalTo: navBar.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: navBar.topAnchor),
            
            navBar.bottomAnchor.constraint(equalTo: tableView.topAnchor),
            
            self.view.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
    }
    
    /// Finds matching exclusions for the selected facility and its option.
    func findMatchingExclusionSets(facility: Facility, facilityOption: Facility.FacilitiesOption) -> [Exclusion] {
        var matchingExclusionSets: [Exclusion] = []
        for exclusionSet in exclusions {
            let firstExclusion = exclusionSet.first!
            let lastExclusion = exclusionSet.last!
            if facility.facilityId == firstExclusion.facilityId && facilityOption.id == firstExclusion.optionsId {
                matchingExclusionSets.append(lastExclusion)
            } else if facility.facilityId == lastExclusion.facilityId && facilityOption.id == lastExclusion.optionsId {
                matchingExclusionSets.append(firstExclusion)
            }
        }
        return matchingExclusionSets
    }
    
    @objc func someAction() {
        print("Save")
    }
}

