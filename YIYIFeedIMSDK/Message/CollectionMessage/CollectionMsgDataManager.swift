//
//  CollectionMsgDataManager.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/4/19.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK

typealias deleteCollectionMsgCall = ((FavoriteMsgModel?) -> Void)?

class CollectionMsgDataManager: NSObject {
    static let collectionManager = CollectionMsgDataManager()
    
    //MARK: collectionMsg to NIMMessage
    func messageModel(model: FavoriteMsgModel?) -> V2NIMMessage? {
        guard let faModel = model else {
            return nil
        }
        var dictModel: SessionDictModel?
        guard let data = faModel.data.data(using: .utf8) else {
            return nil
        }
        do {
            let model = try JSONDecoder().decode(SessionDictModel.self, from: data)
            dictModel = model
        } catch {
           // print("jsonerror = \(error.localizedDescription)")
        }
        
        guard let objectModel = dictModel  else {
            return nil
        }
        var message: V2NIMMessage = V2NIMMessage()
        switch faModel.type {
        case .text:
            message.text = objectModel.content
            break
        case .image:
            guard let dataAttach = objectModel.attachment!.data(using: .utf8) else {
                return nil
            }
            do {
                let attach = try JSONDecoder().decode(IMImageCollectionAttachment.self, from: dataAttach)
                message = MessageUtils.imageV2Message(path: attach.url, name: attach.name, sceneName: nil, width: Int32(attach.w), height: Int32(attach.h))

            } catch {
                print("jsonerror = \(error.localizedDescription)")
            }
            break
        case .audio:
            guard let dataAttach = objectModel.attachment!.data(using: .utf8) else {
                return nil
            }
            do {
                let attach = try JSONDecoder().decode(IMAudioCollectionAttachment.self, from: dataAttach)
                message = MessageUtils.audioV2Message(filePath: attach.url, name: nil, sceneName: nil, duration: Int32(attach.dur))
                
            } catch {
                print("jsonerror = \(error.localizedDescription)")
            }
            break
        case .video:
            guard let dataAttach = objectModel.attachment!.data(using: .utf8) else {
                return nil
            }
            do {
                let attach = try JSONDecoder().decode(IMVideoCollectionAttachment.self, from: dataAttach)
                message = MessageUtils.videoV2Message(filePath: attach.url, name: attach.name, sceneName: nil, width: Int32(attach.w), height: Int32(attach.h), duration: Int32(attach.dur))
               
            } catch {
                print("jsonerror = \(error.localizedDescription)")
            }
            break
        case .location:
            guard let dataAttach = objectModel.attachment!.data(using: .utf8) else {
                return nil
            }
            do {
                let attach = try JSONDecoder().decode(IMLocationCollectionAttachment.self, from: dataAttach)
                message = MessageUtils.locationV2Message(lat: attach.lat, lng: attach.lng, address: attach.title)
            } catch {
                print("jsonerror = \(error.localizedDescription)")
            }
            break
        case .file:
            guard let dataAttach = objectModel.attachment!.data(using: .utf8) else {
                return nil
            }
            do {
                let attach = try JSONDecoder().decode(IMFileCollectionAttachment.self, from: dataAttach)
                message = MessageUtils.fileV2Message(filePath: attach.url, displayName: attach.name, sceneName: nil)
                
            } catch {
                print("jsonerror = \(error.localizedDescription)")
            }
            break
        case .nameCard:
            guard let dataAttach = objectModel.attachment!.data(using: .utf8) else {
                return nil
            }
            do {
                let attach = try JSONSerialization.jsonObject(with: dataAttach, options: []) as! [String: Any]
                
                if let data = attach[CMData] as? [String: Any], let memberId = data[CMContactCard] as? String {

                    let attachment = IMContactCardAttachment()
                    attachment.memberId = memberId
                    let rawAttachment = attachment.encode()
                    message = MessageUtils.customV2Message(text: "", rawAttachment: rawAttachment)
                    
                } else {
                    return nil
                }
            } catch {
                print("jsonerror = \(error.localizedDescription)")
            }
            break
        case .sticker:
            guard let dataAttach = objectModel.attachment!.data(using: .utf8) else {
                return nil
            }
            do {
                let attach = try JSONSerialization.jsonObject(with: dataAttach, options: []) as! [String: Any]
                
                if let data = attach[CMData] as? [String: Any] {
                    let bundleID = data[CMStickerBundleId] as? String
                    let bundleIcon = data[CMStickerIconImage] as? String
                    let bundleName = data[CMStickerName] as? String
                    let bundleDescription = data[CMStickerDiscription] as? String
                    let bundleUrl = data[CMRStickerURL] as? String
                    
//                    let attachment = IMStickerCardAttachment()
//                    attachment.bundleID = bundleID ?? ""
//                    attachment.bundleIcon = bundleIcon ?? ""
//                    attachment.bundleName = bundleName ?? ""
//                    attachment.bundleDescription = bundleDescription ?? ""
//                    attachment.bundleUrl = bundleUrl ?? ""
//                    let customObject = NIMCustomObject()
//                    customObject.attachment = attachment
//                    message.messageObject = customObject
//                    message.apnsContent = "recent_msg_desc_sticker_collection".localized
                    //message.text = ""
                } else {
                    return nil
                }
            } catch {
                print("jsonerror = \(error.localizedDescription)")
            }
            break
        case .link:
            guard let dataAttach = objectModel.attachment!.data(using: .utf8) else {
                return nil
            }
            do {
                let attach = try JSONSerialization.jsonObject(with: dataAttach, options: []) as! [String: Any]
                
                if let data = attach[CMData] as? [String: Any] {
                    let postUrl = data[CMShareURL] as? String
                    let title = data[CMShareTitle] as? String
                    let desc = data[CMShareDescription] as? String
                    let imageURL = data[CMShareImage] as? String
                    let contentType = data[CMShareContentType] as? String
                    let contentUrl = data[CMShareContentUrl] as? String
                    let contentDescribed = data[CMCampaignContent] as? String
                    
                    let attachment = IMSocialPostAttachment()
                    attachment.postUrl = postUrl ?? ""
                    attachment.title = title ?? ""
                    attachment.desc = desc ?? ""
                    attachment.imageURL = imageURL ?? ""
                    attachment.contentType = contentType ?? ""
                    attachment.contentUrl = contentUrl ?? ""
                    attachment.contentDescribed = contentDescribed ?? ""
                    let rawAttachment = attachment.encode()
                    message = MessageUtils.customV2Message(text: "", rawAttachment: rawAttachment)
                } else {
                    return nil
                }
            } catch {
                print("jsonerror = \(error.localizedDescription)")
            }
            break
        case .miniProgram:
            guard let dataAttach = objectModel.attachment!.data(using: .utf8) else {
                return nil
            }
            do {
                let attach = try JSONSerialization.jsonObject(with: dataAttach, options: []) as! [String: Any]
                
                if let data = attach[CMData] as? [String: Any] {
                    let appId = data[CMAppId] as? String
                    let path = data[CMPath] as? String
                    let title = data[CMMPTitle] as? String
                    let desc = data[CMMPDesc] as? String
                    let imageURL = data[CMMPAvatar] as? String
                    let contentType = data[CMMPType] as? String
                    
                    let attachment = IMMiniProgramAttachment()
                    attachment.appId = appId ?? ""
                    attachment.path = path ?? ""
                    attachment.title = title ?? ""
                    attachment.desc = desc ?? ""
                    attachment.imageURL = imageURL ?? ""
                    attachment.contentType = contentType ?? ""
                    
                    let rawAttachment = attachment.encode()
                    message = MessageUtils.customV2Message(text: "", rawAttachment: rawAttachment)
                } else {
                    return nil
                }
            } catch  {
                print("jsonerror = \(error.localizedDescription)")
            }
            break
        case .voucher:
            guard let dataAttach = objectModel.attachment!.data(using: .utf8) else {
                return nil
            }
            do {
                let attach = try JSONSerialization.jsonObject(with: dataAttach, options: []) as! [String: Any]
                
                if let data = attach[CMData] as? [String: Any] {
                    let postUrl = data[CMShareURL] as? String
                    let title = data[CMShareTitle] as? String
                    let desc = data[CMShareDescription] as? String
                    let imageURL = data[CMShareImage] as? String
                    let contentType = data[CMShareContentType] as? String
                    let contentUrl = data[CMShareContentUrl] as? String
                    let contentDescribed = data[CMCampaignContent] as? String
                    
                    let attachment = IMVoucherAttachment()
                    attachment.postUrl = postUrl ?? ""
                    attachment.title = title ?? ""
                    attachment.desc = desc ?? ""
                    attachment.imageURL = imageURL ?? ""
                    attachment.contentType = contentType ?? ""
                    attachment.contentUrl = contentUrl ?? ""
                    let rawAttachment = attachment.encode()
                    message = MessageUtils.customV2Message(text: "", rawAttachment: rawAttachment)
                } else {
                    return nil
                }
            } catch  {
                print("jsonerror = \(error.localizedDescription)")
            }
            break
        default:
            break
        }
        
        
        return message
    }
    
    
}
