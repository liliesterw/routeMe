//
//  MapsViewController.swift
//  skripsiDemo
//
//  Created by IOS on 6/17/17.
//  Copyright © 2017 IOS. All rights reserved.
//

import UIKit
import GoogleMaps
import FirebaseDatabase
class MapsViewController: UIViewController {
    
    var currentDestination: VacationDestination?
    
    class VacationDestination: NSObject {
        
        var name: String
        var location: CLLocationCoordinate2D
        var zoom: Float
        override init()
        {
            self.name = ""
            self.location = CLLocationCoordinate2DMake(37.808, -122.417743)
            self.zoom = 0
        }
        init(name: String, location: CLLocationCoordinate2D, zoom: Float) {
            self.name = name
            self.location = location
            self.zoom = zoom
        }
        
        
    }

    var mapView: GMSMapView?
//    var currentDestination: VacationDestination?
    
   //let destinations = [VacationDestination(name: "Embarcadero Bart Station", location: CLLocationCoordinate2DMake(37.792905, -122.397059), zoom: 14), VacationDestination(name: "Ferry Building", location: CLLocationCoordinate2DMake(37.795434, -122.39473), zoom: 18), VacationDestination(name: "Coit Tower", location: CLLocationCoordinate2DMake(37.802378, -122.405811), zoom: 15), VacationDestination(name: "Fisherman's Wharf", location: CLLocationCoordinate2DMake(37.808, -122.417743), zoom: 15), VacationDestination(name: "Golden Gate Bridge", location: CLLocationCoordinate2DMake(37.807664, -122.475069), zoom: 13)]
    var destination = [VacationDestination]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: "next")
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        validateData()
        //loadData()
        let camera = GMSCameraPosition.camera(withLatitude: -7.257329, longitude: 112.752080, zoom: 12)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        
        let currentLocation = CLLocationCoordinate2DMake(-7.257329, 112.752080)
        //let marker = GMSMarker(position: currentLocation)
        
        //marker.title = "Surabaya City"
        //marker.map = mapView
       // loadData()
        
        
       DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.currentDestination = nil
            self.destination.removeAll()
            self.loadDataFromDB()
        }
    }
    func next() {
        
        if currentDestination?.name == destination.last?.name
        {
          
                let al = UIAlertController(title: "Finish", message: "Trips Finish", preferredStyle: .alert)
                
                let cancel = UIAlertAction(title: "Dismiss", style: .cancel) { (e) in
                    
                    self.tabBarController?.selectedIndex = 0
                }
                al.addAction(cancel)
                self.present(al, animated: true, completion: nil)
            
        }
        if currentDestination == nil {
            currentDestination = destination.first
        }
        else {
            if let index = destination.index(of: currentDestination!), index < destination.count - 1 {
                currentDestination = destination[index + 1]
            }
        }
    
        
        setMapCamera()
    }
    
    fileprivate func setMapCamera() {
        CATransaction.begin()
        CATransaction.setValue(2, forKey: kCATransactionAnimationDuration)
        mapView?.animate(to: GMSCameraPosition.camera(withTarget: currentDestination!.location, zoom: currentDestination!.zoom))
        CATransaction.commit()
        
        let marker = GMSMarker(position: currentDestination!.location)
        marker.title = currentDestination?.name
        marker.map = mapView
    }
    
    func loadDataFromDB()
    {
        Database.database().reference().child("Trips").observe(.childAdded, with: { (DataSnapshot) in
            if let dictionary = DataSnapshot.value as? [String: AnyObject]{
                
                let tripy = VacationDestination()
                guard let long = dictionary["longitude"] else {
                    return
                }
                guard let lati = dictionary["latitude"] else {
                    return
                }
            
                tripy.name = dictionary["destination"] as! String
                tripy.location = CLLocationCoordinate2DMake(lati as! Double, long as! Double)
                tripy.zoom = 15
                self.destination.append(tripy)
                print(tripy.name , tripy.location)
                //print(dictionary)
            }
            
           
        })
    }
    func loadData()
    {
        
        print("111")
        //let adding = "origin=Adelaide,SA.destination=Adelaide,SA.waypoints=optimize:true-Barossa+Valley,SA-Clare,SA-Connawarra,SA-McLaren+Vale,SA"
       
        //let urls = URL(string : stringURL.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)
        
        //let tempoURL = "http://opensource.petra.ac.id/~m26414087/Finder/routes.php?hasil=" + adding
        let tempoURL = "https://maps.googleapis.com/maps/api/directions/json?origin=Adelaide,SA&destination=Adelaide,SA&waypoints=optimize:true\"|Barossa+Valley,SA|Clare,SA|Connawarra,SA|McLaren+Vale,SA&key=AIzaSyCqI-AU7N98CjGnLmHoC25PNw2wEYch0eo"
        print(tempoURL)
        let url = URL(string: tempoURL)
        print("222")
        let session = URLSession.shared
            let dataTask = session.dataTask(with:url!, completionHandler: {(data, response, error) in
                guard let data = data, error == nil else { return }
            do {
                print("333")
                let coba = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                //let coba = try JSONSerialization.jsonObject(with: data, options: .mutableContainers )as! []
                print(coba)
                print("444")
                let jsonData = coba as! [AnyObject]
                //for data in jsonData{
                  print(jsonData)
                let jsonDatas = jsonData as AnyObject
                print("555")
                    if let routes = jsonDatas.object(forKey: "routes") as? NSDictionary{
                        for route in routes{
                            print(route)
 //                           let copyright = route["copyrights"] as String
                            //print(copyright)
                        }
                    }
                //}
                print("SDDDDD")
                print (jsonData)

            } catch {
                
            }
        })
        dataTask.resume()
        
    }
    func validateData() {
        var is_start:Bool = false
        var is_end:Bool = false
       
        
        let ref = Database.database().reference()
        ref.child("Trips").observe(.childAdded, with: { (DataSnapshot) in
            if let dictionary = DataSnapshot.value as? [String: AnyObject]{
                guard let isStart = dictionary["is_start"] else {
                    return
                }
                guard let isEnd = dictionary["is_end"] else {
                    return
                }
                
                let tempoIsStart = isStart as! String
                let tempoIsEnd = isEnd as! String
                
                if tempoIsStart.caseInsensitiveCompare("true") == .orderedSame
                {
                    //print("is_start set")
                    is_start = true
                }
                if tempoIsEnd  == "true"
                {
                    //print("is_end set")
                    is_end = true
                }
            }
            //print ("\(is_start) , \(is_end)")
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
           
            if (is_start == false || is_end == false )
            {
                //print("here")
                let al = UIAlertController(title: "Error", message: "Please choose the Start and/or End Point first!", preferredStyle: .alert)
                
                let cancel = UIAlertAction(title: "Dismiss", style: .cancel) { (e) in
                    
                    self.tabBarController?.selectedIndex = 0
                }
                al.addAction(cancel)
                self.present(al, animated: true, completion: nil)
            }
        }
        
        
        
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
