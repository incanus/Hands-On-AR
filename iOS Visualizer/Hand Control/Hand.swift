import UIKit
import SceneKit

class Hand: SCNNode {

    private let calibratedPositions = SCNVector3(32, 16, 22)
    private let maxPosition = 50

    private var lastFingerRotationX: [CGFloat] = [0, 0, 0, 0, 0]
    private var lastHandRotation = SCNVector3(0, 0, 0)
    private var lastPosition = SCNVector3(0, 0, 0)

    override init() {
        super.init()

        self.name = "hand"
        self.opacity = 0.75

        let colorMaterial = SCNMaterial()
        colorMaterial.diffuse.contents = UIColor.blue
        let darkMaterial = SCNMaterial()
        darkMaterial.diffuse.contents = UIColor.darkGray

        let palm = SCNTube(innerRadius: 0.35, outerRadius: 0.5, height: 0.1)
        palm.materials = [darkMaterial, darkMaterial, colorMaterial, colorMaterial]

        let palmNode = SCNNode(geometry: palm)
        palmNode.name = "palm"
        palmNode.position = SCNVector3(0, 0, 0)
        palmNode.transform = SCNMatrix4MakeRotation(.pi / 2, 1, 0, 0)
        self.addChildNode(palmNode)

        let ls: [CGFloat] = [0.6, 0.75, 0.65, 0.5]
        let rs: [Float] = [.pi / 6, .pi / 11, -.pi / 11, -.pi / 6, .pi / 3]
        let xs: [Float] = [-0.35, -0.1, 0.1, 0.35, -0.35]
        let ys: [Float] = [0.35, 0.5, 0.5, 0.35, 0]

        for f in 1...4 {
            let finger = SCNCylinder(radius: 0.1, height: ls[f - 1])
            finger.materials = [colorMaterial, darkMaterial, darkMaterial]

            let fingerNode = SCNNode(geometry: finger)
            fingerNode.name = "finger.\(f)"
            fingerNode.position = SCNVector3(0, 0, 0)
            fingerNode.pivot = SCNMatrix4MakeTranslation(0, -0.5, 0)
            fingerNode.transform = SCNMatrix4MakeRotation(rs[f - 1], 0, 0, 1)
            fingerNode.transform = SCNMatrix4Translate(fingerNode.transform, xs[f - 1], ys[f - 1], 0)
            self.addChildNode(fingerNode)
        }

        let thumb = SCNCylinder(radius: 0.1, height: 0.4)
        thumb.materials = [colorMaterial, darkMaterial, darkMaterial]

        let thumbNode = SCNNode(geometry: thumb)
        thumbNode.name = "finger.0"
        thumbNode.position = SCNVector3(0, 0, 0)
        thumbNode.pivot = SCNMatrix4MakeTranslation(0, -0.5, 0)
        thumbNode.transform = SCNMatrix4MakeRotation(rs[4], 0, 0, 1)
        thumbNode.transform = SCNMatrix4Translate(thumbNode.transform, xs[4], ys[4], 0)
        self.addChildNode(thumbNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func wiggleFingers() {
        for f in 0...4 {
            if let finger = self.childNode(withName: "finger.\(f)", recursively: true) {
                let bend = SCNAction.rotateBy(x: -.pi / 3, y: 0, z: 0, duration: 0.25)
                let wait = SCNAction.wait(duration: TimeInterval(f) * 0.25)
                let sequence = SCNAction.sequence([wait, bend, bend.reversed()])
                sequence.timingMode = .easeInEaseOut
                finger.runAction(sequence)
            }
        }
    }

    func wave() {
        let moveLeft = SCNAction.moveBy(x: -0.25, y: 0, z: 0, duration: 0.1)
        let moveRight = SCNAction.moveBy(x: 0.25, y: 0, z: 0, duration: 0.1)
        let rotateLeft = SCNAction.rotateBy(x: 0, y: 0, z: .pi / 10, duration: 0.1)
        let rotateRight = SCNAction.rotateBy(x: 0, y: 0, z: -.pi / 10, duration: 0.1)
        let left = SCNAction.group([moveLeft, rotateLeft])
        let right = SCNAction.group([moveRight, rotateRight])
        let reset = SCNAction.group([SCNAction.move(to: SCNVector3(0, 0, 0), duration: 0.1),
                                     SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.1)])
        let wave = SCNAction.sequence([left, reset, right, reset])
        self.runAction(SCNAction.repeat(wave, count: 3))
    }

    func makeFist() {
        for f in 0...4 {
            if let finger = self.childNode(withName: "finger.\(f)", recursively: true) {
                let fist = SCNAction.rotateBy(x: -.pi * 0.6, y: 0, z: 0, duration: 0.25)
                let wait = SCNAction.wait(duration: 1)
                let sequence = SCNAction.sequence([fist, wait, fist.reversed()])
                sequence.timingMode = .easeInEaseOut
                finger.runAction(sequence)
            }
        }
    }

    func setFingers(_ values: [UInt]) {
        for f in 0...4 {
            if let finger = self.childNode(withName: "finger.\(f)", recursively: true) {
                finger.runAction(SCNAction.rotateBy(x: -lastFingerRotationX[f], y: 0, z: 0, duration: 0))
                let factor = CGFloat(Float(values[f]) / 10 * -.pi * 0.6)
                finger.runAction(SCNAction.rotateBy(x: factor, y: 0, z: 0, duration: 0))
                lastFingerRotationX[f] = factor
            }
        }
    }

    func setTilt(_ values: [UInt]) {
        self.runAction(SCNAction.rotateBy(x: CGFloat(-lastHandRotation.x),
                                          y: CGFloat(-lastHandRotation.y),
                                          z: CGFloat(-lastHandRotation.z),
                                          duration: 0))
        let xFactor = (CGFloat(Float(values[0]) - 180) / 360) * 2 * -.pi
        let yFactor = (CGFloat(Float(values[1]) - 180) / 360) * 2 * -.pi
        let zFactor = CGFloat(0)
        self.runAction(SCNAction.rotateBy(x: xFactor, y: yFactor, z: zFactor, duration: 0))
        lastHandRotation = SCNVector3(xFactor, yFactor, zFactor)
    }

    func setPosition(_ values: [UInt]) {
        self.runAction(SCNAction.moveBy(x: Int(lastPosition.x) != maxPosition ? CGFloat(-lastPosition.x) : 0,
                                        y: Int(lastPosition.y) != maxPosition ? CGFloat(-lastPosition.y) : 0,
                                        z: Int(lastPosition.z) != maxPosition ? CGFloat(-lastPosition.z) : 0,
                                        duration: 0))
        let x = Int(calibratedPositions.x) - Int(values[0])
        let y = Int(calibratedPositions.y) - Int(values[1])
        let z = Int(calibratedPositions.z) - Int(values[2])
        let xp = CGFloat((Float(x) / calibratedPositions.x) * -0.5)
        let yp = CGFloat((Float(y) / calibratedPositions.y) *  0.5)
        let zp = CGFloat((Float(z) / calibratedPositions.z) * -0.5)
        self.runAction(SCNAction.moveBy(x: xp, y: yp, z: zp, duration: 0))
        lastPosition = SCNVector3(xp, yp, zp)
    }

}
