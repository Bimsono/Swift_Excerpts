//
//  WhiteBoardView.swift
//  Kidush
//
//  Created by IPaT user on 7/28/16.
//  Copyright © 2016 Abimbola Olajubutu. All rights reserved.
//

import UIKit
import MobileCoreServices

class WhiteBoardView: UIImageView, UIAlertViewDelegate {
    var studentKidushID: String!
    var tutorKidushID:   String!
    
    @IBOutlet weak var theViewController: UIViewController!

    @IBOutlet weak var insertImage: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    @IBOutlet weak var whiteBoardOn: UIButton!
    
    var lastImage: UIImage?
    var red: CGFloat!
    var green: CGFloat!
    var blue: CGFloat!
    var uiColor: UIColor!
    
    var eraseButtonTouched = false
    var brushWidth: CGFloat = 4.0;
    
    var polylines: [Polyline] = []
    var currentPolyline: Polyline!
    var updatedPolyline: Polyline!
    var firstPoint: CGPoint!
    var liveQuery: CBLLiveQuery!
    
    private var imagePicker: UIImagePickerController!

    override init(frame: CGRect){
        super.init(frame: frame)
        super.opaque = false
        super.userInteractionEnabled = true
        //TODO: Do I need to add components to my subView?
        
//        red = CGFloat(0.0)
//        green = CGFloat(0.0)
//        blue = CGFloat(0.0)
        
        uiColor = UIColor( red: red , green: green, blue: blue, alpha: alpha);
        
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        liveQuery = appDelegate!.kDatabase!.createAllDocumentsQuery().asLiveQuery()
        liveQuery.addObserver(self, forKeyPath: "rows", options: NSKeyValueObservingOptions.New, context: nil)
        
        if let error = try? liveQuery.run() {
            print(error)
        }
        
        //Picture live query set up
        print("init: pic alert created")
        
        studentKidushID = "studenttest"
        tutorKidushID = "tutortest"
        
    }
    
    //Used by Storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        super.opaque = false
        super.userInteractionEnabled = true
        //TODO: Do I need to add components to my subView?
        
        red = CGFloat(0.0)
        green = CGFloat(0.0)
        blue = CGFloat(0.0)
        //iPressedClear = false
        
        uiColor = UIColor( red: red , green: green, blue: blue, alpha: alpha);
        
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        liveQuery = appDelegate!.kDatabase!.createAllDocumentsQuery().asLiveQuery()
        liveQuery.addObserver(self, forKeyPath: "rows", options: NSKeyValueObservingOptions.New, context: nil)
        
        if let error = try? liveQuery.run() {
            print(error)
        }
        
        //Picture live query set up
        print("init?: pic alert created")
        
