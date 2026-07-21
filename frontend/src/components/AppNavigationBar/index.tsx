import { Text, View } from '@tarojs/components'
import Taro from '@tarojs/taro'
import styles from './index.module.scss'

interface AppNavigationBarProps {
  title: string
  showBack?: boolean
}

export default function AppNavigationBar({
  title,
  showBack = false,
}: AppNavigationBarProps) {
  return (
    <View className={styles.navigationBar}>
      {showBack && (
        <View
          className={styles.backButton}
          onClick={() => Taro.navigateBack()}
          aria-label="返回"
        >
          <Text className={styles.backIcon}>‹</Text>
        </View>
      )}
      <Text className={styles.title}>{title}</Text>
    </View>
  )
}
