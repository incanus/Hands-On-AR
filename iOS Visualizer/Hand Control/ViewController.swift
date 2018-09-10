import UIKit
import SceneKit
import SwiftSocket

class ViewController: UIViewController {

    @IBOutlet var sceneView: SCNView!

    var hand = Hand()

    func startServer() {
        let server = UDPServer(address: "192.168.1.7", port: 8080)
        DispatchQueue.global(qos: .background).async { [unowned self] in
            repeat {
                let response = server.recv(100)
                let result = String(data: Data(response.0!), encoding: .utf8)!
                let values = result.split(separator: ",")

                var fingers = [UInt]()
                for v in 0...4 {
                    if (Int(values[v])! > 0) {
                        fingers.append(UInt(values[v])!)
                    } else {
                        fingers.append(0)
                    }
                }

                var axes = [UInt]()
                for v in 5...7 {
                    axes.append(UInt(values[v])!)
                }

                DispatchQueue.main.sync { [unowned self] in
                    self.hand.setFingers(fingers)
                    self.hand.setTilt(axes)
                }
            } while true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        startServer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        sceneView.backgroundColor = UIColor.black
        sceneView.allowsCameraControl = true

        sceneView.scene = SCNScene()
        sceneView.scene!.rootNode.addChildNode(hand)
    }

    @IBAction func wiggleFingers() {
        hand.wiggleFingers()
    }

    @IBAction func waveHand() {
        hand.wave()
    }

    @IBAction func makeFist() {
        hand.makeFist()
    }

    func setFingers(_ values: [UInt]) {
        hand.setFingers(values)
    }

    func setTilt(_ values: [UInt]) {
        hand.setTilt(values)
    }

}
