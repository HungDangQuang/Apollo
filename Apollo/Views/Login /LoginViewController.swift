//
//  LoginViewController.swift
//  Apollo
//
//  Created by QUANG HUNG on 01/Oct/2021.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var viewLoading: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide spinner
        spinner.isHidden = true
        spinner.hidesWhenStopped = true
        
        // hide loading view
        viewLoading.alpha = 0
        
        // hide keyboard
        self.hideKeyboardWhenTappedAround()
        view.backgroundColor =  self.hexStringToUIColor(hex: "#097d14")
        
        // Set up animation
//        txtUsername.frame.origin.x = -view.frame.width/2
//        txtPassword.frame.origin.x = 1.5 * view.frame.width/2
//
//        UIView.animate(withDuration: 2) {
//            self.txtUsername.frame.origin.x = (self.view.frame.width - self.txtUsername.frame.width)/2
//            self.txtPassword.frame.origin.x = (self.view.frame.width - self.txtPassword.frame.width)/2
//        }


        btnLogin.layer.cornerRadius = 15
        btnLogin.backgroundColor = .black
        
        txtUsername.borderStyle = .none
        txtPassword.borderStyle = .none
        
        navigationController?.navigationBar.isHidden = true
    }
    
    
    @IBAction func login(_ sender: Any) {
        
        // Enable user interaction when logining
        self.txtUsername.isUserInteractionEnabled = false
        self.txtPassword.isUserInteractionEnabled = false
        self.btnLogin.isUserInteractionEnabled = false
        
        // Increasing alpha to to make animation loading
        self.viewLoading.alpha = 0.5
        
        spinner.startAnimating()
        
        let url = URL(string: Config.serverURL + "/auth/login")
        
        guard let requestUrl = url else { fatalError() }
        
        var request = URLRequest(url: requestUrl)
        
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Encode data
        let sData = Account(email: txtUsername.text!, password: txtPassword.text!, isMobileApp: true)
        let jsonData = try? JSONEncoder().encode(sData)
        
        // Put data in body
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                
                print("Error took place \(error)")
                return
            }
            
            // Check if the call is succeessful
            guard let httpResponse = response as? HTTPURLResponse,
                        (200...299).contains(httpResponse.statusCode) else {
                
                // Show notification to users
                DispatchQueue.main.sync {
                    
                    self.spinner.stopAnimating()
                    
                    // enable user interaction
                    self.txtUsername.isUserInteractionEnabled = true
                    self.txtPassword.isUserInteractionEnabled = true
                    self.btnLogin.isUserInteractionEnabled = true
                    self.viewLoading.alpha = 0
                    
                    // make notification
                    let notification = UIAlertController(title: "Nofication", message: "Login failed, please try again", preferredStyle: .alert)
                    notification.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(notification, animated: true, completion: nil)
                    
                }
                print("Error with the response, unexpected status code: \(String(describing: response))")
                return
              }
            
            guard let data = data else {return}
            
            do{
                
                // decode result
                let result = try JSONDecoder().decode(ReceivedData.self, from: data)
                
                // store access token and user ID to userDefaults
                let defaults = UserDefaults.standard
                defaults.set(result.token.accessToken, forKey: "accessToken")
                defaults.set(result.user.id, forKey: "userID")
                
                DispatchQueue.main.async {
                    
                    // Come to the home screen
                    self.spinner.stopAnimating()
                    let sb = UIStoryboard(name: "Main", bundle: nil)
                    let homeVC = sb.instantiateViewController(identifier: "HomeTabBarController")
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(homeVC)
                    
                }
        
            }catch let jsonErr{
                print(jsonErr)
            }
            
        }
        task.resume()
    }
    
}

extension UIViewController {
    
    // hide keyboard
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // input color by hex code
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    
}
