//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Craig Vargas on 10/22/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FilterCellDelegate {

    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var searchBarButton: UIBarButtonItem!
    
    @IBOutlet weak var filtersTableView: UITableView!
    
    let switchType = "switch"
    let distanceType = "distance"
    let sortType = "sort"
    
    let categories = Filter.yelpCuisineCategories()
    let tableStructure = [["name": "Deals", "type": "switch", "data":Filter.deals],
                          ["name": "Within How Many Miles?", "type": "distance", "data": Filter.distances],
                          ["name": "Sort By", "type": "sort", "data": Filter.sortOptions],
                          ["name": "Categories", "type": "switch", "data": Filter.categories]]
    let separator = "&@&@"
    
//    var filterIsOn: [String:Bool] = [String:Bool]()
    var filterIsOn: [String:Bool] = [String:Bool]()
    var filterSelectionIndex: [String:Int] = [String:Int]()
    
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
        dismiss(animated: true, completion: nil)
    }
    
    //*
    //Protocol implementations
    //*
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return categories.count
        let type = tableStructure[section]["type"] as! String
        if type == switchType{
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
            case switchType:
                cell.switchView.isHidden = false
                cell.filterLabel.text = (tableStructure[indexPath.section]["data"] as! [Dictionary<String,Any>])[indexPath.row]["name"] as? String
                //determine on/off state
                if let isOn = filterIsOn["\(indexPath.section)" + separator + cell.filterLabel.text!]{
                    cell.filterSwitch.isOn = isOn
                }else{
                    cell.filterSwitch.isOn = false
                }
                break
        case distanceType:
            cell.distanceView.isHidden = false
            if filterSelectionIndex[distanceType] != nil{
                cell.distanceSegmentedControl.selectedSegmentIndex = filterSelectionIndex[distanceType]!
            }
            break
        case sortType:
            cell.sortView.isHidden = false
            if filterSelectionIndex[sortType] != nil{
                cell.sortSegmentedControl.selectedSegmentIndex = filterSelectionIndex[sortType]!
            }
            break
        default:
            break
        }
        
//        cell.filterLabel.text = (tableStructure[indexPath.section]["data"] as! [Dictionary<String,Any>])[indexPath.row]["name"] as? String
//        
//        if let isOn = filterIsOn["\(indexPath.section)" + separator + cell.filterLabel.text!]{
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
//        filterIsOn[filterCell.filterLabel.text!] = isOn
        let indexPath = filtersTableView.indexPath(for: filterCell)!
        filterIsOn["\(indexPath.section)" + separator + filterCell.filterLabel.text!] = isOn
        printFilterIsOn()
    }
    
    func filterCell(filterCell: FilterTableViewCell, didChangeSelection index: Int){
        let indexPath = filtersTableView.indexPath(for: filterCell)!
        filterSelectionIndex[tableStructure[indexPath.section]["type"] as! String] = index
        for(k,v) in filterSelectionIndex{
            print("Key: \(k), Value: \(v)")
        }
    }

    
    func printFilterIsOn(){
        for (filterId, isOn) in filterIsOn{
            let range = filterId.range(of: separator, options: .caseInsensitive, range: nil, locale: nil)
            let sectionString = filterId.substring(to: range!.lowerBound)
            let filterString = filterId.substring(from: range!.upperBound)
//            if let separatorIndex = filterId.characters.index(of: separator.characters) {
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
