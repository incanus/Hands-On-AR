import UIKit
import SceneKit
import SwiftSocket

class ViewController: UIViewController {

    @IBOutlet private var sceneView: SCNView!

    private var server: UDPServer!
    private var hand: Hand!

    override func viewDidLoad() {
        super.viewDidLoad()

        server = UDPServer(address: "192.168.1.7", port: 8080)
        setupServerHandling()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        sceneView.backgroundColor = UIColor.black
        sceneView.allowsCameraControl = true

        hand = Hand()

        sceneView.scene = SCNScene()
        sceneView.scene!.rootNode.addChildNode(hand)
    }

    private func setupServerHandling() {
        DispatchQueue.global(qos: .background).async { [unowned self] in
            repeat {
                let response = self.server.recv(100)
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

    @IBAction private func wiggleFingers() {
        hand.wiggleFingers()
    }

    @IBAction private func waveHand() {
        hand.wave()
    }

    @IBAction private func makeFist() {
        hand.makeFist()
    }

    private func setFingers(_ values: [UInt]) {
        hand.setFingers(values)
    }

    private func setTilt(_ values: [UInt]) {
        hand.setTilt(values)
    }

}
