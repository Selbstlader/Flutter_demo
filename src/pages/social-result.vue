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
      calculateResult()
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

// 计算社保结果
function calculateResult() {
  const {
    salary,
    housingFundRate,
    specialDeduction,
    socialSecurityBase,
    housingFundBase,
  } = formData.value

  const salaryAmount = Number.parseFloat(salary)
  const socialBase = Number.parseFloat(socialSecurityBase)
  const housingBase = Number.parseFloat(housingFundBase)
  const fundRate = Number.parseFloat(housingFundRate) / 100
  const specialDed = Number.parseFloat(specialDeduction)

  // 社保缴费计算（个人部分）
  const pensionPersonal = socialBase * 0.08 // 养老保险 8%
  const medicalPersonal = socialBase * 0.02 // 医疗保险 2%
  const unemploymentPersonal = socialBase * 0.005 // 失业保险 0.5%

  // 公积金缴费（个人部分）
  const housingFundPersonal = housingBase * fundRate

  // 个人缴费总额
  const totalPersonalContribution = pensionPersonal + medicalPersonal + unemploymentPersonal + housingFundPersonal

  // 应纳税所得额
  const taxableIncome = salaryAmount - totalPersonalContribution - 5000 - specialDed

  // 个人所得税计算
  let personalTax = 0
  if (taxableIncome > 0) {
    if (taxableIncome <= 3000)
      personalTax = taxableIncome * 0.03
    else if (taxableIncome <= 12000)
      personalTax = taxableIncome * 0.1 - 210
    else if (taxableIncome <= 25000)
      personalTax = taxableIncome * 0.2 - 1410
    else if (taxableIncome <= 35000)
      personalTax = taxableIncome * 0.25 - 2660
    else if (taxableIncome <= 55000)
      personalTax = taxableIncome * 0.3 - 4410
    else if (taxableIncome <= 80000)
      personalTax = taxableIncome * 0.35 - 7160
    else
      personalTax = taxableIncome * 0.45 - 15160
  }

  // 税后收入
  const afterTaxIncome = salaryAmount - totalPersonalContribution - personalTax

  // 公司缴费部分
  const pensionCompany = socialBase * 0.16 // 养老保险 16%
  const medicalCompany = socialBase * 0.09 // 医疗保险 9%
  const unemploymentCompany = socialBase * 0.005 // 失业保险 0.5%
  const injuryCompany = socialBase * 0.002 // 工伤保险 0.2%
  const maternityCompany = socialBase * 0.008 // 生育保险 0.8%
  const housingFundCompany = housingBase * fundRate

  const totalCompanyContribution = pensionCompany + medicalCompany + unemploymentCompany
    + injuryCompany + maternityCompany + housingFundCompany

  resultData.value = {
    // 个人缴费明细
    personalContributions: {
      pension: pensionPersonal,
      medical: medicalPersonal,
      unemployment: unemploymentPersonal,
      housingFund: housingFundPersonal,
      total: totalPersonalContribution,
    },
    // 公司缴费明细
    companyContributions: {
      pension: pensionCompany,
      medical: medicalCompany,
      unemployment: unemploymentCompany,
      injury: injuryCompany,
      maternity: maternityCompany,
      housingFund: housingFundCompany,
      total: totalCompanyContribution,
    },
    // 税收计算
    taxCalculation: {
      preTaxSalary: salaryAmount,
      taxableIncome: Math.max(0, taxableIncome),
      personalTax: Math.max(0, personalTax),
      afterTaxIncome,
    },
    // 年度汇总
    annualSummary: {
      personalTotal: totalPersonalContribution * 12,
      companyTotal: totalCompanyContribution * 12,
      taxTotal: Math.max(0, personalTax) * 12,
      afterTaxTotal: afterTaxIncome * 12,
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
        <text class="nav-icon i-carbon-arrow-left" />
      </view>
      <text class="nav-title">
        社保计算结果
      </text>
      <view class="nav-right" />
    </view>

    <scroll-view scroll-y class="result-scroll">
      <view class="result-content">
        <!-- 结果概览 -->
        <view class="summary-card">
          <view class="summary-header">
            <text class="i-carbon-calculator summary-icon" />
            <text class="summary-title">
              计算结果概览
            </text>
          </view>

          <view class="summary-grid">
            <view class="summary-item">
              <text class="summary-label">
                税前月薪
              </text>
              <text class="summary-value primary">
                ¥{{ resultData.taxCalculation?.preTaxSalary?.toFixed(2) || '0.00' }}
              </text>
            </view>
            <view class="summary-item">
              <text class="summary-label">
                税后月薪
              </text>
              <text class="summary-value success">
                ¥{{ resultData.taxCalculation?.afterTaxIncome?.toFixed(2) || '0.00' }}
              </text>
            </view>
            <view class="summary-item">
              <text class="summary-label">
                个人缴费
              </text>
              <text class="summary-value warning">
                ¥{{ resultData.personalContributions?.total?.toFixed(2) || '0.00' }}
              </text>
            </view>
            <view class="summary-item">
              <text class="summary-label">
                个人所得税
              </text>
              <text class="summary-value danger">
                ¥{{ resultData.taxCalculation?.personalTax?.toFixed(2) || '0.00' }}
              </text>
            </view>
          </view>
        </view>

        <!-- 个人缴费明细 -->
        <view class="detail-card">
          <view class="card-header">
            <text class="i-carbon-user card-icon" />
            <text class="card-title">
              个人缴费明细
            </text>
          </view>

          <view class="detail-list">
            <view class="detail-item">
              <view class="detail-info">
                <text class="detail-name">
                  养老保险
                </text>
                <text class="detail-rate">
                  8%
                </text>
              </view>
              <text class="detail-amount">
                ¥{{ resultData.personalContributions?.pension?.toFixed(2) || '0.00' }}
              </text>
            </view>

            <view class="detail-item">
              <view class="detail-info">
                <text class="detail-name">
                  医疗保险
                </text>
                <text class="detail-rate">
                  2%
                </text>
              </view>
              <text class="detail-amount">
                ¥{{ resultData.personalContributions?.medical?.toFixed(2) || '0.00' }}
              </text>
            </view>

            <view class="detail-item">
              <view class="detail-info">
                <text class="detail-name">
                  失业保险
                </text>
                <text class="detail-rate">
                  0.5%
                </text>
              </view>
              <text class="detail-amount">
                ¥{{ resultData.personalContributions?.unemployment?.toFixed(2) || '0.00' }}
              </text>
            </view>

            <view class="detail-item">
              <view class="detail-info">
                <text class="detail-name">
                  住房公积金
                </text>
                <text class="detail-rate">
                  {{ formData.housingFundRate || 0 }}%
                </text>
              </view>
              <text class="detail-amount">
                ¥{{ resultData.personalContributions?.housingFund?.toFixed(2) || '0.00' }}
              </text>
            </view>

            <view class="detail-total">
              <text class="total-label">
                个人缴费合计
              </text>
              <text class="total-amount">
                ¥{{ resultData.personalContributions?.total?.toFixed(2) || '0.00' }}
              </text>
            </view>
          </view>
        </view>

        <!-- 公司缴费明细 -->
        <view class="detail-card">
          <view class="card-header">
            <text class="card-icon i-carbon-building" />
            <text class="card-title">
              公司缴费明细
            </text>
          </view>

          <view class="detail-list">
            <view class="detail-item">
              <view class="detail-info">
                <text class="detail-name">
                  养老保险
                </text>
                <text class="detail-rate">
                  16%
                </text>
              </view>
              <text class="detail-amount">
                ¥{{ resultData.companyContributions?.pension?.toFixed(2) || '0.00' }}
              </text>
            </view>

            <view class="detail-item">
              <view class="detail-info">
                <text class="detail-name">
                  医疗保险
                </text>
                <text class="detail-rate">
                  9%
                </text>
              </view>
              <text class="detail-amount">
                ¥{{ resultData.companyContributions?.medical?.toFixed(2) || '0.00' }}
              </text>
            </view>

            <view class="detail-item">
              <view class="detail-info">
                <text class="detail-name">
                  失业保险
                </text>
                <text class="detail-rate">
                  0.5%
                </text>
              </view>
              <text class="detail-amount">
                ¥{{ resultData.companyContributions?.unemployment?.toFixed(2) || '0.00' }}
              </text>
            </view>

            <view class="detail-item">
              <view class="detail-info">
                <text class="detail-name">
                  工伤保险
                </text>
                <text class="detail-rate">
                  0.2%
                </text>
              </view>
              <text class="detail-amount">
                ¥{{ resultData.companyContributions?.injury?.toFixed(2) || '0.00' }}
              </text>
            </view>

            <view class="detail-item">
              <view class="detail-info">
                <text class="detail-name">
                  生育保险
                </text>
                <text class="detail-rate">
                  0.8%
                </text>
              </view>
              <text class="detail-amount">
                ¥{{ resultData.companyContributions?.maternity?.toFixed(2) || '0.00' }}
              </text>
            </view>

            <view class="detail-item">
              <view class="detail-info">
                <text class="detail-name">
                  住房公积金
                </text>
                <text class="detail-rate">
                  {{ formData.housingFundRate || 0 }}%
                </text>
              </view>
              <text class="detail-amount">
                ¥{{ resultData.companyContributions?.housingFund?.toFixed(2) || '0.00' }}
              </text>
            </view>

            <view class="detail-total">
              <text class="total-label">
                公司缴费合计
              </text>
              <text class="total-amount">
                ¥{{ resultData.companyContributions?.total?.toFixed(2) || '0.00' }}
              </text>
            </view>
          </view>
        </view>

        <!-- 年度汇总 -->
        <view class="annual-card">
          <view class="card-header">
            <text class="card-icon i-carbon-calendar" />
            <text class="card-title">
              年度汇总
            </text>
          </view>

          <view class="annual-grid">
            <view class="annual-item">
              <text class="annual-label">
                年度税后收入
              </text>
              <text class="success annual-value">
                ¥{{ resultData.annualSummary?.afterTaxTotal?.toFixed(2) || '0.00' }}
              </text>
            </view>
            <view class="annual-item">
              <text class="annual-label">
                年度个人缴费
              </text>
              <text class="annual-value warning">
                ¥{{ resultData.annualSummary?.personalTotal?.toFixed(2) || '0.00' }}
              </text>
            </view>
            <view class="annual-item">
              <text class="annual-label">
                年度公司缴费
              </text>
              <text class="annual-value info">
                ¥{{ resultData.annualSummary?.companyTotal?.toFixed(2) || '0.00' }}
              </text>
            </view>
            <view class="annual-item">
              <text class="annual-label">
                年度个人所得税
              </text>
              <text class="annual-value danger">
                ¥{{ resultData.annualSummary?.taxTotal?.toFixed(2) || '0.00' }}
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
  background: #fff;
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 16px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);

  .summary-header {
    display: flex;
    align-items: center;
    margin-bottom: 20px;

    .summary-icon {
      font-size: 18px;
      color: #3498db;
      margin-right: 8px;
    }

    .summary-title {
      font-size: 16px;
      font-weight: 600;
      color: #2c3e50;
    }
  }

  .summary-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px;
  }

  .summary-item {
    text-align: center;

    .summary-label {
      display: block;
      font-size: 12px;
      color: #7f8c8d;
      margin-bottom: 4px;
    }

    .summary-value {
      display: block;
      font-size: 16px;
      font-weight: 600;

      &.primary { color: #3498db; }
      &.success { color: #27ae60; }
      &.warning { color: #f39c12; }
      &.danger { color: #e74c3c; }
      &.info { color: #9b59b6; }
    }
  }
}

.detail-card,
.annual-card {
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
      color: #3498db;
      margin-right: 8px;
    }

    .card-title {
      font-size: 16px;
      font-weight: 600;
      color: #2c3e50;
    }
  }
}

.detail-list {
  .detail-item {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 12px 0;
    border-bottom: 1px solid #f8f9fa;

    &:last-child {
      border-bottom: none;
    }

    .detail-info {
      display: flex;
      align-items: center;

      .detail-name {
        font-size: 14px;
        color: #2c3e50;
        margin-right: 8px;
      }

      .detail-rate {
        font-size: 12px;
        color: #7f8c8d;
        background: #f8f9fa;
        padding: 2px 6px;
        border-radius: 4px;
      }
    }

    .detail-amount {
      font-size: 14px;
      font-weight: 500;
      color: #e74c3c;
    }
  }

  .detail-total {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 16px 0 0;
    margin-top: 12px;
    border-top: 2px solid #f8f9fa;

    .total-label {
      font-size: 14px;
      font-weight: 600;
      color: #2c3e50;
    }

    .total-amount {
      font-size: 16px;
      font-weight: 600;
      color: #e74c3c;
    }
  }
}

.annual-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.annual-item {
  text-align: center;
  padding: 16px;
  background: #f8f9fa;
  border-radius: 8px;

  .annual-label {
    display: block;
    font-size: 12px;
    color: #7f8c8d;
    margin-bottom: 8px;
  }

  .annual-value {
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
    background: #3498db;
    color: #fff;

    &:active {
      background: #2980b9;
    }
  }
}
</style>
