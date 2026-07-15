import { useEffect } from 'react'
import { View, Text } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { useUserStore } from '../../store/userStore'
import styles from './index.module.scss'

const menuItems = [
  {
    icon: '📊',
    label: '我的健康报告',
    page: '/pages/charts/index',
    isTab: true
  },
  {
    icon: '📋',
    label: '历史记录',
    page: '/subpackages/record/pages/record/index',
    isTab: false
  },
  // { icon: '🤖', label: 'AI 健康助手', page: '/pages/ai/index', isTab: true },
  {
    icon: '🔔',
    label: '提醒设置',
    page: '/subpackages/profile/pages/reminder/index',
    isTab: false
  },
  {
    icon: '📎',
    label: '数据导出',
    page: '/subpackages/profile/pages/export/index',
    isTab: false
  },
  {
    icon: '❓',
    label: '帮助中心',
    page: '/subpackages/profile/pages/help/index',
    isTab: false
  },
  {
    icon: '⭐',
    label: '关于我们',
    page: '/subpackages/profile/pages/about/index',
    isTab: false
  }
]

export default function Profile() {
  const { userInfo, fetchUserInfo, logout } = useUserStore()
  useEffect(() => {
    fetchUserInfo()
  }, [])

  const handleMenuClick = (item: (typeof menuItems)[0]) => {
    if (!item.page) {
      Taro.showToast({ title: '功能开发中...', icon: 'none' })
      return
    }
    if (item.isTab) {
      Taro.switchTab({ url: item.page })
    } else {
      Taro.navigateTo({ url: item.page })
    }
  }

  const handleLogout = () => {
    Taro.showModal({
      title: '提示',
      content: '确定要退出登录吗？',
      success: (res) => {
        if (res.confirm) {
          logout()
        }
      }
    })
  }

  return (
    <View className={styles.container}>
      {/* 用户信息卡片 */}
      <View className={styles.profileCard}>
        <View
          className={styles.avatarSection}
          onClick={() =>
            Taro.navigateTo({ url: '/subpackages/profile/pages/edit/index' })
          }
        >
          <View className={styles.avatar}>
            <Text className={styles.avatarText}>
              {(userInfo?.nickname || '用')[0]}
            </Text>
          </View>
          <View className={styles.userInfo}>
            <Text className={styles.userName}>
              {userInfo?.nickname || '用户'}
            </Text>
            <Text className={styles.userId}>ID: {userInfo?.id || '--'}</Text>
          </View>
          <Text className={styles.editBtn}>编辑 ›</Text>
        </View>

        <View className={styles.statsRow}>
          <View className={styles.profileStat}>
            <Text className={styles.profileStatValue}>
              {userInfo?.age || '--'}
            </Text>
            <Text className={styles.profileStatLabel}>年龄</Text>
          </View>
          <View className={styles.divider} />
          <View className={styles.profileStat}>
            <Text className={styles.profileStatValue}>
              {userInfo?.height || '--'}
            </Text>
            <Text className={styles.profileStatLabel}>身高 cm</Text>
          </View>
          <View className={styles.divider} />
          <View className={styles.profileStat}>
            <Text className={styles.profileStatValue}>
              {userInfo?.weight || '--'}
            </Text>
            <Text className={styles.profileStatLabel}>体重 kg</Text>
          </View>
        </View>
      </View>

      {/* 健康概览卡片 */}
      <View className={styles.overviewCard}>
        <View className={styles.overviewItem}>
          <Text className={styles.overviewIcon}>📅</Text>
          <View className={styles.overviewContent}>
            <Text className={styles.overviewValue}>128</Text>
            <Text className={styles.overviewLabel}>连续记录天数</Text>
          </View>
        </View>
        <View className={styles.overviewItem}>
          <Text className={styles.overviewIcon}>🏆</Text>
          <View className={styles.overviewContent}>
            <Text className={styles.overviewValue}>86</Text>
            <Text className={styles.overviewLabel}>健康评分</Text>
          </View>
        </View>
      </View>

      {/* 菜单列表 */}
      <View className={styles.menuCard}>
        {menuItems.map((item, idx) => (
          <View
            key={idx}
            className={styles.menuItem}
            onClick={() => handleMenuClick(item)}
          >
            <View className={styles.menuLeft}>
              <Text className={styles.menuIcon}>{item.icon}</Text>
              <Text className={styles.menuLabel}>{item.label}</Text>
            </View>
            <Text className={styles.menuArrow}>›</Text>
          </View>
        ))}
      </View>

      {/* 退出按钮 */}
      <View className={styles.logoutBtn} onClick={handleLogout}>
        <Text className={styles.logoutText}>退出登录</Text>
      </View>

      <View className={styles.version}>
        <Text className={styles.versionText}>v1.0.0</Text>
      </View>
    </View>
  )
}
