// Admin common - sidebar, auth, toast
function initAdmin() {
  const user = JSON.parse(localStorage.getItem('user') || '{}');
  if (!user.id || user.role === 'reader') { location.href = 'login.html'; return; }
  const isSuperAdmin = user.role === 'super_admin';
  const path = location.pathname.split('/').pop();
  const menu = [
    { href: 'index.html', icon: '📊', label: '仪表盘', roles: ['admin', 'super_admin'] },
    { href: 'books.html', icon: '📚', label: '图书管理', roles: ['admin', 'super_admin'] },
    { href: 'borrows.html', icon: '📥', label: '借阅管理', roles: ['admin', 'super_admin'] },
    { href: 'readers.html', icon: '👥', label: '读者管理', roles: ['admin', 'super_admin'] },
    { href: 'admins.html', icon: '🔑', label: '管理员管理', roles: ['super_admin'] },
  ];
  const visibleMenu = menu.filter(m => m.roles.includes(user.role));
  document.getElementById('sidebar').innerHTML = `
    <div class="sidebar-logo"><span class="icon">📚</span> <span>图书管理系统</span></div>
    <nav class="sidebar-nav">
      ${visibleMenu.map(m => `<a href="${m.href}" class="${path === m.href ? 'active' : ''}"><span class="nav-icon">${m.icon}</span> <span>${m.label}</span></a>`).join('')}
    </nav>
    <div class="sidebar-footer">
      <div class="user-info">
        <div class="avatar">${(user.name || user.username)[0]}</div>
        <div>
          <div class="user-name">${user.name || user.username}</div>
          <div class="user-role">${isSuperAdmin ? '系统管理员' : '管理员'}</div>
        </div>
      </div>
      <button class="logout-btn" onclick="logout()">退出登录</button>
    </div>
  `;
  loadStats && loadStats();
}

function logout() { localStorage.clear(); location.href = 'login.html'; }

function showToast(msg, type) {
  const container = document.querySelector('.toast-container') || (() => { const c = document.createElement('div'); c.className = 'toast-container'; document.body.appendChild(c); return c; })();
  const toast = document.createElement('div'); toast.className = 'toast toast-' + type; toast.textContent = msg;
  container.appendChild(toast);
  setTimeout(() => toast.remove(), 3000);
}
