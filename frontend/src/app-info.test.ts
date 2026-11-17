import { describe, expect, it } from 'vitest'
import { APP_NAME } from './app-info.ts'

describe('app info', () => {
  it('exposes the application name', () => {
    expect(APP_NAME).toBe('FediFinance')
  })
})
