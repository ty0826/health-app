import { existsSync, rmSync, statSync } from 'node:fs'
import { resolve } from 'node:path'
import { spawnSync } from 'node:child_process'

const bundlePath = resolve('dist/index.bundle')

rmSync(bundlePath, { force: true })

const result = spawnSync('taro', ['build', '--type', 'rn'], {
  stdio: 'inherit',
  shell: process.platform === 'win32',
})

if (result.status !== 0 || !existsSync(bundlePath) || statSync(bundlePath).size === 0) {
  console.error('React Native bundle build failed: dist/index.bundle was not generated.')
  process.exit(result.status || 1)
}

console.log(`React Native bundle generated: ${bundlePath}`)
