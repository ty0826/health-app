import { beforeEach, describe, expect, it, vi } from 'vitest'

const mocks = vi.hoisted(() => ({
  get: vi.fn(),
  post: vi.fn(),
}))

vi.mock('../utils/request', () => mocks)

import { useHealthStore } from './healthStore'

describe('health record writes', () => {
  beforeEach(() => {
    mocks.get.mockReset()
    mocks.post.mockReset()
  })

  it('uses one daily upsert endpoint without a record id', async () => {
    mocks.post.mockResolvedValue(undefined)
    const record = { steps: 8000, recordDate: '2026-07-15' }

    const state = useHealthStore.getState() as any
    expect(typeof state.saveRecord).toBe('function')

    await state.saveRecord(record)

    expect(mocks.post).toHaveBeenCalledWith('/health/record', record)
  })
})
