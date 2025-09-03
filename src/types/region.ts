// 地区数据类型定义
export interface RegionRates {
  pension: {
    personal: number
    company: number
  }
  medical: {
    personal: number
    company: number
  }
  unemployment: {
    personal: number
    company: number
  }
  workInjury: {
    personal: number
    company: number
  }
  maternity: {
    personal: number
    company: number
  }
  housingFund: {
    personal: number
    company: number
  }
  supplementaryHousingFund: {
    personal: number
    company: number
  }
}

export interface RegionInfo {
  name: string
  socialSecurityBase: number
  housingFundBase: number
  rates: RegionRates
}

export interface RegionData {
  version: string
  lastUpdated: string
  regions: Record<string, RegionInfo>
}

export interface RegionOption {
  label: string
  value: string
}
