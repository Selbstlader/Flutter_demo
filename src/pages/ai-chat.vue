<script setup lang="ts">
import { computed, nextTick, onMounted, onUnmounted, ref, watch } from 'vue'
import { useDeepSeek } from '../composables/useDeepSeek'

// 使用DeepSeek服务
const {
  messages,
  error,
  isStreaming,
  isSending,
  hasError,
  addWelcomeMessage,
  sendMessage,
  stopStreaming,
  resetError,
} = useDeepSeek()

// 响应式数据
const inputMessage = ref('')
const messagesContainer = ref<HTMLElement>()

// 计算属性
const canSend = computed(() => {
  return inputMessage.value.trim().length > 0 && !isStreaming.value && !isSending.value
})

// 方法
function goBack() {
  uni.navigateBack()
}

async function handleSend() {
  if (!canSend.value)
    return

  const message = inputMessage.value.trim()
  inputMessage.value = ''

  try {
    await sendMessage(message)
    // 发送消息后立即滚动到底部
    await nextTick()
    scrollToBottom()
  }
  catch (err) {
    console.error('发送消息失败:', err)
    // 即使发送失败也要滚动到底部显示错误信息
    await nextTick()
    scrollToBottom()
  }
}

function handleNewLine(...args: unknown[]) {
  const event = args[0] as Event | undefined
  // 确保在小程序环境下也能正常换行
  if (event)
    event.preventDefault()

  inputMessage.value += '\n'

  // 在小程序环境下，手动触发输入框更新
  nextTick(() => {
    // 确保光标位置正确
    const textarea = event?.target as HTMLTextAreaElement
    if (textarea) {
      const cursorPos = inputMessage.value.length
      textarea.setSelectionRange(cursorPos, cursorPos)
    }
  })
}

// 输入框焦点事件处理
function onInputFocus() {
  // 小程序环境下键盘弹起时的处理
  nextTick(() => {
    scrollToBottom()
  })
}

function onInputBlur() {
  // 输入框失焦时的处理
}

function scrollToBottom() {
  if (messagesContainer.value) {
    const container = messagesContainer.value
    const scrollHeight = container.scrollHeight
    const clientHeight = container.clientHeight

    // 确保需要滚动
    if (scrollHeight > clientHeight) {
      container.scrollTop = scrollHeight

      // 小程序环境下的额外处理
      if (typeof uni !== 'undefined') {
        // 使用 nextTick 确保 DOM 更新完成
        nextTick(() => {
          container.scrollTop = container.scrollHeight
        })
      }
    }
  }
}

// 节流滚动函数，避免频繁滚动影响性能
let scrollTimeout: ReturnType<typeof setTimeout>
let lastScrollTime = 0
const SCROLL_THROTTLE_MS = 50 // 减少延迟，提高响应速度

function throttledScrollToBottom() {
  const now = Date.now()
  const timeSinceLastScroll = now - lastScrollTime

  if (timeSinceLastScroll >= SCROLL_THROTTLE_MS) {
    // 立即滚动
    scrollToBottom()
    lastScrollTime = now
  }
  else {
    // 延迟滚动
    clearTimeout(scrollTimeout)
    scrollTimeout = setTimeout(() => {
      scrollToBottom()
      lastScrollTime = Date.now()
    }, SCROLL_THROTTLE_MS - timeSinceLastScroll)
  }
}

// 监听消息变化，自动滚动到底部
function watchMessages() {
  throttledScrollToBottom()
}

// 生命周期
onMounted(() => {
  addWelcomeMessage()

  // 监听消息数量变化（新消息添加时）
  const unwatch = watch(
    () => messages.value.length,
    () => {
      // 新消息时立即滚动
      nextTick(() => {
        scrollToBottom()
      })
    },
    { flush: 'post' },
  )

  // 监听流式消息内容变化（更频繁的监听）
  const unwatchContent = watch(
    () => messages.value.map(m => m.content).join(''),
    () => watchMessages(),
    { flush: 'post' },
  )

  // 监听流式状态变化
  const unwatchStreaming = watch(
    () => isStreaming.value,
    (newVal) => {
      if (newVal) {
        // 开始流式响应时滚动到底部
        nextTick(() => {
          scrollToBottom()
        })
      }
    },
    { flush: 'post' },
  )

  // 监听当前流式消息的内容变化（实时滚动）
  const unwatchStreamingContent = watch(
    () => {
      const streamingMessage = messages.value.find(m => m.isStreaming)
      return streamingMessage ? streamingMessage.content : ''
    },
    () => {
      if (isStreaming.value)
        watchMessages()
    },
    { flush: 'post' },
  )

  onUnmounted(() => {
    unwatch()
    unwatchContent()
    unwatchStreaming()
    unwatchStreamingContent()
    clearTimeout(scrollTimeout)
  })
})

// 页面标题
uni.setNavigationBarTitle({
  title: 'AI智能助手',
})
</script>

