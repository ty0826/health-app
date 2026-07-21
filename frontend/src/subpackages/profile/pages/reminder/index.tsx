import { useState, useEffect } from 'react'
import { View, Text, Switch, Picker } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { get, put } from '../../../../utils/request'
import PageScaffold from '../../../../components/PageScaffold'
import styles from './index.module.scss'

interface ReminderItem {
  id: number
  reminderType: string
  icon: string
  label: string
  description: string
  enabled: number
  reminderTime: string
}

export default function Reminder() {
  const [reminders, setReminders] = useState<ReminderItem[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchReminders()
  }, [])

  const fetchReminders = async () => {
    try {
      const data = await get<ReminderItem[]>('/reminder/list')
      setReminders(data || [])
    } catch (e) {
      console.error(e)
    } finally {
      setLoading(false)
    }
  }

  const handleToggle = async (item: ReminderItem, value: boolean) => {
    try {
      await put(`/reminder/${item.id}`, {
        enabled: value ? 1 : 0,
        reminderTime: item.reminderTime
      })
      setReminders((prev) =>
        prev.map((r) =>
          r.id === item.id ? { ...r, enabled: value ? 1 : 0 } : r
        )
      )
      if (value) {
        Taro.showToast({ title: `已开启${item.label}`, icon: 'success' })
      }
    } catch (e) {
      Taro.showToast({ title: '更新失败', icon: 'none' })
    }
  }

  const handleTimeChange = async (item: ReminderItem, e: any) => {
    const newTime = e.detail.value
    try {
      await put(`/reminder/${item.id}`, {
        enabled: item.enabled,
        reminderTime: newTime
      })
      setReminders((prev) =>
        prev.map((r) =>
          r.id === item.id ? { ...r, reminderTime: newTime } : r
        )
      )
    } catch (e) {
      Taro.showToast({ title: '更新失败', icon: 'none' })
    }
  }

  if (loading) {
    return (
      <PageScaffold title="提醒设置" className={styles.container} showBack>
        <View style={{ textAlign: 'center', padding: '100px 0' }}>
          <Text style={{ color: '#999' }}>加载中...</Text>
        </View>
      </PageScaffold>
    )
  }

  return (
    <PageScaffold title="提醒设置" className={styles.container} showBack>
      <View className={styles.tipCard}>
        <Text className={styles.tipIcon}>💡</Text>
        <Text className={styles.tipText}>
          开启提醒后，系统将在指定时间通过微信服务通知提醒您。请确保已授权消息通知权限。
        </Text>
      </View>

      <View className={styles.section}>
        {reminders.map((item) => (
          <View key={item.id} className={styles.reminderItem}>
            <View className={styles.reminderLeft}>
              <Text className={styles.reminderIcon}>{item.icon}</Text>
              <View className={styles.reminderInfo}>
                <Text className={styles.reminderLabel}>{item.label}</Text>
                <Text className={styles.reminderDesc}>{item.description}</Text>
              </View>
            </View>
            <View className={styles.reminderRight}>
              <Picker
                mode="time"
                value={item.reminderTime}
                onChange={(e) => handleTimeChange(item, e)}
              >
                <Text
                  className={`${styles.reminderTime} ${item.enabled ? styles.timeActive : ''}`}
                >
                  {item.reminderTime}
                </Text>
              </Picker>
              <Switch
                checked={item.enabled === 1}
                color="#4F46E5"
                onChange={(e) => handleToggle(item, e.detail.value)}
              />
            </View>
          </View>
        ))}
      </View>

      <View className={styles.noteSection}>
        <Text className={styles.noteTitle}>温馨提示</Text>
        <Text className={styles.noteText}>
          • 提醒功能依赖微信订阅消息，首次使用需要授权
        </Text>
        <Text className={styles.noteText}>
          • 提醒时间设置后将在每天固定时段推送
        </Text>
        <Text className={styles.noteText}>• 关闭提醒后将不再收到对应消息</Text>
      </View>
    </PageScaffold>
  )
}
