import { PropsWithChildren, useEffect } from 'react'
import { useUserStore } from './store/userStore'
import './app.scss'

function App({ children }: PropsWithChildren) {
  const hydrateAuth = useUserStore((state) => state.hydrateAuth)

  useEffect(() => {
    void hydrateAuth()
  }, [hydrateAuth])

  return (
    children
  )
}

export default App
