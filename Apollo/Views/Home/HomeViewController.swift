//
//  HomeViewController.swift
//  Apollo
//
//  Created by QUANG HUNG on 08/Oct/2021.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tbvCourses: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var loadingView: UIView!
    
    // Arr stores result
    var arrCourses:[Course] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        spinner.hidesWhenStopped = true
        
        tbvCourses.delegate = self
        tbvCourses.dataSource = self
        
        // set up background color for tbv and view
        view.backgroundColor = self.hexStringToUIColor(hex: "#097d14")
        tbvCourses.backgroundColor = self.hexStringToUIColor(hex: "#097d14")
        
        loadingView.alpha = 0.5
        spinner.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Call api in order to get info of class
        
        // check token
        let token = UserDefaults.standard.string(forKey: "accessToken")

        if (token != nil){

            //get URL
            let url = URL(string: Config.serverURL + "/class")

            // guard url is valid
            guard let requestUrl = url else { fatalError() }

            var request = URLRequest(url: requestUrl)

            // Set http method
            request.httpMethod = "GET"


            // Set HTTP Request Header
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")

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
                        
                        
                        self.loadingView.alpha = 0
                        
                        // make notification
                        let notification = UIAlertController(title: "Nofication", message: "Something went wrong, please try again", preferredStyle: .alert)
                        notification.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(notification, animated: true, completion: nil)
                        
                    }
                    print("Error with the response, unexpected status code: \(String(describing: response))")
                    return
                  }
                // guard we have data
                guard let jsonData = data else {
                    print(data!)
                    return

                }

                let decoder = JSONDecoder()

                do {

                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let result = try decoder.decode(CourseList.self, from: jsonData)
                    self.arrCourses = result.data
                    

                    DispatchQueue.main.async {
                        
                        // Reload data of tbv
                        self.tbvCourses.reloadData()
                        self.loadingView.alpha = 0
                        self.spinner.stopAnimating()
                    }
                } catch {
                    print(error.localizedDescription)
                    debugPrint(error)
                }
            }
            task.resume()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrCourses.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tbvCourses.dequeueReusableCell(withIdentifier: "cell") as! CourseTableViewCell
        
        cell.lblCourse.text = self.arrCourses[indexPath.section].courseCode
        cell.lblRoom.text = self.arrCourses[indexPath.section].room
        cell.backgroundColor = self.hexStringToUIColor(hex: "#097d14")
        
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 2
        
        let x = arrCourses[indexPath.section].teacher!
            switch x {
                case .string(_):
                    cell.lblTeacher.text = "No teacher"
                case .teacherClass(let teacher):
                    cell.lblTeacher.text = teacher.name!
                }
        
        cell.lblStatus.text = self.arrCourses[indexPath.section].timesCheckin
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tbvCourses.frame.height/4
    }
    
    // Set header height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    // Change color
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = self.hexStringToUIColor(hex: "#097d14")
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let QrVC:QRViewController = sb.instantiateViewController(identifier: "qr") as QRViewController
        QrVC.classId = arrCourses[indexPath.section].id!
        navigationController?.pushViewController(QrVC, animated: true)
        
    }
    
}


