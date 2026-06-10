const MOCK = {
  currentUser: null,

  users: [
    { id: 1, username: 'superadmin', password: '123456', role: 'super_admin', name: '张馆长', phone: '13800000001', email: 'zhang@lib.com', status: 1, createdAt: '2026-01-01' },
    { id: 2, username: 'admin01', password: '123456', role: 'admin', name: '李管理员', phone: '13800000002', email: 'li@lib.com', status: 1, createdAt: '2026-02-01' },
    { id: 3, username: 'reader01', password: '123456', role: 'reader', name: '王读者', phone: '13800000003', email: 'wang@qq.com', status: 1, createdAt: '2026-03-01' },
    { id: 4, username: 'reader02', password: '123456', role: 'reader', name: '赵同学', phone: '13800000004', email: 'zhao@qq.com', status: 1, createdAt: '2026-03-15' },
  ],

  books: [
    { id: 1, isbn: '978-7-111-59058-1', title: 'Java核心技术 卷I', author: '霍斯特曼', publisher: '机械工业出版社', category: '计算机', price: 149.00, total: 5, available: 3, cover: 'https://img3m7.ddimg.cn/86/22/25216997-1_b_2.jpg', description: '本书是Java领域最有影响力和价值的著作之一，由拥有20多年教学与研究经验的资深Java技术专家撰写。', location: 'A区-3排-15号', createdAt: '2026-01-10' },
    { id: 2, isbn: '978-7-121-38338-5', title: 'Spring Boot实战', author: '克雷格·沃尔斯', publisher: '人民邮电出版社', category: '计算机', price: 99.00, total: 3, available: 2, cover: 'https://img3m9.ddimg.cn/89/31/27909119-1_b_7.jpg', description: '本书全面讲解Spring Boot 2.x的实际应用，从入门到进阶，循序渐进地介绍Spring Boot的各个核心特性。', location: 'A区-3排-16号', createdAt: '2026-02-15' },
    { id: 3, isbn: '978-7-302-47595-8', title: '数据结构与算法分析', author: '马克·艾伦·维斯', publisher: '清华大学出版社', category: '计算机', price: 79.00, total: 4, available: 4, cover: 'https://img3m6.ddimg.cn/57/8/25217006-1_b_2.jpg', description: '本书是数据结构和算法分析的经典教材，使用Java语言描述，详细讨论了数据结构和算法分析。', location: 'B区-1排-5号', createdAt: '2026-03-01' },
    { id: 4, isbn: '978-7-111-68482-3', title: '深入理解Java虚拟机', author: '周志明', publisher: '机械工业出版社', category: '计算机', price: 129.00, total: 3, available: 1, cover: 'https://img3m8.ddimg.cn/15/8/29199088-1_b_5.jpg', description: '本书全面系统地介绍了Java虚拟机的工作原理，包括内存管理、类加载机制、垃圾收集器等核心内容。', location: 'A区-3排-17号', createdAt: '2026-04-01' },
    { id: 5, isbn: '978-7-121-41312-2', title: 'MySQL必知必会', author: 'Ben Forta', publisher: '人民邮电出版社', category: '数据库', price: 59.00, total: 6, available: 5, cover: 'https://img3m1.ddimg.cn/74/29/25217011-1_b_5.jpg', description: '本书是MySQL领域的经典入门书籍，通过大量实例帮助读者快速掌握SQL查询技巧和数据库操作。', location: 'B区-2排-10号', createdAt: '2026-04-15' },
    { id: 6, isbn: '978-7-115-54478-1', title: '图解HTTP', author: '上野宣', publisher: '人民邮电出版社', category: '网络', price: 49.00, total: 3, available: 0, cover: 'https://img3m2.ddimg.cn/82/13/29199092-1_b_4.jpg', description: '本书用大量生动形象的漫画和插图，深入浅出地讲解了HTTP协议的工作原理、报文结构、状态码等核心知识。', location: 'C区-1排-3号', createdAt: '2026-05-01' },
    { id: 7, isbn: '978-7-111-69142-5', title: '设计模式之美', author: '王争', publisher: '机械工业出版社', category: '计算机', price: 119.00, total: 2, available: 2, cover: 'https://img3m3.ddimg.cn/42/6/29199093-1_b_3.jpg', description: '本书结合作者多年的实践经验，用通俗易懂的语言讲解了23种经典设计模式以及它们在真实项目中的应用。', location: 'A区-2排-8号', createdAt: '2026-05-10' },
    { id: 8, isbn: '978-7-121-38339-1', title: 'JavaScript高级程序设计', author: 'Matt Frisbie', publisher: '人民邮电出版社', category: '计算机', price: 139.00, total: 4, available: 3, cover: 'https://img3m0.ddimg.cn/82/13/29199090-1_b_5.jpg', description: '本书是JavaScript“红宝书”，全面深入地讲解了JavaScript的核心概念、DOM、BOM、事件、Ajax等所有重要知识点。', location: 'A区-1排-12号', createdAt: '2026-06-01' },
  ],

  borrows: [
    { id: 1, bookId: 1, userId: 3, bookTitle: 'Java核心技术 卷I', userName: '王读者', status: 'borrowed', borrowDate: '2026-05-01', dueDate: '2026-06-01', returnDate: null },
    { id: 2, bookId: 2, userId: 3, bookTitle: 'Spring Boot实战', userName: '王读者', status: 'returned', borrowDate: '2026-04-15', dueDate: '2026-05-15', returnDate: '2026-05-10' },
    { id: 3, bookId: 4, userId: 4, bookTitle: '深入理解Java虚拟机', userName: '赵同学', status: 'borrowed', borrowDate: '2026-05-20', dueDate: '2026-06-20', returnDate: null },
    { id: 4, bookId: 5, userId: 4, bookTitle: 'MySQL必知必会', userName: '赵同学', status: 'returned', borrowDate: '2026-04-01', dueDate: '2026-05-01', returnDate: '2026-04-25' },
    { id: 5, bookId: 6, userId: 4, bookTitle: '图解HTTP', userName: '赵同学', status: 'borrowed', borrowDate: '2026-06-01', dueDate: '2026-07-01', returnDate: null },
    { id: 6, bookId: 4, userId: 3, bookTitle: '深入理解Java虚拟机', userName: '王读者', status: 'applying', borrowDate: '2026-06-10', dueDate: '2026-07-10', returnDate: null },
    { id: 7, bookId: 1, userId: 3, bookTitle: 'Java核心技术 卷I', userName: '王读者', status: 'applying', borrowDate: '2026-05-01', dueDate: '2026-06-01', returnDate: null },
  ],

  categories: ['计算机', '数据库', '网络', '文学', '历史', '科学', '数学', '外语', '哲学', '经济'],

  _nextId: function (arr) { return Math.max(0, ...arr.map(x => x.id)) + 1; },
};

MOCK.save = function () { console.log('[Mock] Data saved (mock mode)'); };
