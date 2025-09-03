<script setup lang="ts">
import { ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'

// 计算结果数据
const resultData = ref<any>({})
const formData = ref<any>({})

// 页面加载时获取传递的数据
onLoad((options) => {
  if (options?.data) {
    try {
      formData.value = JSON.parse(decodeURIComponent(options.data))
      calculatePension()
    }
    catch (error) {
      console.error('解析数据失败:', error)
      uni.showToast({
        title: '数据解析失败',
        icon: 'none',
      })
    }
  }
})

// 计算养老金
function calculatePension() {
  const {
    currentAge,
    retirementAge,
    paymentYears,
    socialSecurityBase,
    accountBalance,
    region,
  } = formData.value

  const socialBase = Number.parseFloat(socialSecurityBase)
  const years = Number.parseInt(paymentYears)
  const balance = Number.parseFloat(accountBalance) || 0
  const age = Number.parseInt(currentAge)
  const retireAge = Number.parseInt(retirementAge)

  // 获取地区平均工资（模拟数据）
  const regionSalaryMap: Record<string, number> = {
    beijing: 11187,
    shanghai: 12183,
    guangzhou: 9129,
    shenzhen: 11620,
  }
  const regionAverageSalary = regionSalaryMap[region] || 10000

  // 计算个人账户累计储存额
  // 个人缴费 = 缴费基数 × 8% × 缴费年限 × 12个月
  const personalContribution = socialBase * 0.08 * years * 12

  // 个人账户总额 = 个人缴费 + 当前账户余额 + 利息（简化计算，按3%年利率）
  const totalPersonalAccount = personalContribution + balance + (personalContribution * 0.03 * years)

  // 计算月数（根据退休年龄确定）
  const monthsMap: Record<number, number> = {
    50: 195,
    51: 190,
    52: 185,
    53: 180,
    54: 175,
    55: 170,
    56: 164,
    57: 158,
    58: 152,
    59: 145,
    60: 139,
    61: 132,
    62: 125,
    63: 117,
    64: 109,
    65: 101,
    66: 93,
    67: 84,
    68: 75,
    69: 65,
    70: 56,
  }
  const months = monthsMap[retireAge] || 139

  // 个人账户养老金 = 个人账户累计储存额 ÷ 计发月数
  const personalAccountPension = totalPersonalAccount / months

  // 基础养老金 = (社会平均工资 + 个人指数化月平均缴费工资) ÷ 2 × 缴费年限 × 1%
  // 简化计算：个人指数化月平均缴费工资 ≈ 缴费基数
  const basicPension = (regionAverageSalary + socialBase) / 2 * years * 0.01

  // 月养老金总额
  const monthlyPension = basicPension + personalAccountPension

  // 年养老金
  const annualPension = monthlyPension * 12

  // 计算回本年限（个人缴费总额 ÷ 年养老金）
  const totalPersonalPayment = personalContribution
  const paybackYears = totalPersonalPayment / annualPension

  // 预期寿命（简化计算）
  const lifeExpectancy = 80
  const pensionYears = lifeExpectancy - retireAge
  const totalPensionReceived = annualPension * pensionYears

  resultData.value = {
    // 基本信息
    basicInfo: {
      currentAge: age,
      retirementAge: retireAge,
      paymentYears: years,
      socialSecurityBase: socialBase,
      regionAverageSalary,
      accountBalance: balance,
    },
    // 个人账户计算
    personalAccount: {
      monthlyContribution: socialBase * 0.08,
      totalContribution: personalContribution,
      accountBalance: balance,
      interestEarned: personalContribution * 0.03 * years,
      totalAmount: totalPersonalAccount,
      months,
      monthlyPension: personalAccountPension,
    },
    // 基础养老金计算
    basicPension: {
      formula: `(${regionAverageSalary} + ${socialBase}) ÷ 2 × ${years} × 1%`,
      monthlyAmount: basicPension,
    },
    // 养老金汇总
    pensionSummary: {
      monthlyTotal: monthlyPension,
      annualTotal: annualPension,
      paybackYears,
      pensionYears,
      totalReceived: totalPensionReceived,
      netBenefit: totalPensionReceived - totalPersonalPayment,
    },
  }
}

// 返回上一页
function goBack() {
  uni.navigateBack()
}

// 重新计算
function recalculate() {
  uni.navigateBack()
}
</script>

<template>
  <view class="result-page">
    <!-- 顶部导航 -->
    <view class="nav-bar">
      <view class="nav-left" @click="goBack">
        <text class="i-carbon-arrow-left nav-icon" />
      </view>
      <text class="nav-title">
        养老金计算结果
      </text>
      <view class="nav-right" />
    </view>

    <scroll-view scroll-y class="result-scroll">
      <view class="result-content">
        <!-- 结果概览 -->
        <view class="summary-card">
          <view class="summary-header">
            <text class="i-carbon-user-elderly summary-icon" />
            <text class="summary-title">
              养老金预测
            </text>
          </view>

          <view class="pension-highlight">
            <view class="pension-main">
              <text class="pension-label">
                预计月养老金
              </text>
              <text class="pension-amount">
                ¥{{ resultData.pensionSummary?.monthlyTotal?.toFixed(2) || '0.00' }}
              </text>
            </view>
            <view class="pension-detail">
              <text class="detail-text">
                年养老金：¥{{ resultData.pensionSummary?.annualTotal?.toFixed(2) || '0.00' }}
              </text>
            </view>
          </view>

          <view class="summary-grid">
            <view class="summary-item">
              <text class="summary-label">
                基础养老金
              </text>
              <text class="summary-value primary">
                ¥{{ resultData.basicPension?.monthlyAmount?.toFixed(2) || '0.00' }}
              </text>
            </view>
            <view class="summary-item">
              <text class="summary-label">
                个人账户养老金
              </text>
              <text class="summary-value success">
                ¥{{ resultData.personalAccount?.monthlyPension?.toFixed(2) || '0.00' }}
              </text>
            </view>
            <view class="summary-item">
              <text class="summary-label">
                回本年限
              </text>
              <text class="summary-value warning">
                {{ resultData.pensionSummary?.paybackYears?.toFixed(1) || '0.0' }}年
              </text>
            </view>
            <view class="summary-item">
              <text class="summary-label">
                净收益
              </text>
              <text class="summary-value info">
                ¥{{ resultData.pensionSummary?.netBenefit?.toFixed(0) || '0' }}
              </text>
            </view>
          </view>
        </view>

        <!-- 个人账户详情 -->
        <view class="detail-card">
          <view class="card-header">
            <text class="i-carbon-wallet card-icon" />
            <text class="card-title">
              个人账户详情
            </text>
          </view>

          <view class="account-flow">
            <view class="flow-item">
              <view class="flow-info">
                <text class="flow-label">
                  月缴费金额
                </text>
                <text class="flow-desc">
                  缴费基数 × 8%
                </text>
              </view>
              <text class="flow-amount">
                ¥{{ resultData.personalAccount?.monthlyContribution?.toFixed(2) || '0.00' }}
              </text>
            </view>

            <view class="flow-item">
              <view class="flow-info">
                <text class="flow-label">
                  累计缴费
                </text>
                <text class="flow-desc">
                  {{ resultData.basicInfo?.paymentYears || 0 }}年缴费总额
                </text>
              </view>
              <text class="flow-amount">
                ¥{{ resultData.personalAccount?.totalContribution?.toFixed(2) || '0.00' }}
              </text>
            </view>

            <view class="flow-item">
              <view class="flow-info">
                <text class="flow-label">
                  当前余额
                </text>
                <text class="flow-desc">
                  已有账户余额
                </text>
              </view>
              <text class="flow-amount">
                ¥{{ resultData.basicInfo?.accountBalance?.toFixed(2) || '0.00' }}
              </text>
            </view>

            <view class="flow-item">
              <view class="flow-info">
                <text class="flow-label">
                  利息收益
                </text>
                <text class="flow-desc">
                  按3%年利率计算
                </text>
              </view>
              <text class="flow-amount success">
                ¥{{ resultData.personalAccount?.interestEarned?.toFixed(2) || '0.00' }}
              </text>
            </view>

            <view class="flow-total">
              <view class="total-info">
                <text class="total-label">
                  个人账户总额
                </text>
                <text class="total-desc">
                  退休时预计总额
                </text>
              </view>
              <text class="total-amount">
                ¥{{ resultData.personalAccount?.totalAmount?.toFixed(2) || '0.00' }}
              </text>
            </view>

            <view class="flow-result">
              <view class="result-info">
                <text class="result-label">
                  个人账户养老金
                </text>
                <text class="result-desc">
                  总额 ÷ {{ resultData.personalAccount?.months || 0 }}个月
                </text>
              </view>
              <text class="result-amount">
                ¥{{ resultData.personalAccount?.monthlyPension?.toFixed(2) || '0.00' }}/月
              </text>
            </view>
          </view>
        </view>

        <!-- 基础养老金详情 -->
        <view class="detail-card">
          <view class="card-header">
            <text class="card-icon i-carbon-chart-line" />
            <text class="card-title">
              基础养老金详情
            </text>
          </view>

          <view class="basic-pension-info">
            <view class="formula-card">
              <text class="formula-title">
                计算公式
              </text>
              <text class="formula-text">
                {{ resultData.basicPension?.formula || '' }}
              </text>
            </view>

            <view class="param-list">
              <view class="param-item">
                <text class="param-label">
                  社会平均工资
                </text>
                <text class="param-value">
                  ¥{{ resultData.basicInfo?.regionAverageSalary?.toFixed(2) || '0.00' }}
                </text>
              </view>
              <view class="param-item">
                <text class="param-label">
                  缴费基数
                </text>
                <text class="param-value">
                  ¥{{ resultData.basicInfo?.socialSecurityBase?.toFixed(2) || '0.00' }}
                </text>
              </view>
              <view class="param-item">
                <text class="param-label">
                  缴费年限
                </text>
                <text class="param-value">
                  {{ resultData.basicInfo?.paymentYears || 0 }}年
                </text>
              </view>
            </view>

            <view class="result-highlight">
              <text class="result-label">
                基础养老金
              </text>
              <text class="result-value">
                ¥{{ resultData.basicPension?.monthlyAmount?.toFixed(2) || '0.00' }}/月
              </text>
            </view>
          </view>
        </view>

        <!-- 收益分析 -->
        <view class="analysis-card">
          <view class="card-header">
            <text class="card-icon i-carbon-analytics" />
            <text class="card-title">
              收益分析
            </text>
          </view>

          <view class="analysis-grid">
            <view class="analysis-item">
              <text class="analysis-label">
                个人总缴费
              </text>
              <text class="danger analysis-value">
                ¥{{ resultData.personalAccount?.totalContribution?.toFixed(0) || '0' }}
              </text>
            </view>
            <view class="analysis-item">
              <text class="analysis-label">
                预计总收益
              </text>
              <text class="analysis-value success">
                ¥{{ resultData.pensionSummary?.totalReceived?.toFixed(0) || '0' }}
              </text>
            </view>
            <view class="analysis-item">
              <text class="analysis-label">
                净收益
              </text>
              <text class="analysis-value info">
                ¥{{ resultData.pensionSummary?.netBenefit?.toFixed(0) || '0' }}
              </text>
            </view>
            <view class="analysis-item">
              <text class="analysis-label">
                收益倍数
              </text>
              <text class="analysis-value primary">
                {{ (resultData.pensionSummary?.totalReceived / resultData.personalAccount?.totalContribution)?.toFixed(1) || '0.0' }}倍
              </text>
            </view>
          </view>

          <view class="timeline-info">
            <view class="timeline-item">
              <text class="timeline-label">
                回本时间
              </text>
              <text class="timeline-value">
                退休后{{ resultData.pensionSummary?.paybackYears?.toFixed(1) || '0.0' }}年
              </text>
            </view>
            <view class="timeline-item">
              <text class="timeline-label">
                预计领取年限
              </text>
              <text class="timeline-value">
                {{ resultData.pensionSummary?.pensionYears || 0 }}年（至80岁）
              </text>
            </view>
          </view>
        </view>

        <!-- 操作按钮 -->
        <view class="button-group">
          <button class="btn-primary btn" @click="recalculate">
            <text class="i-carbon-calculator btn-icon" />
            重新计算
          </button>
        </view>
      </view>
    </scroll-view>
  </view>
</template>

<style lang="scss" scoped>
.result-page {
  height: 100vh;
  background: #f5f7fa;
}

.nav-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 44px;
  padding: 0 16px;
  background: #fff;
  border-bottom: 1px solid #e0e6ed;

  .nav-left,
  .nav-right {
    width: 44px;
    height: 44px;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .nav-icon {
    font-size: 20px;
    color: #2c3e50;
  }

  .nav-title {
    font-size: 16px;
    font-weight: 600;
    color: #2c3e50;
  }
}

.result-scroll {
  height: calc(100vh - 44px);
}

.result-content {
  padding: 16px;
  padding-bottom: 32px;
}

.summary-card {
  background: linear-gradient(135deg, #27ae60, #2ecc71);
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 16px;
  box-shadow: 0 4px 12px rgba(39, 174, 96, 0.2);

  .summary-header {
    display: flex;
    align-items: center;
    margin-bottom: 20px;

    .summary-icon {
      font-size: 18px;
      color: #fff;
      margin-right: 8px;
    }

    .summary-title {
      font-size: 16px;
      font-weight: 600;
      color: #fff;
    }
  }

  .pension-highlight {
    text-align: center;
    margin-bottom: 20px;

    .pension-main {
      margin-bottom: 8px;

      .pension-label {
        display: block;
        font-size: 14px;
        color: rgba(255, 255, 255, 0.8);
        margin-bottom: 4px;
      }

      .pension-amount {
        display: block;
        font-size: 28px;
        font-weight: 700;
        color: #fff;
      }
    }

    .pension-detail {
      .detail-text {
        font-size: 12px;
        color: rgba(255, 255, 255, 0.7);
      }
    }
  }

  .summary-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 12px;
  }

  .summary-item {
    background: rgba(255, 255, 255, 0.1);
    border-radius: 8px;
    padding: 12px;
    text-align: center;

    .summary-label {
      display: block;
      font-size: 11px;
      color: rgba(255, 255, 255, 0.7);
      margin-bottom: 4px;
    }

    .summary-value {
      display: block;
      font-size: 14px;
      font-weight: 600;
      color: #fff;
    }
  }
}

.detail-card,
.analysis-card {
  background: #fff;
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 16px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);

  .card-header {
    display: flex;
    align-items: center;
    margin-bottom: 20px;

    .card-icon {
      font-size: 16px;
      color: #27ae60;
      margin-right: 8px;
    }

    .card-title {
      font-size: 16px;
      font-weight: 600;
      color: #2c3e50;
    }
  }
}

