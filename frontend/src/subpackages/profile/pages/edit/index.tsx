import { useEffect, useState } from 'react'
import { View, Text, Input, Picker } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { useUserStore } from '../../../../store/userStore'
import PageScaffold from '../../../../components/PageScaffold'
import styles from './index.module.scss'

const genderOptions = ['未知', '男', '女']

export default function ProfileEdit() {
  const { userInfo, fetchUserInfo, updateUserInfo } = useUserStore()
  const [form, setForm] = useState({
    nickname: '',
    gender: 0,
    age: '',
    height: '',
    weight: '',
    phone: '',
    email: ''
  })
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    if (userInfo) {
      setForm({
        nickname: userInfo.nickname || '',
        gender: userInfo.gender || 0,
        age: userInfo.age ? String(userInfo.age) : '',
        height: userInfo.height ? String(userInfo.height) : '',
        weight: userInfo.weight ? String(userInfo.weight) : '',
        phone: userInfo.phone || '',
        email: userInfo.email || ''
      })
    }
  }, [userInfo])

  const handleSave = async () => {
    if (!form.nickname.trim()) {
      Taro.showToast({ title: '请填写昵称', icon: 'none' })
      return
    }
    setSaving(true)
    try {
      await updateUserInfo({
        nickname: form.nickname,
        gender: form.gender,
        age: form.age ? parseInt(form.age) : 0,
        height: form.height ? parseFloat(form.height) : 0,
        weight: form.weight ? parseFloat(form.weight) : 0,
        phone: form.phone,
        email: form.email
      })
      await fetchUserInfo()
      Taro.showToast({ title: '保存成功', icon: 'success' })
      setTimeout(() => Taro.navigateBack(), 1500)
    } catch (e) {
      Taro.showToast({ title: '保存失败', icon: 'none' })
    } finally {
      setSaving(false)
    }
  }

  return (
    <PageScaffold title="编辑资料" className={styles.container} showBack>
      <View className={styles.section}>
        <View className={styles.field}>
          <Text className={styles.label}>昵称</Text>
          <Input
            className={styles.input}
            value={form.nickname}
            placeholder="请输入昵称"
            onInput={(e) => setForm({ ...form, nickname: e.detail.value })}
          />
        </View>

        <View className={styles.field}>
          <Text className={styles.label}>性别</Text>
          <Picker
            mode="selector"
            range={genderOptions}
            value={form.gender}
            onChange={(e) =>
              setForm({ ...form, gender: Number(e.detail.value) })
            }
          >
            <View className={styles.pickerValue}>
              {genderOptions[form.gender]}
              <Text className={styles.arrow}>›</Text>
            </View>
          </Picker>
        </View>

        <View className={styles.field}>
          <Text className={styles.label}>年龄</Text>
          <Input
            className={styles.input}
            type="number"
            value={form.age}
            placeholder="请输入年龄"
            onInput={(e) => setForm({ ...form, age: e.detail.value })}
          />
        </View>

        <View className={styles.field}>
          <Text className={styles.label}>身高 (cm)</Text>
          <Input
            className={styles.input}
            type="digit"
            value={form.height}
            placeholder="请输入身高"
            onInput={(e) => setForm({ ...form, height: e.detail.value })}
          />
        </View>

        <View className={styles.field}>
          <Text className={styles.label}>体重 (kg)</Text>
          <Input
            className={styles.input}
            type="digit"
            value={form.weight}
            placeholder="请输入体重"
            onInput={(e) => setForm({ ...form, weight: e.detail.value })}
          />
        </View>
      </View>

      <View className={styles.section}>
        <View className={styles.sectionTitle}>
          <Text className={styles.sectionTitleText}>联系方式</Text>
        </View>

        <View className={styles.field}>
          <Text className={styles.label}>手机号</Text>
          <Input
            className={styles.input}
            type="number"
            value={form.phone}
            placeholder="请输入手机号"
            onInput={(e) => setForm({ ...form, phone: e.detail.value })}
          />
        </View>

        <View className={styles.field}>
          <Text className={styles.label}>邮箱</Text>
          <Input
            className={styles.input}
            value={form.email}
            placeholder="请输入邮箱"
            onInput={(e) => setForm({ ...form, email: e.detail.value })}
          />
        </View>
      </View>

      <View className={styles.saveBtn} onClick={handleSave}>
        <Text className={styles.saveBtnText}>
          {saving ? '保存中...' : '保存修改'}
        </Text>
      </View>
    </PageScaffold>
  )
}
