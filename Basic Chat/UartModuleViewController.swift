//
//  UartModuleViewController.swift
//  Basic Chat
//
//  Created by Trevor Beaton on 12/4/16.
//  Copyright © 2016 Vanguard Logic LLC. All rights reserved.
//





import UIKit
import CoreBluetooth

class UartModuleViewController: UIViewController, CBPeripheralManagerDelegate, UITextViewDelegate, UITextFieldDelegate {
    //MARK: Properties
    
    
    @IBOutlet weak var SliderLabel: UILabel!
    
    @IBOutlet weak var Slider: UISlider!
    
   
    
    //UI
    @IBOutlet weak var baseTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var switchUI: UISwitch!
    @IBOutlet weak var Empty: UIButton!
    @IBOutlet weak var Off: UIButton!
    @IBOutlet weak var Fill: UIButton!
    @IBOutlet weak var PumpSpeed: UILabel!
    
    //Data
    var peripheralManager: CBPeripheralManager?
    var peripheral: CBPeripheral!
    private var consoleAsciiText:NSAttributedString? = NSAttributedString(string: "")
    var valueArray: [Float] = []
    var testStr: String = "(1.2,2.3,3.4,4.5)"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"Back", style:.plain, target:nil, action:nil)
        self.baseTextView.delegate = self
        self.inputTextField.delegate = self
        //Base text view setup
        self.baseTextView.layer.borderWidth = 3.0
        self.baseTextView.layer.borderColor = UIColor.blue.cgColor
        self.baseTextView.layer.cornerRadius = 3.0
        self.baseTextView.text = ""
        //Input Text Field setup
        self.inputTextField.layer.borderWidth = 2.0
        self.inputTextField.layer.borderColor = UIColor.blue.cgColor
        self.inputTextField.layer.cornerRadius = 3.0
        //Create and start the peripheral manager
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        //-Notification for updating the text view with incoming text
        updateIncomingData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.baseTextView.text = ""
        
        
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
            //let appendString = "\n"
            //let myFont = UIFont(name: "Helvetica Neue", size: 15.0)
            //let myAttributes2 = [NSFontAttributeName: myFont!, NSForegroundColorAttributeName: UIColor.red]
            //let attribString = NSAttributedString(string: "[Incoming]: " + (characteristicASCIIValue as String) + appendString, attributes: myAttributes2)
            //let newAsciiText = NSMutableAttributedString(attributedString: self.consoleAsciiText!)
            //self.baseTextView.attributedText = NSAttributedString(string: characteristicASCIIValue as String , attributes: myAttributes2)
            
            //newAsciiText.append(attribString)
            
            //self.consoleAsciiText = newAsciiText
            //self.baseTextView.attributedText = self.consoleAsciiText
            
            //struct med: Codable {
              //  var namea:String
                //var vala:Float
                //var nameb:String
                //var valb:Float
            //}
            
            //let jdec = JSONDecoder()
            //let cavS = characteristicASCIIValue as String
            //let decval = jdec.decode(med.self, from: cavS)
            
            //print(decval.a, decval.b)
            //let vf:Float = decval.a
            
            var valueArray = characteristicASCIIValue.components(separatedBy: ",")
            //print("ValArray: \(valueArray[0])")
            let vf:Float = (valueArray[0] as NSString).floatValue
            //for va in valueArray {
              //  print("\(va)")
            //}
            
            //print("vf: \(vf)")
            
            //vf = vf + 100.0
            //print("vf: \(vf)")
            
            //let s = NSString(format: "%f", vf)
            //print("calling wV with: \(self.testStr)")
            //.self.writeValue(data: self.testStr as String)
            self.PumpSpeed.text = "Pump Speed: \(vf)"
        }
    }
    
    @IBAction func clickSendAction(_ sender: AnyObject) {
        outgoingData()
        
    }
    
    
    
    func outgoingData () {
        let appendString = "\n"
        
        let inputText = inputTextField.text
        //let foo = valueArray[0]
        //let inputText = "this is a test of the emergency...";
        let myFont = UIFont(name: "Helvetica Neue", size: 15.0)
        let myAttributes1 = [NSFontAttributeName: myFont!, NSForegroundColorAttributeName: UIColor.blue]
        
        //writeValue(data: "100.123")
        writeValue(data: inputText!)
        
        let attribString = NSAttributedString(string: "[Outgoing]: " + inputText! + appendString, attributes: myAttributes1)
        let newAsciiText = NSMutableAttributedString(attributedString: self.consoleAsciiText!)
        newAsciiText.append(attribString)
        
        consoleAsciiText = newAsciiText
        baseTextView.attributedText = consoleAsciiText
        //erase what's in the text field
        inputTextField.text = ""
        
    }
    
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
    
    
    
    //MARK: UITextViewDelegate methods
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView === baseTextView {
            //tapping on consoleview dismisses keyboard
            inputTextField.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x:0, y:250), animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x:0, y:0), animated: true)
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
    
    //This on/off switch sends a value of 1 and 0 to the Arduino
    //This can be used as a switch or any thing you'd like
    @IBAction func switchAction(_ sender: Any) {
        if switchUI.isOn {
            print("On ")
            writeCharacteristic(val: 1)
        }
        else
        {
            print("Off")
            writeCharacteristic(val: 0)
            print(writeCharacteristic)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        outgoingData()
        return(true)
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
        writeValue(data: "(Slider: \(cv))")
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
}

