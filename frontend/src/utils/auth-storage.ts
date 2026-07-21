import Taro from '@tarojs/taro'

const TOKEN_KEY = 'token'
const USER_INFO_KEY = 'userInfo'

export async function readToken(): Promise<string> {
  try {
    const result = await Taro.getStorage({ key: TOKEN_KEY })
    return typeof result.data === 'string' ? result.data : ''
  } catch {
    return ''
  }
}

export async function writeToken(token: string): Promise<void> {
  await Taro.setStorage({ key: TOKEN_KEY, data: token })
}

export async function clearAuthStorage(): Promise<void> {
  await Promise.allSettled([
    Taro.removeStorage({ key: TOKEN_KEY }),
    Taro.removeStorage({ key: USER_INFO_KEY }),
  ])
}