.account-flow {
  .flow-item,
  .flow-total,
  .flow-result {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 12px 0;
    border-bottom: 1px solid #f8f9fa;

    &:last-child {
      border-bottom: none;
    }
  }

  .flow-total {
    background: #f8f9fa;
    border-radius: 8px;
    padding: 16px;
    margin: 12px 0;
    border: none;
  }

  .flow-result {
    background: rgba(39, 174, 96, 0.05);
    border-radius: 8px;
    padding: 16px;
    border: 1px solid rgba(39, 174, 96, 0.1);
  }

  .flow-info,
  .total-info,
  .result-info {
    .flow-label,
    .total-label,
    .result-label {
      display: block;
      font-size: 14px;
      color: #2c3e50;
      margin-bottom: 2px;
    }

    .flow-desc,
    .total-desc,
    .result-desc {
      font-size: 12px;
      color: #7f8c8d;
    }
  }

  .flow-amount,
  .total-amount,
  .result-amount {
    font-size: 14px;
    font-weight: 500;
    color: #e74c3c;

    &.success {
      color: #27ae60;
    }
  }

  .total-amount {
    font-size: 16px;
    font-weight: 600;
    color: #2c3e50;
  }

  .result-amount {
    font-size: 16px;
    font-weight: 600;
    color: #27ae60;
  }
}

