//
//  ContentView.swift
//  WordWizard
//
//  Created by Nethmee Perera on 4/16/24.
//

import SwiftUI

extension LinearGradient {
    init(colors: [Color]) {
        self.init(gradient: Gradient(colors: colors), startPoint: .leading, endPoint: .trailing)
    }
}

struct MulticolorText: View {
    var text: String
    var colors: [Color]

    var body: some View {
        Text(text)
            .foregroundColor(.clear)
            .overlay(
                LinearGradient(colors: colors)
                    .mask(Text(text))
            )
    }
}

struct ContentView: View {
    @State private var isGameStarted = false // Track if the game has started
    
    var body: some View {
        NavigationView {
            VStack {
                Image("wordwizard_logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 250, height: 250)
                    .padding(.bottom, 20)
                
                MulticolorText(text: "Welcome to WordWizard!", colors: [.blue, .green, .purple])
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                
                MulticolorText(text: "Create a word starting with the last letter of the previous word and keep the chain going to become the ultimate WordWizard!", colors: [.orange, .yellow, .pink])
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 20)
                
                NavigationLink(destination: GameView(), isActive: $isGameStarted) {
                                   EmptyView()
                               }
                               
                               if !isGameStarted {
                                   Button(action: {
                                       isGameStarted = true // Set the game started flag to true
                                   }) {
                                       Text("Ready??")
                                           .font(.headline)
                                           .fontWeight(.bold)
                                           .foregroundColor(.white)
                                           .padding()
                                           .background(Color.blue)
                                           .cornerRadius(10)
                                   }
                                   .padding(.top, 20)
                }
                
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

