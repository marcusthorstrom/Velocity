//
//  ViewController.swift
//  Velocity
//
//  Created by Marcus Thorstrom on 2015-05-15.
//  Copyright (c) 2015 Marcus Thorstrom. All rights reserved.
//

import UIKit
import iAd
import CoreLocation



class ViewController: UIViewController, CLLocationManagerDelegate, UIGestureRecognizerDelegate{
	
	let userBGSwitch = "USERBGSWITCH";
	
	var locationManager = CLLocationManager();
	var label = UILabel();
	var maxLabel = UILabel();
	var speed:CGFloat = 0.0;
	var speedLabel: String = "";
	var maxSpeed:CGFloat = 0.0;
	var maxSpeedLabel: String = "";
	var resetButton = UIButton();
	var warning = UILabel();
	var maxText = UILabel();
	var bgUpdateSwitch = UISwitch();
	var bgUpdateSwitchLabel = UILabel();
	var bgUpdates = false;
	
	
	//Strings
	
	var kilometers = NSLocalizedString("KILOMETERS", comment: "km/h");
	var meters = NSLocalizedString("METERS", comment: "m/s");
	var miles = NSLocalizedString("MILES", comment: "mph");
	var knots = NSLocalizedString("KNOTS", comment: "knots");
	var bgUpdatesString = NSLocalizedString("BGUPDATES", comment: "Stop background updates");
	var max = NSLocalizedString("MAX", comment: "Max");
	var reset = NSLocalizedString("RESET", comment: "Reset");
	var badSignal = NSLocalizedString("badSignal", comment: "The gps signal is weak, try turning of wifi");
	
	
	//Strings
	
