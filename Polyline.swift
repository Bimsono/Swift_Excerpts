//
//  Polyline.swift
//  Whiteboard_bim
//
//  Created by Olajubutu, Abimbola O on 7/5/16.
//  Copyright © 2016 BimOla. All rights reserved.
//

import Foundation
import UIKit

class Polyline: CBLModel {
    @NSManaged var points: [[String: CGFloat]]
    @NSManaged var red:    CGFloat
    @NSManaged var green:  CGFloat
    @NSManaged var blue:   CGFloat
    @NSManaged var alpha:  CGFloat
    @NSManaged var erased: Bool
    @NSManaged var brushwidth: CGFloat
    
    //Picture alerts
    @NSManaged var attachmentName: String
    @NSManaged var pictureSent:  Bool
    
    class func polylineInDatabase(database: CBLDatabase, withPoints points: [[String:CGFloat]], _ red: CGFloat,_ green: CGFloat,
                                  _ blue: CGFloat, _ alpha: CGFloat, _ erased: Bool, _ brush: CGFloat) -> Polyline {
        //let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
        
        let polyline = Polyline(forNewDocumentInDatabase: database)
        polyline.points = points
        polyline.red = red
        polyline.green = green
        polyline.blue = blue
        polyline.alpha = alpha
        polyline.erased = erased
        polyline.brushwidth = brush
        
        return polyline
    }
}