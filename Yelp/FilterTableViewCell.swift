//
//  FilterTableViewCell.swift
//  Yelp
//
//  Created by Craig Vargas on 10/22/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FilterCellDelegate {
    @objc optional func filterCell(filterCell: FilterTableViewCell, didChangeValue isOn: Bool)
    @objc optional func filterCell(filterCell: FilterTableViewCell, didChangeSelection index: Int)
}

class FilterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var switchView: UIView!
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var filterSwitch: UISwitch!
    @IBOutlet weak var filterImageView: UIImageView!
    
    @IBOutlet weak var distanceView: UIView!
    @IBOutlet weak var distanceSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var sortView: UIView!
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    
    
    
    weak var delegate: FilterCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        filterSwitch.addTarget(self, action: #selector(filterSwitchValueChanged), for: UIControlEvents.valueChanged)
        
        distanceSegmentedControl.addTarget(self, action: #selector(distanceChanged), for: UIControlEvents.valueChanged)
        
        sortSegmentedControl.addTarget(self, action: #selector(sortChanged), for: UIControlEvents.valueChanged)
        
        hideViews()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func filterSwitchValueChanged(){
        print("Switch value changed")
        delegate?.filterCell?(filterCell: self, didChangeValue: filterSwitch.isOn)
    }
    
    func distanceChanged(){
        delegate?.filterCell?(filterCell: self, didChangeSelection: distanceSegmentedControl.selectedSegmentIndex)
    }
    
    func sortChanged(){
        delegate?.filterCell?(filterCell: self, didChangeSelection: sortSegmentedControl.selectedSegmentIndex)
    }
    
    func hideViews(){
        switchView.isHidden = true
        distanceView.isHidden = true
        sortView.isHidden = true
    }

    func resetSwitchView(){
        filterSwitch.isHidden = true
        filterImageView.isHidden = true
        switchView.backgroundColor = UIColor.white
        filterLabel.textColor = UIColor.black
        filterImageView.image = #imageLiteral(resourceName: "yelp_red_2")
    }

}
