import { useState, useEffect } from 'react'
import { View, Text } from '@tarojs/components'
import { get } from '../../../../utils/request'
import styles from './index.module.scss'

interface AppInfoData {
  appName: string
  appSlogan: string
  version: string
  email: string
  website: string
  address: string
  copyright: string
  techFrontend: string
  techBackend: string
  techAi: string
  techData: string
}

export default function About() {
  const [info, setInfo] = useState<AppInfoData | null>(null)

  useEffect(() => {
    fetchAppInfo()
  }, [])

  const fetchAppInfo = async () => {
    try {
      const data = await get<AppInfoData>('/system/app-info')
      setInfo(data)
    } catch (e) {
      console.error(e)
    }
  }

  const features = [
    {
      icon: '📊',
      title: '数据可视化',
      desc: '直观的图表展示，帮助您了解健康趋势'
    },
    { icon: '🤖', title: 'AI 智能分析', desc: '基于大模型的个性化健康建议' },
    { icon: '📱', title: '多端适配', desc: '支持小程序、H5、App 多平台使用' },
    { icon: '🔒', title: '数据安全', desc: '端到端加密传输，保障您的隐私安全' }
  ]

  const techStack = [
    { role: '前端技术', name: info?.techFrontend || 'Taro + React' },
    { role: '后端技术', name: info?.techBackend || 'Spring Boot' },
    { role: 'AI 引擎', name: info?.techAi || 'GPT' },
    { role: '数据分析', name: info?.techData || 'ECharts' }
  ]

  return (
    <View className={styles.container}>
      {/* Logo & 版本信息 */}
      <View className={styles.header}>
        <View className={styles.logoWrap}>
          <Text className={styles.logoIcon}>💚</Text>
        </View>
        <Text className={styles.appName}>{info?.appName || '健康管家'}</Text>
        <Text className={styles.appSlogan}>
          {info?.appSlogan || 'AI 驱动的个人健康管理平台'}
        </Text>
        <Text className={styles.version}>
          Version {info?.version || '1.0.0'}
        </Text>
      </View>

      {/* 核心功能 */}
      <View className={styles.section}>
        <Text className={styles.sectionTitle}>核心功能</Text>
        <View className={styles.featureGrid}>
          {features.map((f, idx) => (
            <View key={idx} className={styles.featureItem}>
              <Text className={styles.featureIcon}>{f.icon}</Text>
              <Text className={styles.featureTitle}>{f.title}</Text>
              <Text className={styles.featureDesc}>{f.desc}</Text>
            </View>
          ))}
        </View>
      </View>

      {/* 技术栈 */}
      <View className={styles.section}>
        <Text className={styles.sectionTitle}>技术架构</Text>
        <View className={styles.techList}>
          {techStack.map((t, idx) => (
            <View key={idx} className={styles.techItem}>
              <Text className={styles.techRole}>{t.role}</Text>
              <Text className={styles.techName}>{t.name}</Text>
            </View>
          ))}
        </View>
      </View>

      {/* 联系信息 */}
      <View className={styles.contactSection}>
        <Text className={styles.contactTitle}>联系我们</Text>
        <View className={styles.contactItem}>
          <Text className={styles.contactIcon}>📧</Text>
          <Text className={styles.contactText}>
            {info?.email || 'support@healthmanager.com'}
          </Text>
        </View>
        <View className={styles.contactItem}>
          <Text className={styles.contactIcon}>🌐</Text>
          <Text className={styles.contactText}>
            {info?.website || 'www.healthmanager.com'}
          </Text>
        </View>
        <View className={styles.contactItem}>
          <Text className={styles.contactIcon}>📍</Text>
          <Text className={styles.contactText}>
            {info?.address || '中国 · 深圳'}
          </Text>
        </View>
      </View>

      {/* 版权信息 */}
      <View className={styles.footer}>
        <Text className={styles.footerText}>
          {info?.copyright || '© 2026 健康管家'}
        </Text>
        <Text className={styles.footerLink}>用户协议 | 隐私政策</Text>
      </View>
    </View>
  )
}
