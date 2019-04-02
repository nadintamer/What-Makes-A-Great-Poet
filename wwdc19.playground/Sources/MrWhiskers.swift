import Foundation
import PlaygroundSupport
import AppKit
import SpriteKit
import CreateML
import NaturalLanguage

public class MrWhiskers: SKScene {
    public let examplePoems: [Poem] = [Poem(poem: "I’m Nobody! Who are you?\nAre you – Nobody – too\nThen there’s a pair of us!\nDon’t tell! they’d advertise – you know!\n\nHow dreary – to be – Somebody!\nHow public – like a Frog –\nTo tell one’s name – the livelong June –\nTo an admiring Bog!", poet: "Emily Dickinson"), Poem(poem: "The petals fall in the fountain,\nthe orange-coloured rose-leaves,\nTheir ochre clings to the stone.", poet: "Ezra Pound"), Poem(poem: "Nature’s first green is gold,\nHer hardest hue to hold.\nHer early leaf’s a flower;\nBut only so an hour.\nThen leaf subsides to leaf.\nSo Eden sank to grief,\nSo dawn goes down to day.\nNothing gold can stay.", poet: "Robert Frost")]
    public let poemsToGuess: [Poem] = [Poem(poem: "The Poets light but Lamps—\nThemselves—go out—\nThe Wicks they stimulate—\nIf vital Light\nInhere as do the Suns—\nEach Age a Lens\nDisseminating their\nCircumference—", poet: "Emily Dickinson"), Poem(poem: "The apparition of these faces in the crowd:\nPetals on a wet, black bough.", poet: "Ezra Pound"), Poem(poem: "Not only sands and gravels\nWere once more on their travels,\nBut gulping muddy gallons\nGreat boulders off their balance\nBumped heads together dully\nAnd started down the gully.\nWhole capes caked off in slices.\nI felt my standpoint shaken\nIn the universal crisis.\nBut with one step backward taken\nI saved myself from going.\nA world torn loose went by me.\nThen the rain stopped and the blowing,\nAnd the sun came out to dry me.", poet: "Robert Frost")]
    var poemToGuess: Poem = Poem(poem: "", poet: "")
    var poetryKnowledge: MLTextClassifier? = nil
    var speechNodeNum: Int = 0
    var speechBubbleNum: Int = 0
    
    public func setUp() {
        // Setting up 8-bit font
        let fontURL = Bundle.main.url(forResource: "8-Bit-Madness", withExtension: "ttf")
        
        CTFontManagerRegisterFontsForURL(fontURL as! CFURL, CTFontManagerScope.process, nil)
        
        // Setting up SKView
        let view = SKView(frame: self.frame)
        view.presentScene(self)
        PlaygroundPage.current.liveView = view
        
        // Setting up midPoint
        let midPoint = CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0)
        
        // Displaying the background image
        let background = SKSpriteNode(imageNamed: "dark-bookcase.png")
        background.size = frame.size
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        self.addChild(background)
        
