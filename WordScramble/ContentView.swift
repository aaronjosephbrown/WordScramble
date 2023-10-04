//
//  ContentView.swift
//  WordScramble
//
//  Created by Aaron Brown on 9/30/23.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var hardMode = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text:$newWord)
                        .autocapitalization(.none)
                }
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName:"\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem {
                    Toggle("Hard Mode", isOn: $hardMode)
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
        }
        .onAppear(perform: startGame)
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
    
    func startGame () {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                return rootWord = allWords.randomElement() ?? "silkworm"
            }
        }
        fatalError("Could not lad start.txt from bundle.")
    }
    
    func addNewWord() {
        let answer = newWord
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > (hardMode ? 3 : 0) else {
            wordError(title: "Word too short", message: "Choose 4 or more letters.")
            return
        }
        
        guard isTheWord(original: answer) else {
            wordError(title: "Word already used", message: "Be more original!")
            return
        }
        
        guard isTheWord(possible: answer) else {
            wordError(title: "Word not possible", message: "You can't spell \(answer) from \(rootWord)")
            return
        }
        
        guard isTheWord(real: answer) else {
            wordError(title: "Come on.", message: "Use a real word!")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        return newWord = ""
    }
    
    func isTheWord(original word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isTheWord(possible word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        return true
    }
    
    func isTheWord(real word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledWords = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledWords.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
