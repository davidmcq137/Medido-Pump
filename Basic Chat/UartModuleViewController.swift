//
//  UartModuleViewController.swift
//  Basic Chat
//
//  Created by Trevor Beaton on 12/4/16.
//  Copyright © 2016 Vanguard Logic LLC. All rights reserved.
//





import UIKit
import CoreBluetooth

class UartModuleViewController: UIViewController, CBPeripheralManagerDelegate {
    
    var FlowRate: GDGaugeView!
    var PressPSI: GDGaugeView!
    
    //MARK: Properties
    
    //UI

    @IBOutlet weak var SliderLabel: UILabel!
    @IBOutlet weak var Slider: UISlider!
    @IBOutlet weak var LeftGauge: UIView!
    @IBOutlet weak var RightGauge: UIView!
    @IBOutlet weak var Empty: UIButton!
    @IBOutlet weak var Off: UIButton!
    @IBOutlet weak var Fill: UIButton!
    @IBOutlet weak var PumpSpeed: UILabel!

    @IBOutlet weak var Clear: UIButton!
    @IBOutlet weak var FlowRateLabel: UILabel!
    @IBOutlet weak var RunningTimeLabel: UILabel!
    
    
    //Data
    var peripheralManager: CBPeripheralManager?
    var peripheral: CBPeripheral!
    //private var consoleAsciiText:NSAttributedString? = NSAttributedString(string: "")
    //var valueArray: [Float] = []
    //var testStr: String = "(1.2,2.3,3.4,4.5)"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View did load")
        
        Empty.layer.borderColor = UIColor.white.cgColor
        Empty.layer.borderWidth = 2
        
        
        let LGRect =  CGRect(x: LeftGauge.center.x - LeftGauge.bounds.width / 2, y: LeftGauge.center.y - LeftGauge.bounds.height / 2, width: LeftGauge.bounds.width, height: LeftGauge.bounds.height)
        let RGRect = CGRect(x: RightGauge.center.x - RightGauge.bounds.width / 2, y:RightGauge.center.y - RightGauge.bounds.height / 2, width: RightGauge.bounds.width, height: RightGauge.bounds.height)
        
        FlowRate = GDGaugeView(frame: LGRect)
        PressPSI = GDGaugeView(frame: RGRect)
        
        let FlowColor =  UIColor(hexString: "#6699ffff")!
        let PressColor = UIColor(hexString: "#ffcc00ff")!
        
        FlowRate.baseColor = FlowColor
        PressPSI.baseColor = PressColor
        
        // Show circle border
        FlowRate.showBorder = true
        PressPSI.showBorder = true
        
        // Show full circle border if .showBorder is set to true
        FlowRate.fullBorder = false
        PressPSI.fullBorder = false
        
        // Set starting degree based on zero degree on bottom center of circle space
        // -> speed.startDegree = 45.0
        
        // Set ending degree based on zero degree on bottom center of circle space
        // -> speed.endDegree = 270.0
        
        // Minimum value
        FlowRate.min = -60.0
        PressPSI.min = 0.0
        
        // Maximum value
        FlowRate.max = 60.0
        PressPSI.max = 10.0
        
        // Determine each step value
        FlowRate.stepValue = 20.0
        PressPSI.stepValue = 2.0
        
        // Color of handle
        FlowRate.handleColor = FlowColor
        PressPSI.handleColor = PressColor
        
        // Color of seprators
        FlowRate.sepratorColor = UIColor.black
        PressPSI.sepratorColor = UIColor.black
        
        // Color of texts
        FlowRate.textColor = FlowColor
        PressPSI.textColor = PressColor
        
        // Center indicator text
        FlowRate.unitText = "oz/s"
        PressPSI.unitText = "psi"
        
        // Center indicator font
        //FlowRate.unitTextFont = UIFont.systemFont(ofSize: 24)
        //PressPSI.unitTextFont = UIFont.systemFont(ofSize: 24)
        
        // Indicators text
        //FlowRate.textFont = UIFont.systemFont(ofSize: 20)
        //PressPSI.textFont = UIFont.systemFont(ofSize: 20)
        
        view.addSubview(FlowRate)
        view.addSubview(PressPSI)
        
