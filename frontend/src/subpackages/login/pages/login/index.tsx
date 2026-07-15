import { useState } from 'react'
import { View, Text, Input, Button } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { useUserStore } from '../../../../store/userStore'
import styles from './index.module.scss'

export default function Login() {
  const [isLogin, setIsLogin] = useState(true)
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [nickname, setNickname] = useState('')
  const [loading, setLoading] = useState(false)

  const { login, register } = useUserStore()

  const handleSubmit = async () => {
    if (!username || !password) {
      Taro.showToast({ title: '请填写完整信息', icon: 'none' })
      return
    }
    if (!isLogin && !nickname) {
      Taro.showToast({ title: '请填写昵称', icon: 'none' })
      return
    }

    setLoading(true)
    try {
      if (isLogin) {
        await login(username, password)
      } else {
        await register({ username, password, nickname })
        setIsLogin(true)
      }
    } catch (e) {
      console.error(e)
    } finally {
      setLoading(false)
    }
  }

  return (
    <View className={styles.container}>
      <View className={styles.header}>
        <View className={styles.logoWrap}>
          <Text className={styles.logoIcon}>💚</Text>
        </View>
        <Text className={styles.title}>健康管家</Text>
        <Text className={styles.subtitle}>AI 驱动的个人健康管理平台</Text>
      </View>

      <View className={styles.formCard}>
        <View className={styles.tabs}>
          <Text
            className={`${styles.tab} ${isLogin ? styles.tabActive : ''}`}
            onClick={() => setIsLogin(true)}
          >
            登录
          </Text>
          <Text
            className={`${styles.tab} ${!isLogin ? styles.tabActive : ''}`}
            onClick={() => setIsLogin(false)}
          >
            注册
          </Text>
        </View>

        <View className={styles.inputGroup}>
          <View className={styles.inputWrap}>
            <Text className={styles.inputIcon}>👤</Text>
            <Input
              className={styles.input}
              placeholder="请输入用户名"
              value={username}
              onInput={(e) => setUsername(e.detail.value)}
            />
          </View>

          <View className={styles.inputWrap}>
            <Text className={styles.inputIcon}>🔒</Text>
            <Input
              className={styles.input}
              placeholder="请输入密码"
              password
              value={password}
              onInput={(e) => setPassword(e.detail.value)}
            />
          </View>

          {!isLogin && (
            <View className={styles.inputWrap}>
              <Text className={styles.inputIcon}>😊</Text>
              <Input
                className={styles.input}
                placeholder="请输入昵称"
                value={nickname}
                onInput={(e) => setNickname(e.detail.value)}
              />
            </View>
          )}
        </View>

        <Button
          type="primary"
          loading={loading}
          onClick={handleSubmit}
          style={{
            marginTop: '40px',
            height: '60px',
            fontSize: '25px',
            width: '100%'
          }}
        >
          {isLogin ? '登 录' : '注 册'}
        </Button>
      </View>

      <View className={styles.footer}>
        <Text className={styles.footerText}>
          登录即表示同意《用户协议》和《隐私政策》
        </Text>
      </View>
    </View>
  )
}
