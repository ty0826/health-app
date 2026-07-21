import { useState } from 'react'
import { View, Text, Picker } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { get } from '../../../../utils/request'
import PageScaffold from '../../../../components/PageScaffold'
import styles from './index.module.scss'

const formatOptions = ['CSV 表格', 'JSON 数据']
const formatValues = ['csv', 'json']
const rangeOptions = ['最近 7 天', '最近 30 天', '最近 90 天', '全部数据']
const rangeDays = [7, 30, 90, 9999]

export default function DataExport() {
  const [format, setFormat] = useState(0)
  const [range, setRange] = useState(1)
  const [exporting, setExporting] = useState(false)
  const [exportResult, setExportResult] = useState<{
    totalRecords: number
  } | null>(null)

  const handleExport = async () => {
    setExporting(true)
    setExportResult(null)
    try {
      const days = rangeDays[range]
      const fmt = formatValues[format]
      const result = await get<{
        content: string
        format: string
        totalRecords: number
      }>(`/health/export?days=${days}&format=${fmt}`)

      if (!result || result.totalRecords === 0) {
        Taro.showToast({ title: '暂无数据可导出', icon: 'none' })
        setExporting(false)
        return
      }

      const content =
        typeof result.content === 'string'
          ? result.content
          : JSON.stringify(result.content, null, 2)

      Taro.setClipboardData({
        data: content,
        success: () => {
          setExportResult({ totalRecords: result.totalRecords })
          Taro.showToast({ title: '数据已复制到剪贴板', icon: 'success' })
        }
      })
    } catch (e) {
      Taro.showToast({ title: '导出失败，请重试', icon: 'none' })
    } finally {
      setExporting(false)
    }
  }

  return (
    <PageScaffold title="数据导出" className={styles.container} showBack>
      <View className={styles.header}>
        <Text className={styles.headerIcon}>📎</Text>
        <Text className={styles.headerTitle}>导出健康数据</Text>
        <Text className={styles.headerDesc}>
          将您的健康记录导出为文件，方便备份或分享给医生
        </Text>
      </View>

      <View className={styles.section}>
        <View className={styles.field}>
          <Text className={styles.label}>导出格式</Text>
          <Picker
            mode="selector"
            range={formatOptions}
            value={format}
            onChange={(e) => setFormat(Number(e.detail.value))}
          >
            <View className={styles.pickerValue}>
              <Text>{formatOptions[format]}</Text>
              <Text className={styles.arrow}>›</Text>
            </View>
          </Picker>
        </View>

        <View className={styles.field}>
          <Text className={styles.label}>时间范围</Text>
          <Picker
            mode="selector"
            range={rangeOptions}
            value={range}
            onChange={(e) => setRange(Number(e.detail.value))}
          >
            <View className={styles.pickerValue}>
              <Text>{rangeOptions[range]}</Text>
              <Text className={styles.arrow}>›</Text>
            </View>
          </Picker>
        </View>
      </View>

      <View className={styles.infoCard}>
        <Text className={styles.infoTitle}>导出说明</Text>
        <Text className={styles.infoText}>
          • 数据由服务端生成，确保完整性和准确性
        </Text>
        <Text className={styles.infoText}>
          • CSV 格式可直接导入 Excel 进行分析
        </Text>
        <Text className={styles.infoText}>• JSON 格式适合开发者使用</Text>
      </View>

      <View
        className={`${styles.exportBtn} ${exporting ? styles.btnDisabled : ''}`}
        onClick={exporting ? undefined : handleExport}
      >
        <Text className={styles.exportBtnText}>
          {exporting ? '导出中...' : '开始导出'}
        </Text>
      </View>

      {exportResult && (
        <View className={styles.resultCard}>
          <Text className={styles.resultTitle}>✅ 导出成功</Text>
          <Text className={styles.resultDesc}>
            数据已复制到剪贴板，共导出 {exportResult.totalRecords} 条记录
          </Text>
        </View>
      )}
    </PageScaffold>
  )
}
