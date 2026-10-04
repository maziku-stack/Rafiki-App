import { useState } from 'react'
import { useAuth } from '../context/AuthContext'
import './Profile.css'

const INTENTIONS = [
  { value: 'lonely', label: 'Feeling lonely' },
  { value: 'deep_talk', label: 'Want deep talk' },
  { value: 'share_ideas', label: 'Share ideas' },
  { value: 'casual_chat', label: 'Casual chat' },
  { value: 'need_support', label: 'Need support' },
]

export default function Profile() {
  const { user, updateProfile } = useAuth()
  const [form, setForm] = useState({
    first_name: user?.first_name || '',
    bio: user?.bio || '',
    intention: user?.intention || 'lonely',
    is_open_to_chat: user?.is_open_to_chat ?? true,
  })
  const [saving, setSaving] = useState(false)
  const [message, setMessage] = useState('')

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target
    setForm(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }))
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    setSaving(true)
    setMessage('')
    try {
      await updateProfile(form)
      setMessage('Profile updated successfully')
    } catch (err) {
      setMessage('Failed to update profile')
    } finally {
      setSaving(false)
    }
  }

  return (
    <div className="profile-page">
      <div className="profile-header card">
        <div className="avatar-lg">
          <span>{(user?.first_name || user?.username || '?')[0].toUpperCase()}</span>
        </div>
        <h2>@{user?.username}</h2>
        <p className="email">{user?.email}</p>
      </div>

      <form className="profile-form card" onSubmit={handleSubmit}>
        <h3>Edit Profile</h3>
        {message && <p className={message.includes('success') ? 'success' : 'error'}>{message}</p>}

        <label>Display name</label>
        <input name="first_name" value={form.first_name} onChange={handleChange} />

        <label>Bio</label>
        <textarea name="bio" value={form.bio} onChange={handleChange} rows={3} />

        <label>Current intention</label>
        <select name="intention" value={form.intention} onChange={handleChange}>
          {INTENTIONS.map(i => <option key={i.value} value={i.value}>{i.label}</option>)}
        </select>

        <label className="checkbox-label">
          <input type="checkbox" name="is_open_to_chat" checked={form.is_open_to_chat} onChange={handleChange} />
          I'm open to chat
        </label>

        <button type="submit" className="btn-primary" disabled={saving} style={{width:'100%', marginTop:12}}>
          {saving ? 'Saving...' : 'Save Changes'}
        </button>
      </form>
    </div>
  )
}
