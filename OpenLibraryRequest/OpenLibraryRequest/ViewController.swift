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
    
    // Reference to the resposnse text view.
    @IBOutlet weak var responseTextView: UITextView!
    
    // Reference to the image view for cover.
    @IBOutlet weak var coverImage: UIImageView!
    
    
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
            This function will process the Data object into a JSON object for management into dictionaries and strings,
     */
    func processRequestData(dataString:Data, isbnText:String){
        // Process the Data as JSON.
        do
        {
            let json = try JSONSerialization.jsonObject(with: dataString, options: []) as? [String : Any]
            
            // Get main dictionaries.
            let dict = json! as NSDictionary
            let isbnDict = dict["ISBN:"+isbnText] as! NSDictionary
            
            // Get information dictionaries from main dictionaries.
            
            // Check for title.
            var titleString = "No title available"
            if(isbnDict["title"] != nil){
                titleString = isbnDict["title"] as! NSString as String
            }
            // Check for authors.
            var authorStringArray:Array<String> = []
            if(isbnDict["authors"] != nil){
                let authorArray = isbnDict["authors"] as? NSArray
                for autor in (authorArray!) {
                    let autorDic = autor as! NSDictionary
                    authorStringArray.append(((autorDic["name"] as! NSString) as String))
                    print(authorStringArray)
                }
            }else{
                authorStringArray.append("No author available")
            }
            
            // Check for cover.
            var coverLink = ""
            if(isbnDict["cover"] != nil){
                coverLink = (isbnDict["cover"] as! NSDictionary)["medium"] as! NSString as String
            }else{
                // Add a placeholder cover if none available
                coverLink = "https://images.squarespace-cdn.com/content/v1/5a5547e1a803bb7df0649e50/1569021071787-GQ6QWL4IMADHSY7W7VH2/ke17ZwdGBToddI8pDm48kKDp-7ip__g8QobJS6Y5m3dZw-zPPgdn4jUwVcJE1ZvWEtT5uBSRWt4vQZAgTJucoTqqXjS3CfNDSuuf31e0tVFhb23Mwiwo3IFHbJH9edcC4_w0H8oueJbNNKCuHf_kD6QvevUbj177dmcMs1F0H-0/placeholder.png?format=500w"
            }
            
            // Assign the values in the text view.
            assignRequestValues(title: titleString, authors: authorStringArray, coverURL: coverLink)
        }
        catch
        {
            showAlert(alertMessage: "Error while parsing JSON.")
        }
    }
    
    
    /**
            This function will set the values parsed from the JSON in the text view and image view.
     */
    func assignRequestValues(title:String, authors:Array<String>, coverURL:String){
        // In this string, the info will be stored.
        var requestString = ""
        
        // Check for title existence.
        if(title != ""){
            // Assign title
            requestString += "Title : "+title + "\n"
        }
        
        // Assign the authors.
        for autor in (authors) {
            requestString += "\nAuthor : " + autor + "\n"
        }
        
        // Add the image to the image view.
        let url = URL(string: coverURL)
        let data = try? Data(contentsOf: url!)
        if let imageData = data {
            let image = UIImage(data: imageData)
            coverImage.image = image
        }
        
        // Assign the text to the text view.
        self.responseTextView.text = requestString
    }
    
    
    /**
           This method will clear the text view response from the screen.
    */
    func clearResponseTextView(){
        // Clear the text.
        responseTextView.text = ""
        
        // Clear the image.
        coverImage.image = nil
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

