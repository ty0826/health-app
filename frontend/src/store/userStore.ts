import { create } from 'zustand'
import Taro from '@tarojs/taro'
import { post, get } from '../utils/request'
import { encryptPassword } from '../utils/encrypt'

interface UserInfo {
  id: number
  username: string
  nickname: string
  avatar: string
  gender: number
  age: number
  height: number
  weight: number
  phone: string
  email: string
}

interface UserState {
  token: string
  userInfo: UserInfo | null
  login: (username: string, password: string) => Promise<void>
  register: (data: { username: string; password: string; nickname: string }) => Promise<void>
  fetchUserInfo: () => Promise<void>
  logout: () => void
  updateUserInfo: (info: Partial<UserInfo>) => Promise<void>
}

export const useUserStore = create<UserState>((set, getState) => ({
  token: Taro.getStorageSync('token') || '',
  userInfo: null,
  login: async (username: string, password: string) => {
    Taro.showLoading({ title: '登录中...', mask: true })
    const data = await post<{ token: string; userInfo: UserInfo }>('/user/login', {
      username,
      password: encryptPassword(password),
    })
    Taro.setStorageSync('token', data.token)
    set({ token: data.token, userInfo: data.userInfo})
    Taro.showToast({ title: '登录成功', icon: 'success' })
    Taro.switchTab({ url: '/pages/index/index' })
  },

  register: async (data) => {
    await post('/user/register', {
      ...data,
      password: encryptPassword(data.password),
    })
    Taro.showToast({ title: '注册成功，请登录', icon: 'success' })
  },

  fetchUserInfo: async () => {
    const userInfo = await get<UserInfo>('/user/info')
    set({ userInfo })
  },

  logout: () => {
    Taro.removeStorageSync('token')
    Taro.removeStorageSync('userInfo')
    set({ token: '', userInfo: null })
    Taro.redirectTo({ url: '/subpackages/login/pages/login/index' })
  },

  updateUserInfo: async (info) => {
    await post('/user/edit', info)
    const current = getState().userInfo
    if (current) {
      set({ userInfo: { ...current, ...info } })
    }
  },
}))
