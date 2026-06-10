-- ============================================
-- 图书馆图书管理系统 - 数据库初始化脚本
-- ============================================

DROP DATABASE IF EXISTS library;
CREATE DATABASE library DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE library;

-- ============================================
-- 1. 用户表
-- ============================================
CREATE TABLE users (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    username    VARCHAR(50)  NOT NULL UNIQUE COMMENT '用户名',
    password    VARCHAR(255) NOT NULL COMMENT '密码',
    role        VARCHAR(20)  NOT NULL DEFAULT 'reader' COMMENT '角色: super_admin/admin/reader',
    name        VARCHAR(50)  NOT NULL COMMENT '姓名',
    phone       VARCHAR(20)  DEFAULT '' COMMENT '手机号',
    status      TINYINT      NOT NULL DEFAULT 1 COMMENT '1=正常 0=禁用',
    created_at  DATE         NOT NULL COMMENT '创建日期'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- ============================================
-- 2. 图书表
-- ============================================
CREATE TABLE books (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    isbn        VARCHAR(30)  NOT NULL UNIQUE COMMENT 'ISBN',
    title       VARCHAR(200) NOT NULL COMMENT '书名',
    author      VARCHAR(100) NOT NULL COMMENT '作者',
    publisher   VARCHAR(100) NOT NULL COMMENT '出版社',
    category    VARCHAR(50)  NOT NULL COMMENT '分类',
    price       DECIMAL(10,2) NOT NULL COMMENT '价格',
    total       INT          NOT NULL DEFAULT 1 COMMENT '馆藏总数',
    available   INT          NOT NULL DEFAULT 1 COMMENT '可借数量',
    location    VARCHAR(100) DEFAULT '' COMMENT '馆藏位置',
    cover       VARCHAR(500) DEFAULT '' COMMENT '封面URL',
    description TEXT         COMMENT '简介',
    created_at  DATE         NOT NULL COMMENT '入库日期'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='图书表';

-- ============================================
-- 3. 借阅记录表
-- ============================================
CREATE TABLE borrows (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    book_id     INT          NOT NULL COMMENT '图书ID',
    user_id     INT          NOT NULL COMMENT '用户ID',
    status      VARCHAR(20)  NOT NULL DEFAULT 'applying' COMMENT 'applying/borrowed/returned/rejected',
    borrow_date DATE         NOT NULL COMMENT '借阅日期',
    due_date    DATE         NOT NULL COMMENT '应还日期',
    return_date DATE         DEFAULT NULL COMMENT '归还日期',
    FOREIGN KEY (book_id) REFERENCES books(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='借阅记录表';

-- ============================================
-- 初始数据
-- ============================================

INSERT INTO users (username, password, role, name, created_at) VALUES
('admin',     'admin123', 'super_admin', '系统管理员', '2026-06-08'),
('librarian', 'lib123',   'admin',       '图书管理员', '2026-06-08'),
('zhangsan',  '123456',   'reader',      '张三',       '2026-06-08'),
('lisi',      '123456',   'reader',      '李四',       '2026-06-08');

INSERT INTO books (isbn, title, author, publisher, category, price, total, available, location, description, created_at) VALUES
('978-7-111-59058-1', 'Java核心技术 卷I',        '霍斯特曼',        '机械工业出版社', '计算机', 149.00, 5, 3, 'A区-3排-15号', 'Java领域经典著作，全面覆盖Java SE核心特性。',           '2026-01-10'),
('978-7-121-38338-5', 'Spring Boot实战',         '克雷格·沃尔斯',  '人民邮电出版社', '计算机',  99.00, 3, 2, 'A区-3排-16号', '全面讲解Spring Boot 2.x实际应用。',                     '2026-02-15'),
('978-7-302-47595-8', '数据结构与算法分析',      '马克·艾伦·维斯', '清华大学出版社', '计算机',  79.00, 4, 4, 'B区-1排-5号',  '数据结构经典教材，Java语言描述。',                       '2026-03-01'),
('978-7-111-68482-3', '深入理解Java虚拟机',      '周志明',          '机械工业出版社', '计算机', 129.00, 3, 1, 'A区-3排-17号', '全面介绍JVM原理、内存管理、类加载、垃圾收集。',           '2026-04-01'),
('978-7-121-41312-2', 'MySQL必知必会',           'Ben Forta',       '人民邮电出版社', '数据库',  59.00, 6, 5, 'B区-2排-10号', 'MySQL入门经典，实例丰富。',                              '2026-04-15'),
('978-7-115-54478-1', '图解HTTP',                '上野宣',          '人民邮电出版社', '网络',    49.00, 3, 0, 'C区-1排-3号',  '图文并茂讲解HTTP协议。',                                 '2026-05-01'),
('978-7-111-69142-5', '设计模式之美',            '王争',            '机械工业出版社', '计算机', 119.00, 2, 2, 'A区-2排-8号',  '23种设计模式在真实项目中的应用。',                       '2026-05-10'),
('978-7-121-38339-1', 'JavaScript高级程序设计',  'Matt Frisbie',    '人民邮电出版社', '计算机', 139.00, 4, 3, 'A区-1排-12号', 'JavaScript红宝书，全面深入讲解JS核心。',                 '2026-06-01');

INSERT INTO borrows (book_id, user_id, status, borrow_date, due_date, return_date) VALUES
(1, 3, 'borrowed', '2026-05-20', '2026-06-20', NULL),
(2, 3, 'returned', '2026-05-01', '2026-06-01', '2026-05-28'),
(4, 4, 'borrowed', '2026-06-01', '2026-07-01', NULL),
(5, 4, 'returned', '2026-04-10', '2026-05-10', '2026-05-05'),
(6, 4, 'borrowed', '2026-06-05', '2026-07-05', NULL),
(3, 3, 'applying', '2026-06-09', '2026-07-09', NULL);
