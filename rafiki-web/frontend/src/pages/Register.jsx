import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import './Auth.css'

const INTENTIONS = [
  { value: 'lonely', label: 'Feeling lonely' },
  { value: 'deep_talk', label: 'Want deep talk' },
  { value: 'share_ideas', label: 'Share ideas' },
  { value: 'casual_chat', label: 'Casual chat' },
  { value: 'need_support', label: 'Need support' },
]

export default function Register() {
  const [form, setForm] = useState({
    username: '', email: '', password: '', password2: '',
    intention: 'lonely', bio: '', first_name: ''
  })
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const { register } = useAuth()
  const navigate = useNavigate()

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value })
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    setError('')
    if (form.password !== form.password2) {
      setError('Passwords do not match')
      return
    }
    setLoading(true)
    try {
      await register(form)
      navigate('/')
    } catch (err) {
      const data = err.response?.data
      setError(data?.username?.[0] || data?.email?.[0] || data?.password?.[0] || 'Registration failed')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="auth-page">
      <div className="auth-card">
        <h1 className="auth-logo">Rafiki</h1>
        <p className="auth-subtitle">Join people who want real connection</p>

        <form onSubmit={handleSubmit}>
          {error && <div className="error-box">{error}</div>}
          <input name="username" placeholder="Username" value={form.username} onChange={handleChange} required />
          <input name="email" type="email" placeholder="Email" value={form.email} onChange={handleChange} required />
          <input name="first_name" placeholder="Display name (optional)" value={form.first_name} onChange={handleChange} />
          <input name="password" type="password" placeholder="Password" value={form.password} onChange={handleChange} required />
          <input name="password2" type="password" placeholder="Confirm password" value={form.password2} onChange={handleChange} required />
          
          <label style={{fontSize: 13, color: '#8e8e8e', marginBottom: 4}}>What are you looking for?</label>
          <select name="intention" value={form.intention} onChange={handleChange}>
            {INTENTIONS.map(i => <option key={i.value} value={i.value}>{i.label}</option>)}
          </select>

          <textarea name="bio" placeholder="Short bio (optional)" value={form.bio} onChange={handleChange} rows={2} />

          <button type="submit" className="btn-primary" disabled={loading} style={{width: '100%'}}>
            {loading ? 'Creating account...' : 'Sign Up'}
          </button>
        </form>

        <p className="auth-footer">
          Already have an account? <Link to="/login">Log in</Link>
        </p>
      </div>
    </div>
  )
}
