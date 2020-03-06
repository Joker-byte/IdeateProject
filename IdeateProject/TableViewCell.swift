
import UIKit

protocol CellDelegate {
    func didRequestDelete(_ cell:TableViewCell)
    func didRequestComplete(_ cell:TableViewCell)
    func didRequestShare(_ cell:TableViewCell)
}

class TableViewCell: UITableViewCell {

    var delegte: CellDelegate?
    
    @IBOutlet weak var todoLabel: UILabel!
    
    @IBOutlet weak var delete: UIButton!
    
    @IBOutlet weak var Share: UIButton!
    
    @IBOutlet weak var Complete: UIButton!
    
    override func awakeFromNib() {
        todoLabel.layer.cornerRadius = 8.0
        delete.layer.cornerRadius = 8.0
        Share.layer.cornerRadius = 8.0
        Complete.layer.cornerRadius = 8.0
       
        
        
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func deleteTodo(_ sender: Any) {
        if let delegateObject = self.delegte {
            delegateObject.didRequestDelete(self)
        }
    }
    
    @IBAction func shareToDo(_ sender: Any) {
       
        if let delegateObject = self.delegte {
            delegateObject.didRequestShare(self)
        }
    }
    @IBAction func completeTodo(_ sender: Any) {
        if let delegateObject = self.delegte {
            delegateObject.didRequestComplete(self)
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
