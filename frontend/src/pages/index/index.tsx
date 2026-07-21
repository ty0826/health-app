import { useEffect } from 'react'
import { View, Text } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { useUserStore } from '../../store/userStore'
import { useHealthStore } from '../../store/healthStore'
import PageScaffold from '../../components/PageScaffold'
import styles from './index.module.scss'

const healthCards = [
  { key: 'steps', icon: '🚶', label: '步数', unit: '步', color: '#4F46E5' },
  {
    key: 'heartRate',
    icon: '❤️',
    label: '心率',
    unit: 'bpm',
    color: '#EF4444'
  },
  {
    key: 'sleepHours',
    icon: '😴',
    label: '睡眠',
    unit: '小时',
    color: '#8B5CF6'
  },
  { key: 'weight', icon: '⚖️', label: '体重', unit: 'kg', color: '#10B981' },
  {
    key: 'bloodSugar',
    icon: '🩸',
    label: '血糖',
    unit: 'mmol/L',
    color: '#F59E0B'
  },
  { key: 'calories', icon: '🔥', label: '热量', unit: 'kcal', color: '#F97316' }
]

export default function Index() {
  const { token, authReady, userInfo, fetchUserInfo } = useUserStore()
  const { todayRecord, fetchTodayRecord, fetchStats } = useHealthStore()

  useEffect(() => {
    if (!authReady) return

    if (!token) {
      Taro.reLaunch({ url: '/subpackages/login/pages/login/index' })
      return
    }

    void Promise.allSettled([
      fetchUserInfo(),
      fetchTodayRecord(),
      fetchStats(7),
    ])
  }, [authReady, token, fetchUserInfo, fetchTodayRecord, fetchStats])

  const getCardValue = (key: string) => {
    if (!todayRecord) return '--'
    return todayRecord[key] ?? '--'
  }

  const goToRecord = () => {
    Taro.navigateTo({ url: '/subpackages/record/pages/record/index' })
  }

  if (!authReady || !token) return null

  return (
    <PageScaffold title="健康管家" className={styles.container}>
      {/* 头部区域 */}
      <View className={styles.header}>
        <View className={styles.headerContent}>
          <View className={styles.greeting}>
            <Text className={styles.greetingText}>
              你好，{userInfo?.nickname || '用户'} 👋
            </Text>
            <Text className={styles.dateText}>
              {new Date().toLocaleDateString('zh-CN', {
                month: 'long',
                day: 'numeric',
                weekday: 'long'
              })}
            </Text>
          </View>
          <View className={styles.avatarWrap}>
            <Text className={styles.avatarText}>
              {(userInfo?.nickname || '用')[0]}
            </Text>
          </View>
        </View>

        {/* 健康评分 */}
        <View className={styles.scoreCard}>
          <View className={styles.scoreLeft}>
            <Text className={styles.scoreNumber}>86</Text>
            <Text className={styles.scoreLabel}>健康评分</Text>
          </View>
          <View className={styles.scoreDivider} />
          <View className={styles.scoreRight}>
            <View className={styles.scoreItem}>
              <Text className={styles.scoreItemValue}>
                {todayRecord?.steps || 0}
              </Text>
              <Text className={styles.scoreItemLabel}>今日步数</Text>
            </View>
            <View className={styles.scoreItem}>
              <Text className={styles.scoreItemValue}>
                {todayRecord?.sleepHours || 0}h
              </Text>
              <Text className={styles.scoreItemLabel}>睡眠时长</Text>
            </View>
            <View className={styles.scoreItem}>
              <Text className={styles.scoreItemValue}>
                {todayRecord?.calories || 0}
              </Text>
              <Text className={styles.scoreItemLabel}>消耗热量</Text>
            </View>
          </View>
        </View>
      </View>

      {/* 快捷操作 */}
      <View className={styles.quickActions}>
        <View className={styles.sectionHeader}>
          <Text className={styles.sectionTitle}>快捷操作</Text>
        </View>
        <View className={styles.actionGrid}>
          <View className={styles.actionItem} onClick={goToRecord}>
            <View
              className={styles.actionIcon}
              style={{ backgroundColor: '#EEF2FF' }}
            >
              <Text className={styles.actionEmoji}>📝</Text>
            </View>
            <Text className={styles.actionText}>记录数据</Text>
          </View>
          <View
            className={styles.actionItem}
            onClick={() => Taro.switchTab({ url: '/pages/charts/index' })}
          >
            <View
              className={styles.actionIcon}
              style={{ backgroundColor: '#FEF3C7' }}
            >
              <Text className={styles.actionEmoji}>📊</Text>
            </View>
            <Text className={styles.actionText}>数据分析</Text>
          </View>
          {/* <View
            className={styles.actionItem}
            onClick={() => Taro.switchTab({ url: '/pages/ai/index' })}
          >
            <View
              className={styles.actionIcon}
              style={{ backgroundColor: '#D1FAE5' }}
            >
              <Text className={styles.actionEmoji}>🤖</Text>
            </View>
            <Text className={styles.actionText}>AI 助手</Text>
          </View> */}
          <View
            className={styles.actionItem}
            onClick={() => Taro.switchTab({ url: '/pages/profile/index' })}
          >
            <View
              className={styles.actionIcon}
              style={{ backgroundColor: '#FCE7F3' }}
            >
              <Text className={styles.actionEmoji}>⚙️</Text>
            </View>
            <Text className={styles.actionText}>我的设置</Text>
          </View>
        </View>
      </View>

      {/* 健康数据卡片 */}
      <View className={styles.healthSection}>
        <View className={styles.sectionHeader}>
          <Text className={styles.sectionTitle}>今日健康</Text>
          <Text className={styles.sectionMore} onClick={goToRecord}>
            记录 →
          </Text>
        </View>
        <View className={styles.cardGrid}>
          {healthCards.map((card) => (
            <View key={card.key} className={styles.healthCard}>
              <View className={styles.cardTop}>
                <Text className={styles.cardIcon}>{card.icon}</Text>
                <Text className={styles.cardLabel}>{card.label}</Text>
              </View>
              <View className={styles.cardBottom}>
                <Text
                  className={styles.cardValue}
                  style={{ color: card.color }}
                >
                  {getCardValue(card.key)}
                </Text>
                <Text className={styles.cardUnit}>{card.unit}</Text>
              </View>
            </View>
          ))}
        </View>
      </View>

      {/* 健康提示 */}
      <View className={styles.tipSection}>
        <View className={styles.tipCard}>
          <Text className={styles.tipIcon}>💡</Text>
          <View className={styles.tipContent}>
            <Text className={styles.tipTitle}>今日健康提示</Text>
            <Text className={styles.tipText}>
              建议每天饮水 2000ml 以上，保持充足睡眠 7-8
              小时，有助于提升免疫力。
            </Text>
          </View>
        </View>
      </View>
    </PageScaffold>
  )
}
