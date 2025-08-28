

## 发送对话消息（流式响应）


**接口地址**:`/admin-api/dify/chat/send-message-stream`


**请求方式**:`POST`


**请求数据类型**:`application/x-www-form-urlencoded,application/json`


**响应数据类型**:`text/event-stream`


**接口描述**:


**请求示例**:


```javascript
{
  "query": "你好，请介绍一下你自己",
  "inputs": {
    "name": "张三"
  },
  "user": "client-1",
  "files": [
    {
      "type": "image",
      "url": "https://example.com/image.jpg",
      "transfer_method": "remote_url",
      "upload_file_id": "file-123"
    }
  ],
  "original_text": "你好，请介绍一下你自己",
  "response_mode": "blocking",
  "conversation_id": "1c7e55fb-1ba2-4e10-81b5-30addcea2276",
  "auto_generate_name": true
}
```


**请求参数**:


**请求参数**:


| 参数名称 | 参数说明 | 请求类型    | 是否必须 | 数据类型 | schema |
| -------- | -------- | ----- | -------- | -------- | ------ |
|chatMessageSendReqVO|管理后台 - 发送对话消息请求 VO|body|true|ChatMessageSendReqVO|ChatMessageSendReqVO|
|&emsp;&emsp;query|用户输入/提问内容||true|string||
|&emsp;&emsp;inputs|允许传入 App 定义的各变量值，默认为空对象||false|object||
|&emsp;&emsp;user|用户标识，用于定义终端用户的身份（系统自动设置）||false|string||
|&emsp;&emsp;files|上传的文件列表||false|array|FileInfo|
|&emsp;&emsp;&emsp;&emsp;type|文件类型，目前仅支持 image||false|string||
|&emsp;&emsp;&emsp;&emsp;url|图片地址（仅当传递方式为 remote_url 时）||false|string||
|&emsp;&emsp;&emsp;&emsp;transfer_method|传递方式：remote_url 图片地址，local_file 上传文件||false|string||
|&emsp;&emsp;&emsp;&emsp;upload_file_id|上传文件 ID（仅当传递方式为 local_file 时）||false|string||
|&emsp;&emsp;original_text|原始文本内容（Dify 特定字段）||false|string||
|&emsp;&emsp;response_mode|响应模式：streaming 流式模式（推荐），blocking 阻塞模式||false|string||
|&emsp;&emsp;conversation_id|会话 ID，需要基于之前的聊天记录继续对话时传入||false|string||
|&emsp;&emsp;auto_generate_name|自动生成标题，默认 true||false|boolean||
|tenant-id|租户编号|header|false|integer(int32)||
|Authorization|认证 Token|header|false|string||


**响应状态**:


| 状态码 | 说明 | schema |
| -------- | -------- | ----- | 
|200|OK||


**响应参数**:


暂无


**响应示例**:
```javascript

```




## 获取建议问题


**接口地址**:`/admin-api/dify/chat/messages/{messageId}/suggested`


**请求方式**:`GET`


**请求数据类型**:`application/x-www-form-urlencoded`


**响应数据类型**:`*/*`


**接口描述**:


**请求参数**:


**请求参数**:


| 参数名称 | 参数说明 | 请求类型    | 是否必须 | 数据类型 | schema |
| -------- | -------- | ----- | -------- | -------- | ------ |
|messageId|消息 ID|path|true|string||
|tenant-id|租户编号|header|false|integer(int32)||
|Authorization|认证 Token|header|false|string||


**响应状态**:


| 状态码 | 说明 | schema |
| -------- | -------- | ----- | 
|200|OK|CommonResultSuggestedQuestionsRespVO|


**响应参数**:


| 参数名称 | 参数说明 | 类型 | schema |
| -------- | -------- | ----- |----- | 
|code||integer(int32)|integer(int32)|
|data||SuggestedQuestionsRespVO|SuggestedQuestionsRespVO|
|&emsp;&emsp;result|操作结果|string||
|&emsp;&emsp;data|建议问题列表|array|string|
|msg||string||


**响应示例**:
```javascript
{
	"code": 0,
	"data": {
		"result": "success",
		"data": "[\"你还想了解什么？\",\"有其他问题吗？\"]"
	},
	"msg": ""
}
```



## 获取消息历史


**接口地址**:`/admin-api/dify/chat/messages`


**请求方式**:`GET`


**请求数据类型**:`application/x-www-form-urlencoded`


**响应数据类型**:`*/*`


**接口描述**:


**请求参数**:


**请求参数**:


| 参数名称 | 参数说明 | 请求类型    | 是否必须 | 数据类型 | schema |
| -------- | -------- | ----- | -------- | -------- | ------ |
|conversationId|会话 ID|query|true|string||
|firstId|第一条消息的 ID，用于分页|query|false|string||
|limit|每页数量|query|false|integer(int32)||
|tenant-id|租户编号|header|false|integer(int32)||
|Authorization|认证 Token|header|false|string||


**响应状态**:


| 状态码 | 说明 | schema |
| -------- | -------- | ----- | 
|200|OK|CommonResultMessageHistoryRespVO|


**响应参数**:


