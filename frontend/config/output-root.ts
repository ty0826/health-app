const targetOutputRoots: Record<string, string> = {
  h5: 'dist/h5',
  weapp: 'dist',
}

export const resolveOutputRoot = (target?: string): string =>
  (target && targetOutputRoots[target]) || 'dist'
