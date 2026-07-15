import { useState, useRef, useCallback } from 'react'
import { View, Text, Input, ScrollView } from '@tarojs/components'
import { post } from '../../utils/request'
import styles from './index.module.scss'

interface Message {
  id: string
  role: 'user' | 'assistant'
  content: string
  timestamp: number
}

const quickQuestions = [
  '我的健康数据有什么异常？',
  '如何改善睡眠质量？',
  '推荐今天的运动计划',
  '我需要注意哪些饮食？'
]

export default function AiAssistant() {
  const [messages, setMessages] = useState<Message[]>([
    {
      id: '0',
      role: 'assistant',
      content:
        '你好！我是你的 AI 健康助手 🤖\n\n我可以根据你的健康数据为你提供个性化的健康建议。你可以问我任何关于健康、运动、饮食、睡眠等方面的问题。',
      timestamp: Date.now()
    }
  ])
  const [inputValue, setInputValue] = useState('')
  const [loading, setLoading] = useState(false)
  const scrollId = useRef('msg-0')

  const sendMessage = useCallback(
    async (content: string) => {
      if (!content.trim() || loading) return

      const userMsg: Message = {
        id: `msg-${Date.now()}`,
        role: 'user',
        content: content.trim(),
        timestamp: Date.now()
      }

      setMessages((prev) => [...prev, userMsg])
      setInputValue('')
      setLoading(true)

      const assistantId = `msg-${Date.now() + 1}`
      scrollId.current = assistantId

      try {
        const data = await post<{ reply: string }>('/ai/chat', {
          message: content.trim()
        })

        const assistantMsg: Message = {
          id: assistantId,
          role: 'assistant',
          content: data.reply || '抱歉，我暂时无法回答你的问题，请稍后再试。',
          timestamp: Date.now()
        }

        setMessages((prev) => [...prev, assistantMsg])
      } catch {
        const errorMsg: Message = {
          id: assistantId,
          role: 'assistant',
          content: '网络异常，请检查网络后重试 🔄',
          timestamp: Date.now()
        }
        setMessages((prev) => [...prev, errorMsg])
      } finally {
        setLoading(false)
      }
    },
    [loading]
  )

  const handleSend = () => {
    sendMessage(inputValue)
  }

  const formatTime = (ts: number) => {
    const d = new Date(ts)
    return `${d.getHours().toString().padStart(2, '0')}:${d
      .getMinutes()
      .toString()
      .padStart(2, '0')}`
  }

  return (
    <View className={styles.container}>
      {/* 消息列表 */}
      <ScrollView
        className={styles.messageList}
        scrollY
        scrollIntoView={scrollId.current}
        scrollWithAnimation
      >
        {messages.map((msg) => (
          <View
            key={msg.id}
            id={msg.id}
            className={`${styles.messageWrap} ${
              msg.role === 'user' ? styles.messageUser : styles.messageBot
            }`}
          >
            {msg.role === 'assistant' && (
              <View className={styles.botAvatar}>
                <Text className={styles.avatarEmoji}>🤖</Text>
              </View>
            )}
            <View className={styles.messageBubble}>
              <Text className={styles.messageText}>{msg.content}</Text>
              <Text className={styles.messageTime}>
                {formatTime(msg.timestamp)}
              </Text>
            </View>
            {msg.role === 'user' && (
              <View className={styles.userAvatar}>
                <Text className={styles.avatarEmoji}>👤</Text>
              </View>
            )}
          </View>
        ))}

        {loading && (
          <View className={`${styles.messageWrap} ${styles.messageBot}`}>
            <View className={styles.botAvatar}>
              <Text className={styles.avatarEmoji}>🤖</Text>
            </View>
            <View className={styles.messageBubble}>
              <View className={styles.typingDots}>
                <View className={styles.dot} />
                <View className={styles.dot} />
                <View className={styles.dot} />
              </View>
            </View>
          </View>
        )}

        {/* 快捷问题 */}
        {messages.length <= 1 && (
          <View className={styles.quickSection}>
            <Text className={styles.quickTitle}>试试问我：</Text>
            <View className={styles.quickList}>
              {quickQuestions.map((q, idx) => (
                <View
                  key={idx}
                  className={styles.quickItem}
                  onClick={() => sendMessage(q)}
                >
                  <Text className={styles.quickText}>{q}</Text>
                </View>
              ))}
            </View>
          </View>
        )}
      </ScrollView>

      {/* 输入区域 */}
      <View className={styles.inputBar}>
        <View className={styles.inputWrap}>
          <Input
            className={styles.input}
            placeholder="输入你的健康问题..."
            value={inputValue}
            onInput={(e) => setInputValue(e.detail.value)}
            onConfirm={handleSend}
            confirmType="send"
          />
        </View>
        <View
          className={`${styles.sendBtn} ${
            !inputValue.trim() || loading ? styles.sendDisabled : ''
          }`}
          onClick={handleSend}
        >
          <Text className={styles.sendIcon}>📤</Text>
        </View>
      </View>
    </View>
  )
}
