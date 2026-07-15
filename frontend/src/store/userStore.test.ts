import { beforeEach, describe, expect, it, vi } from 'vitest'

const mocks = vi.hoisted(() => ({
  post: vi.fn(),
  get: vi.fn(),
}))

vi.mock('../utils/request', () => mocks)

vi.mock('@tarojs/taro', () => ({
  default: {
    getStorageSync: vi.fn(() => ''),
    setStorageSync: vi.fn(),
    removeStorageSync: vi.fn(),
    showLoading: vi.fn(),
    showToast: vi.fn(),
    switchTab: vi.fn(),
    redirectTo: vi.fn(),
  },
}))

import { useUserStore } from './userStore'

describe('user authentication requests', () => {
  beforeEach(() => {
    mocks.post.mockReset()
    mocks.get.mockReset()
    useUserStore.setState({ token: '', userInfo: null })
  })

  it('sends the original login password to the backend', async () => {
    mocks.post.mockResolvedValue({
      token: 'jwt-token',
      userInfo: { id: 1, username: 'alice', nickname: 'Alice' },
    })

    await useUserStore.getState().login('alice', 'StrongPassword123')

    expect(mocks.post).toHaveBeenCalledWith('/user/login', {
      username: 'alice',
      password: 'StrongPassword123',
    })
  })

  it('sends the original registration password to the backend', async () => {
    mocks.post.mockResolvedValue(undefined)

    await useUserStore.getState().register({
      username: 'alice',
      password: 'StrongPassword123',
      nickname: 'Alice',
    })

    expect(mocks.post).toHaveBeenCalledWith('/user/register', {
      username: 'alice',
      password: 'StrongPassword123',
      nickname: 'Alice',
    })
  })
})
