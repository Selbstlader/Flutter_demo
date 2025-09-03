/**
 * DeepSeek API 配置
 * 参考Flutter项目中的DeepSeekConfig类
 */
export const DeepSeekConfig = {
  /** API基础URL */
  baseURL: 'https://api.deepseek.com',

  /** API密钥 */
  apiKey: 'sk-a8e4ee88516f40e6a2dc3776d3254846',

  /** 是否允许在浏览器中使用（危险设置） */
  dangerouslyAllowBrowser: true,

  /** 模型配置 */
  model: 'deepseek-chat',

  /** 是否启用流式响应 */
  stream: true,

  /** 最大token数 */
  maxTokens: 8192,

  /** 温度参数，控制回答的随机性 */
  temperature: 0.6,

  /** 重试配置 */
  maxRetries: 3,

  /** 重试延迟（毫秒） */
  retryDelay: 2000,

  /** 请求超时时间（毫秒） */
  timeout: 30000,

  /** 系统提示词 */
  systemPrompt: `您是一位专业的社保和养老金咨询专家，具有丰富的政策解读和实务操作经验。

您的专业领域包括：
• 社会保险政策解读（养老、医疗、失业、工伤、生育保险）
• 养老金计算方法和影响因素
• 个人缴费策略建议
• 退休规划和养老金优化
• 跨地区社保转移接续
• 灵活就业人员社保政策

请遵循以下原则：
1. 提供准确、专业的政策解读
2. 根据用户具体情况给出个性化建议
3. 使用通俗易懂的语言解释复杂概念
4. 及时提醒政策变化和注意事项
5. 保持客观中立，不做投资理财建议

请用温和、专业的语气回答用户问题。`,
} as const

/**
 * 获取完整的API URL
 */
export function getApiUrl(endpoint: string): string {
  return `${DeepSeekConfig.baseURL}${endpoint}`
}

/**
 * 获取请求头
 */
export function getHeaders(): Record<string, string> {
  return {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${DeepSeekConfig.apiKey}`,
    'Accept': 'text/event-stream',
  }
}

/**
 * 验证配置是否有效
 */
export function validateConfig(): boolean {
  return !!(
    DeepSeekConfig.baseURL
    && DeepSeekConfig.apiKey
    && DeepSeekConfig.model
  )
}