<template>
  <div class="min-h-screen from-slate-50 to-slate-200 bg-gradient-to-b">
    <!-- 顶部导航栏 -->
    <div class="border-b border-slate-200 bg-white shadow-sm">
      <div class="flex items-center justify-between px-4 py-3">
        <div class="flex items-center">
          <button class="mr-3 rounded-full p-2 transition-colors hover:bg-slate-100" @click="goBack">
            <div class="i-carbon-arrow-left h-5 w-5 text-slate-600" />
          </button>

          <div class="flex items-center">
            <div
              class="h-9 w-9 flex items-center justify-center rounded-full from-indigo-500 to-purple-600 bg-gradient-to-br shadow-lg"
            >
              <div class="i-carbon-watson h-5 w-5 text-white" />
            </div>
            <div class="ml-3">
              <h1 class="text-lg text-slate-800 font-bold">
                AI智能助手
              </h1>
              <p class="text-xs text-slate-500">
                社保养老金专家
              </p>
            </div>
          </div>
        </div>

        <!-- <div class="flex items-center space-x-2">
          <button
            v-if="isStreaming" class="rounded-full bg-red-500 p-2 shadow-lg transition-colors hover:bg-red-600"
            @click="stopStreaming"
          >
            <div class="i-carbon-stop h-4 w-4 text-white" />
          </button>
          <button class="rounded-full p-2 transition-colors hover:bg-slate-100">
            <div class="i-carbon-overflow-menu-vertical h-5 w-5 text-slate-600" />
          </button>
        </div> -->
      </div>
    </div>

    <!-- 聊天消息区域 -->
    <div class="flex-1 overflow-hidden">
      <div ref="messagesContainer" class="messages-container">
        <div
          v-for="message in messages" :key="message.id" class="flex"
          :class="message.isUser ? 'justify-end' : 'justify-start'"
        >
          <div class="max-w-[80%] flex items-end" :class="message.isUser ? 'flex-row-reverse' : 'flex-row'">
            <!-- 头像 -->
            <div
              class="h-8 w-8 flex flex-shrink-0 items-center justify-center rounded-full shadow-md" :class="message.isUser
                ? 'bg-gradient-to-br from-slate-500 to-slate-600 ml-2'
                : 'bg-gradient-to-br from-indigo-500 to-purple-600 mr-2'"
            >
              <div
                class="h-4 w-4 text-white"
                :class="message.isUser ? 'i-carbon-user' : 'i-carbon-watson'"
              />
            </div>

            <!-- 消息气泡 -->
            <div
              class="max-w-full rounded-2xl px-4 py-3 shadow-lg" :class="[
                message.isUser
                  ? 'bg-gradient-to-br from-indigo-500 to-purple-600 text-white rounded-br-md'
                  : 'bg-white text-slate-700 border border-slate-200 rounded-bl-md',
              ]"
            >
              <div class="whitespace-pre-wrap text-sm leading-relaxed">
                {{ message.content }}
              </div>

              <!-- 流式输入动画 -->
              <div v-if="message.isStreaming" class="mt-2 flex items-center">
                <div class="flex space-x-1">
                  <div
                    v-for="i in 3" :key="i" class="h-1.5 w-1.5 animate-bounce rounded-full bg-indigo-400"
                    :style="{ animationDelay: `${(i - 1) * 0.2}s` }"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 错误提示 -->
        <div v-if="hasError && error" class="flex justify-center">
          <div class="max-w-md border border-red-200 rounded-lg bg-red-50 px-4 py-3">
            <div class="flex items-center">
              <div class="i-carbon-warning mr-2 h-5 w-5 text-red-500" />
              <div>
                <p class="text-sm text-red-800 font-medium">
                  发送失败
                </p>
                <p class="mt-1 text-xs text-red-600">
                  {{ error.message }}
                </p>
              </div>
            </div>
            <button class="mt-2 text-xs text-red-600 underline hover:text-red-800" @click="resetError">
              重试
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 输入区域 -->
    <div class="input-area">
      <div class="input-container">
        <div class="input-wrapper">
          <textarea
            v-model="inputMessage"
            :disabled="isStreaming || isSending"
            placeholder="请输入您的社保或养老金问题..."
            class="input-textarea"
            :class="{
              'input-disabled': isStreaming || isSending,
              'input-enabled': !isStreaming && !isSending,
            }"
            rows="2"
            :maxlength="100"
            @keydown.enter.exact.prevent="handleSend"
            @keydown.enter.shift.exact="handleNewLine"
            @focus="onInputFocus"
            @blur="onInputBlur"
          />
        </div>

        <!-- 停止按钮 -->
        <button
          v-if="isStreaming"
          class="action-button stop-button"
          @click="stopStreaming"
        >
          <div class="button-icon i-carbon-stop" />
        </button>

        <!-- 发送按钮 -->
        <button
          :disabled="!canSend"
          class="action-button send-button"
          :class="{
            'send-enabled': canSend,
            'send-disabled': !canSend,
          }"
          @click="handleSend"
        >
          <div v-if="isSending" class="loading-spinner" />
          <div v-else class="button-icon i-carbon-send" />
        </button>
      </div>

      <!-- 字数统计和提示 -->
      <!-- <div class="input-footer">
        <div class="input-hint">
          按 Enter 发送，Shift + Enter 换行
        </div>
        <div class="char-count">
          {{ inputMessage.length }}/100
        </div>
      </div> -->
    </div>
  </div>
