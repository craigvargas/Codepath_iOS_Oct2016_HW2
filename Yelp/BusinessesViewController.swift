//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol BusinessesViewControllerDelegate {
    @objc optional func businessesViewController(businessesViewController: BusinessesViewController, currentFilters currentFiltersDict: Dictionary<String,AnyObject>)
}

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, FiltersViewControllerDelegate, UIScrollViewDelegate {
    
    var businesses: [Business]! = [Business]()
    var filteredBusinesses: [Business]! = [Business]()
    var searchController: UISearchController!
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    var switchFilterIsOnDict = [String: Bool]()
    var selectionFilterIndexDict = [String: Int]()
    var parametersDict = [String:AnyObject]()

    
    var delegate: BusinessesViewControllerDelegate?
    
    
    @IBOutlet weak var businessTV: UITableView!
    @IBOutlet weak var businessNavItem: UINavigationItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupScrollRefreshIndicator()
        loadTableWithSearchRequest()
        setupSearchBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //*
    //*
    //Protocol implementations
    //*
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
        
        self.businesses = [Business]()
        self.filteredBusinesses = [Business]()
        
        let distances = Filter.distances
        let sortOptions = Filter.sortOptions
        
        var categories: [String]? = [String]()
        var deals: Bool?
        var sort: YelpSortMode?
        var distance: Int?
        
        for(filterId, isOn) in self.switchFilterIsOnDict{
            let range = filterId.range(of: Filter.separator, options: .caseInsensitive, range: nil, locale: nil)
//            let section = filterId.substring(to: range!.lowerBound)
            let filterName = filterId.substring(from: range!.upperBound)

            print("Filter: \(filterName) = \(isOn)")
            if(isOn){
                if(filterName == Filter.dealsTitle){
                    deals = true
                }else{
                    categories!.append(filterName)
                }
            }
        }
        if categories!.isEmpty{
            categories = nil
        }
        for(filterId, selectionIndex) in self.selectionFilterIndexDict{
            switch filterId{
            case Filter.distanceTitle:
                let distanceMiles = distances[selectionIndex]["value"] as! Double
                distance = Int(milesToMeters(numberOfMiles: distanceMiles) + 1)
//                print("Selection: \(filterId) = \(distances[selectionIndex]["value"]!)")
                print("Selection: \(filterId) = \(distance)")
                break
            case Filter.sortByTitle:
                sort = (sortOptions[selectionIndex]["option"]! as! YelpSortMode)
//                print("Selection: \(filterId) = \((sortOptions[selectionIndex]["option"]! as! YelpSortMode).rawValue)")
                print("Selection: \(filterId) = \(sort)")
                break
            default:
                break
            }
        }
        print("RESULTS")
        print("categories resulted in: \(categories)")
        print("deals resulted in: \(deals)")
        print("distance resulted in: \(distance)")
        print("sort resulted in: \(sort)")
        
        if categories != nil {
            parametersDict[YelpClient.categoriesKey] = categories as AnyObject?
        }
        if deals != nil {
            parametersDict[YelpClient.dealsKey] = deals as AnyObject?
        }
        if distance != nil {
            parametersDict[YelpClient.radiusKey] = distance as AnyObject?
        }
        if sort != nil{
            parametersDict[YelpClient.sortKey] = sort as AnyObject?
        }
        loadTableWithSearchRequest()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = businessTV.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - businessTV.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && businessTV.isDragging) {
                isMoreDataLoading = true
                
                let frame = CGRect(x: 0 as CGFloat, y: businessTV.contentSize.height, width: businessTV.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
//                loadingMoreView?.startAnimating()

                loadTableWithSearchRequest()
            }
        }
    }
    
     // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navController = segue.destination as! UINavigationController
        let viewController = navController.topViewController as! FiltersViewController
        viewController.delegate = self
        
        let currentFiltersDict = [Filter.switchKey:self.switchFilterIsOnDict as AnyObject,
                                  Filter.selectionKey:self.selectionFilterIndexDict as AnyObject]
        viewController.setCurrentFilters(currentFilters: currentFiltersDict)
    }

    
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
    
//    //Load table with data from a search
//    func loadTableWithSearchRequest(){
//        loadingMoreView?.startAnimating()
//        Business.searchWithTerm(term: "Restaurants", completion: { (businesses: [Business]?, error: Error?) -> Void in
//            
//            if let businesses = businesses {
//                self.businesses.append(contentsOf: businesses)
//                self.filteredBusinesses = self.businesses
//                self.loadingMoreView?.stopAnimating()
//                self.businessTV.reloadData()
//                self.isMoreDataLoading = false
//                
//                for business in businesses {
//                    print(business.name!)
//                    print(business.address!)
//                    print("")
//                }
//            }
//            
//            print("Error: \(error)")
//        })
//        
//        /* Example of Yelp search with more search options specified
//         Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
//         self.businesses = businesses
//         
//         for business in businesses {
//         print(business.name!)
//         print(business.address!)
//         }
//         }
//         */
//    }
    
    
    func loadTableWithSearchRequest(){
        loadingMoreView?.startAnimating()
        self.parametersDict[YelpClient.offsetKey] = businesses.count as AnyObject?
        Business.searchWithParametersDict(self.parametersDict, completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            if let businesses = businesses {
                self.businesses.append(contentsOf: businesses)
                self.filteredBusinesses = self.businesses
                self.loadingMoreView!.stopAnimating()
                self.businessTV.reloadData()
                self.isMoreDataLoading = false
                
                for business in businesses {
                    print(business.name!)
                    print(business.address!)
                    print("")
                }
                print("Business count: \(self.businesses.count)")
            }
            print("Error: \(error)")
            
        })
    }
    
//    func loadMoreData(){
//        loadTableWithSearchRequest()
//    }
    
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
    
    func milesToMeters(numberOfMiles miles: Double) -> Double{
        let milesPerMeter = 0.000621371
        return miles / milesPerMeter
    }
    
    func setupScrollRefreshIndicator(){
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0 as CGFloat, y: businessTV.contentSize.height, width: businessTV.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        businessTV.addSubview(loadingMoreView!)
        
        var insets = businessTV.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        businessTV.contentInset = insets
    }
    
}
