//
//  ViewController.swift
//  OpenLibraryRequest
//
//  Created by Ivan Pedrero on 3/19/20.
//  Copyright © 2020 Ivan Pedrero. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // Reference to the search text.
    @IBOutlet weak var isbnText: UITextField!
    
    // Reference to the resposne text view.
    @IBOutlet weak var responseTextView: UITextView!
    
    // Search button action.
    @IBAction func searchButtonAction(_ sender: UIButton) {
        // Get the text from the text field.
        // An example of this would be: 978-84-376-0494-7
        let isbn:String? = isbnText.text
        
        // Avoid errors.
        if(isbn == "" || isbn!.count < 10){
            showAlert(alertMessage: "Please provide a valid ISBN.")
            return
        }
        
        // Search the isbn.
        searchISBN(isbnText: isbn!)
    }
    
    // Clear button action.
    @IBAction func clearButtonAction(_ sender: UIButton) {
        // Clear the response text view.
        clearResponseTextView()
    }
    
    
    /**
            This method will search for a given ISBN number to get a response from the server.
     */
    func searchISBN(isbnText:String){
        // Avoid internet connection errors.
        if !Reachability.isConnectedToNetwork(){
            showAlert(alertMessage: "No internet connection.")
            return
        }
        
        // Add to the URL the ISBN given as text.
        let urlForRequest = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:" + isbnText
                
        // Create an URL.
        let url = URL(string: urlForRequest)!
        
        // Create the task.
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.processRequestData(dataString: data, isbnText: isbnText)
            }
            
        }
        
        // Resume the task.
        task.resume()
    }
    
    
    /**
     This function will process the Data object into a JSON object for management into dictionaries,
     */
    func processRequestData(dataString:Data, isbnText:String){
        
        do
        {
            let json = try JSONSerialization.jsonObject(with: dataString, options: []) as? [String : Any]
            
            // Get main dictionaries.
            let dict = json! as NSDictionary
            let isbnDict = dict["ISBN:"+isbnText] as! NSDictionary
            
            // Get information dictionaries from main dictionaries.
            let authorArray = isbnDict["authors"] as! NSArray
            let titleString = isbnDict["title"] as! NSString as String
            let coverLink = (isbnDict["cover"] as! NSDictionary)["medium"] as! NSString as String
            
            // Assign the values in the text view.
            assignRequestValues(title: titleString, authors: authorArray, coverURL: coverLink)
        }
        catch
        {
            showAlert(alertMessage: "Error while parsing JSON.")
        }
    }
    
    
    func assignRequestValues(title:String, authors:NSArray, coverURL:String){
        // In this string, the info will be stored.
        var requestString = ""
        
        // Assign title
        requestString += "Title : "+title + "\n"
        
        // Assign the authors.
        for autor in (authors) {
            let autorDic = autor as! NSDictionary
            requestString += "\nAutor : " + ((autorDic["name"] as! NSString) as String) + "\n"
        }
        
        // TODO: Add it to an image view.
        // Add the image.
        requestString += "\nImage : " + coverURL
        
        self.responseTextView.text = requestString
    }
    
    
    /**
           This method will clear the text view response from the screen.
    */
    func clearResponseTextView(){
        // Clear the text.
        responseTextView.text = ""
    }
    
    
    /**
            This method will show an alert in case of a request error with a given text.
     */
    func showAlert(alertMessage:String){
        // Create the alert.
        let alert = UIAlertController(title: "Request Error", message: alertMessage, preferredStyle: .alert)

        // Add the accept button with no action.
        alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: nil))

        // Present it on the sceen.
        self.present(alert, animated: true)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

