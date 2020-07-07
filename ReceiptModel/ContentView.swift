//
//  ContentView.swift
//  ReceiptModel
//
//  Created by Law, Michael on 6/16/20.
//  Copyright © 2020 lawmicha. All rights reserved.
//

import SwiftUI
import Amplify
import AmplifyPlugins
import Combine
struct ContentView: View {
    @State var message: String = ""
    @State var id: String = ""
    func save() {
        var blog = Blog(name: "name", posts: [])
        let post = Post(title: "title", content: "content", belongsTo: blog)
        self.id = blog.id
        Amplify.DataStore.save(blog) { (result) in
            switch result {
            case .success(let savedModel):
                print("Saved Successfully1 \(savedModel)")
                self.message = savedModel.id
                Amplify.DataStore.save(post) { (result) in
                    switch result {
                    case .success(let savedModel):
                        print("Saved Successfully2 \(savedModel)")
                        blog.posts = [post]
                        Amplify.DataStore.save(blog) { (result) in
                            switch result {
                                case .success(let savedModel):
                                    print("Saved Successfully3 \(savedModel)")
                                case .failure(let error):
                                    print("Failed to save \(error)")
                            }

                        }
                    case .failure(let error):
                        print("Failed to save \(error)")
                    }
                }
            case .failure(let error):
                print("Failed to save \(error)")
            }
        }

    }

    func query() {
        print("Querying for \(id)")
        Amplify.DataStore.query(Blog.self, byId: id) { (result) in
            switch result {
            case .success(let optionalModel):
                if let model = optionalModel {
                    let message = "Got blog back \(model)"
                    if let blogPosts = model.posts {
                        blogPosts
                            .loadAsPublisher()
                            .sink(receiveCompletion: { _ in return },
                                  receiveValue: { items in
                                    print("lazy load posts:")
                                    print(items)
                            } // this is called with empty []
                        )
                    }

                    print(message)
                    self.message = message
                }
            case .failure(let error):
                self.message = "Failed to get id: \(id) error: \(error)"
                print(self.message)
            }
        }
    }

    var body: some View {
        VStack {
            Button(action: {
                self.save()
            }, label: {
                Text("Save").fontWeight(.semibold).font(.title)
            })
            if id != "" {
                Button(action: {
                    self.query()
                }, label: {
                    Text("Query for: ").fontWeight(.semibold).font(.title)
                    Text(self.id)
                })
            }

            Spacer()
            TextView(text: $message)
                .frame(height: 500)
                .padding(.horizontal)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


/// https://github.com/appcoda/MultiLineTextView
struct TextView: UIViewRepresentable {

    @Binding var text: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()

        textView.delegate = context.coordinator
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.autocapitalizationType = .sentences
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator($text)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>

        init(_ text: Binding<String>) {
            self.text = text
        }

        func textViewDidChange(_ textView: UITextView) {
            self.text.wrappedValue = textView.text
        }
    }
}
