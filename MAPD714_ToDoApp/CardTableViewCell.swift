//
//  CardTableViewCell.swift
//  MAPD714_ToDoApp
//
// Personalized cell for ViewController table view.
// Contains images and labels to show the different categories.
// Used in ViewController.
//

import UIKit

class CardTableViewCell: UITableViewCell {
    
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var categoryImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}
