//
//  StudentInfoViewController.swift
//  Apollo
//
//  Created by QUANG HUNG on 11/Oct/2021.
//

import UIKit

class StudentInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tbvStudent: UITableView!
    var arrStudentInfo:[String] = []
    let arrIcon:[String] = ["name", "id", "email"]
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var loadingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tbvStudent.delegate = self
        tbvStudent.dataSource = self
        
        // Set up background color
        view.backgroundColor = self.hexStringToUIColor(hex: "#097d14")
        tbvStudent.backgroundColor = self.hexStringToUIColor(hex: "#097d14")
        
        spinner.hidesWhenStopped = true
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        loadingView.alpha = 0.5
        spinner.startAnimating()
        
        let token = UserDefaults.standard.string(forKey: "accessToken")
        
        if token != nil {
            
            guard let URL = URL(string: Config.serverURL + "/auth/me") else {
                fatalError()
            }
            
                var request = URLRequest(url: URL)
            
                // Set http method
                request.httpMethod = "GET"
            
                // Set HTTP Request Header
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
             
                    if let error = error {
                        
                        print("Error took place \(error)")
                        
                        self.spinner.stopAnimating()
                        self.loadingView.alpha = 0
                        
                        // Show Alert if error
                        DispatchQueue.main.sync {
                            
                            
                            let alert = UIAlertController(title: "Error", message: "Cannot show information of user", preferredStyle: .alert)

                            // Add button for this notification
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                            // Display nofitication
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse,
                            (200...299).contains(httpResponse.statusCode) else {
                    
                    DispatchQueue.main.sync {
                        
                        self.spinner.stopAnimating()
                        self.loadingView.alpha = 0
                        
                        let notification = UIAlertController(title: "Nofication", message: "Failed to load data, please try again", preferredStyle: .alert)
                        notification.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(notification, animated: true, completion: nil)
                        
                    }
                        print("Error with the response, unexpected status code: \(String(describing: response))")
                        return
                  }
                
                guard let data = data else {return}
                
                do{
                    
                    let result = try JSONDecoder().decode(User.self, from: data)
                    self.arrStudentInfo = [result.name!, result.studentCode!, result.email!]
                    
                    DispatchQueue.main.async {
                        
                        self.spinner.stopAnimating()
                        self.loadingView.alpha = 0
                        self.tbvStudent.reloadData()
                    }
            
                }catch let jsonErr{
                    print(jsonErr)
                }
                    
            }
            
                task.resume()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrStudentInfo.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tbvStudent.dequeueReusableCell(withIdentifier: "studentCell") as! StudentInfoTableViewCell
        cell.backgroundColor =  self.hexStringToUIColor(hex: "#097d14")
        cell.lblContent.text = self.arrStudentInfo[indexPath.section]
        cell.imgIcon.image = UIImage(named: arrIcon[indexPath.section])
        return cell
    }
    
    // Add spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    // Change color for the spacing view
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = self.hexStringToUIColor(hex: "#097d14")
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tbvStudent.frame.height/3
    }
    
    
    
    @IBAction func logout(_ sender: Any) {
        // remove token
        UserDefaults.standard.removeObject(forKey: "accessToken")
        UserDefaults.standard.removeObject(forKey: "userID")
        
        // change root view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginNavController = storyboard.instantiateViewController(identifier: "LoginNavigationController")

            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
    }
}
