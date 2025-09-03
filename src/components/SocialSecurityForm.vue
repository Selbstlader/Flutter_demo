<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import type { RegionData, RegionInfo, RegionOption } from '@/types/region'
import regionDataJson from '@/assets/data/regions.json'

// 表单数据
const formData = reactive({
  salary: '',
  housingFundRate: '',
  socialSecurityBase: '',
  housingFundBase: '',
  specialDeduction: '',
  region: '',
})

// 地区数据
const regionData = ref<Record<string, RegionInfo>>({})
const regionOptions = ref<RegionOption[]>([])

// 加载地区数据
function loadRegionData() {
  try {
    const data = regionDataJson as RegionData

    // 验证数据结构
    if (!data || !data.regions || typeof data.regions !== 'object')
      throw new Error('地区数据格式不正确')

    regionData.value = data.regions
    regionOptions.value = Object.entries(data.regions).map(([key, value]) => ({
      label: value.name,
      value: key,
    }))

    // 验证是否有可用的地区数据
    if (regionOptions.value.length === 0)
      throw new Error('没有可用的地区数据')

    // 设置默认地区为第一个选项
    const defaultRegionKey = regionOptions.value[0].value
    const defaultRegion = data.regions[defaultRegionKey]
    if (defaultRegion) {
      formData.region = defaultRegionKey
      formData.socialSecurityBase = defaultRegion.socialSecurityBase.toString()
      formData.housingFundBase = defaultRegion.housingFundBase.toString()
      // 设置其他默认值
      formData.salary = '10000'
      formData.housingFundRate = '12'
      formData.specialDeduction = '2000'
    }
  }
  catch (error) {
    console.error('加载地区数据失败:', error)
    uni.showToast({
      title: `加载地区数据失败: ${error instanceof Error ? error.message : '未知错误'}`,
      icon: 'none',
      duration: 3000,
    })
  }
}

// 计算当前选中地区的索引
const regionIndex = computed(() => {
  return regionOptions.value.findIndex(option => option.value === formData.region)
})

// 地区变更处理
function onRegionSelectChange(e: any) {
  const index = e.detail.value
  const selectedOption = regionOptions.value[index]
  if (selectedOption) {
    const regionKey = selectedOption.value
    const region = regionData.value[regionKey]
    if (region) {
      formData.region = regionKey
      formData.socialSecurityBase = region.socialSecurityBase.toString()
      formData.housingFundBase = region.housingFundBase.toString()
    }
  }
}

// 表单验证
function validateForm() {
  if (!formData.salary || Number.parseFloat(formData.salary) <= 0) {
    uni.showToast({
      title: '请输入有效的税前月薪',
      icon: 'none',
    })
    return false
  }

  if (!formData.housingFundRate || Number.parseFloat(formData.housingFundRate) < 0 || Number.parseFloat(formData.housingFundRate) > 100) {
    uni.showToast({
      title: '请输入0-100之间的公积金比例',
      icon: 'none',
    })
    return false
  }

  if (!formData.socialSecurityBase || Number.parseFloat(formData.socialSecurityBase) <= 0) {
    uni.showToast({
      title: '请输入有效的社保基数',
      icon: 'none',
    })
    return false
  }

  if (!formData.housingFundBase || Number.parseFloat(formData.housingFundBase) <= 0) {
    uni.showToast({
      title: '请输入有效的公积金基数',
      icon: 'none',
    })
    return false
  }

  return true
}

// 提交表单
function submitForm() {
  if (!validateForm())
    return

  uni.navigateTo({
    url: `/pages/social-result?data=${encodeURIComponent(JSON.stringify(formData))}`,
  })
}

// 重置表单
function resetForm() {
  formData.salary = '10000'
  formData.housingFundRate = '12'
  formData.specialDeduction = '2000'

  if (regionOptions.value.length > 0) {
    const defaultRegionKey = regionOptions.value[0].value
    const region = regionData.value[defaultRegionKey]
    if (region) {
      formData.region = defaultRegionKey
      formData.socialSecurityBase = region.socialSecurityBase.toString()
      formData.housingFundBase = region.housingFundBase.toString()
    }
  }

  uni.showToast({
    title: '表单已重置',
    icon: 'success',
  })
}

onMounted(() => {
  loadRegionData()
})
</script>

