//
//  Network.swift
//  Akeyreu
//
//  Created by Kayvan Fouladinovid on 12/16/23.
//

import Foundation
import CFNetwork

//import requests

//
//
//headers = {
//    "Authorization": "Bearer %s" % token,
//}
//
//response = requests.get('https://api.lifx.com/v1/lights/all', headers=headers)
//
//print(response)
//
//response = requests.get('https://api.lifx.com/v1/lights/all', auth=(token, ''))
//
//print(response)
//
//
//
//data = {
//    "period": 2,
//    "cycles": 5,
//    "color": "green",
//}
//
//response = requests.post('https://api.lifx.com/v1/lights/all/effects/pulse', data=data, headers=headers, auth=(token, ''))
//
//print(response.json())
//print(response.text)
class IOT{
    //var token : String = "c55841124b14357fde31dcb0d553c10276f64d0fa8eeca374fa8951352878b54"
    //var token : String =   "cd604e43ac68e880d5ed3fdfb20e6628bac744a2d4856b949d3b36f969a031b3"
    var token : String = "c27315e7f82a4351d5ff84ff543caee48ce31ccfd787ba3d301d8c0ef265ea82"
    //curent bright
    func change_env(power:String){
        print("IOT running")
        let headers = [
          "accept": "text/plain",
          "content-type": "application/json",
          "Authorization": "Bearer " + token
        ]
        let parameters = [
          "power": power,
          "fast": false
        ] as [String : Any]
        var postData: Data = Data.init()
        do{
            postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        }
        catch{
            print("IOT FAIL")
        }
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.lifx.com/v1/lights/all/state")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "PUT"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
          if (error != nil) {
            print(error as Any)
          } else {
            let httpResponse = response as? HTTPURLResponse
            print(httpResponse)
          }
        })
        dataTask.resume()
        
        
    }
    func change_env(parameters:[String:Any]){
        print("IOT running")
        let headers = [
          "accept": "text/plain",
          "content-type": "application/json",
          "Authorization": "Bearer " + token
        ]
        var postData: Data = Data.init()
        do{
            postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        }
        catch{
            print("IOT FAIL")
        }
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.lifx.com/v1/lights/all/state")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "PUT"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
          if (error != nil) {
            print(error as Any)
          } else {
            let httpResponse = response as? HTTPURLResponse
            print(httpResponse)
          }
        })
        dataTask.resume()
        
        
    }
    func dim (){
        
        let data: [String : Any] = [
            "power" : "off"
        ]
        change_env(parameters: data)
        
    }
    func noMotionRest (){
        
        let data: [String : Any] = [
            "power" : "off"
        ]
        change_env(parameters: data)

    }
    func noMotion90 (){
        
        let data: [String : Any] = [
            "color" : "red"
        ]
        change_env(parameters: data)

    }
    func motion90 (){
        
        let data: [String : Any] = [
            "color" : "yellow"
        ]
        change_env(parameters: data)

    }
    func motion100 (){
        
        let data: [String : Any] = [
            "color" : "blue"
        ]
        change_env(parameters: data)

    }
    func noMotion100 (){
        
        let data: [String : Any] = [
            "color" : "purple"
        ]
        change_env(parameters: data)

    }
    //Func DIm
        //Func Off Dim 100
    //Func Bright 
}