| 参数名称 | 参数说明 | 类型 | schema |
| -------- | -------- | ----- |----- | 
|code||integer(int32)|integer(int32)|
|data||MessageHistoryRespVO|MessageHistoryRespVO|
|&emsp;&emsp;limit|每页数量|integer(int32)||
|&emsp;&emsp;data|消息列表|array|MessageInfo|
|&emsp;&emsp;&emsp;&emsp;id|消息 ID|string||
|&emsp;&emsp;&emsp;&emsp;inputs|输入参数|object||
|&emsp;&emsp;&emsp;&emsp;query|用户问题|string||
|&emsp;&emsp;&emsp;&emsp;answer|AI 回答|string||
|&emsp;&emsp;&emsp;&emsp;feedback|反馈信息|FeedbackInfo|FeedbackInfo|
|&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;rating|评分|string||
|&emsp;&emsp;&emsp;&emsp;conversation_id|会话 ID|string||
|&emsp;&emsp;&emsp;&emsp;message_files|消息文件列表|array|MessageFile|
|&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;id|文件 ID|string||
|&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;type|文件类型|string||
|&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;url|文件 URL|string||
|&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;belongs_to|文件归属|string||
|&emsp;&emsp;&emsp;&emsp;retriever_resources|检索资源列表|array|RetrieverResource|
|&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;position|位置|integer(int32)||
|&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;score|相似度分数|number(double)||
|&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;content|分段内容|string||
|&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;dataset_id|数据集 ID|string||
|&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;dataset_name|数据集名称|string||
|&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;document_id|文档 ID|string||
|&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;document_name|文档名称|string||
|&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;data_source_type|数据源类型|string||
|&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;segment_id|分段 ID|string||
|&emsp;&emsp;&emsp;&emsp;agent_thoughts|Agent 思考过程|array|object|
|&emsp;&emsp;&emsp;&emsp;created_at|创建时间|integer(int64)||
|&emsp;&emsp;has_more|是否有更多数据|boolean||
|msg||string||


**响应示例**:
```javascript
{
	"code": 0,
	"data": {
		"limit": 20,
		"data": [
			{
				"id": "msg-123",
				"inputs": "{\"name\":\"张三\"}",
				"query": "你好",
				"answer": "你好！我是 AI 助手。",
				"feedback": {
					"rating": "like"
				},
				"conversation_id": "conv-123",
				"message_files": [
					{
						"id": "file-123",
						"type": "image",
						"url": "https://example.com/file.jpg",
						"belongs_to": "user"
					}
				],
				"retriever_resources": [
					{
						"position": 1,
						"score": 0.95,
						"content": "这是一个产品介绍的片段...",
						"dataset_id": "dataset-123",
						"dataset_name": "产品知识库",
						"document_id": "doc-123",
						"document_name": "产品介绍.pdf",
						"data_source_type": "upload_file",
						"segment_id": "segment-456"
					}
				],
				"agent_thoughts": [],
				"created_at": 1705569239
			}
		],
		"has_more": false
	},
	"msg": ""
}
```




## 获取会话列表


**接口地址**:`/admin-api/dify/chat/conversations`


**请求方式**:`GET`


**请求数据类型**:`application/x-www-form-urlencoded`


**响应数据类型**:`*/*`


**接口描述**:


**请求参数**:


**请求参数**:


| 参数名称 | 参数说明 | 请求类型    | 是否必须 | 数据类型 | schema |
| -------- | -------- | ----- | -------- | -------- | ------ |
|lastId|最后一个会话的 ID，用于分页|query|false|string||
|limit|每页数量|query|false|integer(int32)||
|tenant-id|租户编号|header|false|integer(int32)||
|Authorization|认证 Token|header|false|string||


**响应状态**:


| 状态码 | 说明 | schema |
| -------- | -------- | ----- | 
|200|OK|CommonResultConversationListRespVO|


**响应参数**:


| 参数名称 | 参数说明 | 类型 | schema |
| -------- | -------- | ----- |----- | 
|code||integer(int32)|integer(int32)|
|data||ConversationListRespVO|ConversationListRespVO|
|&emsp;&emsp;limit|每页数量|integer(int32)||
|&emsp;&emsp;data|会话列表|array|ConversationRespVO|
|&emsp;&emsp;&emsp;&emsp;id|会话 ID|string||
|&emsp;&emsp;&emsp;&emsp;name|会话名称|string||
|&emsp;&emsp;&emsp;&emsp;inputs|输入参数|object||
|&emsp;&emsp;&emsp;&emsp;status|会话状态|string||
|&emsp;&emsp;&emsp;&emsp;introduction|会话介绍|string||
|&emsp;&emsp;&emsp;&emsp;created_at|创建时间|integer(int64)||
|&emsp;&emsp;&emsp;&emsp;updated_at|更新时间|integer(int64)||
|&emsp;&emsp;has_more|是否有更多数据|boolean||
|msg||string||


**响应示例**:
```javascript
{
	"code": 0,
	"data": {
		"limit": 20,
		"data": [
			{
				"id": "1c7e55fb-1ba2-4e10-81b5-30addcea2276",
				"name": "新对话",
				"inputs": "{\"name\":\"张三\"}",
				"status": "normal",
				"introduction": "这是一个关于产品咨询的对话",
				"created_at": 1679667915,
				"updated_at": 1679667915
			}
		],
		"has_more": false
	},
	"msg": ""
}
```