        /// After configuring the component, call setupView() method to create the gauge view
        FlowRate.setupView()
        PressPSI.setupView()
        
        
        //Create and start the peripheral manager
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        //-Notification for updating the text view with incoming text
        updateIncomingData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
      //super view did appear goes here?
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // peripheralManager?.stopAdvertising()
        // self.peripheralManager = nil
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        
    }
    
    func updateIncomingData () {
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "Notify"), object: nil , queue: nil){
            notification in
            var cas = characteristicASCIIValue as String

            var nr1 = cas.index(of: "(")
            var nr2 = cas.index(of: ")")

            if nr2 == nil {
                Fragment = cas
                //print("Saving Fragment: \(Fragment)")
                return
            }
            
            if nr1 == nil && Fragment != "" {
                cas = Fragment + cas
                print("Recreating cas: \(cas)")
                Fragment = ""
            }

            nr1 = cas.index(of: "(")
            nr2 = cas.index(of: ")")

            if (nr1 == nil && nr2 == nil) {
                print("Bad value: \(cas)")
                return
            }

            let ss1 = cas.index(cas.startIndex, offsetBy: 1)
            let ss2 = cas.index(cas.endIndex, offsetBy: -1)
            let casInner = cas[ss1..<ss2]
            var valueArray = casInner.components(separatedBy: ":")
            if valueArray.count < 1 {
                return
            }
            let valName = valueArray[0]
            var vf: Double
            if valueArray.count > 1 {
                vf = (valueArray[1] as NSString).doubleValue
            } else {
                vf = 0
            }
            switch valName {
            //case "Sequence":
            //    let modvf = (vf/10).truncatingRemainder(dividingBy: 10)
            //    let modnf = -(modvf*12-60)
            //    self.PressPSI.currentValue = CGFloat(modvf)
            //    self.FlowRate.currentValue = CGFloat(modnf)
            //case "Voltage":
            //    self.PumpSpeed.text = "Pump Speed: \(vf)"
            //case "Pulse":
            //    self.PulseCount.text = "Pulse Count: \(vf)"
            case "rTIM":
                let rtmins = floor(vf / 60.0)
                let rtsecs = vf - rtmins * 60
                let rtf = String(format: "Running Time: %02.0f:%02.0f", rtmins, rtsecs)
                self.RunningTimeLabel.text = rtf
            case "pPSI":
                _ = vf
                //self.PressPSI.currentValue = CGFloat(vf)
            case "pPWM":
                let psf = String(format: "Pump Speed: %.0f %%", 100.0 * vf / 1023.0)
                self.PumpSpeed.text = psf
            case "fCNT":
                let _ = vf
            case "fRAT":
                self.FlowRate.currentValue = CGFloat(vf)
                self.FlowRateLabel.text = "Flow Rate: \(vf)"
            case "volt1":
                print("Voltage: \(vf)")
                self.PressPSI.currentValue = CGFloat(vf*5)
            case "Heap":
                print("heap: \(1000*vf)")
            default:
                print("Bad valName: \(valName)")
            }
        }
    }
    
    //@IBAction func clickSendAction(_ sender: AnyObject) {
    //    outgoingData()
    // }
    
    //func outgoingData () {
    //}
    
    // Write functions
    func writeValue(data: String){
        //print("in wV string: \(data)")
        let valueString = (data as NSString).data(using: String.Encoding.utf8.rawValue)
        //change the "data" to valueString
        if let blePeripheral = blePeripheral{
            if let txCharacteristic = txCharacteristic {
                blePeripheral.writeValue(valueString!, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
            }
        }
    }
    
    func writeCharacteristic(val: Int8){
        var val = val
        let ns = NSData(bytes: &val, length: MemoryLayout<Int8>.size)
        blePeripheral!.writeValue(ns as Data, for: txCharacteristic!, type: CBCharacteristicWriteType.withResponse)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            return
        }
        print("Peripheral manager is running")
    }
    
    //Check when someone subscribe to our characteristic, start sending the data
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("Device subscribe to characteristic")
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("\(error)")
            return
        }
    }
    
    @IBAction func SliderChanged(_ sender: UISlider) {
        let cv = Int(sender.value)
        SliderLabel.text = "Speed(%): \(cv)"
        writeValue(data: "(Speed: \(cv))")
        //print("slider chg", cv)
    }
    
    @IBAction func EmptyPushed(_ sender: Any) {
        print("Empty")
        writeValue(data: "(Empty)")
    }
    @IBAction func OffPushed(_ sender: Any) {
        print("Off")
        writeValue(data: "(Off)")
    }
    @IBAction func FillPushed(_ sender: Any) {
        print("Fill")
        writeValue(data: "(Fill)")
    }
    
    @IBAction func ClearPushed(_ sender: Any) {
        print("Clear")
        writeValue(data: "(Clear)")
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
