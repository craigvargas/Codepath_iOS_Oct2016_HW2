//
//  BusinessTableViewCell.swift
//  Yelp
//
//  Created by Craig Vargas on 10/19/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessTableViewCell: UITableViewCell {

    //Images
    @IBOutlet weak var businessThumbIV: UIImageView!
    @IBOutlet weak var ratingIV: UIImageView!
    
    //Labels
    @IBOutlet weak var businessNameLBL: UILabel!
    @IBOutlet weak var distanceLBL: UILabel!
    @IBOutlet weak var reviewCountLBL: UILabel!
    @IBOutlet weak var addressLBL: UILabel!
    @IBOutlet weak var categoriesLBL: UILabel!
    
    var business: Business! {
//        didSet{
//            self.businessNameLBL.text = business.name
//        }
        willSet{
//            print("New business name \(newValue.name)")
            //Set thumb
            if(newValue.imageURL != nil){
                self.businessThumbIV.setImageWith(newValue.imageURL!)
            }else{
                self.businessThumbIV.image = #imageLiteral(resourceName: "iconmonstr-id-card-gray-24-64")
            }
            
            //Set rating
            if(newValue.ratingImageURL != nil){
                self.ratingIV.setImageWith(newValue.ratingImageURL!)
            }else{
                self.ratingIV.image = #imageLiteral(resourceName: "iconmonstr-help-gray-1-24")
            }
            
            //Set label texts
            self.businessNameLBL.text = newValue.name
            self.distanceLBL.text = newValue.distance
            if newValue.reviewCount != nil{
                self.reviewCountLBL.text = "\(newValue.reviewCount!) Reviews"
            }
            self.addressLBL.text = newValue.address
            self.categoriesLBL.text = newValue.categories
            
        }
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.businessThumbIV.layer.cornerRadius = 5
        self.businessThumbIV.clipsToBounds = true
        
        self.businessNameLBL.preferredMaxLayoutWidth = self.businessNameLBL.frame.size.width
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.businessNameLBL.preferredMaxLayoutWidth = self.businessNameLBL.frame.size.width
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