.basic-pension-info {
  .formula-card {
    background: #f8f9fa;
    border-radius: 8px;
    padding: 16px;
    margin-bottom: 16px;

    .formula-title {
      display: block;
      font-size: 12px;
      color: #7f8c8d;
      margin-bottom: 8px;
    }

    .formula-text {
      font-size: 14px;
      color: #2c3e50;
      font-family: monospace;
    }
  }

  .param-list {
    margin-bottom: 16px;

    .param-item {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 8px 0;
      border-bottom: 1px solid #f8f9fa;

      &:last-child {
        border-bottom: none;
      }

      .param-label {
        font-size: 14px;
        color: #7f8c8d;
      }

      .param-value {
        font-size: 14px;
        font-weight: 500;
        color: #2c3e50;
      }
    }
  }

  .result-highlight {
    background: rgba(39, 174, 96, 0.05);
    border: 1px solid rgba(39, 174, 96, 0.1);
    border-radius: 8px;
    padding: 16px;
    display: flex;
    justify-content: space-between;
    align-items: center;

    .result-label {
      font-size: 14px;
      font-weight: 600;
      color: #2c3e50;
    }

    .result-value {
      font-size: 16px;
      font-weight: 600;
      color: #27ae60;
    }
  }
}

.analysis-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
  margin-bottom: 20px;
}

.analysis-item {
  background: #f8f9fa;
  border-radius: 8px;
  padding: 16px;
  text-align: center;

  .analysis-label {
    display: block;
    font-size: 12px;
    color: #7f8c8d;
    margin-bottom: 8px;
  }

  .analysis-value {
    display: block;
    font-size: 14px;
    font-weight: 600;

    &.primary { color: #3498db; }
    &.success { color: #27ae60; }
    &.warning { color: #f39c12; }
    &.danger { color: #e74c3c; }
    &.info { color: #9b59b6; }
  }
}

.timeline-info {
  .timeline-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 8px 0;
    border-bottom: 1px solid #f8f9fa;

    &:last-child {
      border-bottom: none;
    }

    .timeline-label {
      font-size: 14px;
      color: #7f8c8d;
    }

    .timeline-value {
      font-size: 14px;
      font-weight: 500;
      color: #2c3e50;
    }
  }
}

.button-group {
  margin-top: 24px;
}

.btn {
  width: 100%;
  height: 44px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: 500;
  border: none;

  .btn-icon {
    font-size: 16px;
    margin-right: 6px;
  }

  &.btn-primary {
    background: #27ae60;
    color: #fff;

    &:active {
      background: #219a52;
    }
  }
}
</style>
