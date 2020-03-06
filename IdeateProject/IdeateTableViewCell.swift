// TableViewCell.swift
//  IdeateProject
//
//  Created by Gianluca Dubioso on 06/03/2020.
//  Copyright © 2020 Gianluca. All rights reserved.
//
import UIKit

protocol IdeateCellDelegate {
    func didRequestDelete(_ cell:IdeateTableViewCell)
    func didRequestComplete(_ cell:IdeateTableViewCell)
    func didRequestShare(_ cell:IdeateTableViewCell)
}

class IdeateTableViewCell: UITableViewCell {

    var delegate:IdeateCellDelegate?
    
    @IBOutlet weak var IdeateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func deleteIdeate(_ sender: Any) {
        if let delegateObject = self.delegate {
            delegateObject.didRequestDelete(self)
        }
    }
    
    @IBAction func shareIdeate(_ sender: Any) {
        if let delegateObject = self.delegate {
            delegateObject.didRequestShare(self)
        }
    }
    @IBAction func completeIdeate(_ sender: Any) {
        if let delegateObject = self.delegate {
            delegateObject.didRequestComplete(self)
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
