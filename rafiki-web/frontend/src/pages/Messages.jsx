import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import api from '../services/api'
import './Messages.css'

export default function Messages() {
  const [conversations, setConversations] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    api.get('/chat/conversations/')
      .then(res => setConversations(res.data))
      .catch(console.error)
      .finally(() => setLoading(false))
  }, [])

  if (loading) return <p style={{textAlign:'center', marginTop:40, color:'#8e8e8e'}}>Loading...</p>

  return (
    <div className="messages-page">
      <h2 className="page-title">Messages</h2>

      {conversations.length === 0 ? (
        <div className="empty card">
          <p>No conversations yet</p>
          <Link to="/connect" className="btn-primary">Find someone to talk to</Link>
        </div>
      ) : (
        <div className="conv-list">
          {conversations.map(c => (
            <Link key={c.id} to={`/chat/${c.id}`} className="conv-item card">
              <div className="avatar">
                <span>{(c.other_user?.first_name || c.other_user?.username || '?')[0].toUpperCase()}</span>
              </div>
              <div className="conv-info">
                <strong>{c.other_user?.first_name || c.other_user?.username || 'User'}</strong>
                <p className="last-msg">
                  {c.last_message?.content?.slice(0, 40) || 'Start chatting...'}
                  {c.last_message?.content?.length > 40 ? '...' : ''}
                </p>
              </div>
            </Link>
          ))}
        </div>
      )}
    </div>
  )
}
