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
    
    var switchFilterIsOnDict: [String:Bool] = [String:Bool]()
    var selectionFilterIndexDict: [String:Int] = [String:Int]()
    
    var categoriesMenuIsExpanded = false
    var distanceMenuIsExpanded = false
    var sortByMenuIsExpanded = false
    var menuIsExpanded: [String:Bool] = [Filter.dealsTitle:false,
                                         Filter.distanceTitle:false,
                                         Filter.sortByTitle:false,
                                         Filter.categoriesTitle:false]
    
    let highlightedColor: UIColor = UIColor(red: 124/255, green: 66/255, blue: 255/255, alpha: 255/255)
    let offWhite: UIColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 255/255)
    let lavenderGray: UIColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 255/255)
    let yelpRed: UIColor = UIColor(red: 180/255, green: 40/255, blue: 46/255, alpha: 255/255)
    let skyBlue: UIColor = UIColor(red: 0/255, green: 200/255, blue: 255/255, alpha: 255/255)
    let japaneseIndigo: UIColor = UIColor(red: 38/255, green: 60/255, blue: 84/255, alpha: 255/255)
    let onyx: UIColor = UIColor(red: 52/255, green: 61/255, blue: 70/255, alpha: 255/255)

    
    //*
    //*
    //View Controller Lifecylce Overrides
    //*
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
        let groupName = tableStructure[section]["name"] as! String
        let sectionData = tableStructure[section]["data"] as! [Dictionary<String,Any>]
        
        switch groupName{
        case Filter.dealsTitle:
            return 1
        case Filter.distanceTitle:
            if menuIsExpanded[groupName]!{
                return sectionData.count + 1
            }else{
                return 1
            }
        case Filter.sortByTitle:
            if menuIsExpanded[groupName]!{
                return sectionData.count + 1
            }else{
                return 1
            }
        case Filter.categoriesTitle:
            if menuIsExpanded[groupName]!{
                let sectionData = tableStructure[section]["data"] as! [Dictionary<String,Any>]
                return sectionData.count + 1
            }else{
                return 4
            }
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = filtersTableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath) as! FilterTableViewCell
        
        let groupName = tableStructure[indexPath.section]["name"] as! String
        
        cell.hideViews()
        cell.resetSwitchView()
        
        switch groupName{
        case Filter.dealsTitle:
            cell.switchView.isHidden = false
            cell.filterSwitch.isHidden = false
            cell.filterLabel.text = getNameOfFilter(withIndexPath: indexPath, filterIsInToggleGroup: false)

            if let isOn = switchFilterIsOnDict["\(indexPath.section)" + Filter.separator + Filter.dealsTitle]{
                cell.filterSwitch.isOn = isOn
            }else{
                cell.filterSwitch.isOn = false
            }
            break
        case Filter.categoriesTitle:
            //Setup the categoroies
            cell.switchView.isHidden = false
            //Check if we are setting up Collapse/Expand item
            if(indexPath.row == 0){
                cell.filterImageView.isHidden = false
                if menuIsExpanded[groupName]!{
                    cell.filterLabel.text = "Show Less"
                    cell.filterImageView.image = #imageLiteral(resourceName: "ic_expand_less")
                }else{
                    cell.filterLabel.text = "Show More"
                    cell.filterImageView.image = #imageLiteral(resourceName: "ic_expand_more")
                }
            }else{
                cell.filterSwitch.isHidden = false
                //set filter title
                cell.filterLabel.text = getNameOfFilter(withIndexPath: indexPath, filterIsInToggleGroup: true)
            
                //determine on/off state
                if let isOn = switchFilterIsOnDict["\(indexPath.section)" + Filter.separator + Filter.categories[indexPath.row - 1]["code"]!]{
                    cell.filterSwitch.isOn = isOn
                }else{
                    cell.filterSwitch.isOn = false
                }
            }
            break
        case Filter.distanceTitle:
            //Setup the distance menu
            cell.switchView.isHidden = false
            //Check if we are setting up Collapsed/Expanded item
            if(indexPath.row == 0){
                cell.filterImageView.isHidden = false
                if menuIsExpanded[groupName]! {
                    cell.filterLabel.text = "Make Your Selection"
                    cell.filterImageView.image = #imageLiteral(resourceName: "ic_expand_less")
                }else{
                    if let selection = selectionFilterIndexDict[groupName]{
                        cell.filterLabel.text = getNameOfSelection(selection, withIndexPath: indexPath)
                    }else{
                        cell.filterLabel.text = "Show Options"
                    }
                    cell.filterImageView.image = #imageLiteral(resourceName: "ic_expand_more")
                }
            }else{
                //set filter title
                cell.filterLabel.text = (tableStructure[indexPath.section]["data"] as! [Dictionary<String,Any>])[indexPath.row - 1]["name"] as? String
                
                //determine on/off state
                if let selectionIndex = selectionFilterIndexDict[groupName]{
                    if (indexPath.row - 1) == selectionIndex{
                        cell.filterImageView.isHidden = false
                        cell.filterLabel.textColor = yelpRed
                        cell.switchView.backgroundColor = offWhite
                    }
                }
            }
            break
        case Filter.sortByTitle:
            //Setup the distance menu
            cell.switchView.isHidden = false
            //Check if we are setting up Collapsed/Expanded item
            if(indexPath.row == 0){
                cell.filterImageView.isHidden = false
                if menuIsExpanded[groupName]! {
                    cell.filterLabel.text = "Make Your Selection"
                    cell.filterImageView.image = #imageLiteral(resourceName: "ic_expand_less")
                }else{
                    if let selection = selectionFilterIndexDict[groupName]{
                        cell.filterLabel.text = getNameOfSelection(selection, withIndexPath: indexPath)
                    }else{
                        cell.filterLabel.text = "Show Options"
                    }
                    cell.filterImageView.image = #imageLiteral(resourceName: "ic_expand_more")
                }
            }else{
                //set filter title
                cell.filterLabel.text = (tableStructure[indexPath.section]["data"] as! [Dictionary<String,Any>])[indexPath.row - 1]["name"] as? String
                
                //determine on/off state
                if let selectionIndex = selectionFilterIndexDict[groupName]{
                    if (indexPath.row - 1) == selectionIndex{
                        cell.filterImageView.isHidden = false
                        cell.filterLabel.textColor = yelpRed
                        cell.switchView.backgroundColor = offWhite
                    }
                }
            }
        default:
            break
        }
        
        cell.delegate = self
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableStructure.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        tableView.headerView(forSection: section)?.textLabel?.textColor = yelpRed
        return tableStructure[section]["name"] as? String
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let groupName = tableStructure[indexPath.section]["name"] as! String
        print("selected: \(groupName)")

        
        switch groupName{
        case Filter.dealsTitle:
            tableView.deselectRow(at: indexPath, animated: true)
            break
        case Filter.distanceTitle:
//            if indexPath.row == 0{
//                menuIsExpanded[groupName] = !(menuIsExpanded[groupName]!)
//                filtersTableView.reloadData()
//            }else{
//                selectionFilterIndexDict[groupName] = (indexPath.row - 1)
//                menuIsExpanded[groupName] = !(menuIsExpanded[groupName]!)
//                filtersTableView.reloadData()
//            }
            if indexPath.row != 0{
                selectionFilterIndexDict[groupName] = (indexPath.row - 1)
            }
            menuIsExpanded[groupName] = !(menuIsExpanded[groupName]!)
            filtersTableView.reloadData()
            tableView.deselectRow(at: indexPath, animated: true)
            break
        case Filter.sortByTitle:
//            if indexPath.row == 0{
//                menuIsExpanded[groupName] = !(menuIsExpanded[groupName]!)
//                filtersTableView.reloadData()
//            }else{
//                selectionFilterIndexDict[groupName] = (indexPath.row - 1)
//                filtersTableView.reloadData()
//            }
            if indexPath.row != 0{
                selectionFilterIndexDict[groupName] = (indexPath.row - 1)
            }
            menuIsExpanded[groupName] = !(menuIsExpanded[groupName]!)
            filtersTableView.reloadData()
            tableView.deselectRow(at: indexPath, animated: true)
            break
        case Filter.categoriesTitle:
            if indexPath.row == 0{
                menuIsExpanded[groupName] = !(menuIsExpanded[groupName]!)
                filtersTableView.reloadData()
            }
            tableView.deselectRow(at: indexPath, animated: true)
            break
        default:
            break
        }
        
        print(self.switchFilterIsOnDict)
        print(self.selectionFilterIndexDict)
        
        
