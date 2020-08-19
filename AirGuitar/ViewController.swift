
import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    var guitarString: GuitarString!
    
    var rotationRate: CMRotationRate?
    var prevX = 0
    var currX = 0
    var roll: UInt8 = 0
    let motionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guitarString = GuitarString()
        updateDeviceMotions()
        let stringOneQueue = DispatchQueue(label: "stringOneListener")
        let stringTwoQueue = DispatchQueue(label: "stringTwoListener")
        let stringThreeQueue = DispatchQueue(label: "stringThreeListener")
        let stringFourQueue = DispatchQueue(label: "stringFourListener")
        let stringFiveQueue = DispatchQueue(label: "stringFiveListener")
        let stringSixQueue = DispatchQueue(label: "stringSixListener")
        stringOneQueue.async(execute: stringListener(guitarStringNumber: .one))
        stringTwoQueue.async(execute: stringListener(guitarStringNumber: .two))
        stringThreeQueue.async(execute: stringListener(guitarStringNumber: .three))
        stringFourQueue.async(execute: stringListener(guitarStringNumber: .four))
        stringFiveQueue.async(execute: stringListener(guitarStringNumber: .five))
        stringSixQueue.async(execute: stringListener(guitarStringNumber: .six))
    }
    
    func stringListener(guitarStringNumber: GuitarStringNumber) -> (()->Void) {
        var noteAngle = 0
        switch guitarStringNumber {
            case .one:
                noteAngle = 25
            case .two:
                noteAngle = 15
            case .three:
                noteAngle = 5
            case .four:
                noteAngle = -5
            case .five:
                noteAngle = -15
            case .six:
                noteAngle = -25
        }
        return({ [unowned self] in
            var playNote = true
            while motionManager.isDeviceMotionActive {
                usleep(10000)
                var start = prevX
                var end = currX
                if prevX > currX {
                    start = currX
                    end = prevX
                }
                if (!playNote && start != noteAngle && end != noteAngle) {
                    playNote = true
                }
                if (start <= noteAngle && noteAngle <= end) {
                    if playNote {
                        playGuitarString(guitarStringNumber: guitarStringNumber, velocity: roll)
                        playNote = false
                    }
                }
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func playGuitarString(guitarStringNumber: GuitarStringNumber, velocity: UInt8) {
        var note: UInt8 = 0
        switch(guitarStringNumber) {
            case .one:
                note = 40
            case .two:
                note = 47
            case .three:
                note = 52
            case .four:
                note = 56
            case .five:
                note = 59
            case .six:
                note = 64
        }
        guitarString.play(note: note, velocity: velocity)
    }

    func degrees(radians:Double) -> Double {
        return 180 / .pi * radians
    }
    
    func checkDeviceMotion(motionData: CMDeviceMotion) {
        let acceleration = motionData.gravity
        let rotationRate = motionData.rotationRate
        prevX = currX
        currX = Int(degrees(radians: (acceleration.x)))
        let temp = abs(rotationRate.y) * 255 / .pi 
        roll = UInt8(temp > 255 ? 255 : temp)
    }
    
    func updateDeviceMotions() {
        motionManager.deviceMotionUpdateInterval = 0.01 //  Change to whatever suits your app - milli-seconds
        motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {
            (data, error) -> Void in
            if(error == nil) {
                self.checkDeviceMotion(motionData: data!)
            } else {
                print("error in motion manager")
            }
        })
    }
}

enum GuitarStringNumber {
    case one, two, three, four, five, six
}
