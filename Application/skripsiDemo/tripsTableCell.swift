//
//  tripsTableCell.swift
//  skripsiDemo
//
//  Created by IOS on 6/13/17.
//  Copyright © 2017 IOS. All rights reserved.
//

import UIKit

class tripsTableCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var titleText: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
func numberOfSections(in tableView: UITableView) -> Int {
    return 1
}
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
}
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    tableView.reloadData()
    if let cell = tableView.dequeueReusableCell(withIdentifier: "myCell") as? UITableViewCell
    {
        
        return cell
    }
    else return UITableViewCell()
}
