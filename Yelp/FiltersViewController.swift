//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Craig Vargas on 10/22/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    @objc optional func filtersViewController(filtersViewController: FiltersViewController, dictionaryOfSwitchFiltersTurnedOn switchFilterIsOnDict: Dictionary<String,Bool>)
    @objc optional func filtersViewController(filtersViewController: FiltersViewController, dictionaryOfSelectionFilterIndexes selectionFilterIndexDict: Dictionary<String,Int>)
    @objc optional func filtersViewController(filtersViewController: FiltersViewController, didTapSearchButton seachButtonWasTapped: Bool)
}

class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FilterCellDelegate {
    
    var delegate: FiltersViewControllerDelegate?

    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var searchBarButton: UIBarButtonItem!
    
    @IBOutlet weak var filtersTableView: UITableView!
    
    let switchType = "switch"
    let distanceType = "distance"
    let sortType = "sort"
    
    let categories = Filter.yelpCuisineCategories()
    let tableStructure = [["name": Filter.dealsTitle,       "type": Filter.switchKey,   "data": Filter.deals],
                          ["name": Filter.distanceTitle,    "type": Filter.distanceKey, "data": Filter.distances],
                          ["name": Filter.sortByTitle,      "type": Filter.sortByKey,   "data": Filter.sortOptions],
                          ["name": Filter.categoriesTitle,  "type": Filter.switchKey,   "data": Filter.categories]]
    let separator = "&@&@"
    
//    var switchFilterIsOnDict: [String:Bool] = [String:Bool]()
    var switchFilterIsOnDict: [String:Bool] = [String:Bool]()
    var selectionFilterIndexDict: [String:Int] = [String:Int]()
    
    //*
    //View Controller Lifecylce Overrides
    //*
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //*
    //Button Actions
    //*
    
    @IBAction func onCancelButtonTap(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSearchButtonTap(_ sender: UIBarButtonItem) {
        delegate?.filtersViewController?(filtersViewController: self, dictionaryOfSwitchFiltersTurnedOn: switchFilterIsOnDict)
        delegate?.filtersViewController?(filtersViewController: self, dictionaryOfSelectionFilterIndexes: selectionFilterIndexDict)
        delegate?.filtersViewController?(filtersViewController: self, didTapSearchButton: true)
        dismiss(animated: true, completion: nil)
    }
    
    //*
    //Protocol implementations
    //*
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return categories.count
        let type = tableStructure[section]["type"] as! String
        if type == Filter.switchKey{
            let sectionData = tableStructure[section]["data"] as! [Dictionary<String,Any>]
            return sectionData.count
        }else{
            return 1
        }
//        return tableStructure[section]["data"].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = filtersTableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath) as! FilterTableViewCell
        
        let type = tableStructure[indexPath.section]["type"] as! String
        
        cell.hideViews()
        
        switch type{
            case Filter.switchKey:
                cell.switchView.isHidden = false
                cell.filterLabel.text = (tableStructure[indexPath.section]["data"] as! [Dictionary<String,Any>])[indexPath.row]["name"] as? String
                //determine on/off state
                if let isOn = switchFilterIsOnDict["\(indexPath.section)" + Filter.separator + cell.filterLabel.text!]{
                    cell.filterSwitch.isOn = isOn
                }else{
                    cell.filterSwitch.isOn = false
                }
                break
        case Filter.distanceKey:
            cell.distanceView.isHidden = false
            if selectionFilterIndexDict[Filter.distanceKey] != nil{
                cell.distanceSegmentedControl.selectedSegmentIndex = selectionFilterIndexDict[Filter.distanceKey]!
            }
            break
        case Filter.sortByKey:
            cell.sortView.isHidden = false
            if selectionFilterIndexDict[Filter.sortByKey] != nil{
                cell.sortSegmentedControl.selectedSegmentIndex = selectionFilterIndexDict[Filter.sortByKey]!
            }
            break
        default:
            break
        }
        
//        cell.filterLabel.text = (tableStructure[indexPath.section]["data"] as! [Dictionary<String,Any>])[indexPath.row]["name"] as? String
//        
//        if let isOn = switchFilterIsOnDict["\(indexPath.section)" + Filter.separator + cell.filterLabel.text!]{
//            cell.filterSwitch.isOn = isOn
//        }else{
//            cell.filterSwitch.isOn = false
//        }
//        
        cell.delegate = self
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableStructure.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableStructure[section]["name"] as? String
    }
    
    func filterCell(filterCell: FilterTableViewCell, didChangeValue isOn: Bool) {
//        switchFilterIsOnDict[filterCell.filterLabel.text!] = isOn
        let indexPath = filtersTableView.indexPath(for: filterCell)!
        if(tableStructure[indexPath.section]["name"] as! String == Filter.dealsTitle){
            switchFilterIsOnDict["\(indexPath.section)" + Filter.separator + Filter.dealsTitle] = isOn
        }else{
        switchFilterIsOnDict["\(indexPath.section)" + Filter.separator + Filter.categories[indexPath.row]["code"]!] = isOn
        }
//        printFilterIsOn()
    }
    
    func filterCell(filterCell: FilterTableViewCell, didChangeSelection index: Int){
        let indexPath = filtersTableView.indexPath(for: filterCell)!
        selectionFilterIndexDict[tableStructure[indexPath.section]["type"] as! String] = index
        for(k,v) in selectionFilterIndexDict{
            print("Key: \(k), Value: \(v)")
        }
    }

    
    func printFilterIsOn(){
        for (filterId, isOn) in switchFilterIsOnDict{
            let range = filterId.range(of: Filter.separator, options: .caseInsensitive, range: nil, locale: nil)
            let sectionString = filterId.substring(to: range!.lowerBound)
            let filterString = filterId.substring(from: range!.upperBound)
//            if let separatorIndex = filterId.characters.index(of: Filter.separator.characters) {
//                let section = String(filterId.characters.prefix(upTo: separatorIndex))
//                print(section)
//            }
            print("Range Upper Bound: \(range?.upperBound), Range Lower Bound: \(range?.lowerBound)")
            print(sectionString + " " + filterString)
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //*
    //Modular functoins
    //*
    //Initialize table view
    func setupTableView(){
        filtersTableView.dataSource = self
        filtersTableView.delegate = self
        filtersTableView.rowHeight = UITableViewAutomaticDimension
        filtersTableView.estimatedRowHeight = 120;
    }

}
