//
//  addDestinationControllerViewController.swift
//  skripsiDemo
//
//  Created by IOS on 6/12/17.
//  Copyright © 2017 IOS. All rights reserved.
//

import UIKit
import FirebaseDatabase

class addDestinationControllerViewController: UIViewController {

    @IBOutlet weak var detailDestination: UITextField!
    @IBOutlet weak var textDestination: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addDest(_ sender: Any) {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref = ref.child("Trips").childByAutoId()
        let dest = textDestination.text
        ref.child("destination").setValue(dest)
        
    
        //ref.child("Babi Guling/Nama").setValue("awowo")
        

    }

}
