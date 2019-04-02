import Foundation
import PlaygroundSupport
import AppKit
import SpriteKit
import CreateML

public class PoemScene: SKScene {
    public var pickedPoem: Poem = Poem()
    
    public func setUp() {
        // Setting up 8-bit font
        let fontURL = Bundle.main.url(forResource: "8-Bit-Madness", withExtension: "ttf")
        
        CTFontManagerRegisterFontsForURL(fontURL as! CFURL, CTFontManagerScope.process, nil)
                
        // Displaying the background image
        let background = SKSpriteNode(imageNamed: "dark-bookcase.png")
        background.size = frame.size
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        self.addChild(background)
        
        // Setting up SKView 
        let view = SKView(frame: self.frame)
        view.presentScene(self)
        PlaygroundPage.current.liveView = view
    }
    
    public func pickPoem() {
        let midPoint = CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0)

        let emilyButton = SKSpriteNode(imageNamed: "emily-scroll.png")
        emilyButton.position = CGPoint(x: midPoint.x, y: midPoint.y + 90)
        emilyButton.setScale(0.9)
        emilyButton.name = "emily-poet"
        self.addChild(emilyButton)
        
        let ezraButton = SKSpriteNode(imageNamed: "ezra-scroll.png")
        ezraButton.position = CGPoint(x: midPoint.x, y: midPoint.y)
        ezraButton.setScale(0.9)
        ezraButton.name = "ezra-poet"
        self.addChild(ezraButton)
        
        let robertButton = SKSpriteNode(imageNamed: "robert-scroll.png")
        robertButton.position = CGPoint(x: midPoint.x, y: midPoint.y - 90)
        robertButton.setScale(0.9)
        robertButton.name = "robert-poet"
        self.addChild(robertButton)
    }
    
    public override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        let touchedNodes = nodes(at: location)
        let firstTouchedNode = atPoint(location).name
        
        // Reading in the poems.json file and storing it in an MLDataTable
        guard let json = Bundle.main.url(forResource: "poems", withExtension: "json") else {
            fatalError()
        }
        
        var data: MLDataTable = MLDataTable()
        
        do {
            data = try MLDataTable(contentsOf: json)
        } catch {
            print("Error reading in data")
        }
        
        self.childNode(withName: "robert-poet")?.isHidden = true
        self.childNode(withName: "emily-poet")?.isHidden = true
        self.childNode(withName: "ezra-poet")?.isHidden = true
        
        if let name = firstTouchedNode {
            if name == "emily-poet" {
                let selection = Array(Array(data[data["author"] == "Emily Dickinson"]["content"])).randomElement()!.stringValue!
                self.pickedPoem = Poem(poem: selection, poet: "Emily Dickinson")
                self.pickedPoem.enjoy()
            } else if name == "ezra-poet" {
                let selection = Array(Array(data[data["author"] == "Ezra Pound"]["content"])).randomElement()!.stringValue!
                self.pickedPoem = Poem(poem: selection, poet: "Ezra Pound")
                self.pickedPoem.enjoy()
            } else if name == "robert-poet" {
                let selection = Array(Array(data[data["author"] == "Robert Frost"]["content"])).randomElement()!.stringValue!
                self.pickedPoem = Poem(poem: selection, poet: "Robert Frost")
                self.pickedPoem.enjoy()
            }
        }
    }
    
    public func display(poem: Poem) {
        let midPoint = CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0)

        // Picking which poet image to use
        var imageName: String = ""
        if (poem.poet == "Emily Dickinson") {
            imageName = "emily-dickinson.png"
        } else if (poem.poet == "Ezra Pound") {
            imageName = "ezra-pound.png"
        } else {
            imageName = "robert-frost.png"
        }
        
        // Setting up poetNode
        let poetNode = SKSpriteNode(imageNamed: imageName)
        poetNode.position = CGPoint(x: 100, y: midPoint.y - 60)
        poetNode.setScale(0.3)
        self.addChild(poetNode)
        
        // Setting up SpeechBubble
        let speechBubble = SKSpriteNode(imageNamed: "speechBubble.png")
        speechBubble.name = "speechBubble"
        speechBubble.setScale(1.4)
        speechBubble.position = CGPoint(x: midPoint.x + 40, y: midPoint.y + 42)
        speechBubble.xScale = -1
        self.addChild(speechBubble)
        
        // Setting up SpriteNodes for each line of poem
        var poemNodes: [SKLabelNode] = []
        
        for (i, line) in poem.lines.enumerated() {
            let poemNode = SKLabelNode(text: line)
            poemNode.name = "poemNode\(i)"
            poemNode.fontName = "8-Bit-Madness"
            poemNode.fontSize = 20
            poemNode.fontColor = .black
            poemNode.preferredMaxLayoutWidth = 300
            poemNode.numberOfLines = 0
            poemNode.horizontalAlignmentMode = .center
            poemNode.verticalAlignmentMode = .center
            poemNode.position = CGPoint(x: midPoint.x + 40, y: midPoint.y + 60)
            poemNodes.append(poemNode)
        }
        
        for node in poemNodes {
            node.isHidden = true
            self.addChild(node)
        }
        
        var delay = 0.0
        
        for (i, line) in poem.lines.enumerated() {
            //let length = line.components(separatedBy: " ").count
            //let duration = Double(length * 60) / 175.0
            
            let action = SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.run(.unhide(), onChildWithName: "poemNode\(i)"),
                SKAction.wait(forDuration: 1.0),
                SKAction.run { self.isLineShown(poem: poem) },
                SKAction.run(.hide(), onChildWithName: "poemNode\(i)"),
                SKAction.wait(forDuration: delay)])
            
            self.run(action)
            delay += 1
        }
    }
    
    func isLineShown(poem: Poem) {
        while (poem.lineSpoken == false) {
            SKAction.wait(forDuration: 0.01)
        }
        //print("completed")
    }
    
    public func hideSpeechBubble() {
        SKAction.wait(forDuration: 2.0)
        self.childNode(withName: "speechBubble")!.isHidden = true
    }
}
