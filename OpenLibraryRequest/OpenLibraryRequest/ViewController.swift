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
            // Make sure the text is going to be updated in the main thread.
            DispatchQueue.main.async {
                self.responseTextView.text = String(data: data, encoding: .utf8)!
            }
        }
        
        // Resume the task.
        task.resume()
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

