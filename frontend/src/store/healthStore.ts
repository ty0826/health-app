import { create } from 'zustand'
import { get, post } from '../utils/request'

export interface HealthRecord {
  id: number
  userId: number
  recordDate: string
  steps: number
  heartRate: number
  sleepHours: number
  weight: number
  systolicBp: number
  diastolicBp: number
  bloodSugar: number
  calories: number
  waterIntake: number
  mood: number  // 1-5
  note: string
  createTime: string
}

export interface HealthStats {
  avgSteps: number
  avgHeartRate: number
  avgSleepHours: number
  avgWeight: number
  avgBloodSugar: number
  weeklySteps: number[]
  weeklyHeartRate: number[]
  weeklySleep: number[]
  weekDates: string[]
  monthlyWeight: number[]
  monthDates: string[]
}

interface HealthState {
  records: HealthRecord[]
  todayRecord: HealthRecord | null
  stats: HealthStats | null
  loading: boolean
  fetchRecords: (page?: number, size?: number) => Promise<void>
  fetchTodayRecord: () => Promise<void>
  fetchStats: (days?: number) => Promise<void>
  saveRecord: (data: Partial<HealthRecord>) => Promise<void>
}

export const useHealthStore = create<HealthState>((set) => ({
  records: [],
  todayRecord: null,
  stats: null,
  loading: false,

  fetchRecords: async (page = 1, size = 20) => {
    set({ loading: true })
    try {
      const data = await get<HealthRecord[]>('/health/list', { page, size })
      set({ records: data })
    } finally {
      set({ loading: false })
    }
  },

  fetchTodayRecord: async () => {
    try {
      const data = await get<HealthRecord>('/health/today', undefined)
      set({ todayRecord: data })
    } catch {
      set({ todayRecord: null })
    }
  },

  fetchStats: async (days = 7) => {
    const data = await get<HealthStats>('/health/stats', { days })
    set({ stats: data })
  },

  saveRecord: async (data) => {
    await post('/health/record', data)
  },
}))
