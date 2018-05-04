import UIKit
import Alamofire
import SwiftyJSON

//let appID = "55cf315d"
//let appKey = "b24d5e7e54ec236d112ed4e888ab206b"
//
//var recipeTitle: String?
//var ingr: [String]?
////var url: String?
//var pantry = [String]()
//var concoctions = []

class Yummly: UIViewController {
    
//    @IBAction func add_ingredients(_ sender: Any) {
//        pantry.append(self.textbox.text!)
//        self.textbox.text = ""
//        print(pantry)
//    }
//
//    @IBAction func find_recipes(_ sender: Any) {
//        fetchConcoctions()
//        pantry.removeAll()
//    }
//
    override func viewDidLoad() {
        super.viewDidLoad()
        pantry.append("chicken")
        self.fetchConcoctions()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchConcoctions() {
        
        var concoctions = [String]()
        let url = "https://api.yummly.com/v1/api/recipes"
        
        var search = ""
        
        for ingredient in pantry {
            
            search += ingredient + "+"
        }
        print(search)
        
        let query = ["_app_id": appID, "_app_key": appKey, "q": search]
        
        Alamofire.request(url, method: .get, parameters: query)
            .responseJSON {(responseData) -> Void in
                if((responseData.result.value) != nil) {
                    let json = JSON(responseData.result.value!)
                    print(json)
                    
                    for match in json["matches"].array! {
                        
                        var ingredients = [String]()
                        
                        for ingredient in match["ingredients"].array! {
                            
                            ingredients.append(ingredient.string!)
                        }
                        
                        let title = match["recipeName"].string!
                        let url = "https://www.yummly.com/recipe/" +  match["id"].string!

                        concoctions.append(title)
                    }
                    print(concoctions)
                }
                
                
        }
        
        //                self.concoctionTable.reloadData()
        
    }
}

