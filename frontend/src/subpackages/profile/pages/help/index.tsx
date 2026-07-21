import { useState, useEffect } from 'react'
import { View, Text } from '@tarojs/components'
import { get } from '../../../../utils/request'
import PageScaffold from '../../../../components/PageScaffold'
import styles from './index.module.scss'

interface FaqItem {
  id: number
  question: string
  answer: string
  sortOrder: number
}

export default function Help() {
  const [faqList, setFaqList] = useState<FaqItem[]>([])
  const [expandedIndex, setExpandedIndex] = useState<number | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchFaqList()
  }, [])

  const fetchFaqList = async () => {
    try {
      const data = await get<FaqItem[]>('/system/faq')
      setFaqList(data || [])
    } catch (e) {
      console.error(e)
    } finally {
      setLoading(false)
    }
  }

  const toggleFaq = (index: number) => {
    setExpandedIndex(expandedIndex === index ? null : index)
  }

  return (
    <PageScaffold title="帮助中心" className={styles.container} showBack>
      <View className={styles.header}>
        <Text className={styles.headerIcon}>❓</Text>
        <Text className={styles.headerTitle}>帮助中心</Text>
        <Text className={styles.headerDesc}>常见问题解答，帮助您快速上手</Text>
      </View>

      {loading ? (
        <View style={{ textAlign: 'center', padding: '40px 0' }}>
          <Text style={{ color: '#999' }}>加载中...</Text>
        </View>
      ) : (
        <View className={styles.faqList}>
          {faqList.map((faq, idx) => (
            <View
              key={faq.id}
              className={`${styles.faqItem} ${expandedIndex === idx ? styles.faqExpanded : ''}`}
              onClick={() => toggleFaq(idx)}
            >
              <View className={styles.faqHeader}>
                <Text className={styles.faqQuestion}>{faq.question}</Text>
                <Text className={styles.faqArrow}>
                  {expandedIndex === idx ? '−' : '+'}
                </Text>
              </View>
              {expandedIndex === idx && (
                <View className={styles.faqBody}>
                  <Text className={styles.faqAnswer}>{faq.answer}</Text>
                </View>
              )}
            </View>
          ))}
        </View>
      )}

      <View className={styles.contactCard}>
        <Text className={styles.contactTitle}>仍有疑问？</Text>
        <Text className={styles.contactDesc}>请联系我们的客服团队</Text>
        <Text className={styles.contactEmail}>
          📧 support@healthmanager.com
        </Text>
      </View>
    </PageScaffold>
  )
}