<template>
  <view class="social-security-form-container">
    <scroll-view scroll-y class="form-scroll">
      <view class="social-security-form">
        <!-- 地区选择 -->
        <view class="form-section">
          <view class="section-header">
            <view class="section-icon">
              <text class="i-carbon-location" />
            </view>
            <text class="section-title">
              地区选择
            </text>
          </view>
          <view class="form-item">
            <picker :value="regionIndex" :range="regionOptions" range-key="label" @change="onRegionSelectChange">
              <view class="picker-input">
                <text class="picker-text">
                  {{ regionOptions.find(option => option.value === formData.region)?.label || '请选择地区' }}
                </text>
                <text class="i-carbon-chevron-down picker-arrow" />
              </view>
            </picker>
          </view>
        </view>

        <!-- 基本信息 -->
        <view class="form-section" style="margin-bottom: 50px;">
          <view class="section-header">
            <view class="section-icon">
              <text class="i-carbon-user" />
            </view>
            <text class="section-title">
              基本信息
            </text>
          </view>

          <view class="form-item">
            <text class="form-label">
              税前月薪
            </text>
            <view class="input-wrapper">
              <text class="input-prefix">
                ¥
              </text>
              <input v-model="formData.salary" type="number" placeholder="请输入税前月薪" class="form-input">
              <text class="input-suffix">
                元
              </text>
            </view>
          </view>

          <view class="form-item">
            <text class="form-label">
              公积金缴纳比例
            </text>
            <view class="input-wrapper">
              <text class="input-icon i-carbon-percentage" />
              <input v-model="formData.housingFundRate" type="number" placeholder="请输入公积金比例" class="form-input">
              <text class="input-suffix">
                %
              </text>
            </view>
          </view>

          <view class="form-item">
            <text class="form-label">
              专项附加扣除
            </text>
            <view class="input-wrapper">
              <text class="input-icon i-carbon-receipt" />
              <input v-model="formData.specialDeduction" type="number" placeholder="请输入专项附加扣除" class="form-input">
              <text class="input-suffix">
                元
              </text>
            </view>
          </view>

          <view class="form-item">
            <text class="form-label">
              社保基数
            </text>
            <view class="input-wrapper">
              <text class="i-carbon-security input-icon" />
              <input v-model="formData.socialSecurityBase" type="number" placeholder="请输入社保基数" class="form-input">
              <text class="input-suffix">
                元
              </text>
            </view>
          </view>

          <view class="form-item">
            <text class="form-label">
              公积金基数
            </text>
            <view class="input-wrapper">
              <text class="input-icon i-carbon-home" />
              <input v-model="formData.housingFundBase" type="number" placeholder="请输入公积金基数" class="form-input">
              <text class="input-suffix">
                元
              </text>
            </view>
          </view>
        </view>

        <!-- 底部占位空间 -->
        <view class="bottom-spacer" />
      </view>
    </scroll-view>

    <!-- 固定底部按钮 -->
    <view class="fixed-button-group">
      <button class="btn-primary btn" @click="submitForm">
        <text class="i-carbon-calculator btn-icon" />
        计算结果
      </button>
      <button class="btn-secondary btn" @click="resetForm">
        <text class="i-carbon-reset btn-icon" />
        重置表单
      </button>
    </view>
  </view>
</template>

<style lang="scss" scoped>
.social-security-form-container {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background: transparent;
}

.form-scroll {
  flex: 1;
  background: transparent;
}

.social-security-form {
  // padding: 20px;
  padding-bottom: 0;
  background: transparent;
}

.bottom-spacer {
  height: 80px;
}

.form-section {
  background: #ffffff;
  border-radius: 16px;
  padding: 20px;
  margin-bottom: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  border: 1px solid #e5e7eb;

  .section-header {
    display: flex;
    align-items: center;
    margin-bottom: 20px;
    padding-bottom: 12px;
    border-bottom: 1px solid #f3f4f6;

    .section-icon {
      width: 32px;
      height: 32px;
      border-radius: 8px;
      background: #3b82f6;
      display: flex;
      align-items: center;
      justify-content: center;
      margin-right: 12px;

      text {
        font-size: 16px;
        color: white;
      }
    }

    .section-title {
      font-size: 16px;
      font-weight: 600;
      color: #1f2937;
    }
  }
}

.form-item {
  margin-bottom: 16px;

  &:last-child {
    margin-bottom: 0;
  }

  .form-label {
    display: block;
    font-size: 14px;
    font-weight: 500;
    color: #374151;
    margin-bottom: 8px;
  }
}

.input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
  background: #f9fafb;
  border: 1px solid #d1d5db;
  border-radius: 8px;
  padding: 0 12px;
  height: 44px;
  transition: all 0.2s ease;

  &:focus-within {
    border-color: #3b82f6;
    background: #ffffff;
    box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
  }

  .input-prefix,
  .input-suffix {
    font-size: 14px;
    color: #6b7280;
    white-space: nowrap;
    font-weight: 500;
  }

  .input-icon {
    font-size: 16px;
    color: #3b82f6;
    margin-right: 8px;
  }

  .form-input {
    flex: 1;
    border: none;
    background: transparent;
    font-size: 14px;
    color: #1f2937;
    font-weight: 400;

    &::placeholder {
      color: #9ca3af;
      font-weight: 400;
    }
  }
}

.picker-input {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: #f9fafb;
  border: 1px solid #d1d5db;
  border-radius: 8px;
  padding: 0 12px;
  height: 44px;
  transition: all 0.2s ease;

  &:active {
    border-color: #3b82f6;
    background: #ffffff;
    box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
  }

  .picker-text {
    font-size: 14px;
    color: #1f2937;
    font-weight: 400;
  }

  .picker-arrow {
    font-size: 16px;
    color: #6b7280;
    transition: transform 0.2s ease;
  }
}

.fixed-button-group {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  display: flex;
  gap: 12px;
  padding: 16px 20px;
  padding-bottom: calc(16px + env(safe-area-inset-bottom));
  background: #ffffff;
  border-top: 1px solid #e5e7eb;
  box-shadow: 0 -2px 8px rgba(0, 0, 0, 0.1);
  z-index: 100;
}

.btn {
  flex: 1;
  height: 44px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: 500;
  border: none;
  transition: all 0.2s ease;

  .btn-icon {
    font-size: 16px;
    margin-right: 6px;
  }

  &.btn-primary {
    background: #3b82f6;
    color: #ffffff;

    &:active {
      background: #2563eb;
      transform: scale(0.98);
    }
  }

  &.btn-secondary {
    background: #ffffff;
    color: #6b7280;
    border: 1px solid #d1d5db;

    &:active {
      background: #f9fafb;
      transform: scale(0.98);
    }
  }
}
</style>
