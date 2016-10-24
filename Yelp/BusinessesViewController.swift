//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, FiltersViewControllerDelegate {
    
    var businesses: [Business]!
    var filteredBusinesses: [Business]!
    var searchController: UISearchController!
    
    var switchFilterIsOnDict = [String: Bool]()
    var selectionFilterIndexDict = [String: Int]()
    
    
    @IBOutlet weak var businessTV: UITableView!
    @IBOutlet weak var businessNavItem: UINavigationItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        loadTableWithSearchRequest()
        setupSearchBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //*
    //Protocol implementations
    //*
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.businesses != nil {
            return self.filteredBusinesses!.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.businessTV.dequeueReusableCell(withIdentifier: "BusinessTableViewCell", for: indexPath) as! BusinessTableViewCell
        cell.business = self.filteredBusinesses[indexPath.row]
        
        return cell
    }
    
    func updateSearchResults(for: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filteredBusinesses = searchText.isEmpty ? businesses : businesses.filter({(business: Business) -> Bool in
                var stringData: String = ""
                stringData += business.name ?? ""
                stringData += business.address ?? ""
                stringData += business.categories ?? ""
                return stringData.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            })
            businessTV.reloadData()
        }
    }
    
    func filtersViewController(filtersViewController: FiltersViewController, dictionaryOfSwitchFiltersTurnedOn switchFilterIsOnDict: Dictionary<String, Bool>) {
        self.switchFilterIsOnDict = switchFilterIsOnDict
    }
    
    func filtersViewController(filtersViewController: FiltersViewController, dictionaryOfSelectionFilterIndexes selectionFilterIndexDict: Dictionary<String, Int>) {
        self.selectionFilterIndexDict = selectionFilterIndexDict
    }
    
    func filtersViewController(filtersViewController: FiltersViewController, didTapSearchButton seachButtonWasTapped: Bool) {
        print("BusinessViewController: Search button was tapped")
        
        let distances = Filter.distances
        let sortOptions = Filter.sortOptions
        
        var searchParameters = [String:Any?]()
        
        var categories = [String]()
        var deals = false
        for(filterId, isOn) in self.switchFilterIsOnDict{
            let range = filterId.range(of: Filter.separator, options: .caseInsensitive, range: nil, locale: nil)
            let sectionString = filterId.substring(to: range!.lowerBound)
            let filterString = filterId.substring(from: range!.upperBound)

//            print("Range Upper Bound: \(range?.upperBound), Range Lower Bound: \(range?.lowerBound)")
//            print(sectionString + " " + filterString)
            print("Filter: \(filterString) = \(isOn)")
            if(isOn){
                if(filterId == Filter.dealsTitle){
                    deals = true
                }else{
                    categories.append(filterString)
                }
            }
        }
        for(filterId, selectionIndex) in self.selectionFilterIndexDict{
            switch filterId{
            case Filter.distanceKey:
                print("Selection: \(filterId) = \(distances[selectionIndex]["value"]!)")
                break
            case Filter.sortByKey:
                print("Selection: \(filterId) = \(sortOptions[selectionIndex]["option"]!)")
                break
            default:
                break
            }
        }
    }
    
     // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navController = segue.destination as! UINavigationController
        let viewController = navController.topViewController as! FiltersViewController
        viewController.delegate = self
    }
    
//     // In a storyboard-based application, you will often want to do a little preparation before navigation
//    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//
//    }
    
    //*
    //Modular Functions
    //*
    
    //Initialize table view
    func setupTableView(){
        businessTV.dataSource = self
        businessTV.delegate = self
        businessTV.rowHeight = UITableViewAutomaticDimension
        businessTV.estimatedRowHeight = 120;
    }
    
    //Load table with data from a search
    func loadTableWithSearchRequest(){
        Business.searchWithTerm(term: "Thai", completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            self.businesses = businesses
            self.filteredBusinesses = businesses
            self.businessTV.reloadData()
            
            if let businesses = businesses {
                for business in businesses {
                    print(business.name!)
                    print(business.address!)
                    print("")
                }
            }
        })
        
        /* Example of Yelp search with more search options specified
         Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
         self.businesses = businesses
         
         for business in businesses {
         print(business.name!)
         print(business.address!)
         }
         }
         */
    }
    
    //Setup the seach bar
    func setupSearchBar() -> Void {
        // Initializing with searchResultsController set to nil means that
        // searchController will use this view controller to display the search results
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        
        //Don't dim presentation since we are using this VC to present results
        searchController.dimsBackgroundDuringPresentation = false
        
        searchController.searchBar.sizeToFit()
        businessNavItem.titleView = searchController.searchBar
        
        // Sets this view controller as presenting view controller for the search interface
        definesPresentationContext = true
        
        // Dont hide navigation bar
        searchController.hidesNavigationBarDuringPresentation = false
    }
    
}
