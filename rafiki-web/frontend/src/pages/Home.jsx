import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import api from '../services/api'
import { useAuth } from '../context/AuthContext'
import './Home.css'

export default function Home() {
  const [users, setUsers] = useState([])
  const [loading, setLoading] = useState(true)
  const { user } = useAuth()

  useEffect(() => {
    api.get('/auth/available/')
      .then(res => setUsers(res.data))
      .catch(console.error)
      .finally(() => setLoading(false))
  }, [])

  const startChat = async (userId) => {
    try {
      const res = await api.post('/chat/conversations/create/', { user_id: userId })
      window.location.href = `/chat/${res.data.id}`
    } catch (err) {
      alert('Could not start conversation')
    }
  }

  return (
    <div className="home-page">
      <div className="welcome-banner card">
        <h2>Hello, {user?.first_name || user?.username} 👋</h2>
        <p>People who are open to talk right now</p>
      </div>

      {loading ? (
        <p style={{textAlign:'center', color:'#8e8e8e', marginTop:40}}>Loading...</p>
      ) : users.length === 0 ? (
        <div className="empty-state card">
          <h3>No one is available right now</h3>
          <p>Try again later or find people on other platforms</p>
          <div className="fallback-buttons">
            <a href="https://www.tiktok.com" target="_blank" rel="noreferrer" className="btn-primary">Find on TikTok</a>
            <a href="https://www.facebook.com" target="_blank" rel="noreferrer" className="btn-outline">Find on Facebook</a>
          </div>
          <Link to="/connect" className="btn-primary" style={{marginTop:16, display:'inline-block'}}>
            Go to Connect
          </Link>
        </div>
      ) : (
        <div className="users-list">
          {users.map(u => (
            <div key={u.id} className="user-card card">
              <div className="user-info">
                <div className="avatar">
                  {u.profile_photo ? (
                    <img src={u.profile_photo} alt={u.username} />
                  ) : (
                    <span>{(u.first_name || u.username)[0].toUpperCase()}</span>
                  )}
                </div>
                <div>
                  <strong>{u.first_name || u.username}</strong>
                  <p className="intention">{u.intention?.replace('_', ' ')}</p>
                  {u.bio && <p className="bio">{u.bio}</p>}
                </div>
              </div>
              <button className="btn-primary" onClick={() => startChat(u.id)}>
                Start Chat
              </button>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
