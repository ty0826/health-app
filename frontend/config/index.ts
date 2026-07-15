import { defineConfig } from '@tarojs/cli'

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
  outputRoot: 'dist',
  plugins: ['@tarojs/plugin-framework-react', '@tarojs/plugin-html'],
  defineConstants: {},
  copy: {
    patterns: [
      {
        from: 'src/assets/icons',
        to: 'assets/icons',
      },
    ],
    options: {},
  },
  framework: 'react',
  compiler: {
    type: 'webpack5',
    prebundle: { enable: false },
  },
  sass: {
    resource: [
      'src/styles/variables.scss',
      // Removed global NutUI style injection to prevent massive duplication
    ],
  },
  mini: {
    // 启用智能提取分包依赖，减少主包体积
    optimizeMainPackage: {
      enable: true,
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
    // 启用代码压缩和优化
    webpackChain() {
      // 启用代码压缩已在 Taro 默认配置中处理
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
