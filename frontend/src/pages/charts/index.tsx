import { useEffect, useState } from 'react'
import { View, Text } from '@tarojs/components'
import { useHealthStore } from '../../store/healthStore'
import styles from './index.module.scss'

const tabList = [
  { key: 'week', label: '近一周' },
  { key: 'month', label: '近一月' }
]

const metricList = [
  { key: 'steps', label: '步数', icon: '🚶', color: '#4F46E5', unit: '步' },
  {
    key: 'heartRate',
    label: '心率',
    icon: '❤️',
    color: '#EF4444',
    unit: 'bpm'
  },
  { key: 'sleep', label: '睡眠', icon: '😴', color: '#8B5CF6', unit: '小时' },
  { key: 'weight', label: '体重', icon: '⚖️', color: '#10B981', unit: 'kg' }
]

export default function Charts() {
  const [activeTab, setActiveTab] = useState('week')
  const [activeMetric, setActiveMetric] = useState('steps')
  const { stats, fetchStats } = useHealthStore()

  useEffect(() => {
    const days = activeTab === 'week' ? 7 : 30
    fetchStats(days)
  }, [activeTab])

  const getChartData = () => {
    if (!stats) return { values: [], labels: [], max: 0 }
    let values: number[] = []
    let labels: string[] = []

    switch (activeMetric) {
      case 'steps':
        values = stats.weeklySteps || []
        labels = stats.weekDates || []
        break
      case 'heartRate':
        values = stats.weeklyHeartRate || []
        labels = stats.weekDates || []
        break
      case 'sleep':
        values = stats.weeklySleep || []
        labels = stats.weekDates || []
        break
      case 'weight':
        values = stats.monthlyWeight || []
        labels = stats.monthDates || []
        break
    }

    const max = Math.max(...values, 1)
    return { values, labels, max }
  }

  const chartData = getChartData()

  const getAverage = () => {
    if (!chartData.values.length) return '--'
    const sum = chartData.values.reduce((a, b) => a + b, 0)
    return (sum / chartData.values.length).toFixed(1)
  }

  const getMax = () => {
    if (!chartData.values.length) return '--'
    return Math.max(...chartData.values).toString()
  }

  const getMin = () => {
    if (!chartData.values.length) return '--'
    return Math.min(...chartData.values).toString()
  }

  const currentMetric = metricList.find((m) => m.key === activeMetric)!

  return (
    <View className={styles.container}>
      {/* 时间筛选 */}
      <View className={styles.tabs}>
        {tabList.map((tab) => (
          <View
            key={tab.key}
            className={`${styles.tab} ${activeTab === tab.key ? styles.tabActive : ''}`}
            onClick={() => setActiveTab(tab.key)}
          >
            <Text className={styles.tabText}>{tab.label}</Text>
          </View>
        ))}
      </View>

      {/* 指标切换 */}
      <View className={styles.metricTabs}>
        {metricList.map((metric) => (
          <View
            key={metric.key}
            className={`${styles.metricTab} ${activeMetric === metric.key ? styles.metricTabActive : ''}`}
            onClick={() => setActiveMetric(metric.key)}
            style={
              activeMetric === metric.key
                ? { background: metric.color, borderColor: metric.color }
                : {}
            }
          >
            <Text className={styles.metricIcon}>{metric.icon}</Text>
            <Text
              className={styles.metricLabel}
              style={activeMetric === metric.key ? { color: '#fff' } : {}}
            >
              {metric.label}
            </Text>
          </View>
        ))}
      </View>

      {/* 统计卡片 */}
      <View className={styles.statsRow}>
        <View className={styles.statCard}>
          <Text className={styles.statLabel}>平均值</Text>
          <Text
            className={styles.statValue}
            style={{ color: currentMetric.color }}
          >
            {getAverage()}
          </Text>
          <Text className={styles.statUnit}>{currentMetric.unit}</Text>
        </View>
        <View className={styles.statCard}>
          <Text className={styles.statLabel}>最高值</Text>
          <Text className={styles.statValue} style={{ color: '#10B981' }}>
            {getMax()}
          </Text>
          <Text className={styles.statUnit}>{currentMetric.unit}</Text>
        </View>
        <View className={styles.statCard}>
          <Text className={styles.statLabel}>最低值</Text>
          <Text className={styles.statValue} style={{ color: '#F59E0B' }}>
            {getMin()}
          </Text>
          <Text className={styles.statUnit}>{currentMetric.unit}</Text>
        </View>
      </View>

      {/* 柱状图 */}
      <View className={styles.chartCard}>
        <Text className={styles.chartTitle}>
          {currentMetric.icon} {currentMetric.label}趋势
        </Text>
        <View className={styles.chart}>
          <View className={styles.barContainer}>
            {chartData.values.map((val, idx) => (
              <View key={idx} className={styles.barWrap}>
                <Text className={styles.barValue}>{val}</Text>
                <View
                  className={styles.bar}
                  style={{
                    height: `${(val / chartData.max) * 200}px`,
                    background: currentMetric.color
                  }}
                />
                <Text className={styles.barLabel}>
                  {chartData.labels[idx]?.slice(-5) || ''}
                </Text>
              </View>
            ))}
          </View>
        </View>
      </View>

      {/* 数据洞察 */}
      <View className={styles.insightCard}>
        <Text className={styles.insightTitle}>📊 数据洞察</Text>
        <View className={styles.insightList}>
          <View className={styles.insightItem}>
            <Text
              className={styles.insightDot}
              style={{ background: '#10B981' }}
            />
            <Text className={styles.insightText}>
              平均{currentMetric.label}为 {getAverage()} {currentMetric.unit}
            </Text>
          </View>
          <View className={styles.insightItem}>
            <Text
              className={styles.insightDot}
              style={{ background: '#F59E0B' }}
            />
            <Text className={styles.insightText}>
              与上周相比呈稳定趋势，请继续保持！
            </Text>
          </View>
          <View className={styles.insightItem}>
            <Text
              className={styles.insightDot}
              style={{ background: '#EF4444' }}
            />
            <Text className={styles.insightText}>
              建议通过 AI 助手获取个性化健康建议
            </Text>
          </View>
        </View>
      </View>
    </View>
  )
}
