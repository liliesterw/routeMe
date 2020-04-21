//
//  File.swift
//  skripsiDemo
//
//  Created by IOS on 6/14/17.
//  Copyright © 2017 IOS. All rights reserved.
//

import Foundation
class TripData
{
    var latitude:Double = 0 , destination="", longitude:Double = 0, is_start="false" ,is_end="false", urutan:Int = 0
    init()
    {
        self.latitude = 0;
        self.longitude = 0;
        self.destination = "";
        self.urutan = 0;
        
    }
    init(longitude:Double, latitude:Double ,destination:String,is_start:String,is_end:String, urutan:Int)
    {
        self.latitude = latitude;
        self.longitude = longitude;
        self.destination = destination;
        self.urutan = urutan;
        self.is_start = is_start;
        self.is_end = is_end;
        
    }
    
}
