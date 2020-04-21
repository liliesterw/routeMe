//
//  GoogleMapsViewController.swift
//  skripsiDemo
//
//  Created by IOS on 6/15/17.
//  Copyright © 2017 IOS. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Firebase
import CoreLocation

class GoogleMapsViewController: UIViewController , UISearchBarDelegate,LocateOnTheMap, GMSAutocompleteFetcherDelegate, GMSMapViewDelegate {
    public func didFailAutocompleteWithError(_ error: Error) {
        //        resultText?.text = error.localizedDescription
    }
    
    public func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        //self.resultsArray.count + 1
        
        for prediction in predictions {
            
            if let prediction = prediction as GMSAutocompletePrediction!{
                self.resultsArray.append(prediction.attributedFullText.string)
            }
        }
        self.searchResultController.reloadDataWithArray(self.resultsArray)
        //   self.searchResultsTable.reloadDataWithArray(self.resultsArray)
        print(resultsArray)
    }
    @IBOutlet weak var googleMapsContainer: UIView!
    
    var googleMapsView: GMSMapView!
    var searchResultController: SearchResultsController!
    var gmsFetcher: GMSAutocompleteFetcher!
    
    
    var resultsArray = [String]()
    var hasilTrip:String = ""
    var hasilTripLat:Double = 0
    var hasilTripLon:Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        
        self.googleMapsView = GMSMapView(frame: self.googleMapsContainer.frame)
        self.view.addSubview(googleMapsView)
    
        searchResultController = SearchResultsController()
        searchResultController.delegate = self
        
        gmsFetcher = GMSAutocompleteFetcher()
        gmsFetcher.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        print("PINDAH : \(marker.position.latitude)")
    }
//    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
//        print("You tapped : \(coordinate.latitude)/\(coordinate.longitude)")
//    let infoMarker = GMSMarker()
//        infoMarker.snippet = "coba"
//        infoMarker.position = coordinate
//        infoMarker.infoWindowAnchor.y = 1
//        infoMarker.map = mapView
//        mapView.selectedMarker = infoMarker
//    }
    func locateWithLongitude(_ lon: Double, andLatitude lat:Double, andTitle title:String)
    {
        
        DispatchQueue.main.async(execute: {
            let position = CLLocationCoordinate2DMake(lat,lon)
            let marker = GMSMarker(position: position)
            
            let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 15)
            self.googleMapsView.camera = camera
            
            marker.title = "Address : \(title)"
//            marker.isDraggable = true
//            marker.appearAnimation = KGMSMarkerAnimaionPop
            
            self.hasilTrip = title
            self.hasilTripLon = lon
            self.hasilTripLat = lat
            marker.map = self.googleMapsView
        })
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        //        let placeClient = GMSPlacesClient()
        //
        //
        //        placeClient.autocompleteQuery(searchText, bounds: nil, filter: nil)  {(results, error: Error?) -> Void in
        //           // NSError myerr = Error;
        //            print("Error @%",Error.self)
        //
        //            self.resultsArray.removeAll()
        //            if results == nil {
        //                return
        //            }
        //
        //            for result in results! {
        //                if let result = result as? GMSAutocompletePrediction {
        //                    self.resultsArray.append(result.attributedFullText.string)
        //                }
        //            }
        //
        //            self.searchResultController.reloadDataWithArray(self.resultsArray)
        //
        //        }
        
        
        self.resultsArray.removeAll()
        gmsFetcher?.sourceTextHasChanged(searchText)
        
        
    }
    @IBAction func addingTheData(_ sender: Any) {
        if(hasilTrip == "")
        {
            print("data kosong")
            let al = UIAlertController(title: "Error", message: "Please choose the location first", preferredStyle: .alert)
            
            let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
      
            al.addAction(cancel)
            self.present(al, animated: true, completion: nil)
        }
        else {
            var ref: DatabaseReference!
            ref = Database.database().reference()
            ref = ref.child("Trips").childByAutoId()
            let dest = hasilTrip
            ref.child("destination").setValue(dest)
            ref.child("latitude").setValue(hasilTripLat)
            ref.child("longitude").setValue(hasilTripLon)
            ref.child("is_start").setValue("false")
            ref.child("is_end").setValue("false")
            ref.child("urutan").setValue(0)
            performSegueToReturnBack()
        }
    }
    @IBAction func searchWithAddress(_ sender: Any) {
        let searchController = UISearchController(searchResultsController: searchResultController)
        searchController.searchBar.delegate = self
        self.present(searchController, animated:true, completion : nil)
    }
    
}
extension UIViewController {
    func performSegueToReturnBack(){
        if let nav = self.navigationController{
            nav.popViewController(animated:true)
        }else {
            self.dismiss(animated:true, completion:nil)
        }
    }
}

