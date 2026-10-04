import { Outlet, NavLink, useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import './Layout.css'

export default function Layout() {
  const { user, logout } = useAuth()
  const navigate = useNavigate()

  const handleLogout = () => {
    logout()
    navigate('/login')
  }

  return (
    <div className="app-layout">
      <header className="top-nav">
        <div className="nav-inner">
          <NavLink to="/" className="logo">Rafiki</NavLink>
          <nav className="nav-links">
            <NavLink to="/" end className={({isActive}) => isActive ? 'active' : ''}>Home</NavLink>
            <NavLink to="/connect" className={({isActive}) => isActive ? 'active' : ''}>Connect</NavLink>
            <NavLink to="/messages" className={({isActive}) => isActive ? 'active' : ''}>Messages</NavLink>
            <NavLink to="/profile" className={({isActive}) => isActive ? 'active' : ''}>Profile</NavLink>
          </nav>
          <div className="nav-right">
            <span className="username">@{user?.username}</span>
            <button className="btn-outline" onClick={handleLogout} style={{padding: '6px 12px', fontSize: 13}}>Logout</button>
          </div>
        </div>
      </header>

      <main className="main-content">
        <Outlet />
      </main>

      {/* Mobile bottom nav - Instagram style */}
      <nav className="bottom-nav">
        <NavLink to="/" end><span>🏠</span><small>Home</small></NavLink>
        <NavLink to="/connect"><span>💬</span><small>Connect</small></NavLink>
        <NavLink to="/messages"><span>✉️</span><small>Messages</small></NavLink>
        <NavLink to="/profile"><span>👤</span><small>Profile</small></NavLink>
      </nav>
    </div>
  )
}
