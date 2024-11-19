import SwiftUI
import FirebaseAuth

struct Login_SignupView: View {
    @Binding var isLoggedIn: Bool
    @Binding var pantryList: [PantryIngredient]
    @Binding var userId: String
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var signUpusername = ""
    @State private var signUpEmail = ""
    @State private var signUpPassword = ""
    @State private var signUpErrorMessage = ""
    @State private var showSignUpPopup = false
    @State private var showPassword = false
    
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            Text("Log in or Sign up")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
                .padding(.top, 10)
            Spacer()
            TextField("Email",
                      text: $email,
                      prompt: Text("Email").foregroundColor(.gray))
            .padding(10)
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.blue, lineWidth: 2)
            }
            .textInputAutocapitalization(.never)
            .padding(.horizontal)
            HStack {
                Group {
                    if showPassword {
                        TextField("Password",
                                  text: $password,
                                  prompt: Text("Password").foregroundColor(.gray))
                        
                    } else {
                        SecureField("Password",
                                    text: $password,
                                    prompt: Text("Password").foregroundColor(.gray))
                    }
                }
                .padding(10)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.blue, lineWidth: 2)
                }
                .textInputAutocapitalization(.never)
                
                Button {
                    showPassword.toggle()
                } label: {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundColor(.black)
                }
                
            }.padding(.horizontal)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Spacer()
            HStack(spacing: 10) {  // Reduced spacing between the buttons
                Button {
                    print("do login action")
                    if(!email.isEmpty && !password.isEmpty){
                        loginUser(email: email, password: password) { result in
                            switch result {
                            case .success(let (user, pantry)):
                                isLoggedIn = true
                                print("User's pantry: \(pantry)")
                                userId = user.uid
                                pantryList = pantry
                            case .failure(let error):
                                errorMessage = error.localizedDescription
                            }
                        }
                    } else {
                        errorMessage = "Email or password are empty!"
                    }
                } label: {
                    Text("Log In")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                }
                .frame(height: 60) // Increase height
                .frame(maxWidth: .infinity) // Spread button to full width
                .background(
                    Color.blue
                )
                .cornerRadius(20)

                Button {
                    print("do signup action")
                    
                    if(!email.isEmpty && !password.isEmpty){
                        signUpUser(email: email, password: password) { result in
                            switch result {
                            case .success(let user):
                                isLoggedIn = true
                                userId = user.uid
                                print("User registered: \(user.email ?? "")")
                            case .failure(let error):
                                errorMessage = error.localizedDescription
                            }
                        }
                        
                    } else {
                        errorMessage = "Username, email or password are empty!"
                    }
                } label: {
                    Text("Sign Up")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                }
                .frame(height: 60) // Increase height
                .frame(maxWidth: .infinity) // Spread button to full width
                .background(
                    Color.orange
                )
                .cornerRadius(20)
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity)

        }
    }
}

#Preview {
    Login_SignupView(isLoggedIn: .constant(false), pantryList: .constant([]), userId: .constant(""))
}
