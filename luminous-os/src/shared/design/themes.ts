import { createContext, useContext } from 'react'

export type ThemeMode = 'sunlit' | 'deep-rest'

export interface ThemeContextValue {
  theme: ThemeMode
  toggleTheme: () => void
}

export const ThemeContext = createContext<ThemeContextValue>({
  theme: 'sunlit',
  toggleTheme: () => {},
})

export const useTheme = () => useContext(ThemeContext)
