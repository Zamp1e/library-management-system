// ========== API 封装层 ==========
// 当前为 Mock 模式，对接后端时修改 USE_MOCK = false 并配置 BASE_URL

// 自动检测：GitHub Pages 用 Mock，本地连后端
const isRemote = location.hostname.includes('github.io');
const USE_MOCK = isRemote;
const BASE_URL = isRemote ? '' : 'http://localhost:8080/api';
// 管理端/读者端会话隔离：不同路径用不同 localStorage key
const STORAGE_NS = location.pathname.includes('/admin/') ? 'admin_' : 'reader_';

async function request(method, url, data) {
  if (USE_MOCK) {
    console.log('[Mock]', method, url, data);
    return new Promise((resolve, reject) => setTimeout(() => {
      const result = handleMock(method, url, data);
      if (result.code !== 200) reject(new Error(result.message || '请求失败'));
      else resolve(result.data);
    }, 300));
  }
  const opts = {
    method,
    headers: { 'Content-Type': 'application/json' },
  };
  const token = localStorage.getItem(STORAGE_NS + 'token');
  if (token) opts.headers['Authorization'] = 'Bearer ' + token;
  if (data && method !== 'GET') opts.body = JSON.stringify(data);
  const res = await fetch(BASE_URL + url, opts);
  if (res.status === 401) { localStorage.removeItem(STORAGE_NS + 'token'); localStorage.removeItem(STORAGE_NS + 'user'); location.href = location.pathname.includes('/admin/') ? 'login.html' : '../front/login.html'; return; }
  const json = await res.json();
  if (json.code !== 200) throw new Error(json.message || '请求失败');
  return json.data;
}

function get(url, params) {
  if (params) url += '?' + new URLSearchParams(params).toString();
  return request('GET', url);
}
function post(url, data) { return request('POST', url, data); }
function put(url, data) { return request('PUT', url, data); }
function del(url) { return request('DELETE', url); }

