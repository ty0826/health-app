import { useState } from 'react'
import { View, Text, Input, Textarea } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { useHealthStore } from '../../../../store/healthStore'
import PageScaffold from '../../../../components/PageScaffold'
import styles from './index.module.scss'

const moodList = [
  { value: 5, icon: '😄', label: '很好' },
  { value: 4, icon: '😊', label: '不错' },
  { value: 3, icon: '😐', label: '一般' },
  { value: 2, icon: '😟', label: '较差' },
  { value: 1, icon: '😫', label: '很差' }
]

const fields = [
  {
    key: 'steps',
    label: '步数',
    icon: '🚶',
    placeholder: '请输入今日步数',
    type: 'number'
  },
  {
    key: 'heartRate',
    label: '心率',
    icon: '❤️',
    placeholder: '次/分钟',
    type: 'number'
  },
  {
    key: 'sleepHours',
    label: '睡眠',
    icon: '😴',
    placeholder: '小时',
    type: 'digit'
  },
  {
    key: 'weight',
    label: '体重',
    icon: '⚖️',
    placeholder: 'kg',
    type: 'digit'
  },
  {
    key: 'systolicBp',
    label: '收缩压',
    icon: '🫀',
    placeholder: 'mmHg',
    type: 'number'
  },
  {
    key: 'diastolicBp',
    label: '舒张压',
    icon: '🩺',
    placeholder: 'mmHg',
    type: 'number'
  },
  {
    key: 'bloodSugar',
    label: '血糖',
    icon: '🩸',
    placeholder: 'mmol/L',
    type: 'digit'
  },
  {
    key: 'calories',
    label: '热量消耗',
    icon: '🔥',
    placeholder: 'kcal',
    type: 'number'
  },
  {
    key: 'waterIntake',
    label: '饮水量',
    icon: '💧',
    placeholder: 'ml',
    type: 'number'
  }
]

export default function Record() {
  const [formData, setFormData] = useState<Record<string, any>>({})
  const [mood, setMood] = useState(3)
  const [note, setNote] = useState('')
  const [loading, setLoading] = useState(false)
  const { saveRecord } = useHealthStore()

  const handleInputChange = (key: string, value: string) => {
    setFormData((prev) => ({ ...prev, [key]: value }))
  }

  const handleSubmit = async () => {
    setLoading(true)
    try {
      await saveRecord({
        ...formData,
        mood,
        note,
        recordDate: new Date().toISOString().split('T')[0]
      })
      Taro.showToast({ title: '记录成功！', icon: 'success' })
      setTimeout(() => Taro.navigateBack(), 1500)
    } catch (e) {
      console.error(e)
    } finally {
      setLoading(false)
    }
  }

  return (
    <PageScaffold title="健康数据录入" className={styles.container} showBack>
      <View className={styles.dateCard}>
        <Text className={styles.dateIcon}>📅</Text>
        <Text className={styles.dateText}>
          {new Date().toLocaleDateString('zh-CN', {
            year: 'numeric',
            month: 'long',
            day: 'numeric'
          })}
        </Text>
      </View>

      {/* 健康指标输入 */}
      <View className={styles.section}>
        <Text className={styles.sectionTitle}>📋 健康指标</Text>
        <View className={styles.fieldList}>
          {fields.map((field) => (
            <View key={field.key} className={styles.fieldItem}>
              <View className={styles.fieldLabel}>
                <Text className={styles.fieldIcon}>{field.icon}</Text>
                <Text className={styles.fieldText}>{field.label}</Text>
              </View>
              <Input
                className={styles.fieldInput}
                type={field.type as any}
                placeholder={field.placeholder}
                value={formData[field.key] || ''}
                onInput={(e) => handleInputChange(field.key, e.detail.value)}
              />
            </View>
          ))}
        </View>
      </View>

      {/* 心情 */}
      <View className={styles.section}>
        <Text className={styles.sectionTitle}>🎭 今日心情</Text>
        <View className={styles.moodList}>
          {moodList.map((item) => (
            <View
              key={item.value}
              className={`${styles.moodItem} ${mood === item.value ? styles.moodActive : ''}`}
              onClick={() => setMood(item.value)}
            >
              <Text className={styles.moodIcon}>{item.icon}</Text>
              <Text className={styles.moodLabel}>{item.label}</Text>
            </View>
          ))}
        </View>
      </View>

      {/* 备注 */}
      <View className={styles.section}>
        <Text className={styles.sectionTitle}>📝 备注</Text>
        <Textarea
          className={styles.textarea}
          placeholder="记录今天的健康状况..."
          value={note}
          onInput={(e) => setNote(e.detail.value)}
          maxlength={500}
        />
      </View>

      {/* 提交按钮 */}
      <View className={styles.submitWrap}>
        <View
          className={`${styles.submitBtn} ${loading ? styles.disabled : ''}`}
          onClick={!loading ? handleSubmit : undefined}
        >
          <Text className={styles.submitText}>
            {loading ? '提交中...' : '✅ 保存记录'}
          </Text>
        </View>
      </View>
    </PageScaffold>
  )
}