        studentKidushID = "studenttest"
        tutorKidushID = "tutortest"
    }//END init?
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     */
    override func drawRect(rect: CGRect) {
        // Drawing code
        super.drawRect(rect)
    }
    
    /******************************BEGIN Action Methods****************************************************************/
    @IBAction func eraseButtonTouched(sender: AnyObject)
    {
        eraseButtonTouched = !eraseButtonTouched
        if( eraseButtonTouched ){
            print("Erase touched")
            //Set here in case background is just whiteboard
            red   = CGFloat(1.0)
            green = CGFloat(1.0)
            blue  = CGFloat(1.0)
            brushWidth = CGFloat(4)
        }
        else if !eraseButtonTouched {
            print("Erase not touched")
            red = CGFloat(redSlider.value)
            green = CGFloat(greenSlider.value)
            blue  = CGFloat(blueSlider.value)
            brushWidth = CGFloat(4)
        }
        //If eraseButtonTouched and image isn't nill we'll be erasing x,y points
        uiColor = UIColor(red: red, green: green, blue: blue, alpha:1)
    }

    @IBAction func turnOnWhiteBoard(sender: AnyObject){
        image = nil
        lastImage = nil
        //concurdraw
    }
    
    @IBAction func clearButtonTouched(sender: AnyObject)
    {
        //iPressedClear = !iPressedClear
        for polyline in polylines{
            //TODO write try catch
            if let error = try? polyline.deleteDocument() {
                print(error)
            }
        }
        polylines = []
        if lastImage != nil{
            image = lastImage
        }else{
            image = nil
        }
        var alertView: UIAlertView = UIAlertView()
        //alertView.sho
    }
    
    @IBAction func saveButtonTouched(sender: AnyObject)
    {
        print("save button touched")
        //uploadImage(anImage: image!)
    }
    
    @IBAction func insertImageTouched(sender: AnyObject)
    {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        // let alert: UIAlertView = UIAlertView()
        //alert.title =  "Choose option"
        //alert.message = "Pic from library or Take photo"
        //let library = alert.addButtonWithTitle("Library")
        //let takephoto = alert.addButtonWithTitle("Take Photo")
        //alert.delegate = self
        //alert.show()
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera){
            imagePicker.sourceType = .Camera
        }else{
            imagePicker.sourceType = .PhotoLibrary //action sheet
        }
        
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(imagePicker.sourceType)!
        
        theViewController.presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIdx buttonIdx: Int){
        let buttonTitle = alertView.buttonTitleAtIndex(buttonIdx)
        if buttonTitle == "Library"{
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            
            imagePicker.sourceType = .PhotoLibrary
            
            imagePicker.allowsEditing = true
            imagePicker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(imagePicker.sourceType)!
            
            theViewController.presentViewController(imagePicker, animated: true, completion: nil)
        }
        else if buttonTitle == "Take Photo"{
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            
            imagePicker.sourceType = .PhotoLibrary
            
            imagePicker.allowsEditing = true
            imagePicker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(imagePicker.sourceType)!
            
            theViewController.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func redSliderChanged(sender: AnyObject)
    {
        red = CGFloat(redSlider.value)
        print("red slider changed: \(red)")
    }
    
    @IBAction func greenSlider(sender: AnyObject)
    {
        green = CGFloat(greenSlider.value)
        print("green slider changed: \(green)")
    }
    
    @IBAction func blueSlider(sender: AnyObject)
    {
        blue = CGFloat(blueSlider.value)
        print("blue slider changed: \(blue)")
    }
    /******************************END Action Methods****************************************************************/

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        print("touchesBegan")
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        firstPoint = touches.first!.locationInView(self)
        
        //print("Erased button not pressed")
        
        currentPolyline = Polyline(forNewDocumentInDatabase: appDelegate!.kDatabase!)
        
        currentPolyline.points.append(["x" : firstPoint.x, "y" : firstPoint.y])
        
        print("polyline red value: \(red)")
        currentPolyline.red = red
        print("polyline green value: \(green)")
        currentPolyline.green = green
        print("polyline blue value: \(blue)")
        currentPolyline.blue  = blue
        currentPolyline.alpha = 1.0
        currentPolyline.erased = false
        currentPolyline.brushwidth = brushWidth
        
        //If touched then block above is white. Below we want to make sure KVO doesn't redraw it, so implicitly takes it away
        //Below, We also want to the the points array of where the white was drawn over to remove those drawn over points so KVO doesnt draw them
        
        
        //Erase button pressed code handles setting brush width
        print("polyline my brush width value: \(brushWidth)")
        //currentPolyline.brushwidth  = brushWidth
    }//END touchesBegan

    //Appends many points to Polyline points
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("Touches touchesMoved")
        let point = touches.first!.locationInView(self)
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        
        //EraseButtonTouched sets red, green, blue all to 1 so white will happen
        
        currentPolyline.points.append(["x" : point.x, "y" : point.y])
        
        print("polyline red value: \(red)")
        currentPolyline.red = red
        print("polyline green value: \(green)")
        currentPolyline.green = green
        print("polyline blue value: \(blue)")
        currentPolyline.blue  = blue
        currentPolyline.alpha = 1
        currentPolyline.brushwidth = brushWidth
        
        uiColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
        draw(uiColor, start: firstPoint!, end: point, brushWidth: brushWidth, alpha: 1)
        
        print("polyline my brush width value: \(brushWidth)")
        currentPolyline.brushwidth  = brushWidth
        firstPoint = point
        
    }//END touchesMoved
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //Sanity mark, this is for drawing not picture taken
        currentPolyline.pictureSent = false
        if let error = try? currentPolyline.save() {
            print(error)
        }
        
        //enable slider once finished drawing
        print("touches ended")
    }

    //TODO: in combination with concurDraw... must preserve other user's color here and brushwidth
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String:AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if (object as! CBLLiveQuery) == liveQuery {
            polylines.removeAll(keepCapacity: false)
            
            if( liveQuery.rows!.allObjects.count == 0){
                print("Observe value for key path: clear detected")
                for polyline in polylines{
                    if let error = try? polyline.deleteDocument() {
                        print(error)
                    }
                }
                polylines = []
                if lastImage != nil{
                    image = lastImage
                }else{
                    image = nil
                }
                
                return
            }
            else if( liveQuery.rows!.allObjects.count == 1 ){
                for (index, row) in liveQuery.rows!.allObjects.enumerate() {
                    let thePolyline = Polyline(forDocument: (row as! CBLQueryRow).document!)
                    if thePolyline.pictureSent == false && thePolyline.points.isEmpty{
                        print("Observe value for key path: deleted previous picture")
                        
                        if let error = try? thePolyline.deleteDocument() {
                            print(error)
                        }
                    }
                }
                return
            }
            
            
            //liveQuery.rows!.allObjects.enumerate().
            for (index, row) in liveQuery.rows!.allObjects.enumerate() {
                let thePolyline = Polyline(forDocument: (row as! CBLQueryRow).document!)
                
                if !thePolyline.points.isEmpty {
                    print("Observed value for key path changed: Drawings")
                    polylines.append(thePolyline)
                    
                    
                    print("first point: X: \(thePolyline.points.first!["x"])    Y: \(thePolyline.points.first!["y"])")
                    print("last  point: X: \(thePolyline.points.last!["x"])     Y: \(thePolyline.points.last!["y"])")
                    
                    //let otherBrushWidth = thePolyline.brushwidth
                    concurDrawPolylines(brushWidth)
                }
                else if thePolyline.pictureSent{
                    print("Observed value for key path changed: Picture")
                    
                    concurPicReplicate(thePolyline)//It deletes polyline
                    return
                }
                else if (thePolyline.points.isEmpty && thePolyline.pictureSent == false){
                    
                    if let error = try? thePolyline.deleteDocument() {
                        print(error)
                    }
                }
                
                print("in-loop")
                
            }//END for loop
            print("out-loop")
            print()
            
            //get our side's color back
            uiColor = UIColor(red: red, green: green, blue: blue, alpha:1)
        }
    }//END observableValue For Key Path
    
    //Made some optimizations
    func draw(uicolor: UIColor, start: CGPoint, end: CGPoint, brushWidth: CGFloat, alpha: CGFloat){
        print("inside of draw method")
        uiColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        print("uicolor: \(uicolor)")
        
        UIGraphicsBeginImageContext(bounds.size)
        image?.drawInRect(bounds)
        //whiteBoardView.image?.drawInRect(whiteBoardView.bounds)
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, brushWidth)
        CGContextSetStrokeColorWithColor(context, uiColor.CGColor)
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, start.x, start.y)
        CGContextAddLineToPoint(context, end.x, end.y)
        CGContextStrokePath(context)
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    //TODO: Here is where color needs to be preserved and brush width
    func concurDrawPolylines(otherBrushWidth: CGFloat) {
        //drawImageView.image = nil
        print("inside concurDrawPolylines")
        
        UIGraphicsBeginImageContext(bounds.size)
        image?.drawInRect(bounds)
        
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, otherBrushWidth)
        CGContextBeginPath(context)
        
        //E/c polyline's set of points represents a line drawn
        for polyline in polylines {
            //Our uiColor is set to other person's in session
            if let firstPoint = polyline.points.first {
                CGContextMoveToPoint(UIGraphicsGetCurrentContext(), firstPoint["x"]!, firstPoint["y"]!)
                
                print("A line from: X: \(firstPoint["x"]!)   Y: \(firstPoint["y"]!)")
                print("to         : X: \(polyline.points.last!["x"])   Y: \(polyline.points.last!["y"]) ")
                print("red: \(polyline.red)   green: \(polyline.green)   blue: \(polyline.blue) alpha: \(polyline.alpha)")
                
                uiColor = UIColor(red: polyline.red, green: polyline.green, blue: polyline.blue, alpha: polyline.alpha)
            }
            CGContextSetStrokeColorWithColor(context, uiColor.CGColor)
            
            for point in polyline.points {
                CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), point["x"]!, point["y"]!)
            }
            CGContextStrokePath(UIGraphicsGetCurrentContext())
        }
        print("uicolor of other is: \(uiColor)")
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        print()
    }
    
    
    //Read picture from other user and set as our image here
    func concurPicReplicate(polyline: Polyline)
    {
        //for (index, row) in picLiveQuery.rows!.allObjects.enumerate() {
        print("concurPicReplicate: loop ran")
        
        //let aPicObj = PictureAlerts(forDocument: (row as! CBLQueryRow).document!)
        //if(aPicObj.pictureSent == "true"){
        if(polyline.pictureSent){
            print("Picture sent is true")
            print("Document ID: \(polyline.document!.documentID ) ")
            
            let rev = polyline.document?.currentRevision
            let att = rev?.attachmentNamed("picture")
            
            if att != nil {
                print("Content about to set to image: \(att!.content!.description) ")
                image = UIImage(data: att!.content!)
                print("image: \(image?.description)")
                lastImage = image
            }
            //Now that we've gotten it...
            polyline.pictureSent = false
            
        }
        
    }//END concurPicReplicate

    func uploadImage(anImage pic: UIImage){
        
        if (image == nil){
            print("image nil")
            return
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string:"http://173.236.249.59:5005/upload")!)
        let session = NSURLSession.sharedSession()
        let param = ["file": "var/www/html/pictures/"]
        
        request.HTTPMethod = "POST";
        
        //let boundary = NSString(format: "---------------------------14737809831466499882746641449")
        let boundary = "Boundary-\(NSUUID().UUIDString)"
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        //let contentType = NSString(format: "multipart/form-data; boundary=%@",boundary)
        
        //  println("Content Type \(contentType)")
        //request.addValue(contentType as String, forHTTPHeaderField: "Content-Type")
        //request.setValue(contentType as String, forHTTPHeaderField: "Content-Type")
        
        let imageData = UIImageJPEGRepresentation(pic, 0.75)
        let body = NSMutableData()
        
        //createBodyWithParameters: request.HTTPBody = ...
        let filename = studentKidushID
        let mimetype = "image/jpg"
        
        
        
        // Title
        
        
        //body.appendData(NSString(format: "\r\n--%@\r\n",boundary).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        body.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        
        //body.appendData(NSString(format:"Content-Disposition: form-data; name=\"\(studentKidushID)\"\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        let filePathKey = "file"
        body.appendData("Content-Disposition: form-data; name=\"\(filePathKey)\"; filename=\"\(filename)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        body.appendData("Content-Type: \(mimetype)\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        body.appendData(imageData!)
        body.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        body.appendData("--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        //body.appendData("KIDUSH".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        
        
        
        // Image
        //        body.appendData(NSString(format: "\r\n--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        //        //TODO: Change to /var/www/...
        //        //let filename = studentKidushID
        //        let key = "file"
        //        body.appendData(NSString(format:"Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(filename)\"\r\n").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        //
        //        //body.appendData(NSString(format: "Content-Type: application/octet-stream\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        //        body.appendData(NSString(format: "Content-Type: \(mimetype)\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        //        body.appendData(imageData!)
        //        body.appendData(NSString(format: "\r\n--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        
        
        
        request.HTTPBody = body
        print("about to upload ")
        
        //        session.uploadTaskWithRequest(request, fromData: body, completionHandler:
        //            {
        //                (data,response,error) in guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
        //                        print("error")
        //                        return
        //                    }
        //                    print("response")
        ////                        if let httpResponse = response as? NSHTTPURLResponse {
        ////                            print("httpResponse")
        ////                            if httpResponse.statusCode == 200 {
        ////                                print("Success talking to server!")
        ////                            }
        ////                        }
        //                    if error != nil {
        //                        print("error=\(error)")
        //                        return
        //                    }
        //                    print("Inside dataTaskWithRequest")
        //                    print("******* response = \(response)")
        //                    let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
        //                    print("****** response data = \(responseString!)")
        //
        //                    let json: AnyObject?
        //                    do{
        //                         json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)  as? NSDictionary
        //
        //                    }catch{
        //                        print("JSON serialization error")
        //                    }
        //        });
        
        //guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
        session.dataTaskWithRequest(request)
        {(data,response,error) in
            if error != nil {
                print("error=\(error)")
                return
            }
            //                        if let httpResponse = response as? NSHTTPURLResponse {
            //                            print("httpResponse")
            //                            if httpResponse.statusCode == 200 {
            //                                print("Success talking to server!")
            //                            }
            //                        }
            
            print("Inside dataTaskWithRequest")
            print("******* response = \(response)")
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("****** response data = \(responseString!)")
            
            let json: AnyObject?
            do{
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)  as? NSDictionary
                
            }catch{
                print("JSON serialization error")
            }
        }
    }//END uploadImage

    
}//END WhiteBoardView
    
    //Captures lastImage var here
    extension WhiteBoardView : UIImagePickerControllerDelegate, UINavigationControllerDelegate
    {
        func imagePickerControllerDidCancel(picker: UIImagePickerController) {
            
            theViewController.dismissViewControllerAnimated(true, completion: nil)
            print("user cancelled the camera / photo library")
        }
        
        func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
        {
            let mediaType = info[UIImagePickerControllerMediaType] as! String
            
            if mediaType == (kUTTypeImage as String) {
                print("Inside media delegate")
                //a photo is taken
                image = info[UIImagePickerControllerOriginalImage] as? UIImage
                print("image: \(image?.description)")
                
                lastImage = image
                
                //print("Image picker delegate: Document ID: \(picAlert.document?.documentID)")
                
                //Attach photo blob ID to PictureAlert object, put to database
                let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
                let database = appDelegate!.kDatabase!
                
                
                currentPolyline = Polyline(forNewDocumentInDatabase: database)
                currentPolyline.pictureSent = true
                currentPolyline.attachmentName = "picture"
                
                print("Document ID: \(currentPolyline.document!.documentID ) ")
                if let error = try? currentPolyline.save() {
                    print(error)
                }
                
                let picDocRevision = currentPolyline.document!.currentRevision!.createRevision()
                let imageData = UIImageJPEGRepresentation(image!, 0.75)
                picDocRevision.setAttachmentNamed("picture", withContentType: "image/jpeg", content: imageData)
                if let error = try? picDocRevision.save() {
                    print(error)
                }
                
                
            }else{
                // a video was shot
            }
            
            theViewController.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    