	var speedToShow:DisplaySpeed = DisplaySpeed.Kilometers;
	
	
	enum DisplaySpeed{
		case Kilometers
		case Knots
		case Miles
		case Meters
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated);
		updateLabels();
		
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let defaults = NSUserDefaults.standardUserDefaults();
		bgUpdateSwitch.setOn(defaults.boolForKey(userBGSwitch), animated: true);
		
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "backgroundMode", name: UIApplicationDidEnterBackgroundNotification, object: nil);
		
		NSNotificationCenter.defaultCenter().addObserver(self,
			selector: "activeMode",
			name: UIApplicationDidBecomeActiveNotification,
			object: nil)
		
		
		//		//Add first-open-view
		//var firstVeiw = UIView(frame: self.view.frame);
		//self.view.addSubview(firstVeiw);
		//firstVeiw.backgroundColor = UIColor.blackColor();
		
		
		//ClLocation
		locationManager.requestWhenInUseAuthorization();
		locationManager.delegate = self;
		locationManager.startUpdatingLocation();
		locationManager.startUpdatingHeading();
		locationManager.desiredAccuracy = 1.0;
		//locationManager.pausesLocationUpdatesAutomatically = true;
		
		//Touch Gestures
		
		
		
		var gestures = UITapGestureRecognizer(target: self, action: "screenTapped");
		gestures.numberOfTapsRequired = 1;
		self.view .addGestureRecognizer(gestures);
		
		//Banner View
		
		
		
		self.view.addSubview(label);
		self.view.addSubview(maxText);
		self.view.addSubview(maxLabel);
		self.view.addSubview(resetButton);
		self.view.addSubview(warning);
		self.view.addSubview(bgUpdateSwitch);
		self.view.addSubview(bgUpdateSwitchLabel);
		
		updateViews();
		updateLabels();
	}
	
	override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
		updateViews();
	}
	
	
	/*
	func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
		NSLog("Speed: %d", CGFloat(newLocation.speed))
		updateSpeed( CGFloat(manager.location!.speed));
		
	}
*/
	
	func updateSpeed(var newSpeed: CGFloat){
		if(newSpeed < 0 ){
			//This means the gps is to inacurate it gets the speed from wifi or just a bad signal
			warning.text = badSignal;
			newSpeed = 0;
			updateViews();
		}else {
			warning.text = "";
			
		}
		
		if(speed > maxSpeed){
			maxSpeed = speed;
		}
		
		if(newSpeed != speed){
			speed = newSpeed;
		}
		updateLabels();
	}
	
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		
		for location in locations{
			if let newLocation = location as? CLLocation {
				NSLog("Speed from list: \( CGFloat(newLocation.speed))")
				updateSpeed(CGFloat(newLocation.speed));

			}
		}
		
	}
	
	
	
	func updateViews() {
		
		//Warning text
		warning.frame = CGRectZero;
		warning.numberOfLines = 0;
		warning.textColor = rgb(231, green: 76, blue: 60);
		warning.shadowColor = UIColor.blackColor();
		warning.shadowOffset = CGSizeMake(1, 1);
		
		warning.sizeToFit();
		warning.center.x = (self.view.frame.size.width / 2);
		warning.center.y = (self.view.frame.size.height * 0.2);
		
		//Switch + label
		bgUpdateSwitch.frame = CGRectZero;
		bgUpdateSwitch.frame.origin.x = self.view.frame.origin.x + 20;
		bgUpdateSwitch.frame.origin.y = self.view.frame.origin.y + 20;
		
		bgUpdateSwitch.addTarget(self, action: "bgSwitch", forControlEvents: UIControlEvents.TouchUpInside);
		
		bgUpdateSwitchLabel.frame = CGRectZero;
		bgUpdateSwitchLabel.text = bgUpdatesString
		bgUpdateSwitchLabel.numberOfLines = 0;
		bgUpdateSwitchLabel.sizeToFit();
		
		bgUpdateSwitchLabel.center.y = bgUpdateSwitch.center.y
		bgUpdateSwitchLabel.frame.origin.x = bgUpdateSwitch.frame.origin.x + bgUpdateSwitch.frame.size.width + 10;
		
		
		//Current Speed
		let labelWidth:CGFloat = self.view.frame.size.width*0.8;
		let labelHeight:CGFloat = self.view.frame.size.height*0.11;
		
		
		
		label.frame =  CGRectMake(self.view.frame.size.width/2-(labelWidth/2), self.view.frame.size.height/3 - (labelHeight/2), labelWidth, labelHeight);
		
		label.text = speedLabel;
		label.textAlignment = NSTextAlignment.Center;
		label.font = UIFont.boldSystemFontOfSize(labelHeight*0.7);
		
		
		//Max speed
		let maxLabelWidth:CGFloat = labelWidth*0.8;
		let maxLabelHeight:CGFloat = labelHeight*0.7;
		
		maxLabel.frame = CGRectMake(self.view.frame.size.width/2-(maxLabelWidth/2), (self.view.frame.size.height/2) - (maxLabelHeight/2), maxLabelWidth, maxLabelHeight);
		
		maxLabel.textAlignment = NSTextAlignment.Center;
		maxLabel.font = UIFont.boldSystemFontOfSize(maxLabelHeight*0.7);
		
		
		//Max text
		let maxTextHeight:CGFloat = maxLabelHeight*0.7;
		let maxTextWidth:CGFloat = maxLabelWidth;
		
		maxText.frame = CGRectMake((self.view.frame.size.width/2) - (maxTextWidth/2), maxLabel.frame.origin.y - maxTextHeight, maxTextWidth, maxTextHeight);
		
		maxText.text =  max + ":";
		
		maxText.font = UIFont.boldSystemFontOfSize(maxTextHeight*0.9);
		maxText.textAlignment = NSTextAlignment.Center;
		
		
		
		//Reset button
		var buttonWidth = labelWidth;
		var buttonHeight = labelHeight;
		
		if(buttonHeight > 60){
			buttonHeight = 60;
		}
		if(buttonWidth > 300){
			buttonWidth = 300;
		}
		
		resetButton.frame = CGRectMake(self.view.frame.size.width/2-(buttonWidth/2), (self.view.frame.size.height/3)*2 - (buttonHeight/2), buttonWidth, buttonHeight);
		resetButton.setTitle(reset, forState: UIControlState.Normal);
		
		resetButton.addTarget(self, action: "resetButtonAction", forControlEvents: UIControlEvents.TouchUpInside);
		resetButton.layer.cornerRadius = 10;
		resetButton.layer.borderWidth = 1;
		resetButton.layer.borderColor = UIColor.blackColor().CGColor;
		
		resetButton.addTarget(self, action: "resetButtonHoldDown", forControlEvents: UIControlEvents.TouchDown);
		resetButton.addTarget(self, action: "resetButtonLetGo", forControlEvents: UIControlEvents.TouchUpInside);
		resetButton.addTarget(self, action: "resetButtonLetGo", forControlEvents: UIControlEvents.TouchUpOutside);
	}
	
	func resetButtonAction(){
		maxSpeed = 0.0;
		updateLabels();
	}
	func resetButtonHoldDown() {
		resetButton.backgroundColor = UIColor.whiteColor();
		resetButton.alpha = 0.7;
		resetButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal);
	}
	func resetButtonLetGo() {
		resetButton.backgroundColor = UIColor.clearColor();
		resetButton.alpha = 1.0;
		resetButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal);
	}
	
	func bgSwitch() {
		let defaults = NSUserDefaults.standardUserDefaults();
		defaults.setBool(bgUpdateSwitch.on, forKey: userBGSwitch);
		//defaults.synchronize();
		
		//If set to true
		if(bgUpdateSwitch.on){
			if (self.locationManager.respondsToSelector("requestAlwaysAuthorization")){
				self.locationManager.requestAlwaysAuthorization()
			}
			bgUpdates = true;
		}
		//If set to false
		else {
			bgUpdates = false;
		}
	}
	
	func updateLabels() {
		
		switch speedToShow {
			
		case .Kilometers:
			speedLabel = "\(Int(round(speed*3.6))) " + kilometers;
			maxSpeedLabel = "\(Int(round(maxSpeed*3.6))) " + kilometers;
			self.view.backgroundColor = rgb(75, green: 119, blue: 190);
		case .Knots:
			speedLabel = "\(Int(round(speed*0.514))) " + knots;
			maxSpeedLabel = "\(Int(round(maxSpeed*0.514))) " + knots;
			self.view.backgroundColor = rgb(78,green: 205,blue: 196);
			
		case .Meters:
			speedLabel = "\(Int(round(speed))) " + meters;
			maxSpeedLabel = "\(Int(round(maxSpeed))) " + meters;
			self.view.backgroundColor = rgb(92, green: 151, blue: 191);
			
		case .Miles:
			speedLabel = "\(Int(round(speed*2.2369362920544))) " + miles;
			maxSpeedLabel = "\(Int(round(maxSpeed*2.2369362920544))) " + miles;
			self.view.backgroundColor = rgb(3, green: 201, blue: 169);
			
		}
		
		label.text = speedLabel;
		maxLabel.text = maxSpeedLabel;
	}
	
	
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func screenTapped(){
		
		switch speedToShow {
		case .Kilometers:
			speedToShow = DisplaySpeed.Meters;
		case .Meters:
			speedToShow = DisplaySpeed.Miles;
		case .Miles:
			speedToShow = DisplaySpeed.Knots;
		case .Knots:
			speedToShow = DisplaySpeed.Kilometers;
		}
		
		updateLabels();
		
	}
	
	func backgroundMode(){
		//When the BGUpdates are switched of
		if(!bgUpdates) {
			//Then disable location tracking
			locationManager.stopUpdatingLocation()
			locationManager.stopUpdatingHeading();
			NSLog("Locaton manager stopped");
		}
		
		
	}
	func activeMode() {
		if(!bgUpdates){
			locationManager.startUpdatingLocation();
			locationManager.startUpdatingHeading();
			NSLog("Location Manager started");
		}
	}
	
}




func rgba(red: Float, green:Float, blue:Float, alpha:Float) -> UIColor{
	return UIColor(red:CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: CGFloat(alpha));
}
func rgb(red: Float, green:Float, blue:Float) -> UIColor{
	return rgba(red, green: green, blue: blue, alpha: 1.0);
}

