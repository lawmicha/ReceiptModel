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
class ContentViewModel2: ObservableObject {
    @Published var user: AuthUser?
    @Published var subscriptionData: String = ""
    @Published var subscriptionData2: String = ""
    var listener: UnsubscribeToken?
    var blogListener: AnyCancellable?
    var approvedBlogListener: AnyCancellable?
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

    func signIn1() {
        _ = Amplify.Auth.signIn(username: "user1", password: "password") {
            switch $0 {
            case .success(let signInResult):
                print("Sign In success \(signInResult)")
            case .failure(let error):
                print("Sign in error \(error)")
            }
        }
    }
    func signIn2() {
        _ = Amplify.Auth.signIn(username: "user2", password: "password") {
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

}
struct ContentView2: View {
    @ObservedObject var vm = ContentViewModel2()
    @State var message: String = ""

    @State var id: String = ""
    @State var approvedId: String = ""

    func save1() {
        let userProfile = UserProfile(dietryRequirments: nil, weightHistory: nil, bmiHistory: nil, favouriteFood: nil)
        Amplify.DataStore.save(userProfile) { (result) in
            switch result {
            case .success(let savedModel):
                print("Success!")
                self.message = "userProfile \(savedModel)"
            case .failure(let error):
                self.message = "Error \(error)"
                print(self.message)
            }
        }
    }

    func saveFails() {
        let userProfile = UserProfile(dietryRequirments: nil, bmiHistory: nil, favouriteFood: nil)
        Amplify.DataStore.save(userProfile) { (result) in
            switch result {
            case .success(let savedModel):
                print("Success!")
                self.message = "userProfile \(savedModel)"
            case .failure(let error):
                self.message = "Error \(error)"
                print(self.message)
            }
        }
    }
    var body: some View {
        VStack {
            Group {
                Button(action: {
                   self.vm.signIn1()
               }, label: {
                   Text("Sign In 1").fontWeight(.semibold).font(.title)
               })
               Button(action: {
                   self.vm.signIn2()
               }, label: {
                   Text("Sign In 2").fontWeight(.semibold).font(.title)
               })
               Button(action: {
                   self.vm.signOut()
               }, label: {
                   Text("Sign Out").fontWeight(.semibold).font(.title)
               })
            }

            Button(action: {
                self.save1()
            }, label: {
                Text("1. Save UserProfile with nil").fontWeight(.semibold).font(.title)
            })

            Button(action: {
                self.saveFails()
            }, label: {
                Text("1. Save UserProfile with []").fontWeight(.semibold).font(.title)
            })
//
//            Button(action: {
//                self.save3()
//            }, label: {
//                Text("1. Save User with message").fontWeight(.semibold).font(.title)
//            })

            Spacer()
            TextView(text: $message)
                .frame(height: 120)
                .padding(.horizontal).border(Color.blue)
            TextView(text: $vm.subscriptionData)
                .frame(height: 200)
                .padding(.horizontal).border(Color.black)
            TextView(text: $vm.subscriptionData2)
                .frame(height: 200)
                .padding(.horizontal).border(Color.black)
        }.onAppear {
            self.vm.listen()
            //self.vm.blogSubscription()
            //self.vm.approvedBlogSubscription()
        }
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
