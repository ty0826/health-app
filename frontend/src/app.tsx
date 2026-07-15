import { PropsWithChildren } from 'react'
import { ConfigProvider } from '@nutui/nutui-react-taro'
import './app.scss'

function App({ children }: PropsWithChildren) {
  return <ConfigProvider>{children}</ConfigProvider>
}

export default App
