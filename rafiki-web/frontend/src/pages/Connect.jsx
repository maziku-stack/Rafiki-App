import { useState } from 'react'
import { useAuth } from '../context/AuthContext'
import api from '../services/api'
import './Connect.css'

const INTENTIONS = [
  { value: 'lonely', label: 'Feeling lonely', emoji: '😔' },
  { value: 'deep_talk', label: 'Want deep talk', emoji: '💭' },
  { value: 'share_ideas', label: 'Share ideas', emoji: '💡' },
  { value: 'casual_chat', label: 'Casual chat', emoji: '😊' },
  { value: 'need_support', label: 'Need support', emoji: '🤝' },
]

export default function Connect() {
  const { user, updateProfile } = useAuth()
  const [intention, setIntention] = useState(user?.intention || 'lonely')
  const [isOpen, setIsOpen] = useState(user?.is_open_to_chat ?? true)
  const [users, setUsers] = useState([])
  const [searched, setSearched] = useState(false)
  const [loading, setLoading] = useState(false)

  const handleToggleOpen = async () => {
    const newValue = !isOpen
    setIsOpen(newValue)
    try {
      await updateProfile({ is_open_to_chat: newValue })
    } catch (e) {
      setIsOpen(!newValue)
    }
  }

  const handleFindPeople = async () => {
    setLoading(true)
    setSearched(true)
    try {
      await updateProfile({ intention })
      const res = await api.get(`/auth/available/?intention=${intention}`)
      setUsers(res.data)
    } catch (err) {
      console.error(err)
    } finally {
      setLoading(false)
    }
  }

  const startChat = async (userId) => {
    try {
      const res = await api.post('/chat/conversations/create/', { user_id: userId })
      window.location.href = `/chat/${res.data.id}`
    } catch (err) {
      alert('Could not start conversation')
    }
  }

  return (
    <div className="connect-page">
      <div className="connect-hero card">
        <h2>I want to talk</h2>
        <p>Choose how you're feeling and find people with the same intention</p>

        <div className="intention-grid">
          {INTENTIONS.map(i => (
            <button
              key={i.value}
              className={`intention-btn ${intention === i.value ? 'selected' : ''}`}
              onClick={() => setIntention(i.value)}
            >
              <span className="emoji">{i.emoji}</span>
              <span>{i.label}</span>
            </button>
          ))}
        </div>

        <div className="open-toggle">
          <label>
            <input type="checkbox" checked={isOpen} onChange={handleToggleOpen} />
            I'm open to chat right now
          </label>
        </div>

        <button className="btn-primary find-btn" onClick={handleFindPeople} disabled={loading}>
          {loading ? 'Searching...' : 'Find People'}
        </button>
      </div>

      {searched && (
        <div className="results">
          {users.length === 0 ? (
            <div className="empty-state card">
              <h3>No one with this intention is available</h3>
              <p>You can try a different intention or connect on other platforms</p>
              <div className="fallback-buttons">
                <a href="https://www.tiktok.com" target="_blank" rel="noreferrer" className="btn-primary">TikTok</a>
                <a href="https://www.facebook.com" target="_blank" rel="noreferrer" className="btn-outline">Facebook</a>
              </div>
            </div>
          ) : (
            users.map(u => (
              <div key={u.id} className="user-card card">
                <div className="user-info">
                  <div className="avatar">
                    <span>{(u.first_name || u.username)[0].toUpperCase()}</span>
                  </div>
                  <div>
                    <strong>{u.first_name || u.username}</strong>
                    <p className="intention">{u.intention?.replace('_', ' ')}</p>
                  </div>
                </div>
                <button className="btn-primary" onClick={() => startChat(u.id)}>Chat</button>
              </div>
            ))
          )}
        </div>
      )}
    </div>
  )
}
