import { defineConfig } from '@tarojs/cli'
import { resolveOutputRoot } from './output-root'

export default defineConfig({
  projectName: 'health-manager',
  date: '2026-3-3',
  designWidth: 750,
  deviceRatio: {
    640: 2.34 / 2,
    750: 1,
    375: 2,
    828: 1.81 / 2,
  },
  sourceRoot: 'src',
  outputRoot: resolveOutputRoot(process.env.TARO_ENV),
  plugins: ['@tarojs/plugin-framework-react', '@tarojs/plugin-html'],
  defineConstants: {
    __TARO_APP_API_BASE_URL__: JSON.stringify(
      process.env.TARO_APP_API_BASE_URL || '',
    ),
  },
  copy: {
    patterns: [
      {
        from: 'src/assets/icons',
        to: process.env.TARO_ENV === 'h5' ? 'static/images' : 'assets/icons',
      },
    ],
    options: {},
  },
  framework: 'react',
  compiler: {
    type: 'vite',
    prebundle: { enable: false },
  },
  sass: {
    resource: ['src/styles/variables.scss'],
  },
  mini: {
    // 启用智能提取分包依赖，减少主包体积
    optimizeMainPackage: {
      enable: false,
    },
    postcss: {
      pxtransform: {
        enable: true,
        config: {},
      },
      cssModules: {
        enable: true,
        config: {
          namingPattern: 'module',
          generateScopedName: '[name]__[local]___[hash:base64:5]',
        },
      },
    },
  },
  h5: {
    publicPath: '/',
    staticDirectory: 'static',
    postcss: {
      autoprefixer: {
        enable: true,
        config: {},
      },
      cssModules: {
        enable: true,
        config: {
          namingPattern: 'module',
          generateScopedName: '[name]__[local]___[hash:base64:5]',
        },
      },
    },
  },
})