</template>

<style scoped>
/* 自定义滚动条 */
::-webkit-scrollbar {
  width: 4px;
}

::-webkit-scrollbar-track {
  background: transparent;
}

::-webkit-scrollbar-thumb {
  background: rgba(148, 163, 184, 0.3);
  border-radius: 2px;
}

::-webkit-scrollbar-thumb:hover {
  background: rgba(148, 163, 184, 0.5);
}

/* 动画 */
@keyframes bounce {
  0%,
  80%,
  100% {
    transform: scale(0);
  }

  40% {
    transform: scale(1);
  }
}

.animate-bounce {
  animation: bounce 1.4s infinite ease-in-out;
}

/* 消息容器样式 */
.messages-container {
  height: calc(100vh - 60px - 120px); /* 减去顶部导航和输入区域高度 */
  overflow-y: auto;
  padding: 16px;
  display: flex;
  flex-direction: column;
  gap: 16px;
  -webkit-overflow-scrolling: touch;
}

/* 小程序环境下的消息容器适配 */
@media screen and (max-width: 750px) {
  .messages-container {
    height: calc(100vh - 60px - 140px); /* 为小程序留出更多底部空间 */
    padding-bottom: calc(16px + env(safe-area-inset-bottom));
  }
}

/* 输入区域样式 - 小程序兼容 */
.input-area {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: #ffffff;
  border-top: 1px solid #e2e8f0;
  box-shadow: 0 -4px 6px -1px rgba(0, 0, 0, 0.1);
  padding: 12px 16px;
  padding-bottom: calc(12px + env(safe-area-inset-bottom));
  z-index: 1000;
  transition: transform 0.3s ease;
}

/* 小程序环境适配 */
@media screen and (max-width: 750px) {
  .input-area {
    padding-bottom: calc(12px + 12px); /* 为小程序底部留出更多空间 */
  }
}

.input-container {
  display: flex;
  align-items: flex-end;
  gap: 12px;
}

.input-wrapper {
  flex: 1;
  min-width: 0;
}

.input-textarea {
  width: 100%;
  min-height:70px;
  max-height: 70px;
  line-height: 1.5;
  resize: none;
  border: 1px solid #cbd5e1;
  border-radius: 16px;
  padding: 12px 16px;
  font-size: 14px;
  transition: all 0.2s ease;
  outline: none;
  box-sizing: border-box;
  -webkit-appearance: none;
  -webkit-tap-highlight-color: transparent;
}

.input-textarea:focus {
  border-color: transparent;
  box-shadow: 0 0 0 2px #6366f1;
}

.input-enabled {
  background-color: #ffffff;
  color: #374151;
}

.input-disabled {
  background-color: #f8fafc;
  color: #9ca3af;
  cursor: not-allowed;
}

.action-button {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 48px;
  height: 48px;
  border-radius: 16px;
  border: none;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
  transition: all 0.2s ease;
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
  flex-shrink: 0;
}

.stop-button {
  background-color: #ef4444;
  color: #ffffff;
}

.stop-button:active {
  background-color: #dc2626;
  transform: scale(0.95);
}

.send-button {
  position: relative;
}

.send-enabled {
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
  color: #ffffff;
}

.send-enabled:active {
  background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
  transform: scale(0.95);
}

.send-disabled {
  background-color: #cbd5e1;
  color: #64748b;
  cursor: not-allowed;
}

.button-icon {
  width: 20px;
  height: 20px;
}

.loading-spinner {
  width: 20px;
  height: 20px;
  border: 2px solid #ffffff;
  border-top: 2px solid transparent;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

.input-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 8px;
  font-size: 12px;
  color: #64748b;
}

.input-hint {
  flex: 1;
}

.char-count {
  flex-shrink: 0;
}

/* 键盘弹起时的适配 */
.keyboard-active .input-area {
  transform: translateY(0);
}

/* 小程序特殊适配 */
/* #ifdef MP-WEIXIN */
.input-area {
  padding-bottom: calc(12px + 12px); /* 微信小程序底部安全区域 */
}
/* #endif */

/* 防止在小程序中出现滚动问题 */
.input-textarea {
  -webkit-overflow-scrolling: touch;
  overflow-y: auto;
}

/* 优化触摸体验 */
.action-button:active {
  opacity: 0.8;
}

.input-textarea:focus {
  -webkit-user-select: text;
  user-select: text;
}
</style>
