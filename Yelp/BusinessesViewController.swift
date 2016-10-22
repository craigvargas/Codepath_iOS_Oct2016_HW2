//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    
    var businesses: [Business]!
    var filteredBusinesses: [Business]!
    var searchController: UISearchController!
    
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
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
