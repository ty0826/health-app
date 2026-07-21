import { create } from 'zustand'
import Taro from '@tarojs/taro'
import { post, get } from '../utils/request'
import {
  clearAuthStorage,
  readToken,
  writeToken,
} from '../utils/auth-storage'

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
  authReady: boolean
  userInfo: UserInfo | null
  hydrateAuth: () => Promise<void>
  login: (username: string, password: string) => Promise<void>
  register: (data: { username: string; password: string; nickname: string }) => Promise<void>
  fetchUserInfo: () => Promise<void>
  logout: () => Promise<void>
  updateUserInfo: (info: Partial<UserInfo>) => Promise<void>
}

export const useUserStore = create<UserState>((set, getState) => {
  let hydrationPromise: Promise<void> | null = null

  return {
    token: '',
    authReady: false,
    userInfo: null,
    hydrateAuth: async () => {
      if (getState().authReady) return

      if (!hydrationPromise) {
        hydrationPromise = readToken()
          .then((token) => set({ token, authReady: true }))
          .finally(() => {
            hydrationPromise = null
          })
      }

      await hydrationPromise
    },
    login: async (username: string, password: string) => {
      const data = await post<{ token: string; userInfo: UserInfo }>(
        '/user/login',
        { username, password },
      )
      await writeToken(data.token)
      set({ token: data.token, authReady: true, userInfo: data.userInfo })
      Taro.showToast({ title: '登录成功', icon: 'success' })
      Taro.switchTab({ url: '/pages/index/index' })
    },

  register: async (data) => {
    await post('/user/register', data)
    Taro.showToast({ title: '注册成功，请登录', icon: 'success' })
  },

  fetchUserInfo: async () => {
    const userInfo = await get<UserInfo>('/user/info')
    set({ userInfo })
  },

    logout: async () => {
      await clearAuthStorage()
      set({ token: '', authReady: true, userInfo: null })
      Taro.reLaunch({ url: '/subpackages/login/pages/login/index' })
    },

  updateUserInfo: async (info) => {
    await post('/user/edit', info)
    const current = getState().userInfo
    if (current) {
      set({ userInfo: { ...current, ...info } })
    }
    },
  }
})
