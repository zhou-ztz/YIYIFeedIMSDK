//
//  TGTopicCommonModel.swift
//  YIYIFeedIMSDK
//
//  Created by yiyikeji on 2025/1/3.
//

import Foundation
import ObjectMapper

class TGTopicCommonModel {
    /// 话题 id
    var id = 0
    /// 话题名称
    var name = ""

    init() {
    }

    /// 从话题信息 model 初始化
    init(topicModel model: TGTopicModel) {
        id = model.id
        name = model.name
    }

    /// 话题列表 model 初始化
    init(topicListModel model: TopicListModel) {
        id = model.topicId
        name = model.topicTitle
    }
}
