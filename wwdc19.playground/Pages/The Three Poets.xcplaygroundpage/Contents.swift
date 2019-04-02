/*:
 ## The Three Poets: Robert Frost, Emily Dickinson & Ezra Pound
 The three poets that we'll be examining today are Robert Frost (1874-1963), Emily Dickinson (1830-1886), and Ezra Pound (1885-1972). All three have distinctive styles that we'll learn to recognize. Let's start off by listening to a poem by each of the three poets. 📝
 
 To make this easy, I built a web scraper to collect poems off of poemhunter.com and package them into a neat little file called poems.json. Each item in this file has three properties: title, content, and author. 🌐
 
 To view a random poem by any of the three poets, open up the current page's Live View from the Assistant Editor to the right and run the code! Choose which poet you want to hear a poem from, and don't forget to turn on sound. 🔊
 
 [Previous: Introduction](@previous) | page 2 of 7 |  [Next: Meet Mr. Whiskers](@next)
 */
import Foundation
import CreateML
import SpriteKit

let myScene = PoemScene(size: CGSize(width: 480, height: 384))
myScene.setUp()
myScene.pickPoem()
