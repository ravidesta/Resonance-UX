import { useState, useCallback, useEffect } from 'react'

const STORAGE_KEY = 'love-journal-data'

function loadFromStorage() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    return raw ? JSON.parse(raw) : {}
  } catch {
    return {}
  }
}

function saveToStorage(data) {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(data))
  } catch {
    // storage full or unavailable
  }
}

export function useJournalStore() {
  const [data, setData] = useState(loadFromStorage)

  useEffect(() => {
    saveToStorage(data)
  }, [data])

  const getValue = useCallback((key, fallback = '') => {
    return data[key] ?? fallback
  }, [data])

  const setValue = useCallback((key, value) => {
    setData(prev => ({ ...prev, [key]: value }))
  }, [])

  const getChecked = useCallback((key) => {
    return data[key] === true
  }, [data])

  const setChecked = useCallback((key, checked) => {
    setData(prev => ({ ...prev, [key]: checked }))
  }, [])

  const getScale = useCallback((key) => {
    return data[key] ?? 5
  }, [data])

  const setScale = useCallback((key, value) => {
    setData(prev => ({ ...prev, [key]: value }))
  }, [])

  const exportData = useCallback(() => {
    const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `love-journal-backup-${new Date().toISOString().slice(0, 10)}.json`
    a.click()
    URL.revokeObjectURL(url)
  }, [data])

  const importData = useCallback((file) => {
    const reader = new FileReader()
    reader.onload = (e) => {
      try {
        const imported = JSON.parse(e.target.result)
        setData(prev => ({ ...prev, ...imported }))
      } catch {
        alert('Invalid journal file')
      }
    }
    reader.readAsText(file)
  }, [])

  const getProgress = useCallback((sectionPrefix) => {
    const keys = Object.keys(data).filter(k => k.startsWith(sectionPrefix))
    if (keys.length === 0) return 0
    const filled = keys.filter(k => {
      const v = data[k]
      return v !== '' && v !== null && v !== undefined
    })
    return Math.round((filled.length / Math.max(keys.length, 1)) * 100)
  }, [data])

  return { getValue, setValue, getChecked, setChecked, getScale, setScale, exportData, importData, getProgress, data }
}
