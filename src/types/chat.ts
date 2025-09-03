/**
 * 聊天消息接口
 * 参考Flutter项目中的ChatMessage类
 */
export interface ChatMessage {
  /** 消息唯一标识 */
  id: string
  /** 消息内容 */
  content: string
  /** 是否为用户消息 */
  isUser: boolean
  /** 消息时间戳 */
  timestamp: Date
  /** 是否正在流式传输 */
  isStreaming?: boolean
}

/**
 * 用户上下文信息接口
 * 参考Flutter项目中的UserContext类
 */
export interface UserContext {
  /** 社保类型 */
  socialSecurityType?: string
  /** 缴费年限 */
  paymentYears?: number
  /** 养老金余额 */
  pensionBalance?: number
  /** 年龄 */
  age?: number
  /** 地区 */
  region?: string
  /** 月收入 */
  monthlyIncome?: number
  /** 就业状态 */
  employmentStatus?: string
}

/**
 * DeepSeek API 请求消息格式
 */
export interface DeepSeekMessage {
  role: 'system' | 'user' | 'assistant'
  content: string
}

/**
 * DeepSeek API 请求体
 */
export interface DeepSeekRequest {
  model: string
  messages: DeepSeekMessage[]
  stream: boolean
  max_tokens?: number
  temperature?: number
}

/**
 * DeepSeek API 响应数据
 */
export interface DeepSeekResponse {
  id: string
  object: string
  created: number
  model: string
  choices: Array<{
    index: number
    delta?: {
      content?: string
      role?: string
    }
    message?: {
      role: string
      content: string
    }
    finish_reason?: string
  }>
}

/**
 * 聊天状态类型
 */
export type ChatStatus = 'idle' | 'sending' | 'streaming' | 'error'

/**
 * 错误类型
 */
export interface ChatError {
  code: string
  message: string
  details?: any
}
