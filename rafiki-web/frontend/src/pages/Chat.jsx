import { useEffect, useState, useRef } from 'react'
import { useParams, Link } from 'react-router-dom'
import api from '../services/api'
import { useAuth } from '../context/AuthContext'
import './Chat.css'

export default function Chat() {
  const { conversationId } = useParams()
  const { user } = useAuth()
  const [messages, setMessages] = useState([])
  const [text, setText] = useState('')
  const [loading, setLoading] = useState(true)
  const [connected, setConnected] = useState(false)
  const bottomRef = useRef(null)
  const socketRef = useRef(null)

  // Load existing messages via REST
  useEffect(() => {
    api.get(`/chat/conversations/${conversationId}/messages/`)
      .then(res => setMessages(res.data))
      .catch(console.error)
      .finally(() => setLoading(false))
  }, [conversationId])

  // WebSocket connection for real-time
  useEffect(() => {
    // For development with session/auth middleware.
    // In production you would pass JWT as query param and use custom middleware.
    const wsUrl = `ws://127.0.0.1:8000/ws/chat/${conversationId}/`
    const socket = new WebSocket(wsUrl)
    socketRef.current = socket

    socket.onopen = () => {
      console.log('WebSocket connected')
      setConnected(true)
    }

    socket.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data)
        setMessages(prev => {
          // Avoid duplicates
          if (prev.some(m => m.id === data.id)) return prev
          return [...prev, data]
        })
      } catch (e) {
        console.error('Invalid WS message', e)
      }
    }

    socket.onclose = () => {
      console.log('WebSocket closed')
      setConnected(false)
    }

    socket.onerror = (err) => {
      console.error('WebSocket error', err)
      setConnected(false)
    }

    return () => {
      socket.close()
    }
  }, [conversationId])

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [messages])

  const sendMessage = (e) => {
    e.preventDefault()
    const content = text.trim()
    if (!content || !socketRef.current || socketRef.current.readyState !== WebSocket.OPEN) {
      return
    }
    socketRef.current.send(JSON.stringify({ message: content }))
    setText('')
  }

  return (
    <div className="chat-page">
      <div className="chat-header">
        <Link to="/messages" className="back">← Back</Link>
        <span>Conversation</span>
        <span className={`status ${connected ? 'online' : 'offline'}`}>
          {connected ? '● Live' : '○ Connecting...'}
        </span>
      </div>

      <div className="messages-area">
        {loading ? (
          <p style={{textAlign:'center', color:'#8e8e8e'}}>Loading messages...</p>
        ) : messages.length === 0 ? (
          <p style={{textAlign:'center', color:'#8e8e8e', marginTop:40}}>
            No messages yet. Say hello!
          </p>
        ) : (
          messages.map(m => (
            <div
              key={m.id}
              className={`message ${m.sender?.id === user?.id ? 'mine' : 'theirs'}`}
            >
              <div className="bubble">{m.content}</div>
              <span className="time">
                {m.created_at
                  ? new Date(m.created_at).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})
                  : ''}
              </span>
            </div>
          ))
        )}
        <div ref={bottomRef} />
      </div>

      <form className="chat-input" onSubmit={sendMessage}>
        <input
          type="text"
          placeholder={connected ? "Type a message..." : "Connecting..."}
          value={text}
          onChange={(e) => setText(e.target.value)}
          disabled={!connected}
        />
        <button
          type="submit"
          className="btn-primary"
          disabled={!text.trim() || !connected}
        >
          Send
        </button>
      </form>
    </div>
  )
}
