import Foundation

public class Poem: NSObject {
    public var poem: String
    public var poet: String
    public var lines: [String]
    public var lineSpoken: Bool
    
    public init(poem: String, poet: String) {
        self.poem = poem
        self.poet = poet
        self.lines = poem.components(separatedBy: "\n")
        self.lineSpoken = false
    }
    
    public override init() {
        self.poem = ""
        self.poet = ""
        self.lines = [""]
        self.lineSpoken = false
    }
    
    public func enjoy() {
        let myScene = PoemScene(size: CGSize(width: 480, height: 384))
        let mySpeaker = PoemSpeaker()
        myScene.setUp()
        myScene.display(poem: self)
        
        DispatchQueue.global(qos: .background).async {
            mySpeaker.play(poem: self)
            
            DispatchQueue.main.async {
                myScene.hideSpeechBubble()
            }
        }
    }
    
}