// ========== Mock 处理器 ==========
function handleMock(method, url, data) {
  const M = MOCK;
  const qIndex = url.indexOf('?');
  if (!data && qIndex > -1) {
    const params = {};
    url.substring(qIndex + 1).split('&').forEach(function(p) {
      var kv = p.split('='); if (kv[0]) params[kv[0]] = decodeURIComponent(kv[1] || '');
    });
    data = params;
  }
  const path = qIndex > -1 ? url.substring(0, qIndex) : url;
  const parts = path.replace('/api/', '').split('/').filter(Boolean);
  const entity = parts[0]; // books | borrows | users | auth
  const id = parts[1] ? parseInt(parts[1]) : null;

  if (entity === 'auth') {
    if (url.includes('login') && method === 'POST') {
      const u = M.users.find(x => x.username === data.username && x.password === data.password);
      if (!u) return { code: 401, message: '用户名或密码错误' };
      if (!u.status) return { code: 403, message: '账号已被禁用' };
      const token = 'mock-token-' + u.id;
      return { code: 200, data: { token, user: { id: u.id, username: u.username, role: u.role, name: u.name, phone: u.phone, email: u.email } } };
    }
    if (url.includes('register') && method === 'POST') {
      return { code: 403, message: '注册已关闭，请联系管理员开通账号' };
    }
    if (url.includes('me') && method === 'GET') {
      const u = M.users[0];
      return { code: 200, data: { id: u.id, username: u.username, role: u.role, name: u.name, phone: u.phone, email: u.email } };
    }
  }

  if (entity === 'books') {
    if (method === 'GET' && id) {
      const book = M.books.find(x => x.id === id);
      return book ? { code: 200, data: book } : { code: 404, message: '图书不存在' };
    }
    if (method === 'GET') {
      let list = [...M.books];
      if (data) {
        if (data.keyword) list = list.filter(x => x.title.includes(data.keyword) || x.author.includes(data.keyword) || x.isbn.includes(data.keyword));
        if (data.category) list = list.filter(x => x.category === data.category);
      }
      return { code: 200, data: { list, total: list.length } };
    }
    if (method === 'POST') { const b = { ...data, id: M._nextId(M.books), total: data.total || 1, available: data.total || 1, createdAt: new Date().toISOString().slice(0, 10) }; M.books.push(b); M.save(); return { code: 200, data: b }; }
    if (method === 'PUT' && id) { const idx = M.books.findIndex(x => x.id === id); if (idx > -1) { M.books[idx] = { ...M.books[idx], ...data, id }; M.save(); return { code: 200, data: M.books[idx] }; } return { code: 404 }; }
    if (method === 'DELETE' && id) { const idx = M.books.findIndex(x => x.id === id); if (idx > -1) { M.books.splice(idx, 1); M.save(); return { code: 200, data: null }; } return { code: 404 }; }
  }

  if (entity === 'borrows') {
    // 辅助函数: JOIN books+users 填充显示字段
    function enrich(b) {
      const book = M.books.find(x => x.id === b.bookId);
      const user = M.users.find(x => x.id === b.userId);
      return { ...b, bookTitle: book ? book.title : '', userName: user ? user.name : '' };
    }
    if (method === 'GET' && id) {
      const b = M.borrows.find(x => x.id === id);
      return b ? { code: 200, data: enrich(b) } : { code: 404 };
    }
    if (method === 'GET') {
      let list = [...M.borrows];
      if (data) {
        if (data.userId) list = list.filter(x => x.userId === parseInt(data.userId));
        if (data.status) list = list.filter(x => x.status === data.status);
        if (data.bookId) list = list.filter(x => x.bookId === parseInt(data.bookId));
      }
      return { code: 200, data: { list: list.sort((a, b) => b.id - a.id).map(enrich), total: list.length } };
    }
    if (method === 'POST') {
      const book = M.books.find(x => x.id === data.bookId);
      if (!book) return { code: 404, message: '图书不存在' };
      if (book.available <= 0) return { code: 400, message: '图书已全部借出' };
      const b = { id: M._nextId(M.borrows), bookId: data.bookId, userId: data.userId, status: 'applying', borrowDate: new Date().toISOString().slice(0, 10), dueDate: data.dueDate || '', returnDate: null };
      M.borrows.push(b); M.save();
      return { code: 200, data: enrich(b) };
    }
    if (method === 'PUT' && id) {
      const idx = M.borrows.findIndex(x => x.id === id);
      if (idx === -1) return { code: 404 };
      if (data.status) {
        M.borrows[idx].status = data.status;
        const book = M.books.find(x => x.id === M.borrows[idx].bookId);
        if (data.status === 'borrowed' && book) { book.available = Math.max(0, book.available - 1); }
        if ((data.status === 'returned' || data.status === 'rejected') && book) {
          const wasApproved = M.borrows[idx].status === 'borrowed' || M.borrows[idx].status === 'applying';
          if (wasApproved && data.status === 'returned') book.available = Math.min(book.total, book.available + 1);
          if (data.status === 'rejected' && M.borrows[idx].status === 'applying') { /* no stock change */ }
        }
        if (data.status === 'returned') M.borrows[idx].returnDate = new Date().toISOString().slice(0, 10);
      }
      M.save();
      return { code: 200, data: enrich(M.borrows[idx]) };
    }
  }

  if (entity === 'users') {
    if (method === 'GET' && id) {
      const u = M.users.find(x => x.id === id);
      return u ? { code: 200, data: { id: u.id, username: u.username, role: u.role, name: u.name, phone: u.phone, email: u.email, status: u.status, createdAt: u.createdAt } } : { code: 404 };
    }
    if (method === 'GET') {
      let list = [...M.users];
      if (data) {
        if (data.role) list = list.filter(x => x.role === data.role);
        if (data.keyword) list = list.filter(x => x.name.includes(data.keyword) || x.username.includes(data.keyword));
      }
      const mapped = list.map(u => ({ id: u.id, username: u.username, role: u.role, name: u.name, phone: u.phone, email: u.email, status: u.status, createdAt: u.createdAt }));
      return { code: 200, data: { list: mapped, total: mapped.length } };
    }
    if (method === 'POST') {
      if (data.role === 'super_admin') return { code: 400, message: '不允许创建系统管理员' };
      if (M.users.find(x => x.username === data.username)) return { code: 400, message: '用户名已存在' };
      const u = { id: M._nextId(M.users), username: data.username, password: data.password || '123456', role: data.role, name: data.name, phone: data.phone || '', email: data.email || '', status: 1, createdAt: new Date().toISOString().slice(0, 10) };
      M.users.push(u); M.save();
      return { code: 200, data: { id: u.id } };
    }
    if (method === 'PUT' && id) {
      const idx = M.users.findIndex(x => x.id === id);
      if (idx === -1) return { code: 404 };
      if (data.role === 'super_admin' && M.users[idx].role !== 'super_admin') return { code: 400, message: '不允许升级为系统管理员' };
      M.users[idx] = { ...M.users[idx], ...data, id, password: M.users[idx].password }; M.save();
      return { code: 200, data: { id } };
    }
    if (method === 'DELETE' && id) {
      const idx = M.users.findIndex(x => x.id === id);
      if (idx === -1) return { code: 404 };
      if (M.users[idx].role === 'super_admin') return { code: 400, message: '不能删除系统管理员' };
      M.users.splice(idx, 1); M.save();
      return { code: 200, data: null };
    }
  }

  if (entity === 'stats') {
    return { code: 200, data: { totalBooks: M.books.length, totalReaders: M.users.filter(x => x.role === 'reader').length, borrowing: M.borrows.filter(x => x.status === 'borrowed').length, overdue: M.borrows.filter(x => x.status === 'borrowed' && new Date(x.dueDate) < new Date()).length, returnedToday: 2, borrowingTrend: [ { month: '1月', count: 12 }, { month: '2月', count: 18 }, { month: '3月', count: 25 }, { month: '4月', count: 20 }, { month: '5月', count: 32 }, { month: '6月', count: 28 } ], categoryDist: [ { name: '计算机', value: 35 }, { name: '数据库', value: 15 }, { name: '网络', value: 10 }, { name: '文学', value: 20 }, { name: '历史', value: 12 }, { name: '其他', value: 8 } ] } };
  }

  return { code: 404, message: '接口不存在' };
}

// ========== 业务 API ==========
const API = {
  auth: {
    login: (username, password) => post('/auth/login', { username, password }),
    register: (data) => post('/auth/register', data),
    me: () => get('/auth/me'),
  },
  books: {
    list: (params) => get('/books', params),
    detail: (id) => get('/books/' + id),
    add: (data) => post('/books', data),
    update: (id, data) => put('/books/' + id, data),
    delete: (id) => del('/books/' + id),
  },
  borrows: {
    list: (params) => get('/borrows', params),
    create: (data) => post('/borrows', data),
    approve: (id) => put('/borrows/' + id, { status: 'borrowed' }),
    reject: (id) => put('/borrows/' + id, { status: 'rejected' }),
    returnBook: (id) => put('/borrows/' + id, { status: 'returned' }),
  },
  users: {
    list: (params) => get('/users', params),
    create: (data) => post('/users', data),
    update: (id, data) => put('/users/' + id, data),
    delete: (id) => del('/users/' + id),
  },
  stats: {
    overview: () => get('/stats/overview'),
  },
};
