const tabBarIconRoot =
  process.env.TARO_ENV === 'h5' &&
  process.env.NODE_ENV !== 'production'
    ? '/assets/icons'
    : 'assets/icons'

export default defineAppConfig({
  lazyCodeLoading: 'requiredComponents',
  pages: [
    'pages/index/index',
    'pages/charts/index',
    'pages/ai/index',
    'pages/profile/index',
  ],
  window: {
    backgroundTextStyle: 'light',
    navigationBarBackgroundColor: '#4F46E5',
    navigationBarTitleText: '健康管家',
    navigationBarTextStyle: 'white',
  },
  tabBar: {
    color: '#fff',
    selectedColor: '#fff',
    backgroundColor: '#4F46E5',
    borderStyle: 'white',
    list: [
      {
        pagePath: 'pages/index/index',
        text: '首页',
        iconPath: `${tabBarIconRoot}/home.png`,
        selectedIconPath: `${tabBarIconRoot}/home-active.png`,
      },
      {
        pagePath: 'pages/charts/index',
        text: '数据',
        iconPath: `${tabBarIconRoot}/chart.png`,
        selectedIconPath: `${tabBarIconRoot}/chart-active.png`,
      },
      {
        pagePath: 'pages/ai/index',
        text: 'AI助手',
        iconPath: `${tabBarIconRoot}/ai.png`,
        selectedIconPath: `${tabBarIconRoot}/ai-active.png`,
      },
      {
        pagePath: 'pages/profile/index',
        text: '我的',
        iconPath: `${tabBarIconRoot}/profile.png`,
        selectedIconPath: `${tabBarIconRoot}/profile-active.png`,
      },
    ],
  },
  // 分包配置
  subPackages: [
    {
      root: 'subpackages/record',
      name: 'record',
      pages: [
        'pages/record/index',
      ],
    },
    {
      root: 'subpackages/login',
      name: 'login',
      pages: [
        'pages/login/index',
      ],
      // independent: true, // 独立分包，可以独立运行
    },
    {
      root: 'subpackages/profile',
      name: 'profile',
      pages: [
        'pages/edit/index',
        'pages/reminder/index',
        'pages/export/index',
        'pages/help/index',
        'pages/about/index',
      ],
    },
  ],
})

