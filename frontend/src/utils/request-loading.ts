export const createRequestLoadingController = (
  show: () => void,
  hide: () => void,
) => {
  let activeRequests = 0

  return {
    start: () => {
      if (activeRequests === 0) {
        show()
      }
      activeRequests += 1
    },
    finish: () => {
      if (activeRequests === 0) {
        return
      }
      activeRequests -= 1
      if (activeRequests === 0) {
        hide()
      }
    },
  }
}
