/*:
 ## Predicting the Poet
 We've seen that all three of our poets have distinctive styles. Do you think you could identify which poet wrote a given poem? Make sure to bring your A-game because Mr. Whiskers has been studying hard! 🤓
 
 [Previous: Different Poets, Different Styles](@previous) | page 5 of 7 |  [Next: Imitating Poetry Styles](@next)
 */
import CreateML
import Foundation
import SpriteKit
import PlaygroundSupport

let kitty = MrWhiskers(size: CGSize(width: 480, height: 384))
kitty.setUp()
kitty.studyPoems()
kitty.playGame(guess: kitty.poemsToGuess.randomElement()!)
