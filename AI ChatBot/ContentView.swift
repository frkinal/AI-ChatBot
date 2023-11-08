//
//  ContentView.swift
//  AI ChatBot
//
//  Created by Ömer Faruk İnal on 8.11.2023.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State var chatMessages: [ChatMessage] = []
    @State var messageText:String=""
    @State var cancellables = Set<AnyCancellable>()
    @State private var showAlert=false
    let openAIService=OpenAIService()
    
    var body: some View {
        VStack{
            ScrollView{
                LazyVStack {
                    ForEach(chatMessages,id: \.id){
                        message in messageView(message: message)
                    }
                }
            }
            HStack{
                TextField("Enter a message",text: $messageText)
                    .padding()
                    .background(.gray.opacity(0.1))
                    .cornerRadius(12)
                Button{
                    sendMessage()
                }label: {
                    Text("Send")
                        .foregroundColor(.white)
                        .padding()
                        .background(.black)
                        .cornerRadius(12)
                }
            }
         
                    .alert("Error", isPresented: $showAlert) {
                        Button("OK") {
                            showAlert=false
                        }
                    } message: {
                        Text("Message is required.")
                    }
        }
        .padding()
    }
        func messageView(message: ChatMessage) -> some View{
            HStack{
                if message.sender == .me {Spacer()}
                Text(message.content)
                    .foregroundColor(message.sender == .me ? .white : .black)
                    .padding()
                    .background(message.sender == .me ? .blue : .gray.opacity(0.1))
                    .cornerRadius(16)
                if message.sender == .gpt {Spacer()}
            }
        }
    func sendMessage(){
        if messageText != "" {
            let myMessage=ChatMessage(id: UUID().uuidString, content: messageText, dateCreated: Date(), sender: .me)
            chatMessages.append(myMessage)
            openAIService.sendMessage(message: messageText).sink{
                completion in
            }receiveValue: { response in
                guard let textResponse = response.choices.first?.text else {return}
                let gptMessage=ChatMessage(id: response.id, content: textResponse, dateCreated: Date(), sender: .gpt)
                chatMessages.append(gptMessage)
            }.store(in: &cancellables)
            messageText=""
        }else{
           showAlert=true
        }
    }
    }


#Preview {
    ContentView()
}

struct ChatMessage{
    let id:String
    let content:String
    let dateCreated:Date
    let sender: MessageSender
}

enum MessageSender{
    case me
    case gpt
}

extension ChatMessage{
    static let sampleMessages=[
        ChatMessage(id:UUID().uuidString,content: "Sample message from me",dateCreated: Date(),sender: .me),
        ChatMessage(id:UUID().uuidString,content: "Sample message from gpt",dateCreated: Date(),sender: .gpt),
        ChatMessage(id:UUID().uuidString,content: "Sample message from me",dateCreated: Date(),sender: .me),
        ChatMessage(id:UUID().uuidString,content: "Sample message from gpt",dateCreated: Date(),sender: .gpt)
    ]
}
