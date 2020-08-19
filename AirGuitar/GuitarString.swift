
import Foundation
import AVFoundation

class GuitarString {
    
    var engine: AVAudioEngine!
    
    var sampler: AVAudioUnitSampler!
    
    init() {
        
        engine = AVAudioEngine()
        
        sampler = AVAudioUnitSampler()
        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)
        
        loadSF2PresetIntoSampler(25)
        
        addObservers()
        
        startEngine()
        
        setSessionPlayback()
    }
    
    deinit {
        removeObservers()
    }
    
    
    func play(note: UInt8, velocity: UInt8) {
        sampler.startNote(note, withVelocity: velocity, onChannel: 0)
    }
    
    func loadSF2PresetIntoSampler(_ preset: UInt8) {
        guard let bankURL = Bundle.main.url(forResource: "FluidR3 GM2-2", withExtension: "SF2") else {
            print("could not load sound font")
            return
        }
        
        do {
            try self.sampler.loadSoundBankInstrument(at: bankURL,
                                                     program: preset,
                                                     bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                                                     bankLSB: 0)
        } catch {
            print("error loading sound bank instrument")
        }
        
    }
    
    // might be better to do this in the app delegate
    func setSessionPlayback() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try
                audioSession.setCategory(AVAudioSession.Category.playback, mode: .default, options: [])
        } catch {
            print("couldn't set category \(error)")
            return
        }
        
        do {
            try audioSession.setActive(true)
        } catch {
            print("couldn't set category active \(error)")
            return
        }
    }
    
    func startEngine() {
        
        if engine.isRunning {
            print("audio engine already started")
            return
        }
        
        do {
            try engine.start()
            print("audio engine started")
        } catch {
            print("oops \(error)")
            print("could not start audio engine")
        }
    }
    
    // MARK: - Notifications
    
    func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(GuitarString.engineConfigurationChange(_:)),
                                               name: NSNotification.Name.AVAudioEngineConfigurationChange,
                                               object: engine)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(GuitarString.sessionInterrupted(_:)),
                                               name: AVAudioSession.interruptionNotification,
                                               object: engine)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(GuitarString.sessionRouteChange(_:)),
                                               name: AVAudioSession.routeChangeNotification,
                                               object: engine)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.AVAudioEngineConfigurationChange,
                                                  object: nil)
        
        NotificationCenter.default.removeObserver(self,
                                                  name: AVAudioSession.interruptionNotification,
                                                  object: nil)
        
        NotificationCenter.default.removeObserver(self,
                                                  name: AVAudioSession.routeChangeNotification,
                                                  object: nil)
    }
    
    
    // MARK: notification callbacks
    
    @objc
    func engineConfigurationChange(_ notification: Notification) {
        print("engineConfigurationChange")
    }
    
    @objc
    func sessionInterrupted(_ notification: Notification) {
        print("audio session interrupted")
        if let engine = notification.object as? AVAudioEngine {
            engine.stop()
        }
        
        if let userInfo = notification.userInfo as? [String: Any?] {
            if let reason = userInfo[AVAudioSessionInterruptionTypeKey] as? AVAudioSession.InterruptionType {
                switch reason {
                case .began:
                    print("began")
                case .ended:
                    print("ended")
                default:
                    print("default")
                }
            }
        }
    }
    
    @objc
    func sessionRouteChange(_ notification: Notification) {
        print("sessionRouteChange")
        if let engine = notification.object as? AVAudioEngine {
            engine.stop()
        }
        
        if let userInfo = notification.userInfo as? [String: Any?] {
            
            if let reason = userInfo[AVAudioSessionRouteChangeReasonKey] as? AVAudioSession.RouteChangeReason {
                
                print("audio session route change reason \(reason)")
                
                switch reason {
                case .categoryChange: print("CategoryChange")
                case .newDeviceAvailable:print("NewDeviceAvailable")
                case .noSuitableRouteForCategory:print("NoSuitableRouteForCategory")
                case .oldDeviceUnavailable:print("OldDeviceUnavailable")
                case .override: print("Override")
                case .wakeFromSleep:print("WakeFromSleep")
                case .unknown:print("Unknown")
                case .routeConfigurationChange:print("RouteConfigurationChange")
                default: print("default")
                }
            }
            
            if let previous = userInfo[AVAudioSessionRouteChangePreviousRouteKey] {
                print("audio session route change previous \(String(describing: previous))")
            }
        }
    }
    
}
