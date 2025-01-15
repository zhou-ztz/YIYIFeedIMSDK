//
//  RLSendFileManager.swift
//  yiyisc
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/1/10.
//

import UIKit
import MobileCoreServices

class RLSendFileManager: NSObject, UIDocumentPickerDelegate {
    static let shared = RLSendFileManager()
    
    private var types: [String] = [(kUTTypeContent as String), (kUTTypeItem as String)]
    var completion: (([URL]) -> Void)?
    
    @objc func presentView(owner: UIViewController) {
        let picker = UIDocumentPickerViewController(documentTypes: types, in: .import)
        picker.delegate = self
        picker.modalPresentationStyle = .fullScreen
        owner.present(picker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        defer { controller.dismiss(animated: true, completion: nil) }
        
        let newUrls = urls.compactMap { url -> URL? in
            let docPath =  NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
            let filePath = docPath + "/chatFile/" + url.lastPathComponent
            do {
                
                // 检查文件夹是否存在
                if !FileManager.default.fileExists(atPath: docPath + "/chatFile/") {
                    // 文件夹不存在，创建文件夹
                    try FileManager.default.createDirectory(atPath: docPath + "/chatFile/", withIntermediateDirectories: true)
                }
                
                if FileManager.default.fileExists(atPath: filePath) {
                    try FileManager.default.removeItem(atPath: filePath)
                }else{
                    let filesArray = try FileManager.default.contentsOfDirectory(atPath: docPath + "/chatFile/" ) as [String]
                    if filesArray.count >= 5 {
                        
                        let path = self.sortFileWithDate(filesArray: filesArray)
                        try FileManager.default.removeItem(atPath: path)
                    }
                }
                
                let data = try Data(contentsOf: url)
                
                FileManager.default.createFile(atPath: filePath, contents: data, attributes: nil)
                return URL(fileURLWithPath: filePath)
            } catch {
                print("file error= \(error)")
                return nil
            }
        }
        completion?(newUrls)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
   
    static func fileIcon(with fileExtension: String) -> (icon: UIImage?, type: String) {
        var image = UIImage.set_image(named: "ic_unknown")
        var text = "msg_tips_file"
        
        let items = ["png", "gif", "jpg", "jpeg", "xls", "xlsx", "ppt", "pptx", "html", "htm", "zip", "7z", "mp4", "mp3", "doc", "docx", "pdf", "txt", "rar"]
        let item = items.firstIndex(of: fileExtension.lowercased()) ?? NSNotFound
        switch item {
        case 0, 1, 2, 3:
            image = UIImage.set_image(named: "file_img")
            text = "Image"
        case 4, 5:
            image = UIImage.set_image(named: "file_xls")
            text = "Xlsx"
        case 6, 7:
            image = UIImage.set_image(named: "file_ppt")
            text = "Ppt"
        case 8, 9:
            image = UIImage.set_image(named: "file_html")
            text = "Html"
        case 10, 11:
            image = UIImage.set_image(named: "file_zip")
            text = "Zip"
        case 12:
            image = UIImage.set_image(named: "file_mp4")
            text = "Media"
        case 13:
            image = UIImage.set_image(named: "file_mp3")
            text = "Media"
        case 14, 15:
            image = UIImage.set_image(named: "file_doc")
            text = "Doc"
        case 16:
            image = UIImage.set_image(named: "file_pdf")
            text = "Pdf"
        case 17:
            image = UIImage.set_image(named: "file_txt")
            text = "Txt"
        case 18:
            image = UIImage.set_image(named: "file_rar")
            text = "Rar"
        default:
            image = UIImage.set_image(named: "ic_unknown")
            text = "msg_tips_file"
        }
        return (icon: image, type: text)
    }
    //根据日期排序
    func sortFileWithDate(filesArray: [String]) -> String{
        
        var dataArray = [[String: Any]]()
        let documentsPath =  NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        for file in filesArray {
            let filePath = documentsPath + "/chatFile/" + file
            let properties = try! FileManager.default.attributesOfItem(atPath: filePath) as [FileAttributeKey : Any]
            let modDate = properties[FileAttributeKey.creationDate]
            
            let dict = ["path": filePath, "date": modDate!] as [String : Any]
            dataArray.append(dict)
            
        }
        
        // sort by creation date
        dataArray.sort { (s1, s2) -> Bool in
            let date1 = s1["date"] as? Date
            let date2 = s2["date"] as? Date
            if date1?.compare(date2!) == .orderedAscending
            {
                return false
            }
            
            if date1?.compare(date2!) == .orderedDescending
            {
                return true
            }
            
            return true
            
        }
        
        let dict = dataArray.last!
        if let path = dict["path"] {
            return path as! String
        }
        
        return ""
    }
    
    
    @objc func covertToFileString(path: String) -> Bool {
        let properties = try! FileManager.default.attributesOfItem(atPath: path)
        let fileSize = properties[FileAttributeKey.size] as! UInt64
        let convertedValue: Double = Double(fileSize)
        // 大于100M
        if convertedValue > 1024 * 1024 * 100 {
            return true
        }
        return false
    }
}
