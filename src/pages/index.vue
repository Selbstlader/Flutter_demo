<script setup lang="ts">
import { ref } from 'vue'
import SocialSecurityForm from '@/components/SocialSecurityForm.vue'
import PensionForm from '@/components/PensionForm.vue'

const currentIndex = ref(0)

const tabs = [
  {
    id: 'social',
    title: '社保计算',
    icon: 'i-carbon-security',
  },
  {
    id: 'pension',
    title: '养老金计算',
    icon: 'i-carbon-user',
  },
]

// AI对话功能
function goToAIChat() {
  // 跳转到AI对话页面
  uni.navigateTo({
    url: '/pages/ai-chat',
  })
}
</script>

<template>
  <view class="home-page">
    <!-- 顶部导航栏 -->
    <!-- <view class="app-header">
      <view class="header-content">
        <view class="header-left">
          <view class="logo-container">
            <text class="logo-icon i-carbon-calculator" />
          </view>
          <view class="header-info">
            <text class="header-title">社保计算工具</text>
          </view>
        </view>
        <view class="header-actions">
          <button class="action-btn" @click="goToSettings">
            <text class="i-carbon-settings" />
          </button>
        </view>
      </view>
    </view> -->

    <!-- 功能选择区域 -->
    <view class="tab-selector">
      <view
        v-for="(tab, index) in tabs" :key="tab.id" class="tab-item" :class="{ active: currentIndex === index }"
        @click="currentIndex = index"
      >
        <text class="tab-icon" :class="tab.icon" />
        <text class="tab-title">
          {{ tab.title }}
        </text>
      </view>
    </view>

    <!-- 主要内容区域 -->
    <view class="main-content">
      <SocialSecurityForm v-if="currentIndex === 0" />
      <PensionForm v-else-if="currentIndex === 1" />
    </view>

    <!-- AI对话浮动按钮 -->
    <view class="ai-chat-fab" @click="goToAIChat">
      <view class="fab-content">
        <text class="fab-icon i-carbon-chat" />
        <text class="fab-text">
          AI助手
        </text>
      </view>
      <view class="fab-pulse" />
    </view>
  </view>
</template>

<style lang="scss" scoped>
.home-page {
  min-height: 100vh;
  background: #f8fafc;
}

.app-header {
  background: #ffffff;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  padding: env(safe-area-inset-top) 0 0;
  position: sticky;
  top: 0;
  z-index: 100;

  .header-content {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 16px 20px;
  }

  .header-left {
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .logo-container {
    width: 36px;
    height: 36px;
    background: #3b82f6;
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .logo-icon {
    font-size: 18px;
    color: #ffffff;
  }

  .header-info {
    display: flex;
    flex-direction: column;
  }

  .header-title {
    font-size: 18px;
    font-weight: 600;
    color: #1f2937;
  }

  .header-actions {
    display: flex;
    align-items: center;
  }

  .action-btn {
    width: 36px;
    height: 36px;
    background: #f3f4f6;
    border: none;
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #6b7280;
    font-size: 16px;
    transition: all 0.2s ease;

    &:active {
      background: #e5e7eb;
      transform: scale(0.95);
    }
  }
}

.tab-selector {
  display: flex;
  margin: 16px 20px;
  background: #ffffff;
  border-radius: 12px;
  padding: 4px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  position: sticky;
  top: 0;
  z-index: 99;
}

.tab-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 10px;
  border-radius: 8px;
  transition: all 0.2s ease;
  cursor: pointer;

  &.active {
    background: #3b82f6;
    color: #ffffff;

    .tab-icon {
      color: #ffffff;
    }

    .tab-title {
      color: #ffffff;
    }
  }
}

.tab-icon {
  font-size: 24px;
  color: #6b7280;
  margin-bottom: 8px;
  transition: color 0.2s ease;
}

.tab-title {
  font-size: 14px;
  font-weight: 500;
  color: #374151;
  transition: color 0.2s ease;
}

.main-content {
  flex: 1;
  padding: 0 20px 20px;
}

// AI对话浮动按钮样式
.ai-chat-fab {
  position: fixed;
  right: 20px;
  bottom: 120px;
  width: 64px;
  height: 64px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.4);
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  z-index: 1000;
  overflow: hidden;

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 12px 32px rgba(102, 126, 234, 0.5);
  }

  &:active {
    transform: translateY(0) scale(0.95);
    box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
  }

  .fab-content {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    color: #ffffff;
    z-index: 2;
  }

  .fab-icon {
    font-size: 24px;
    margin-bottom: 2px;
    transition: transform 0.3s ease;
  }

  .fab-text {
    font-size: 10px;
    font-weight: 500;
    opacity: 0.9;
    line-height: 1;
  }

  .fab-pulse {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    border-radius: 32px;
    background: rgba(255, 255, 255, 0.1);
    animation: pulse 2s infinite;
  }

  // 悬浮动画效果
  &::before {
    content: '';
    position: absolute;
    top: -2px;
    left: -2px;
    right: -2px;
    bottom: -2px;
    background: linear-gradient(135deg, #667eea, #764ba2, #667eea);
    border-radius: 34px;
    z-index: -1;
    opacity: 0;
    transition: opacity 0.3s ease;
  }

  &:hover::before {
    opacity: 1;
    animation: rotate 3s linear infinite;
  }
}

@keyframes pulse {
  0% {
    transform: scale(1);
    opacity: 0.1;
  }

  50% {
    transform: scale(1.1);
    opacity: 0.2;
  }

  100% {
    transform: scale(1);
    opacity: 0.1;
  }
}

@keyframes rotate {
  0% {
    transform: rotate(0deg);
  }

  100% {
    transform: rotate(360deg);
  }
}

// 响应式适配
@media (max-width: 480px) {
  .ai-chat-fab {
    right: 16px;
    bottom: 120px;
    width: 56px;
    height: 56px;
    border-radius: 28px;

    .fab-icon {
      font-size: 20px;
    }

    .fab-text {
      font-size: 9px;
    }

    &::before {
      border-radius: 30px;
    }
  }
}
</style>

<route lang="yaml">
layout: default
</route>
