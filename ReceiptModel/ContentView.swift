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
class ContentViewModel: ObservableObject {
    @Published var user: AuthUser?
    @Published var subscriptionData: String = ""
    var listener: UnsubscribeToken?
    var blogListener: AnyCancellable?
    func listen() {
        _ = Amplify.Auth.fetchAuthSession { event in
            switch event {
            case .success(let authSession):
                if authSession.isSignedIn {

                    DispatchQueue.main.async {
                        self.user = Amplify.Auth.getCurrentUser()
                        print(self.user?.userId)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.user = nil
                    }
                }
            case .failure(let error):
                print("failed to get auth session", error)
                DispatchQueue.main.async {
                    self.user = nil
                }
            }
        }
        listener = Amplify.Hub.listen(to: .auth) { payload in
            switch payload.eventName {
            case HubPayload.EventName.Auth.signedIn:
                print("Hub: Signed In")
                self.user = nil
            case HubPayload.EventName.Auth.signedOut:
                print("Hub: Signed Out")
                DispatchQueue.main.async {
                    self.user = nil
                }
            case HubPayload.EventName.Auth.sessionExpired:
                print("Hub: Session expired")
                DispatchQueue.main.async {
                    self.user = nil
                }
            default:
                break;
            }
        }
    }

    func signIn() {
        _ = Amplify.Auth.signIn(username: "user1", password: "password") {
            switch $0 {
            case .success(let signInResult):
                print("Sign In success \(signInResult)")
            case .failure(let error):
                print("Sign in error \(error)")
            }
        }
    }
    func signOut() {
        _ = Amplify.Auth.signOut(listener: {
            switch $0 {
            case .success:
                print("Signed Out")
            case .failure(let error):
                print("signed out error \(error)")
            }
        })
    }
    func blogSubscription() {
        blogListener = Amplify.DataStore.publisher(for: Blog.self).sink(receiveCompletion: { (completion) in
            switch completion {
            case .failure(let error):
                print("Error \(error)")
            case .finished:
                print("Finished")
            }
        }) { (mutationEvent) in
            DispatchQueue.main.async {
                self.subscriptionData = mutationEvent.json
            }

        }
    }
}
struct ContentView: View {
    @ObservedObject var vm = ContentViewModel()
    @State var message: String = "" 

    @State var id: String = ""
    @State var approvedId: String = "C1DB05C8-7B98-4BD8-A0A8-AF5C83B4728C"

    func save() {
        let blog = Blog()
        self.id = blog.id
        Amplify.DataStore.save(blog) { (result) in
            switch result {
            case .success(let savedModel):
                self.message = "Saved Successfully \(savedModel)"
                print(self.message)
            case .failure(let error):
                self.message = "Failed to save \(error)"
                print(self.message)
            }
        }

    }

    func query() {
        print("Querying for \(id)")
        Amplify.DataStore.query(Blog.self, byId: id) { (result) in
            switch result {
            case .success(let optionalModel):
                if let model = optionalModel {
                    let message = "Got result back \(model)"
                    print(message)
                    self.message = message
                }
            case .failure(let error):
                self.message = "Failed to get id: \(id) error: \(error)"
                print(self.message)
            }
        }
    }

    func saveApprovedBlog() {
        let approvedBlog = ApprovedBlog(blogId: self.id)
        self.approvedId = approvedBlog.id
        Amplify.DataStore.save(approvedBlog) { (result) in
            switch result {
            case .success(let savedModel):
                self.message = "Saved Successfully \(savedModel)"
                print(self.message)
            case .failure(let error):
                self.message = "Failed to save \(error)"
                print(self.message)
            }
        }
    }

    func queryApprovedBlog() {
        print("Querying for ApprovedBlog \(id)")
        Amplify.DataStore.query(ApprovedBlog.self, byId: approvedId) { (result) in
            switch result {
            case .success(let optionalModel):
                if let model = optionalModel {
                    let message = "Got result back \(model)"
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
                self.vm.signIn()
            }, label: {
                Text("Sign In").fontWeight(.semibold).font(.title)
            })
            Button(action: {
                self.vm.signOut()
            }, label: {
                Text("Sign Out").fontWeight(.semibold).font(.title)
            })
            Button(action: {
                self.save()
            }, label: {
                Text("1. Save Blog").fontWeight(.semibold).font(.title)
            })
            Button(action: {
                self.query()
            }, label: {
                Text("2. Query for: ").fontWeight(.semibold).font(.title)
                Text(self.id)
            })
            Button(action: {
                self.saveApprovedBlog()
            }, label: {
                Text("3. Save Approved Blog").fontWeight(.semibold).font(.title)
            })
            Button(action: {
                self.queryApprovedBlog()
            }, label: {
                Text("4. Query Approved Blog: ").fontWeight(.semibold).font(.title)
                Text(self.approvedId)
            })
            Spacer()
            TextView(text: $message)
                .frame(height: 200)
                .padding(.horizontal).border(Color.blue)
            TextView(text: $vm.subscriptionData)
                .frame(height: 200)
                .padding(.horizontal).border(Color.black)
        }.onAppear {
            self.vm.listen()
            self.vm.blogSubscription()
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
