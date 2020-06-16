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
    @State var user: AuthUser?
    var listener: UnsubscribeToken?
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
}
struct ContentView: View {
    @ObservedObject var vm = ContentViewModel()
    @State var message: String = ""
    @State var id: String = "F2C34625-AF12-4EFF-B9EF-34070FB42AC8"
    func save() {
        let receipt = Receipt(state: "state",
                              isFavorite: true,
                              created: 111,
                              extracted: 111,
                              updated: 111,
                              viewed: 11,
                              emailDocument: "emailDoc",
                              receiptImage: "image",
                              receiptRawText: "rawText", dateTime: .now(),
                              merchant: "merchant",
                              amount: 123,
                              taxTotal: 12,
                              subTotalAmount: 12,
                              tipAmount: 34,
                              total: "22")
        self.id = receipt.id
        Amplify.DataStore.save(receipt) { (result) in
            switch result {
            case .success(let savedModel):
                print("Saved Successfully \(savedModel)")
                self.message = savedModel.id
            case .failure(let error):
                print("Failed to save \(error)")
            }
        }

    }

    func query() {
        print("Querying for \(id)")
        Amplify.DataStore.query(Receipt.self, byId: id) { (result) in
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
                Text("Save").fontWeight(.semibold).font(.title)
            })
            Button(action: {
                self.query()
            }, label: {
                Text("Query for: ").fontWeight(.semibold).font(.title)
                Text(self.id)
            })
            Spacer()
            TextView(text: $message)
                .frame(height: 500)
                .padding(.horizontal)
        }.onAppear {
            self.vm.listen()
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
