import { PropsWithChildren } from 'react'
import { View } from '@tarojs/components'
import { getPageLayout } from '../../utils/page-layout'
import AppNavigationBar from '../AppNavigationBar'
import styles from './index.module.scss'

interface PageScaffoldProps extends PropsWithChildren {
  title: string
  className?: string
  showBack?: boolean
}

export default function PageScaffold({
  title,
  className = '',
  showBack = false,
  children,
}: PageScaffoldProps) {
  const layout = getPageLayout(process.env.TARO_ENV || '', title)

  return (
    <View
      className={`${styles.scaffold} ${layout.useSafeArea ? styles.safeArea : ''}`}
    >
      {layout.showNavigationBar && (
        <AppNavigationBar title={layout.title} showBack={showBack} />
      )}
      <View className={`${styles.content} ${className}`}>{children}</View>
    </View>
  )
}
