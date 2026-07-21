export interface PageLayout {
  title: string
  showNavigationBar: boolean
  useSafeArea: boolean
}

export function getPageLayout(platform: string, title: string): PageLayout {
  const isH5 = platform === 'h5'

  return {
    title,
    showNavigationBar: isH5,
    useSafeArea: isH5,
  }
}
