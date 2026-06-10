// Reader common — sidebar, auth, toast
function initReader() {
  const user = JSON.parse(localStorage.getItem('reader_user') || '{}');
  if (!user.id) { location.href = 'login.html'; return; }
  const path = location.pathname.split('/').pop();
  const menu = [
    { href: 'index.html', icon: '🔍', label: '图书检索' },
    { href: 'my-books.html', icon: '📖', label: '我的借阅' },
  ];
  document.getElementById('sidebar').innerHTML = `
    <div class="sidebar-logo"><span class="icon">📚</span> <span>图书管理系统</span></div>
    <nav class="sidebar-nav">
      ${menu.map(m => `<a href="${m.href}" class="${path === m.href ? 'active' : ''}"><span class="nav-icon">${m.icon}</span> <span>${m.label}</span></a>`).join('')}
    </nav>
    <div class="sidebar-footer">
      <div class="user-info">
        <div class="avatar">${(user.name || user.username)[0]}</div>
        <div>
          <div class="user-name">${user.name || user.username}</div>
          <div class="user-role">读者</div>
        </div>
      </div>
      <button class="logout-btn" onclick="logout()">退出登录</button>
    </div>
  `;
}

function logout() { localStorage.removeItem('reader_token'); localStorage.removeItem('reader_user'); location.href = 'login.html'; }

function showToast(msg, type) {
  const container = document.querySelector('.toast-container') || (() => { const c = document.createElement('div'); c.className = 'toast-container'; document.body.appendChild(c); return c; })();
  const toast = document.createElement('div'); toast.className = 'toast toast-' + type; toast.textContent = msg;
  container.appendChild(toast);
  setTimeout(() => toast.classList.add('toast-exit'), 2600);
  setTimeout(() => toast.remove(), 2900);
}
