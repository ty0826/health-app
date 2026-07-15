import Taro from '@tarojs/taro'

const BASE_URL = 'http://localhost:9999/api'

interface RequestOptions {
  url: string
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE'
  data?: any
  header?: Record<string, string>
  showLoading?: boolean
}

interface ApiResponse<T = any> {
  code: number
  message: string
  data: T
}

// 请求拦截
function getAuthHeader(): Record<string, string> {
  const token = Taro.getStorageSync('token')
  return token ? { Authorization: `Bearer ${token}` } : {}
}

// 统一请求方法
export async function request<T = any>(options: RequestOptions): Promise<T> {
  const { url, method = 'GET', data, header = {}, showLoading = true } = options

  if (showLoading) {
    Taro.showLoading({ title: '加载中...', mask: true })
  }

  try {
    const res = await Taro.request({
      url: `${BASE_URL}${url}`,
      method,
      data,
      header: {
        'Content-Type': 'application/json',
        ...getAuthHeader(),
        ...header,
      },
    })

    if (showLoading) {
      Taro.hideLoading()
    }

    const result = res.data as ApiResponse<T>
    if (result.code === 200) {
      return result.data
    }

    // Token 过期
    if (result.code === 401) {
      Taro.removeStorageSync('token')
      Taro.removeStorageSync('userInfo')
      Taro.redirectTo({ url: '/subpackages/login/pages/login/index' })
      throw new Error('登录已过期，请重新登录')
    }

    Taro.showToast({ title: result.message || '请求失败', icon: 'none' })
    throw new Error(result.message)
  } catch (error: any) {
    if (showLoading) {
      Taro.hideLoading()
    }
    Taro.showToast({ title: error.message, icon: 'none' })
    throw error
  }
}

// 快捷方法
export const get = <T = any>(url: string, data?: any) =>
  request<T>({ url, method: 'GET', data })

export const post = <T = any>(url: string, data?: any) =>
  request<T>({ url, method: 'POST', data })

export const put = <T = any>(url: string, data?: any) =>
  request<T>({ url, method: 'PUT', data })

export const del = <T = any>(url: string, data?: any) =>
  request<T>({ url, method: 'DELETE', data })
