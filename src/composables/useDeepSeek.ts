import { computed, ref } from 'vue'
import type { ChatError, ChatMessage, ChatStatus, DeepSeekRequest, DeepSeekResponse, UserContext } from '../types/chat'
import { DeepSeekConfig, getApiUrl, getHeaders, validateConfig } from '../config/deepseek'

// AbortController polyfill for environments that don't support it
class SimpleAbortController {
  private _aborted = false

  get signal() {
    return {
      aborted: this._aborted,
    }
  }

  abort() {
    this._aborted = true
  }
}

// 检测并使用合适的 AbortController
function getAbortController(): typeof AbortController | typeof SimpleAbortController {
  if (typeof AbortController !== 'undefined')
    return AbortController

  return SimpleAbortController
}

/**
 * DeepSeek API 服务 Composable
 * 参考Flutter项目中的DeepSeekService实现
 */
export function useDeepSeek() {
  const messages = ref<ChatMessage[]>([])
  const status = ref<ChatStatus>('idle')
  const error = ref<ChatError | null>(null)
  const currentStreamingId = ref<string>('')
  const abortController = ref<InstanceType<ReturnType<typeof getAbortController>> | null>(null)

  // 计算属性
  const isStreaming = computed(() => status.value === 'streaming')
  const isSending = computed(() => status.value === 'sending')
  const isIdle = computed(() => status.value === 'idle')
  const hasError = computed(() => status.value === 'error')

  /**
   * 添加欢迎消息
   */
  function addWelcomeMessage() {
    const welcomeMessage: ChatMessage = {
      id: `welcome_${Date.now()}`,
      content: '您好！我是AI智能助手，专门为您提供社保和养老金相关咨询服务。\n\n我可以帮助您：\n• 社保政策解读\n• 养老金计算\n• 缴费策略建议\n• 退休规划指导\n\n请问有什么可以帮助您的吗？',
      isUser: false,
      timestamp: new Date(),
    }
    messages.value.push(welcomeMessage)
  }

  /**
   * 发送消息
   */
  async function sendMessage(content: string, userContext?: UserContext): Promise<void> {
    if (!content.trim() || isStreaming.value || isSending.value)
      return

    // 验证配置
    if (!validateConfig())
      throw new Error('DeepSeek配置无效')

    // 添加用户消息
    const userMessage: ChatMessage = {
      id: `user_${Date.now()}`,
      content: content.trim(),
      isUser: true,
      timestamp: new Date(),
    }
    messages.value.push(userMessage)

    // 设置发送状态
    status.value = 'sending'
    error.value = null

    // 创建AI消息占位符
    currentStreamingId.value = `ai_${Date.now()}`
    const aiMessage: ChatMessage = {
      id: currentStreamingId.value,
      content: '',
      isUser: false,
      timestamp: new Date(),
      isStreaming: true,
    }
    messages.value.push(aiMessage)

    try {
      await streamResponse(content, userContext)
    }
    catch (err) {
      handleError(err as Error)
    }
  }

  /**
   * 检测当前环境是否支持 fetch API
   */
  function isFetchSupported(): boolean {
    return typeof fetch !== 'undefined'
  }

  /**
   * 使用 uni.request 发送请求（小程序环境）
   */
  function uniRequest(url: string, options: any): Promise<any> {
    return new Promise((resolve, reject) => {
      uni.request({
        url,
        method: options.method || 'GET',
        header: options.headers || {},
        data: options.body ? JSON.parse(options.body) : undefined,
        success: (res) => {
          resolve({
            ok: res.statusCode >= 200 && res.statusCode < 300,
            status: res.statusCode,
            statusText: res.statusCode === 200 ? 'OK' : 'Error',
            json: () => Promise.resolve(res.data),
          })
        },
        fail: (err) => {
          reject(new Error(err.errMsg || '网络请求失败'))
        },
      })
    })
  }

  /**
   * 流式响应处理
   */
  async function streamResponse(content: string, userContext?: UserContext): Promise<void> {
    const request = buildRequest(content, userContext)

    // 创建新的AbortController（兼容性处理）
    const AbortControllerClass = getAbortController()
    abortController.value = new AbortControllerClass()

    try {
    // 检测环境并选择合适的请求方式
      if (isFetchSupported()) {
        await handleFetchRequest(request)
      }
      else {
      // 小程序环境，降级为普通请求（不支持流式）
        await handleUniRequest(request)
      }
    }
    catch (err) {
    // 检查是否是中断错误（支持原生 AbortError 和自定义中断）
      if (err instanceof Error
        && (err.name === 'AbortError'
        || err.message === 'Request aborted'
        || abortController.value?.signal.aborted))
        handleStreamStop()
      else
        throw err
    }
  }

  /**
   * 使用 fetch 处理请求（支持流式响应）
   */
  async function handleFetchRequest(request: DeepSeekRequest): Promise<void> {
  // 构建 fetch 选项
    const fetchOptions: RequestInit = {
      method: 'POST',
      headers: getHeaders(),
      body: JSON.stringify(request),
    }

    // 只有在支持原生 AbortController 时才添加 signal
    if (typeof AbortController !== 'undefined' && abortController.value)
      fetchOptions.signal = abortController.value.signal as AbortSignal

    const response = await fetch(getApiUrl('/chat/completions'), fetchOptions)

    if (!response.ok)
      throw new Error(`HTTP ${response.status}: ${response.statusText}`)

    if (!response.body)
      throw new Error('响应体为空')

    // 设置流式状态
    status.value = 'streaming'

    const reader = response.body.getReader()
    const decoder = new TextDecoder()
    let buffer = ''

    while (true) {
    // 检查是否被中断
      if (abortController.value?.signal.aborted) {
        reader.cancel()
        throw new Error('Request aborted')
      }

      const { done, value } = await reader.read()

      if (done)
        break

      buffer += decoder.decode(value, { stream: true })
      const lines = buffer.split('\n')
      buffer = lines.pop() || ''

      for (const line of lines) {
      // 再次检查是否被中断
        if (abortController.value?.signal.aborted) {
          reader.cancel()
          throw new Error('Request aborted')
        }

        if (line.trim() === '')
          continue
        if (line.startsWith('data: ')) {
          const data = line.slice(6)
          if (data === '[DONE]') {
            handleStreamComplete()
            return
          }

          try {
            const parsed: DeepSeekResponse = JSON.parse(data)
            handleStreamChunk(parsed)
          }
          catch (parseError) {
            console.warn('解析流数据失败:', parseError)
          }
        }
      }
    }

    handleStreamComplete()
  }

  /**
   * 使用 uni.request 处理请求（小程序环境，不支持流式）
   */
  async function handleUniRequest(request: DeepSeekRequest): Promise<void> {
    // 小程序不支持流式响应，修改请求为非流式
    const nonStreamRequest = {
      ...request,
      stream: false,
    }

    // 设置发送状态
    status.value = 'streaming'

    const response = await uniRequest(getApiUrl('/chat/completions'), {
      method: 'POST',
      headers: getHeaders(),
      body: JSON.stringify(nonStreamRequest),
    })

    if (!response.ok)
      throw new Error(`HTTP ${response.status}: ${response.statusText}`)

    const data = await response.json()

    // 检查是否被中断
    if (abortController.value?.signal.aborted)
      throw new Error('Request aborted')

    // 模拟流式响应效果
    const content = data.choices?.[0]?.message?.content || ''
    if (content)
      await simulateStreamingResponse(content)

    handleStreamComplete()
  }

  /**
   * 模拟流式响应效果（小程序环境）
   */
  async function simulateStreamingResponse(content: string): Promise<void> {
    const messageIndex = messages.value.findIndex(msg => msg.id === currentStreamingId.value)
    if (messageIndex === -1)
      return

    const words = content.split('')
    let currentContent = ''

    for (let i = 0; i < words.length; i++) {
    // 检查是否被中断
      if (abortController.value?.signal.aborted)
        throw new Error('Request aborted')

      currentContent += words[i]

      // 更新消息内容
      const currentMessage = messages.value[messageIndex]
      messages.value[messageIndex] = {
        ...currentMessage,
        content: currentContent,
      }

      // 添加延迟以模拟打字效果
      if (i < words.length - 1)
        await new Promise(resolve => setTimeout(resolve, 20))
    }
  }

  /**
   * 处理流式数据块
   */
  function handleStreamChunk(response: DeepSeekResponse): void {
    const choice = response.choices?.[0]
    if (!choice?.delta?.content)
      return

    const messageIndex = messages.value.findIndex(msg => msg.id === currentStreamingId.value)
    if (messageIndex !== -1) {
      const currentMessage = messages.value[messageIndex]
      messages.value[messageIndex] = {
        ...currentMessage,
        content: currentMessage.content + choice.delta.content,
      }
    }
  }

  /**
   * 处理流式完成
   */
  function handleStreamComplete(): void {
    const messageIndex = messages.value.findIndex(msg => msg.id === currentStreamingId.value)
    if (messageIndex !== -1) {
      messages.value[messageIndex] = {
        ...messages.value[messageIndex],
        isStreaming: false,
      }
    }
    status.value = 'idle'
    currentStreamingId.value = ''
    abortController.value = null
  }

  /**
   * 处理流式停止
   */
  function handleStreamStop(): void {
    const messageIndex = messages.value.findIndex(msg => msg.id === currentStreamingId.value)
    if (messageIndex !== -1) {
      const currentMessage = messages.value[messageIndex]
      messages.value[messageIndex] = {
        ...currentMessage,
        content: currentMessage.content || '对话已被用户终止',
        isStreaming: false,
      }
    }
    status.value = 'idle'
    currentStreamingId.value = ''
    abortController.value = null
  }

  /**
   * 停止流式响应
   */
  function stopStreaming(): void {
    if (abortController.value)
      abortController.value.abort()
  }

  /**
   * 处理错误
   */
  function handleError(err: Error): void {
    const chatError: ChatError = {
      code: 'SEND_MESSAGE_ERROR',
      message: err.message,
      details: err,
    }

    error.value = chatError
    status.value = 'error'

    const messageIndex = messages.value.findIndex(msg => msg.id === currentStreamingId.value)
    if (messageIndex !== -1) {
      messages.value[messageIndex] = {
        ...messages.value[messageIndex],
        content: `抱歉，发生了错误：${err.message}\n\n请稍后重试或检查网络连接。`,
        isStreaming: false,
      }
    }
    else {
      // 创建新的错误消息
      const errorMessage: ChatMessage = {
        id: `error_${Date.now()}`,
        content: `抱歉，发生了错误：${err.message}`,
        isUser: false,
        timestamp: new Date(),
      }
      messages.value.push(errorMessage)
    }

    currentStreamingId.value = ''
    abortController.value = null
  }

  /**
   * 构建请求体
   */
  function buildRequest(content: string, userContext?: UserContext): DeepSeekRequest {
    const systemMessage = {
      role: 'system' as const,
      content: DeepSeekConfig.systemPrompt + (userContext ? `\n\n用户上下文信息：${JSON.stringify(userContext)}` : ''),
    }

    const userMessage = {
      role: 'user' as const,
      content,
    }

    return {
      model: DeepSeekConfig.model,
      messages: [systemMessage, userMessage],
      stream: DeepSeekConfig.stream,
      max_tokens: DeepSeekConfig.maxTokens,
      temperature: DeepSeekConfig.temperature,
    }
  }

  /**
   * 清空消息
   */
  function clearMessages(): void {
    messages.value = []
    status.value = 'idle'
    error.value = null
    currentStreamingId.value = ''
  }

  /**
   * 重置错误状态
   */
  function resetError(): void {
    error.value = null
    if (status.value === 'error')
      status.value = 'idle'
  }

  return {
    // 响应式数据
    messages,
    status,
    error,

    // 计算属性
    isStreaming,
    isSending,
    isIdle,
    hasError,

    // 方法
    addWelcomeMessage,
    sendMessage,
    stopStreaming,
    clearMessages,
    resetError,
  }
}
