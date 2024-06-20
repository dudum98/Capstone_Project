//
//  GameView.swift
//  WordWizard
//
//  Created by Nethmee Perera on 4/21/24.
//


import SwiftUI

struct DefinitionResponse: Codable {
    let meanings: [Meaning]
}

struct Meaning: Codable {
    let definitions: [Definition]
}

struct Definition: Codable {
    let definition: String
}

struct GameView: View {
    @State private var computerWord = ""
    @State private var wordDefinition = ""
    @State private var userWord = ""
    @State private var isLoading = false
    @State private var isGameActive = false
    @State private var correctWords: [String] = []
    @State private var timeRemaining = 10
    @State private var showAlertTimeUp = false
    @State private var showAlertIncorrectWord = false
    @State private var totalScore = 0 // Reset the score at the beginning of each new game
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private func fetchRandomWord() {
        isLoading = true
        guard let url = URL(string: "https://random-word-api.herokuapp.com/word") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            defer { isLoading = false }
            if let data = data, let word = try? JSONDecoder().decode([String].self, from: data).first {
                computerWord = word
                fetchWordDefinition(word) // Fetch the definition after setting the word
                isGameActive = true
                timeRemaining = 10
            }
        }.resume()
    }


    private func fetchWordDefinition(_ word: String) {
        computerWord = word
        guard let url = URL(string: "https://api.dictionaryapi.dev/api/v2/entries/en/\(word)") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            do {
                let definitions = try JSONDecoder().decode([DefinitionResponse].self, from: data)
                print("Definitions:", definitions)
                if let definition = definitions.first?.meanings.first?.definitions.first {
                    DispatchQueue.main.async {
                        self.wordDefinition = definition.definition
                    }
                }
            } catch {
                print("Error decoding definition response: \(error)")
            }
        }.resume()
    }

    private func checkWord() {
        let trimmedUserWord = userWord.trimmingCharacters(in: .whitespacesAndNewlines)
        let userFirstLetter = trimmedUserWord.lowercased().first
        let computerLastLetter = computerWord.lowercased().last
        if let userFirstLetter = userFirstLetter, userFirstLetter == computerLastLetter {
            let score = trimmedUserWord.count > 5 ? 3 : 1
            totalScore += score
            correctWords.append("\(userWord) (\(score) points)")
            fetchRandomWord()
            userWord = ""
        } else {
            if !computerWord.isEmpty {
                showAlertIncorrectWord = true
                print("Incorrect word detected.")
            }
        }
    }

    var body: some View {
        VStack {
            if isGameActive {
                Text("Definition: \(wordDefinition)")
                    .font(.headline)
                    .padding(.top, 10)
            }
            
            HStack {
                Spacer()
                Text("\(timeRemaining)s")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.trailing, 10)
                Image(systemName: "clock")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            .padding(.top, 10)
            
            HStack {
                Spacer()
                Text("Score: \(totalScore)")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding()
            }
            
            if !isGameActive {
                Button(action: {
                    totalScore = 0 // Reset the score when starting a new game
                    fetchRandomWord()
                }) {
                    Text("Let's Go")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(40.0)
                        .background(Color.green)
                        .cornerRadius(40)
                }
            } else {
                if isLoading {
                    ProgressView("Generating word...")
                } else {
                    Text(computerWord)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    TextField("Type a word...", text: Binding<String>(
                        get: { self.userWord.lowercased() },
                        set: { self.userWord = $0 }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    Button(action: {
                        checkWord()
                    }) {
                        Text("Submit")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(10.0)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(correctWords, id: \.self) { word in
                                Text(word)
                                    .padding(.horizontal, 5)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .onReceive(timer) { _ in
            if isGameActive && timeRemaining > 0 {
                timeRemaining -= 1
                if timeRemaining == 0 {
                    showAlertTimeUp = true
                    isGameActive = false
                }
            }
        }
        .alert(isPresented: .constant(showAlertTimeUp || showAlertIncorrectWord)) {
            let alertTitle: String
            let alertMessage: String
            
            if showAlertTimeUp {
                alertTitle = "Time's up!"
                alertMessage = "You ran out of time. Final score: \(totalScore)" // Display final score in the alert
            } else {
                alertTitle = "Game Over!"
                alertMessage = "You entered an incorrect word. Final score: \(totalScore)" // Display final score in the alert
            }
            
            return Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                isGameActive = false
                showAlertTimeUp = false
                showAlertIncorrectWord = false
            })
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
