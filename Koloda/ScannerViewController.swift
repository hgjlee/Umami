//
//  ScannerViewController.swift
//  Koloda_Example
//
//  Created by Jacob Lee on 5/3/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import TesseractOCR
import Alamofire
import SwiftyJSON
import Koloda
import Alamofire_Synchronous

let appID = "55cf315d"
let appKey = "b24d5e7e54ec236d112ed4e888ab206b"
var recipeTitle: String?
var rec_text: String!
var pantry = [String]()
let tagger = NSLinguisticTagger(tagSchemes: [.tokenType, .language, .lexicalClass, .nameType, .lemma], options: 0)
let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace, .omitOther]
var search = ""
let ing_list = ["BACON", "LAMB", "YOGURT", "YGRT", "TOMATO", "TOMATOES", "BASIL", "CHICKEN", "EGGS", "BROCCOLI", "CHEESE", "BRUSSEL SPROUTS", "LETTUCE ICEBERG", "TOFU", "STRAWBERRIES", "STRAWBERRY", "GARLIC", "YELLOW ONIONS", "GREEN BELL PEPPERS", "AVOCADO", "CUCUMBERS", "CUCUMBER", "TUN", "TUNA", "SQUASH", "SPAGHETTI", "A-POTATO", "AVOCADO", "ZUCCHINI", "MUSHROOMS", "CHICK PEAS", "BLACK BEANS", "PEPPERS", "GINGER ROOT", "BUTTERNUT SQUASH", "MILK", "CHEDDAR", "CHICKEN BREAST CUTLET", "CARROTS", "ASPARAGUS", "KALE", "SALMON FILLETS", "LEMONS", "BELL PEPPER", "ROMAIN SALAD", "POTATO", "ALMOND BUTTER", "BUTTER", "KIDNEY BEAN", "TUNA", "EGGPLANT", "PEANUT", "BUTTER", "MILK", "BANANA", "AVOCADO", "SCALLION", "POTATO", "RICE", "APPLES", "WALNUT", "ALMOND", "KOMBUCHA", "CORN", "BEEF", "KALE", "SALAD", "CARROTS", "GINGER", "SWEET POTATOES", "EGGS", "OLIVES", "PORK", "SIRLOIN", "TURKEY", "LIME", "LEMON", "SALT", "SPINACH", "SHRIMP", "COD", "SQUID", "SHALLOTS", "GRAPES", "CABBAGE"
]

//var urls = [(String, String)]()

var concoctions = [(String, String)]()

class ScannerViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var urls = [(String, String)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func takePhoto(_ sender: Any) {
        view.endEditing(true)
        presentImagePicker()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func presentImagePicker() {
        
        let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Image",
                                                       message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraButton = UIAlertAction(title: "Take Photo",
                                             style: .default) { (alert) -> Void in
                                                let imagePicker = UIImagePickerController()
                                                imagePicker.delegate = self
                                                imagePicker.sourceType = .camera
                                                self.present(imagePicker, animated: true)
            }
            imagePickerActionSheet.addAction(cameraButton)
        }
        
        let libraryButton = UIAlertAction(title: "Choose Existing",
                                          style: .default) { (alert) -> Void in
                                            let imagePicker = UIImagePickerController()
                                            imagePicker.delegate = self
                                            imagePicker.sourceType = .photoLibrary
                                            self.present(imagePicker, animated: true)
        }
        imagePickerActionSheet.addAction(libraryButton)
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        imagePickerActionSheet.addAction(cancelButton)
        
        present(imagePickerActionSheet, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let selectedPhoto = info[UIImagePickerControllerOriginalImage] as? UIImage,
            let scaledImage = selectedPhoto.scaleImage(640) {
            
            activityIndicator.startAnimating()
            
            dismiss(animated: true, completion: {
                self.performImageRecognition(scaledImage)
            })
        }
    }
    
    func performImageRecognition(_ image: UIImage) {
        
        if let tesseract = G8Tesseract(language: "eng") {
            tesseract.engineMode = .tesseractCubeCombined
            tesseract.pageSegmentationMode = .auto
            tesseract.image = image.g8_blackAndWhite()
            tesseract.recognize()
            rec_text = tesseract.recognizedText
            self.parse_ingredients(rec_text)
        }
        activityIndicator.stopAnimating()
    }
    

    
    func parse_ingredients(_ recognized: String){
        print(recognized)
        tagger.string = recognized
        let range = NSRange(location: 0, length: recognized.utf16.count)
        tagger.enumerateTags(in: range, unit: .word, scheme: .tokenType, options: options) { tag, tokenRange, stop in
            let word = (recognized as NSString).substring(with: tokenRange)
            pantry.append(contentsOf: word.regex(pattern: "^[A-Z]+$"))
        }
        print(pantry)
        for ing in pantry{
            search += ing + "+"
        }
        textView.text = search
    }
    
    @IBAction func recipeButton(_ sender: Any) {
        let url = "https://api.yummly.com/v1/api/recipes"
        
        let query = ["_app_id": appID, "_app_key": appKey, "q": search]
        
        
        Alamofire.request(url, method: .get, parameters: query)
            .responseJSON {(responseData) -> Void in
                if((responseData.result.value) != nil) {
                    let json = JSON(responseData.result.value!)
                    
                    for match in json["matches"].array! {
                        
                        var ingredients = [String]()
                        
                        for ingredient in match["ingredients"].array! {
                            
                            ingredients.append(ingredient.string!)
                        }
                        
                        let title = match["recipeName"].string!
                        let url = match["smallImageUrls"].array![0].stringValue
                        let tup = (title, url)
                        concoctions.append(tup)
                    }
//                    print(concoctions)
                    
                    self.performSegue(withIdentifier: "ViewController", sender: nil)
                }
//            print(concoctions)
//                self.urls = concoctions
        }
        
    }
    
    
    
//    func presentDestinationViewController(data:[(String, String)]) {
//        let destinationViewController = Bundle.main.loadNibNamed("ViewController",
//                                                                 owner: self, options: nil)![0] as? ViewController
//        destinationViewController?.urls = data
//        present(destinationViewController!, animated: true, completion: nil)
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // get a reference to the second view controller
        let secondViewController = segue.destination as! ViewController
//        print(self.urls)
        // set a variable in the second view controller with the String to pass
//        print(urls)
        secondViewController.urls = concoctions
        print(concoctions)
    }
}

extension String {
    func regex (pattern: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options(rawValue: 0))
            let nsstr = self as NSString
            let all = NSRange(location: 0, length: nsstr.length)
            var matches : [String] = [String]()
            regex.enumerateMatches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: all) {
                (result : NSTextCheckingResult?, _, _) in
                pattern:    if let r = result {
                    let result = nsstr.substring(with: r.range) as String
                    if result.count > 3 && ing_list.contains(result) {
                        matches.append(result)
                    }
                }
                
            }
            return matches  } catch {
            return [String]()
        }
    }
}

extension UIImage {
    func scaleImage(_ maxDimension: CGFloat) -> UIImage? {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        
        if size.width > size.height {
            let scaleFactor = size.height / size.width
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            let scaleFactor = size.width / size.height
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        draw(in: CGRect(origin: .zero, size: scaledSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}
