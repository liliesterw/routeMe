//
//  ViewController.swift
//  skripsiDemo
//
//  Created by IOS on 5/22/17.
//  Copyright © 2017 IOS. All rights reserved.
//

import UIKit
import FirebaseDatabase
import UserNotifications
class ViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    var tripsArray = [TripData]()
    @IBOutlet weak var tripsTable: UITableView!
   
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.tripsArray.removeAll()
            self.fetchUser()
        }
    }
  override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
    
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { (granted, error) in
            if granted {
                print("Notification access granted")
            } else {
                print(error?.localizedDescription ?? "")
            }
            })

    
       }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if(editingStyle == UITableViewCellEditingStyle.delete){
            
            print(tripsArray[indexPath.row].destination)
            let dataDel = tripsArray[indexPath.row].destination
            let ref = Database.database().reference()
            var snapKey = ""
            ref.child("Trips").observe(.childAdded, with: { (DataSnapshot) in
                if let dictionary = DataSnapshot.value as? [String: AnyObject]{
                    
                    let tempo = dictionary["destination"] as! String
                    
                    //print(DataSnapshot.key)
                    if tempo  == dataDel
                    {
                        
                        //print("SAMA")
                        snapKey = DataSnapshot.key
                        ref.child("Trips").child(snapKey).removeValue()
                    }
                }
            })
            
            tripsArray.remove(at: indexPath.row)
            
            tripsTable.deleteRows(at: [indexPath], with: .fade)
            

        }else{
            print(editingStyle)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func removeData(_ sender: Any) {
        print("removed")
        tripsArray.removeAll()
        fetchUser()
        
    }
    @IBAction func notif_clicked(_ sender: Any) {
        //notification will appear 5 seconds after button is clicked and app is closed:
        scheduleNotification(inSeconds: 5, completion: { success in
            if success {
                print("Successfully scheduled notification")
            } else {
                print("Error scheduling notification")
            }
        })
    }
    func scheduleNotification(inSeconds: TimeInterval, completion: @escaping (_ Success: Bool) -> ()) {
        let myImage = "DfQqM" 			// first add this image to the project folder, e.g.:  gambar.gif
        guard let imageUrl = Bundle.main.url(forResource: myImage, withExtension: "gif") else {
            completion(false)
            return
        }
        var attachment: UNNotificationAttachment
        attachment = try! UNNotificationAttachment(identifier: "myNotification", url: imageUrl, options: .none)

        let notif = UNMutableNotificationContent()
        notif.title = "New Notification"
        notif.subtitle = "These are great!"
        notif.body = "The new notification options in iOS 10 are what I've always dreamed of!"
        notif.attachments = [attachment]
        notif.categoryIdentifier = "myNotificationCategory"

        let notifTrigger = UNTimeIntervalNotificationTrigger(timeInterval: inSeconds, repeats: false)
        let request = UNNotificationRequest(identifier: "myNotification", content: notif, trigger: notifTrigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            if error != nil {
                print(error ?? "")
                completion(false)
            } else {
                completion(true)
            }
        })
    }
     func fetchUser()
    {
        Database.database().reference().child("Trips").observe(.childAdded, with: { (DataSnapshot) in
            if let dictionary = DataSnapshot.value as? [String: AnyObject]{
                
                let tripy = TripData()
                guard let long = dictionary["longitude"] else {
                    return
                }
                guard let lati = dictionary["latitude"] else {
                    return
                }
                guard let urut = dictionary["urutan"] else {
                    return
                }
                tripy.destination = dictionary["destination"] as! String
                tripy.longitude = long as! Double
                tripy.latitude = lati  as! Double
                tripy.is_start = dictionary["is_start"] as! String
                tripy.is_end = dictionary["is_end"] as! String
                tripy.urutan = urut as! Int
               self.tripsArray.append(tripy)
                
                //print(dictionary)
            }
           
            if self.tripsArray.count > 0 {
                DispatchQueue.main.async{
                    //print(self.tripsArray.count)
                    guard let tripsTable = self.tripsTable else{
                        return
                    }
                    tripsTable.reloadData()
                }
            }
        }
        )
       
        
        
      
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tripsArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        if let cell = tripsTable.dequeueReusableCell(withIdentifier: "myCell") as? TripsTableViewCell
        {
            cell.layer.borderWidth = 0.1
            cell.layer.borderColor = UIColor.yellow.cgColor
            cell.tripsTitle.text = tripsArray[indexPath.row].destination
            cell.tripsKey.text = "\(tripsArray[indexPath.row].longitude),\(tripsArray[indexPath.row].latitude)"
            if(tripsArray[indexPath.row].is_start == "true")
            {
                cell.tripsImage.image = #imageLiteral(resourceName: "start")
            }
            else if(tripsArray[indexPath.row].is_end == "true")
            {
                cell.tripsImage.image = #imageLiteral(resourceName: "end")
            }
            else {
                
                cell.tripsImage.image = #imageLiteral(resourceName: "default_location")
                
            }
            return cell
        }
        else
        {
        return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let more = UITableViewRowAction(style: .normal, title: "Start") { action, index in
            //print("Start button tapped")
           DispatchQueue.main.async{
            let dataDel = self.tripsArray[editActionsForRowAt.row].destination
            let ref = Database.database().reference()
            var snapKey = ""
            ref.child("Trips").observe(.childAdded, with: { (DataSnapshot) in
                if let dictionary = DataSnapshot.value as? [String: AnyObject]{
                    guard let long = dictionary["longitude"] else {
                        return
                    }
                    guard let lati = dictionary["latitude"] else {
                        return
                    }
                    guard let urut = dictionary["urutan"] else {
                        return
                    }
                    let tempoDicti = dictionary["destination"] as! String
                     let tempoLongi = long
                     let tempoLati = lati
                     let tempoUrutan = urut
                    let tempoIsEnd = dictionary["is_end"] as! String
                    var post = ["destination" : "" ] as [String: Any]
                    
                    if tempoDicti  == dataDel
                    {
                        
                             print("C : \(editActionsForRowAt.row)")
                        snapKey = DataSnapshot.key
                         post = ["destination": tempoDicti , "is_end": "false",                                     "is_start" : "true",
                                     "latitude" : tempoLati,
                                     "longitude" : tempoLongi ,                                  "urutan" : tempoUrutan
                        ] as [String : Any]
                        
                    }
                    else {
                        if( tempoIsEnd == "true")
                        {
                        print("NC : \(editActionsForRowAt.row)")
                        snapKey = DataSnapshot.key
                         post = ["destination": tempoDicti, "is_end": "true",                                     "is_start" : "false",
                                    "latitude" : tempoLati,
                                    "longitude" : tempoLongi ,                                  "urutan" : tempoUrutan
                            ] as [String : Any]
                       
                    }
                        else
                        {
                            print("NC : \(editActionsForRowAt.row)")
                            snapKey = DataSnapshot.key
                            post = ["destination": tempoDicti, "is_end": "false",                                     "is_start" : "false",
                                    "latitude" : tempoLati,
                                    "longitude" : tempoLongi ,                                  "urutan" : tempoUrutan
                                ] as [String : Any]
                            
                        }
                    }
                    ref.child("Trips").child(snapKey).updateChildValues(post)
                }
                
            })
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.tripsArray.removeAll()
            self.fetchUser()
            }
            }
        more.backgroundColor = UIColor(red: 194/255, green: 192/255, blue: 199/255, alpha: 1)
        
        let favorite = UITableViewRowAction(style: .normal, title: "End") { action, index in
            //print("favorite button tapped")
            
            let dataDel = self.tripsArray[editActionsForRowAt.row].destination
            let ref = Database.database().reference()
            var snapKey = ""
            ref.child("Trips").observe(.childAdded, with: { (DataSnapshot) in
                if let dictionary = DataSnapshot.value as? [String: AnyObject]{
                    
                    guard let long = dictionary["longitude"] else {
                        return
                    }
                    guard let lat = dictionary["latitude"] else {
                        return
                    }
                    guard let ur = dictionary["urutan"] else {
                        return
                    }
                    let tempoDicti = dictionary["destination"] as! String
                    let tempoLongi = long
                    let tempoLati = lat
                    let tempoUrutan = ur
                    let tempoIsStart = dictionary["is_start"] as! String
                    var post = ["destination" : "" ] as [String: Any]
                    
                    
                    if tempoDicti  == dataDel
                    {
                        
                        print("C : \(editActionsForRowAt.row)")
                        snapKey = DataSnapshot.key
                        post = ["destination": tempoDicti , "is_end": "true",                                     "is_start" : "false",
                                "latitude" : tempoLati,
                                "longitude" : tempoLongi ,                                  "urutan" : tempoUrutan
                            ] as [String : Any]
                        
                    }
                    else {
                        if( tempoIsStart == "true")
                        {
                        print("NC : \(editActionsForRowAt.row)")
                        snapKey = DataSnapshot.key
                        post = ["destination": tempoDicti, "is_end": "false",                                     "is_start" : "true",
                                "latitude" : tempoLati,
                                "longitude" : tempoLongi ,                                  "urutan" : tempoUrutan
                            ] as [String : Any]
                    }
                        else {
                                print("NC : \(editActionsForRowAt.row)")
                                snapKey = DataSnapshot.key
                                post = ["destination": tempoDicti, "is_end": "false",                                     "is_start" : "false",
                                        "latitude" : tempoLati,
                                        "longitude" : tempoLongi ,                                  "urutan" : tempoUrutan
                                    ] as [String : Any]
                            
                        }
                    }
                    ref.child("Trips").child(snapKey).updateChildValues(post)
                
                }
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.tripsArray.removeAll()
                self.fetchUser()
            }
            
        }
        favorite.backgroundColor = UIColor(red: 251/255, green: 139/255, blue: 3/255, alpha: 1)
        
        let share = UITableViewRowAction(style: .normal, title: "Remove") { action, index in
            print(self.tripsArray[editActionsForRowAt.row].destination)
            let dataDel = self.tripsArray[editActionsForRowAt.row].destination
            let ref = Database.database().reference()
            var snapKey = ""
            ref.child("Trips").observe(.childAdded, with: { (DataSnapshot) in
                if let dictionary = DataSnapshot.value as? [String: AnyObject]{
                    
                    let tempo = dictionary["destination"] as! String
                    
                    //print(DataSnapshot.key)
                    if tempo  == dataDel
                    {
                        
                        //print("SAMA")
                        snapKey = DataSnapshot.key
                        ref.child("Trips").child(snapKey).removeValue()
                    }
                    
                    
                }
            })
            
    
            self.tripsArray.remove(at: editActionsForRowAt.row)
            
            self.tripsTable.deleteRows(at: [editActionsForRowAt], with: .fade)
            
        }
        share.backgroundColor = UIColor(red: 249/255, green: 51/255, blue: 44/255, alpha: 1)
        print(tripsArray[ editActionsForRowAt.row].destination)
        return [share, favorite, more]
    }
} //end of class ViewController