//        if(tableStructure[indexPath.section]["name"] as! String == Filter.categoriesTitle && indexPath.row == 0){
//            categoriesMenuIsExpanded = !categoriesMenuIsExpanded
//            filtersTableView.reloadData()
//        }
//        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        let headerView = view as! UITableViewHeaderFooterView
        headerView.backgroundView?.backgroundColor = japaneseIndigo
        headerView.textLabel?.textColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int){
        let footerView = view as! UITableViewHeaderFooterView
        footerView.isHidden = true
//        headerView.backgroundView?.backgroundColor = japaneseIndigo
//        headerView.textLabel?.textColor = UIColor.white
    }
    
    func filterCell(filterCell: FilterTableViewCell, didChangeValue isOn: Bool) {
//        switchFilterIsOnDict[filterCell.filterLabel.text!] = isOn
        let indexPath = filtersTableView.indexPath(for: filterCell)!
        if(tableStructure[indexPath.section]["name"] as! String == Filter.dealsTitle){
            switchFilterIsOnDict["\(indexPath.section)" + Filter.separator + Filter.dealsTitle] = isOn
        }else{
        switchFilterIsOnDict["\(indexPath.section)" + Filter.separator + Filter.categories[indexPath.row - 1]["code"]!] = isOn
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
    
//    func printFilterIsOn(){
//        for (filterId, isOn) in switchFilterIsOnDict{
//            let range = filterId.range(of: Filter.separator, options: .caseInsensitive, range: nil, locale: nil)
//            let sectionString = filterId.substring(to: range!.lowerBound)
//            let filterString = filterId.substring(from: range!.upperBound)
////            if let separatorIndex = filterId.characters.index(of: Filter.separator.characters) {
////                let section = String(filterId.characters.prefix(upTo: separatorIndex))
////                print(section)
////            }
//            print("Range Upper Bound: \(range?.upperBound), Range Lower Bound: \(range?.lowerBound)")
//            print(sectionString + " " + filterString)
//        }
//    }
    
    

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
        filtersTableView.separatorColor = japaneseIndigo
        filtersTableView.headerView(forSection: 0)?.textLabel?.textColor = UIColor.black
        filtersTableView.estimatedRowHeight = 120;
//        filtersTableView.reloadData()
    }
    
    //Set the current(saved) filters
    func setCurrentFilters(currentFilters currentFiltersDict: Dictionary<String, AnyObject>) {
        for (dictType, dict) in currentFiltersDict{
            switch dictType{
            case Filter.switchKey:
                self.switchFilterIsOnDict = dict as! Dictionary<String,Bool>
                break
            case Filter.selectionKey:
                self.selectionFilterIndexDict = dict as! Dictionary<String,Int>
                break
            default:
                break
            }
        }
//        print(self.switchFilterIsOnDict)
//        print(self.selectionFilterIndexDict)
    }
    
    func getNameOfSelection(_ selection: Int, withIndexPath indexPath: IndexPath) -> String? {
        return (tableStructure[indexPath.section]["data"] as! [Dictionary<String,Any>])[selection]["name"] as! String?
    }
    
    func getNameOfFilter(withIndexPath indexPath: IndexPath, filterIsInToggleGroup isInToggleGroup: Bool) -> String? {
        if isInToggleGroup{
            return (tableStructure[indexPath.section]["data"] as! [Dictionary<String,Any>])[indexPath.row - 1]["name"] as? String
        }else{
            return (tableStructure[indexPath.section]["data"] as! [Dictionary<String,Any>])[indexPath.row]["name"] as? String
        }
    }
        

}