        // Setting up kittyNode
        let kittyNode = SKSpriteNode(imageNamed: "kitty.png")
        kittyNode.position = CGPoint(x: 100, y: midPoint.y - 60)
        kittyNode.setScale(0.5)
        kittyNode.name = "mr.whiskers"
        self.addChild(kittyNode)
    }
    
    public func introduceSelf() {
        // Setting up SpriteNodes for Mr. Whiskers' introduction
        let introduction: [String] = ["Hello there! My name is Mr. Whiskers and I want to be a famous poet!", "I've heard that the best way to learn is from other poets.", "That's why I've decided to study three poets and look at their styles."]
        self.speak(speech: introduction)
        
    }
    
    func guessPoet(poem: Poem) -> String? {
        do {
            let prediction = try self.poetryKnowledge!.prediction(from: poem.poem)
            return prediction
        } catch {
            print("Sorry, I couldn't guess the poet!")
            return nil
        }
    }
    
    public func studyPoems() {
        do {
            guard let json = Bundle.main.url(forResource: "poems", withExtension: "json") else {
                fatalError()
            }
            
            let data = try MLDataTable(contentsOf: json)
            
            let (trainingData, testingData) = data.randomSplit(by: 0.8, seed: 5)
            
            let authorClassifier = try MLTextClassifier(trainingData: trainingData,
                                                        textColumn: "content",
                                                        labelColumn: "author")
            
            // Training accuracy as a percentage
            let trainingAccuracy = (1.0 - authorClassifier.trainingMetrics.classificationError) * 100
            
            // Validation accuracy as a percentage
            let validationAccuracy = (1.0 - authorClassifier.validationMetrics.classificationError) * 100
            
            let evaluationMetrics = authorClassifier.evaluation(on: testingData)
            
            self.poetryKnowledge = authorClassifier
        } catch {
            print("I'm too tired to study poems right now!")
        }
    }
    
    func showPoem(poem: Poem) {
        let midPoint = CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0)
        
        let scroll = SKSpriteNode(imageNamed: "scroll.png")
        scroll.position = CGPoint(x: midPoint.x + 100, y: midPoint.y)
        scroll.name = "scroll"
        scroll.setScale(0.8)
        self.addChild(scroll)
        
        let poemNode = SKLabelNode(text: poem.poem)
        poemNode.fontName = "8-Bit-Madness"
        poemNode.fontSize = 15
        poemNode.fontColor = .black
        poemNode.position = CGPoint(x: midPoint.x + 105, y: midPoint.y + 10)
        poemNode.numberOfLines = 0
        poemNode.horizontalAlignmentMode = .center
        poemNode.verticalAlignmentMode = .center
        poemNode.preferredMaxLayoutWidth = 170
        poemNode.name = "poem"
        
        self.addChild(poemNode)
    }
    
    func speak(speech: [String]) {
        let midPoint = CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0)
        
        self.childNode(withName: "mr.whiskers")!.isHidden = false
        
        // Setting up SpeechBubble
        let speechBubble = SKSpriteNode(imageNamed: "speechBubble.png")
        speechBubble.name = "speechBubble\(self.speechBubbleNum)"
        speechBubble.setScale(1.2)
        speechBubble.position = CGPoint(x: midPoint.x + 40, y: midPoint.y + 42)
        speechBubble.xScale = -1
        self.addChild(speechBubble)
        self.speechBubbleNum += 1
        
        var speechNodes: [SKLabelNode] = []
        
        for line in speech {
            let speechNode = SKLabelNode(text: line)
            speechNode.name = "speechNode\(self.speechNodeNum)"
            speechNode.fontName = "8-Bit-Madness"
            speechNode.fontSize = 20
            speechNode.fontColor = .black
            speechNode.preferredMaxLayoutWidth = 300
            speechNode.numberOfLines = 0
            speechNode.horizontalAlignmentMode = .center
            speechNode.verticalAlignmentMode = .center
            speechNode.position = CGPoint(x: midPoint.x + 40, y: midPoint.y + 60)
            speechNodes.append(speechNode)
            self.speechNodeNum += 1
        }
        
        for node in speechNodes {
            node.isHidden = true
            self.addChild(node)
        }
        
        var delay = 0.0
        
        for i in self.speechNodeNum - speechNodes.count..<(self.speechNodeNum) {
            // print("\(i) " + (self.childNode(withName: "speechNode\(i)") as! SKLabelNode).text!)
            let action = SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.run(.unhide(), onChildWithName: "speechNode\(i)"),
                SKAction.wait(forDuration: 2.0),
                SKAction.run(.hide(), onChildWithName: "speechNode\(i)"),
                SKAction.wait(forDuration: delay)])
            
            self.run(action)
            delay += 2
        }
        
        let hideSpeech = SKAction.sequence([SKAction.wait(forDuration: Double(speechNodes.count) * 2.0),
                                            SKAction.run(.hide(), onChildWithName: "speechBubble\(self.speechBubbleNum - 1)")])
        self.run(hideSpeech)
    }
    
    public func playGame(guess: Poem) {
        self.poemToGuess = guess
        showPoem(poem: self.poemToGuess)
        
        let gameSequence = SKAction.sequence([SKAction.wait(forDuration: 3.0),
                                              SKAction.run { self.speak(speech: ["Can you guess who wrote this poem? Click one of the options!"]) },
                                              SKAction.wait(forDuration: 2.0),
                                              SKAction.run { self.showOptions(situation: "Game") }])
        self.run(gameSequence)
    }
    
    func checkAnswer(poemToGuess: Poem, userAnswer: String) {
        self.childNode(withName: "emily")!.isHidden = true
        self.childNode(withName: "ezra")!.isHidden = true
        self.childNode(withName: "robert")!.isHidden = true
        
        let correctAnswer = poemToGuess.poet
        
        guard let kittyAnswer = self.guessPoet(poem: self.poemToGuess) else {
            return
        }
        
        var answerSpeech = ["I guessed \(kittyAnswer).", "You guessed \(userAnswer).", "The correct answer was \(correctAnswer)."]
        
        if (correctAnswer == userAnswer) {
            answerSpeech.append("Congratulations! You guessed right!")
        } else {
            answerSpeech.append("Sorry, you guessed wrong!")
        }
        
        self.speak(speech: answerSpeech)
        
    }
    
    func showOptions(situation: String) {
        let midPoint = CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0)
        
        self.childNode(withName: "mr.whiskers")!.isHidden = true
        
        if (situation == "Game") {
            let emilyButton = SKSpriteNode(imageNamed: "emily-scroll.png")
            emilyButton.position = CGPoint(x: midPoint.x - 120, y: midPoint.y + 70)
            emilyButton.setScale(0.7)
            emilyButton.name = "emily"
            self.addChild(emilyButton)
            
            let ezraButton = SKSpriteNode(imageNamed: "ezra-scroll.png")
            ezraButton.position = CGPoint(x: midPoint.x - 120, y: midPoint.y)
            ezraButton.setScale(0.7)
            ezraButton.name = "ezra"
            self.addChild(ezraButton)
            
            let robertButton = SKSpriteNode(imageNamed: "robert-scroll.png")
            robertButton.position = CGPoint(x: midPoint.x - 120, y: midPoint.y - 70)
            robertButton.setScale(0.7)
            robertButton.name = "robert"
            self.addChild(robertButton)
        } else {
            let emilyButton = SKSpriteNode(imageNamed: "emily-scroll.png")
            emilyButton.position = CGPoint(x: midPoint.x, y: midPoint.y + 90)
            emilyButton.setScale(0.9)
            emilyButton.name = "emily-imitate"
            self.addChild(emilyButton)
            
            let ezraButton = SKSpriteNode(imageNamed: "ezra-scroll.png")
            ezraButton.position = CGPoint(x: midPoint.x, y: midPoint.y)
            ezraButton.setScale(0.9)
            ezraButton.name = "ezra-imitate"
            self.addChild(ezraButton)
            
            let robertButton = SKSpriteNode(imageNamed: "robert-scroll.png")
            robertButton.position = CGPoint(x: midPoint.x, y: midPoint.y - 90)
            robertButton.setScale(0.9)
            robertButton.name = "robert-imitate"
            self.addChild(robertButton)
        }
    }
    
    public override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        let touchedNodes = nodes(at: location)
        let firstTouchedNode = atPoint(location).name
        
        if let name = firstTouchedNode {
            if name == "emily" {
                let userAnswer = "Emily Dickinson"
                checkAnswer(poemToGuess: self.poemToGuess, userAnswer: userAnswer)
            } else if name == "ezra" {
                let userAnswer = "Ezra Pound"
                checkAnswer(poemToGuess: self.poemToGuess, userAnswer: userAnswer)
            } else if name == "robert" {
                let userAnswer = "Robert Frost"
                checkAnswer(poemToGuess: self.poemToGuess, userAnswer: userAnswer)
            } else if name == "emily-imitate" {
                tryToWrite(poet: "Emily Dickinson")
            } else if name == "ezra-imitate" {
                tryToWrite(poet: "Ezra Pound")
            } else if name == "robert-imitate" {
                tryToWrite(poet: "Robert Frost")
            }
        }
    }
    
    public func thinkAloud() {
        let imitateSequence = SKAction.sequence([SKAction.run { self.speak(speech: ["Maybe I should start out by trying to imitate some great poets?", "Which poet's style would you like me to imitate?"]) },
                                                 SKAction.wait(forDuration: 4.0),
                                                 SKAction.run { self.showOptions(situation: "Imitate") }])
        self.run(imitateSequence)
    }
    
    func studyPoetStyles(poetToStudy: String) -> [[String]] {
        guard let json = Bundle.main.url(forResource: "poems", withExtension: "json") else {
            fatalError()
        }
        
        var data: MLDataTable = MLDataTable()
        
        do {
            data = try MLDataTable(contentsOf: json)
        } catch {
            print("Error reading in data")
        }
        
        var selection = Array(data[data["author"] == poetToStudy]["content"])
        var poems: [String] = []
        
        for _ in 0..<5 {
            let num = Int.random(in: 0..<selection.count)
            poems.append(selection[num].stringValue!)
            selection.remove(at: num)
        }
        
        var giantCorpus: [[String]] = []
        
        for poem in poems {
            let poem = poem.replacingOccurrences(of: "\n", with: " \n ")
            let splitPoem = poem.components(separatedBy: " ")
            giantCorpus.append(splitPoem)
        }
        
        return giantCorpus
    }
    
    public func tryToWrite(poet: String) {
        self.childNode(withName: "emily-imitate")!.isHidden = true
        
        self.childNode(withName: "robert-imitate")!.isHidden = true
        
        self.childNode(withName: "ezra-imitate")!.isHidden = true
        
        let giantCorpus = studyPoetStyles(poetToStudy: poet)
        
        func make_pairs(corpus: [String]) -> [[String]] {
            var pairs: [[String]] = []
            for i in 0..<corpus.count - 1 {
                pairs.append([corpus[i], corpus[i+1]])
            }
            return pairs
        }
        
        var words: [String:[String]] = [:]
        
        for corpus in giantCorpus {
            let pairs = make_pairs(corpus: corpus)
            
            for pair in pairs {
                let word1 = pair[0]
                let word2 = pair[1]
                if Array(words.keys).contains(word1) {
                    words[word1]!.append(word2)
                } else {
                    words[word1] = [word2]
                }
            }
        }
        
        var firstWord = ""
        
        while (firstWord == firstWord.lowercased()) || ([".", "?", "!", "'", "\""].contains(firstWord.last!)) || firstWord.count < 1 {
            firstWord = giantCorpus[0].randomElement()!
        }
        
        var chain = [firstWord]
        let n_words = 30
        var i = 0
        
        var lastWord = chain[0]
        
        while (i < n_words) && words[lastWord] != nil {
            var options: [String] = words[lastWord]!
            options = options.filter{ $0.count > 0 }
            chain.append(options.randomElement()!)
            lastWord = Array(chain.suffix(1))[0]
            if ([".", "?", "!", "'", "\""].contains(lastWord.last!)) {
                chain.append("\n")
                lastWord = ""
                while (lastWord == lastWord.lowercased()) || ([".", "?", "!", "'", "\"", "-"].contains(lastWord.last!)) {
                    lastWord = giantCorpus[0].randomElement()!
                }
            }
            i += 1
        }
        
        while !([".", "?", "!", "'", "\"", "-"].contains(lastWord.last!)) && words[lastWord] != nil {
            var options: [String] = words[lastWord]!
            options = options.filter{ $0.count > 0 }
            chain.append(options.randomElement()!)
            lastWord = Array(chain.suffix(1))[0]
        }
        
        let whiskersPoem = Poem(poem: chain.joined(separator: " "), poet: "Mr. Whiskers")
        
        let showPoemSequence = SKAction.sequence([SKAction.run { self.speak(speech: ["I gave it my best try! I hope you like it!", "Here's a poem by Mr. Whiskers in the style of \(poet)."]) },
                                                  SKAction.wait(forDuration: 4.0),
                                                  SKAction.run { self.showPoem(poem: whiskersPoem) }])
        self.run(showPoemSequence)
    }
    
    public func sayGoodbye() {
        let goodbyeSpeech = ["Thanks for joining me today!", "I hope you enjoyed learning more about poetry.", "And I definitely hope you liked my poem!", "Goodbye!"]
        self.speak(speech: goodbyeSpeech)
    }
    
    func discussDickinsonPoem() {
        let dickinson: Poem = self.examplePoems[0]
        let pound: Poem = self.examplePoems[1]
        let frost: Poem = self.examplePoems[2]
        
        self.showPoem(poem: dickinson)
        let discussSequence = SKAction.sequence([
            SKAction.run { self.speak(speech: ["Let's start off by reading a poem by Emily Dickinson!"]) },
            SKAction.wait(forDuration: 10.0),
            SKAction.run { self.speak(speech: ["Running dominantPunctuation() on this poem returns \"\(self.dominantPunctuation(poem: dickinson))\".", "This shows us that Dickinson often uses dashes in her poems.", "Furthermore, capitalizedRatio() for this poem returns \(self.capitalizedRatio(poem: dickinson)).", "This is significantly higher than Pound's \(self.capitalizedRatio(poem: pound)) or Frost's \(self.capitalizedRatio(poem: frost)).", "This shows us that Dickinson likes to use Capital Letters in her poems."]) }])
        self.run(discussSequence)
    }
    
    func discussPoundPoem() {
        let pound: Poem = self.examplePoems[1]
        
        self.showPoem(poem: pound)
        let discussSequence = SKAction.sequence([
            SKAction.run { self.speak(speech: ["Now let's move on to a poem by Ezra Pound."]) },
            SKAction.wait(forDuration: 8.0),
            SKAction.run { self.speak(speech: ["We can immediately see that Pound uses a lot of nature imagery in his poems.", "This is part of a literary movement called imagism.", "It's inspired by the Japanese haiku."]) }
            ])
        self.run(discussSequence)
    }
    
    func discussFrostPoem() {
        let dickinson: Poem = self.examplePoems[0]
        let pound: Poem = self.examplePoems[1]
        let frost: Poem = self.examplePoems[2]
        
        self.showPoem(poem: frost)
        let discussSequence = SKAction.sequence([
            SKAction.run { self.speak(speech: ["Now it's time to finish off with a poem by Robert Frost."]) },
            SKAction.wait(forDuration: 10.0),
            SKAction.run { self.speak(speech: ["We can run perfectRhyme() on the final words of every line of this poem.", "perfectRhyme(\"gold\", \"hold\") = \(self.perfectRhyme(firstWord: "gold", secondWord: "hold"))", "perfectRhyme(\"flower\", \"hour\") = \(self.perfectRhyme(firstWord: "flower", secondWord: "hour"))", "perfectRhyme(\"leaf\", \"grief\") = \(self.perfectRhyme(firstWord: "leaf", secondWord: "grief"))", "perfectRhyme(\"day\", \"stay\") = \(self.perfectRhyme(firstWord: "day", secondWord: "stay"))", "Wow! Robert Frost sure likes to rhyme!"]) }])
        self.run(discussSequence)
    }
    
    func perfectRhyme(firstWord: String, secondWord: String) -> Bool {
        let firstSyllables = firstWord.components(separatedBy: CharacterSet.init(charactersIn: "aeiouy"))
        let secondSyllables = secondWord.components(separatedBy: CharacterSet.init(charactersIn: "aeiouy"))
        
        let firstLast = firstSyllables[firstSyllables.count - 1]
        let secondLast = secondSyllables[firstSyllables.count - 1]
        
        let speechSynthesizer = NSSpeechSynthesizer()
        
        let firstPronunciation = speechSynthesizer.phonemes(from: firstLast)
        let secondPronunciation = speechSynthesizer.phonemes(from: secondLast)
        
        return (firstPronunciation == secondPronunciation)
    }
    
    func dominantPunctuation(poem: Poem) -> String {
        let tagger = NLTagger(tagSchemes: [.tokenType])
        let text = poem.poem
        let options: NLTagger.Options = [.omitWhitespace]
        
        tagger.string = text
        tagger.setLanguage(.english, range: text.startIndex..<text.endIndex)
        
        var punctuation: [String] = []
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .tokenType, options: options) { tag, tokenRange in
            if let tag = tag {
                if (tag.rawValue == "Punctuation") {
                    punctuation.append(String(text[tokenRange]))
                }
            }
            return true
        }
        
        let counted = NSCountedSet(array: punctuation)
        let max = counted.max { counted.count(for: $0) < counted.count(for: $1) }
        return max as! String
    }
    
    func capitalizedRatio(poem: Poem) -> Double {
        let tokenizer = NLTokenizer(unit: .word)
        let text = poem.poem
        
        tokenizer.setLanguage(.english)
        tokenizer.string = text
        
        let tokens = tokenizer.tokens(for: text.startIndex..<text.endIndex)
        
        var capitalizedTotal = 0.0
        
        for token in tokens {
            let word = text[token]
            let capitalized = word.prefix(1).uppercased() + word.lowercased().dropFirst()
            
            if (word == capitalized) {
                capitalizedTotal += 1
            }
        }
        let ratio = capitalizedTotal / Double(tokens.count)
        
        return Double(round(100*ratio)/100)
    }
    
    public func discussPoems() {
        let discussPoems = SKAction.sequence([
            SKAction.run { self.discussDickinsonPoem() },
            SKAction.wait(forDuration: 20.0),
            SKAction.run { self.discussPoundPoem() },
            SKAction.wait(forDuration: 13.0),
            SKAction.run { self.discussFrostPoem() }])
        self.run(discussPoems)
    }
}
