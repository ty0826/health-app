import CryptoJS from 'crypto-js'

/**
 * 密码加密工具
 * 与后端加密逻辑保持一致：MD5(SALT + password)
 */
const SALT = 'health_manager_2026'

/**
 * 加密密码
 * @param password 原始密码
 * @returns 加密后的密码（MD5 十六进制字符串）
 */
export function encryptPassword(password: string): string {
  const text = SALT + password
  return CryptoJS.MD5(text).toString()
}
